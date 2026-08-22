-- ============================================================
-- GameDamage — 伤害系统（基于 Event.lua API）
--
-- 功能：
--   1. 物理/魔法伤害分类
--   2. 物理暴击 / 法术暴击
--   3. 物理抗性 / 魔法抗性 + 穿透衰减
--   4. 伤害实时修正（e:setDamage → Event.lua 自动执行 EXSetEventDamage）
--   5. 伤害统计
--   6. 自动接入 Event.anyUnitDamageEvent
--
-- 使用方式：
--   require "Game_.GameDamage"   -- 自动注册到伤害事件，无需额外初始化
--
--  API：
--   GameDamage.getStats(target)
--   GameDamage.resetStats(target)
--   GameDamage.resetAllStats()
--   GameDamage.setDebug(bool)
-- ============================================================

-- ============================================================
-- [2026-08-13] 锚点全清除：DMG_TRACE 埋点（dmTag/dmTrace）已删除，改用 DesyncGuard 指纹法定位
-- ============================================================

-- ============================================================
-- 配置
-- ============================================================

local BASE_CRIT_MULT = 2.0      -- 基础暴击倍率
local RES_CONST = 50            -- 抗性衰减常数
local DEBUG_ENABLED = false       -- 调试输出（上线前关闭）
local REENTRY_LOCK_MS = 0.03125  -- 异步重入锁时长（~1帧）

local AMP_TO_PCT   = 1000        -- 攻击强化换算：每 1000 点 = +100% 增伤（multiplier = 1 + attackStr/AMP_TO_PCT）
local MAGICAMP_TO_PCT = 1000     -- 魔法强化换算：每 1000 点 = +100% 魔法伤害（仅魔法伤害生效）

local _asyncLock  = {}   -- target+source 锁，1帧内挡住二次触发

local function clearLock(key)
    _asyncLock[key] = nil
end

-- 攻击强化 → 增伤倍率（multiplier = 1 + attackStr/AMP_TO_PCT）
--   直接读取攻击者的 Unit.state.attackStr（由装备系统写入，与 resMag/penPhys 等一致）
local function applyAttackAmp(sourceHandle, damage)
    if sourceHandle == nil then return damage end
    local attacker = Unit.fromHandle(sourceHandle)
    if attacker == nil then return damage end
    local amp = attacker.state.attackStr or 0
    if amp <= 0 then return damage end
    return math.floor(damage * (1 + amp / AMP_TO_PCT))
end

-- 魔法强化 → 魔法伤害增伤倍率（multiplier = 1 + magicAmp/MAGICAMP_TO_PCT）
--   仅对魔法伤害生效；读取攻击者的 Unit.state.magicAmp（与 attackStr 同款挂载方式）
local function applyMagicAmp(sourceHandle, damage)
    if sourceHandle == nil then return damage end
    local attacker = Unit.fromHandle(sourceHandle)
    if attacker == nil then return damage end
    local ma = attacker.state.magicAmp or 0
    if ma <= 0 then return damage end
    return math.floor(damage * (1 + ma / MAGICAMP_TO_PCT))
end

-- ============================================================
-- 统计数据
-- ============================================================

local _dmgStats = {}
local _playerDmg = {}  -- [playerId] = { total = 0 }

local function getStatsRecord(handle)
    local key = cj.GetHandleId(handle)
    if not _dmgStats then _dmgStats = {} end
    if not _dmgStats[key] then
        _dmgStats[key] = {
            received = { total = 0, phys = 0, mag = 0 },
            dealt    = { total = 0, phys = 0, mag = 0 },
            critCount = 0,
        }
    end
    return _dmgStats[key]
end

local function isUnitRemoved(h)
    if h == nil then return true end
    return cj.GetUnitTypeId(h) == 0
end

local function cleanupDmgStats()
    for key in pairs(_dmgStats) do
        _dmgStats[key] = nil
    end
    for pid in pairs(_playerDmg) do
        _playerDmg[pid] = nil
    end
end

Timer:new(300, true, function()
    cleanupDmgStats()
end)

-- ============================================================
-- 暴击系统
-- ============================================================

local function calcCrit(attackerHandle, isPhys, damage)
    
    if attackerHandle == nil then return damage, false end
    local unit = Unit.fromHandle(attackerHandle)
    if unit == nil then return damage, false end
    local chance = isPhys and unit.state.critPhys or unit.state.critMag
    if chance == nil or chance <= 0 then return damage, false end
    local random = math.floor(math.random(0,100))
    if random >= chance then return damage, false end
    local bonus = isPhys and unit.state.critDmgPhys or unit.state.critDmgMag
    return math.floor(damage * (BASE_CRIT_MULT + (bonus or 0) / 100)), true
end

-- ============================================================
-- 抗性系统（衰减公式）
-- ============================================================

local function calcResistance(targetHandle, attackerHandle, isPhys, damage)
    if targetHandle == nil then return damage end

    local res = 0
    if isPhys then
        res = cj.GetUnitState(targetHandle, UNIT_STATE_DEFEND_WHITE) or 0
    else
        local target = Unit.fromHandle(targetHandle)
        if target then res = target.state.resMag or 0 end
    end

    local pen = 0
    if attackerHandle ~= nil then
        local attacker = Unit.fromHandle(attackerHandle)
        if attacker then
            pen = isPhys and (attacker.state.penPhys or 0) or (attacker.state.penMag or 0)
        end
    end

    local effectiveRes = math.max(0, res - pen)
    local reduction = effectiveRes / (effectiveRes + RES_CONST)
    if reduction > 0.95 then reduction = 0.95 end
    return math.floor(damage * (1 - reduction))
end


-- 显示伤害浮动数字特效
-- @param targetHandle 目标单位句柄
-- @param damage       伤害数值
-- @param isPhys       是否为物理伤害 (true=物理, false=魔法)
-- @param isCrit       是否为暴击
local function showDamageFloat(targetHandle, damage, isPhys, isCrit)
    -- 参数验证：目标单位不存在则直接返回
    if targetHandle == nil then return end

    -- 确定伤害类型字符：C=物理伤害, L=魔法伤害
    local typeChar = isPhys and "C" or "L"   -- C=物理, L=魔法

    -- 准备伤害数字字符串：取整后转为字符串，用于逐位显示
    local dmgStr   = tostring(math.floor(damage))
    local count    = #dmgStr  -- 数字位数

    -- 飘字 RNG 消费点（恒消费 1 次/伤害事件，双机随机流对齐的最强锚点）
    local rngFx = math.random(-20, 20)
    -- 计算特效显示的基准坐标：单位位置 + 随机水平偏移
    local baseX    = cj.GetUnitX(targetHandle) + rngFx
    local baseY    = cj.GetUnitY(targetHandle)


    -- 遍历伤害数字的每一位，为每个数字创建对应特效
    for i = 1, count do
        local digit = tonumber(dmgStr:sub(i, i))  -- 提取当前位的数字
        local path  = string.format([[TX\INT\%s%d.mdx]], typeChar, digit)  -- 构建特效路径

        Effect:new(path, baseX - 24 * (count - i),baseY,nil,0)
    end

    -- 如果是暴击，在数字最前面添加暴击标记特效
    if isCrit then
        Effect:new(string.format([[TX\INT\%sB.mdx]], typeChar), baseX - 24 * count,baseY,nil,0)
    end

end

-- ============================================================
-- 伤害入口（Event.lua 回调）
-- ★ 注册为“最后执行”的底层回调：在所有其他伤害修正回调跑完之后才
--   结算伤害、统计与飘字，确保排行榜/伤害数值读取的是最终结算值，
--   不会被后续回调二次 setDamage 覆盖导致数值不准。
-- ============================================================
---@param e Event
local function onUnitDamaged(e)
    local targetHandle = e.unit
    local rawDamage    = e:getFinalDamage()
    local sourceHandle = e.damageSource
    if rawDamage <= 0 then return end

    -- ── 异步重入锁 ──
    -- EXSetEventDamage 后引擎可能异步再触发一次事件，
    -- 用 target+source 锁 1 帧挡住。
    local lockKey = (targetHandle and cj.GetHandleId(targetHandle) or 0) .. "_" .. (sourceHandle and cj.GetHandleId(sourceHandle) or 0)
    if _asyncLock[lockKey] then
        return
    end
    _asyncLock[lockKey] = true
    local tmr = cj.CreateTimer()
    cj.TimerStart(tmr, REENTRY_LOCK_MS, false, function()
        clearLock(lockKey)
        cj.DestroyTimer(tmr)
    end)

    -- ── 1. 伤害分类 ──
    local dmgType = cj.ConvertDamageType(cdz.EXGetEventDamageData(EVENT_DAMAGE_DATA_DAMAGE_TYPE))
    if dmgType ~= DAMAGE_TYPE_NORMAL and dmgType ~= DAMAGE_TYPE_ENHANCED and dmgType ~= DAMAGE_TYPE_MAGIC then
        return
    end
    local isPhys = dmgType == DAMAGE_TYPE_NORMAL or dmgType == DAMAGE_TYPE_ENHANCED

    -- ── 2. 暴击计算 ──
    local critDmg, isCrit = calcCrit(sourceHandle, isPhys, rawDamage)

    -- ── 3. 抗性计算 ──
    local ampDmg = applyAttackAmp(sourceHandle, critDmg)

    -- [魔法强化] 魔法伤害额外增伤倍率：multiplier = 1 + magicAmp/1000（仅魔法伤害）
    if not isPhys then
        ampDmg = applyMagicAmp(sourceHandle, ampDmg)
    end

    -- [攻击强化] 增伤倍率：multiplier = 1 + amp/1000
    local finalDmg = calcResistance(targetHandle, sourceHandle, isPhys, ampDmg)

    -- ── 4. 设定最终伤害（Event.lua 处理 EXSetEventDamage） ──
    e:setDamage(finalDmg)

    -- ── 5. 伤害漂浮 ──
    showDamageFloat(targetHandle, finalDmg, isPhys, isCrit)

    -- ── 6. 伤害统计 ──
    local tStats = getStatsRecord(targetHandle)
    tStats.received.total = tStats.received.total + finalDmg
    if isPhys then
        tStats.received.phys = tStats.received.phys + finalDmg
    else
        tStats.received.mag = tStats.received.mag + finalDmg
    end

    if sourceHandle ~= nil then
        local aStats = getStatsRecord(sourceHandle)
        aStats.dealt.total = aStats.dealt.total + finalDmg
        if isPhys then
            aStats.dealt.phys = aStats.dealt.phys + finalDmg
        else
            aStats.dealt.mag = aStats.dealt.mag + finalDmg
        end
        if isCrit then
            aStats.critCount = aStats.critCount + 1
        end

        -- 玩家维度汇总
        local pid = cj.GetPlayerId(cj.GetOwningPlayer(sourceHandle))
        if pid >= 0 and pid <= 3 then
            local p = _playerDmg[pid]
            if not p then p = { total = 0 }; _playerDmg[pid] = p end
            p.total = p.total + finalDmg
        end
    end

    -- ── 7. 调试输出 ──
    if DEBUG_ENABLED then
        local dmgTag = isPhys and "物理" or "魔法"
        local critTag = isCrit and " [暴击!]" or ""
        local diff = rawDamage - finalDmg
        local corrStr = ""
        if diff > 0 then
            corrStr = " (减免 " .. diff .. ")"
        elseif diff < 0 then
            corrStr = " (追加 " .. (-diff) .. ")"
        end
        print("[GameDamage] " .. dmgTag .. "=" .. finalDmg .. corrStr .. critTag)
    end
end

-- 注册为任意单位伤害事件（普通通道，保证系统初始化）
Event.anyUnitDamageEvent(onUnitDamaged)
-- ★ 提升为底层【最后执行】回调：确保在所有伤害修正完成后才结算
Event.lastDamageEvent(onUnitDamaged)



-- ============================================================
-- 公开 API
-- ============================================================

GameDamage = {}

function GameDamage.getStats(unitHandle)
    if unitHandle == nil then return nil end
    local key = cj.GetHandleId(unitHandle)
    if not _dmgStats or not _dmgStats[key] then
        return { received = { total = 0, phys = 0, mag = 0 },
                 dealt = { total = 0, phys = 0, mag = 0 },
                 critCount = 0 }
    end
    return _dmgStats[key]
end

--- 获取某玩家造成的总伤害
---@param pid integer 玩家索引 (0-3)
---@return number
function GameDamage.getPlayerDealt(pid)
    local p = _playerDmg[pid]
    return p and p.total or 0
end

function GameDamage.resetStats(unitHandle)
    if unitHandle == nil then return end
    if _dmgStats then _dmgStats[cj.GetHandleId(unitHandle)] = nil end
end

function GameDamage.resetAllStats()
    _dmgStats = {}
end

function GameDamage.setDebug(enabled)
    DEBUG_ENABLED = enabled
end
