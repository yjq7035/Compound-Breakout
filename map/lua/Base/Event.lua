-- ============================================================
-- Event 类 — 事件
-- 通过 common.lua / KK_japi.lua 已注册函数封装
--
-- 调用方式：
--   local e = Event:new(unit, EVENT_UNIT_DAMAGED, function()
--       print(self.unit, self.damage)  -- self 就是 Event 对象
--   end)
--   e:destroy()
--
--   -- 全局事件（传入 nil）
--   local g = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function()
--       print(self.unit, self.damageSource)
--   end)
-- ============================================================

-- ============================================================
-- [2026-08-13] 死亡清理 trace 锚点已全部删除（改用 DesyncGuard 指纹法定位）
--   配套总开关：_G.DEAD_CLEAN_ENABLED（false = 链不启动）+ _G.DEAD_KEEP_CORPSE（尸体策略）
-- ============================================================
if _G.DEAD_CLEAN_ENABLED == nil then _G.DEAD_CLEAN_ENABLED = true end

---@class Event 事件
---@field unit                  userdata    触发单位（GetTriggerUnit）
---@field killingUnit           userdata    击杀单位（GetKillingUnit）
---@field item                  userdata    被操作物品（GetManipulatedItem）
---@field soldItem              userdata    售出物品（GetSoldItem）
---@field buyingUnit            userdata    购买单位（GetBuyingUnit）
---@field player                userdata    触发玩家（GetTriggerPlayer）
---@field trigger               userdata    触发器对象
---@field target                userdata    注册目标
---@field eventType             any         事件类型
---@field damage                number      伤害值（GetEventDamage）
---@field damageSource          userdata    伤害来源（GetEventDamageSource）
---@field targetUnit            userdata    事件目标单位（GetEventTargetUnit）
---@field destructable          userdata    触发可破坏物（GetTriggerDestructable）
---@field detectingPlayer       userdata    检测玩家（GetEventDetectingPlayer）
---@field chatString            string      聊天字符串全文
---@field chatMatched           string      聊天命令匹配部分
---@field spellId               integer     技能ID（GetSpellAbilityId）
---@field spellAbility          userdata    技能对象
---@field spellTargetUnit       userdata    技能目标单位
---@field spellTargetX          number      技能目标X
---@field spellTargetY          number      技能目标Y
---@field spellTargetItem       userdata    技能目标物品
---@field spellTargetDestructable userdata  技能目标可破坏物
---@field triggerKey            integer     按键事件键值（DzGetTriggerKey）
---@field triggerKeyPlayer      userdata    按键事件玩家
---@field syncData              string      Sync数据（DzGetTriggerSyncData）
---@field syncPlayer            userdata    Sync发送玩家
---@field syncPrefix            string      Sync前缀
---@field triggerUIEventFrame   userdata    UI事件帧
---@field triggerUIEventPlayer  userdata    UI事件玩家
---@field isEnabled             boolean     触发器是否启用
---@field attacker              userdata    攻击单位
Event = {}

Event.DEBUG = false     -- 排泄输出开关（默认关闭，不影响 Event.dump 等用户主动调用的诊断）

local _mt = {}

--- __index 元方法：self.xxx 直接映射到当前触发状态的 War3 查询函数
_mt.__index = function(self, key)
    -- 优先从 Event 类上读取方法（destroy/enable/disable 等）
    local eventVal = Event[key]
    if (eventVal ~= nil) then return eventVal end

    if (key == "unit") then
        return cj.GetTriggerUnit()
    elseif (key == "killingUnit") then
        return cj.GetKillingUnit()
    elseif (key == "item") then
        return cj.GetManipulatedItem()
    elseif (key == "soldItem") then
        return cj.GetSoldItem()
    elseif (key == "buyingUnit") then
        return cj.GetBuyingUnit()
    elseif (key == "player") then
        return cj.GetTriggerPlayer()
    elseif (key == "trigger") then
        return self._trigger
    elseif (key == "target") then
        return self._target
    elseif (key == "eventType") then
        return self._eventType
    elseif (key == "damage") then
        return cj.GetEventDamage()
    elseif (key == "damageSource") then
        return cj.GetEventDamageSource()
    elseif (key == "targetUnit") then
        return cj.GetEventTargetUnit()
    elseif (key == "attacker") then
        return cj.GetAttacker()
    elseif (key == "destructable") then
        return cj.GetTriggerDestructable()
    elseif (key == "detectingPlayer") then
        return cj.GetEventDetectingPlayer()
    elseif (key == "chatString") then
        return cj.GetEventPlayerChatString()
    elseif (key == "chatMatched") then
        return cj.GetEventPlayerChatStringMatched()
    elseif (key == "spellId") then
        return cj.GetSpellAbilityId()
    elseif (key == "spellAbility") then
        return cj.GetSpellAbility()
    elseif (key == "spellTargetUnit") then
        return cj.GetSpellTargetUnit()
    elseif (key == "spellTargetX") then
        return cj.GetSpellTargetX()
    elseif (key == "spellTargetY") then
        return cj.GetSpellTargetY()
    elseif (key == "spellTargetItem") then
        return cj.GetSpellTargetItem()
    elseif (key == "spellTargetDestructable") then
        return cj.GetSpellTargetDestructable()
    elseif (key == "triggerKey") then
        return cdz.DzGetTriggerKey()
    elseif (key == "triggerKeyPlayer") then
        return cdz.DzGetTriggerKeyPlayer()
    elseif (key == "syncData") then
        return cdz.DzGetTriggerSyncData()
    elseif (key == "syncPlayer") then
        return cdz.DzGetTriggerSyncPlayer()
    elseif (key == "syncPrefix") then
        return cdz.DzGetTriggerSyncPrefix()
    elseif (key == "triggerUIEventFrame") then
        return cdz.DzGetTriggerUIEventFrame()
    elseif (key == "triggerUIEventPlayer") then
        return cdz.DzGetTriggerUIEventPlayer()
    elseif (key == "isEnabled") then
        return cj.IsTriggerEnabled(self._trigger)
    end
    return nil
end

-----------------------------------------------------------------
-- 单位绑定触发器登记表
--   记录「绑定到具体单位」的触发器（Event:new 的 unit 事件、伤害系统 per-unit 触发器），
--   供本文件死亡单位清理系统（scanDeadUnits）在单位死亡/移除时统一清空动作并销毁，避免原生 handle 与 Lua 对象泄漏。
--   结构：handleId -> { trigger, trigger, ... }
-----------------------------------------------------------------
local _unitTriggers = {}
-- 存储结构：handleId -> { handle = userdata, trigger = trigger, actions = {func, ..} }
local _dmgUnits = {}

-----------------------------------------------------------------
-- ★ 反向清理：全局"触发器→单位"绑定表（万能兜底）
--   原理：不管触发器由谁创建、走哪条代码路径，只要它通过
--   TriggerRegisterUnitEvent 绑定了单位，就会被本表记录。
--   定期反向扫描：检查每个绑定的单位是否已被引擎移除
--   （GetUnitTypeId == 0），若已移除则销毁对应触发器。
--   结构：_allUnitBindings[trigger] = unitHandle  （trigger 作 key，userdata 可作表键）
-----------------------------------------------------------------
local _allUnitBindings = {}       -- [trigger] = { unit = unitHandle, event = eventNum }
local _allPlayerBindings = {}      -- [trigger] = { player = playerHandle, event = eventNum }

-- ★ 机器无关 tie-break 序列号：所有登记/死亡/清理都发生在同步回调内，各机执行顺序一致，
--   该计数器跨机逐字一致 → 作为排序键兜底，杜绝「同 key 记录 sort 顺序两机分叉」
--   ★ 必须声明在下方所有 hook / 登记函数之前，否则闭包会解析成 nil 全局变量
local _machineSeq = 0
local function nextMachineSeq() _machineSeq = _machineSeq + 1 return _machineSeq end

local _origTriggerRegisterUnitEvent = cj.TriggerRegisterUnitEvent
local _origTriggerRegisterPlayerUnitEvent = cj.TriggerRegisterPlayerUnitEvent

--- 事件枚举反查表：数字常量 -> 可读名字（用于诊断日志）
local _EVENT_NAMES = {}
do
    for k, v in pairs(cj) do
        if type(k) == "string" and type(v) == "number" and k:sub(1, 6) == "EVENT_" then
            _EVENT_NAMES[v] = k
        end
    end
end
local function _eventName(e)
    return _EVENT_NAMES[e] or ("#" .. tostring(e))
end

--- 全局 hook：拦截所有 TriggerRegisterUnitEvent 调用，记录「触发器→单位→事件」
---@param whichTrigger userdata 触发器
---@param whichUnit      userdata 单位
---@param whichEvent     number   事件类型
cj.TriggerRegisterUnitEvent = function(whichTrigger, whichUnit, whichEvent)
    if whichTrigger ~= nil and whichUnit ~= nil then
        _allUnitBindings[whichTrigger] = { unit = whichUnit, event = whichEvent, seq = nextMachineSeq() }
    end
    return _origTriggerRegisterUnitEvent(whichTrigger, whichUnit, whichEvent)
end

--- 全局 hook：拦截所有 TriggerRegisterPlayerUnitEvent 调用（不传具体单位，记录 player+事件）
---   注：Event:new 里的【全局/玩家单位事件】走的就是这个，之前的反向清理 hook 漏了它，
---   导致这类触发器既不被记录、也无法按"单位生死"判断 → 实测是黑户主力来源之一。
cj.TriggerRegisterPlayerUnitEvent = function(whichTrigger, whichPlayer, whichEvent, filterFunc)
    if whichTrigger ~= nil then
        _allPlayerBindings[whichTrigger] = { player = whichPlayer, event = whichEvent, seq = nextMachineSeq() }
    end
    return _origTriggerRegisterPlayerUnitEvent(whichTrigger, whichPlayer, whichEvent, filterFunc)
end

--- 从全局绑定表中移除某触发器的记录（销毁时调用）
local function _untrackBinding(trig)
    if trig ~= nil then
        _allUnitBindings[trig] = nil
        _allPlayerBindings[trig] = nil
    end
end

--- 查询某个触发器是否绑定了单位事件（供 LeakDetect 智能排泄使用）
---@param trig userdata 触发器 handle
---@return userdata|nil unitHandle 绑定的单位，没有则返回 nil
function Event.getUnitBinding(trig)
    if trig == nil then return nil end
    local b = _allUnitBindings[trig]
    if b and b.unit then return b.unit end
    return nil
end

-- 调试输出：仅 Event.DEBUG=true 时生效
local function dbg(...)
    if Event.DEBUG then
        print(...)
    end
end

-- [2026-08-13] 锚点全清除：DEAD_CLEAN_TRACE 埋点（dcTrace/dcTag）已全部删除，改用 DesyncGuard 指纹法定位

--- 整数ID → 四字符码（机器无关；AbilityId2String 对部分类型会失败返回空，手动解码更稳）
local function rawcodeStr(id)
    if id == nil or id == 0 then return "0" end
    local b1 = math.floor(id / 16777216) % 256
    local b2 = math.floor(id / 65536)    % 256
    local b3 = math.floor(id / 256)      % 256
    local b4 = id % 256
    return string.char(b1, b2, b3, b4)
end

--- 单位描述（跨机 diff 用）：hid(机器本地，仅供参考) + 类型四码 + 拥有者 + UserData + 坐标
---   坐标/类型/UserData 由引擎同步，跨机必须一致 → 两机日志以「除 hid 外字段」对齐同一逻辑单位
---@param h userdata
---@param hid number|nil
---@return string
function Event.unitDesc(h, hid)
    if h == nil then return "nil" end
    hid = hid or 0
    local ok
    local tid, pid, ud = 0, -1, 0
    local x, y = 0, 0
    ok, tid = pcall(cj.GetUnitTypeId, h); if not ok then tid = 0 end
    ok, pid = pcall(function() return cj.GetPlayerId(cj.GetOwningPlayer(h)) end); if not ok then pid = -1 end
    ok, ud = pcall(cj.GetUnitUserData, h); if not ok then ud = 0 end
    ok, x = pcall(cj.GetUnitX, h); if not ok then x = 0 end
    ok, y = pcall(cj.GetUnitY, h); if not ok then y = 0 end
    local sx = (x >= 0) and ("+" .. math.floor(x)) or tostring(math.floor(x))
    local sy = (y >= 0) and ("+" .. math.floor(y)) or tostring(math.floor(y))
    return string.format("hid=%s type=%s('%s') owner=%d ud=%d pos=%s,%s",
        tostring(hid), tostring(tid), rawcodeStr(tid), pid, ud, sx, sy)
end

--- 跨机确定性排序键（机器无关！）：
---   ownerPid → UserData(刷怪序号) → 类型 → X → Y
---   ★ handle id 是机器本地的：双机 id 一旦错位（UI帧/本地句柄已导致），
---     按 hid 排序销毁 → 两侧销毁顺序不同 → handle 槽位回收/复用错位 → 强 desync 放大器。
---   因此所有「销毁/清理」的排序都必须用本键，禁止用 handle id 排序。
---@param h userdata
---@return string
function Event.unitKey(h)
    if h == nil then return "p-001_u0000000000_t0000000000_x-0000000000000_y-0000000000000" end
    local ok
    local pid, ud, tid = -1, 0, 0
    local x, y = 0, 0
    ok, pid = pcall(function() return cj.GetPlayerId(cj.GetOwningPlayer(h)) end); if not ok then pid = -1 end
    ok, ud = pcall(cj.GetUnitUserData, h); if not ok then ud = 0 end
    ok, tid = pcall(cj.GetUnitTypeId, h); if not ok then tid = 0 end
    ok, x = pcall(cj.GetUnitX, h); if not ok then x = 0 end
    ok, y = pcall(cj.GetUnitY, h); if not ok then y = 0 end
    local fx = (x >= 0) and ("+" .. string.format("%012.2f", x)) or ("-" .. string.format("%012.2f", -x))
    local fy = (y >= 0) and ("+" .. string.format("%012.2f", y)) or ("-" .. string.format("%012.2f", -y))
    return string.format("p%03d_u%010d_t%010d_x%s_y%s", pid, ud, tid, fx, fy)
end

-- 清理诊断计数器（排查"触发器只增不减"问题）
local _cleanupStats = {
    clearUnitTriggersCalls = 0,   -- clearUnitTriggers 被调用次数
    triggersDestroyed    = 0,    -- 累计销毁的触发器数
    reverseSweepCalls    = 0,    -- 反向扫描调用次数
    reverseSweepCleaned  = 0,    -- 反向扫描发现的并销毁的黑户数
    lastLogTime          = 0,    -- 上次输出统计的时间
}

--- 登记一个绑定到某单位的触发器
---  同时写入 _unitTriggers（按单位索引）和 _allUnitBindings（按触发器索引用于反向扫描）
---@param unitHandle userdata
---@param trigger userdata
function Event.registerUnitTrigger(unitHandle, trigger)
    if unitHandle == nil or trigger == nil then return end
    local hid = cj.GetHandleId(unitHandle)
    if hid == nil or hid == 0 then return end
    _unitTriggers[hid] = _unitTriggers[hid] or {}
    table.insert(_unitTriggers[hid], trigger)
    -- ★ 同步写入全局绑定表（与 TriggerRegisterUnitEvent hook 同样用 {unit,event} 结构）
    _allUnitBindings[trigger] = { unit = unitHandle, event = nil, seq = nextMachineSeq() }
end

--- 从登记表中移除某触发器（Event:destroy 时调用，避免重复销毁）
local function _untrackTrigger(trig)
    if trig == nil then return end
    for hid, list in pairs(_unitTriggers) do
        for i = #list, 1, -1 do
            if list[i] == trig then
                table.remove(list, i)
            end
        end
        if #list == 0 then
            _unitTriggers[hid] = nil
        end
    end
    -- ★ 同时清除全局绑定表记录
    _untrackBinding(trig)
end

--- 清空并销毁某单位绑定的所有触发器（单位死亡/移除时由本文件死亡单位清理系统调用）
--  一个单位可能绑定【多个】触发器（多个 Event:new 单位事件 + 伤害系统 per-unit 触发器），
--  它们统一通过 registerUnitTrigger 登记进 _unitTriggers[hid] 这张【列表】里，
--  这里遍历列表逐个「先 TriggerClearActions 释放捕获闭包，再 DestroyTrigger 销毁」。
--  伤害触发器同时登记在 _dmgUnits（供伤害系统自身逻辑用），故用 destroyed 集合去重，
--  避免同一触发器被重复销毁；最后清掉 _dmgUnits 记账（含 actions 回调表）。
--  重复调用安全（pcall 包裹 + 去重）。
---@param unitHandle userdata
function Event.clearUnitTriggers(unitHandle)
    if unitHandle == nil then return end
    local hid = cj.GetHandleId(unitHandle)
    if hid == nil or hid == 0 then return end

    _cleanupStats.clearUnitTriggersCalls = _cleanupStats.clearUnitTriggersCalls + 1

    -- 已销毁触发器集合，避免同一触发器被重复销毁（伤害触发器同时登记在两处）
    local destroyed = {}
    local destroyCount = 0

    -- 1) 遍历该单位绑定的所有触发器（列表），逐个清空动作并销毁
    local list = _unitTriggers[hid]
    local listCount = list and #list or 0
    if list then
        for _, trig in ipairs(list) do
            if trig ~= nil and not destroyed[trig] then
                pcall(cj.TriggerClearActions, trig)
                pcall(cj.DestroyTrigger, trig)
                _untrackBinding(trig)          -- ★ 清除全局绑定表记录
                destroyed[trig] = true
                destroyCount = destroyCount + 1
            end
        end
        _unitTriggers[hid] = nil
    end

    -- 2) 伤害系统 per-unit 触发器：正常已在上面列表中销毁；此处兜底销毁未登记的情况，
    --    并清除 _dmgUnits 记账（连同 actions 回调表一起释放）
    local dentry = _dmgUnits[hid]
    if dentry then
        local dtrig = dentry.trigger
        if dtrig ~= nil and not destroyed[dtrig] then
            pcall(cj.TriggerClearActions, dtrig)
            pcall(cj.DestroyTrigger, dtrig)
            _untrackBinding(dtrig)          -- ★ 清除全局绑定表记录
            destroyed[dtrig] = true
            destroyCount = destroyCount + 1
        end
        _dmgUnits[hid] = nil
    end

    -- 有实际销毁时才输出日志（避免刷屏）
    if destroyCount > 0 then
        -- [PROBE] 周期清理分步计数（双机 console diff 定位：哪一步的数量两机不等 → 分叉点）
        _G._PT = _G._PT or {}; _G._PT.clTrig = (_G._PT.clTrig or 0) + destroyCount
        _cleanupStats.triggersDestroyed = _cleanupStats.triggersDestroyed + destroyCount
        dbg(string.format(
            "[Event.cleanup] 单位%s 清理 %d 个触发器 (列表%d + 兜底%d) | 累计调用%d 销毁%d",
            hid, destroyCount, listCount, destroyCount - listCount,
            _cleanupStats.clearUnitTriggersCalls, _cleanupStats.triggersDestroyed
        ))
    end
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建并注册事件
---@param target userdata|nil 目标（单位/玩家，nil=全局）
---@param eventType any 事件类型常量
---@param callback fun(Event) 回调函数（self 为 Event 对象）
---@return Event
function Event:new(target, eventType, callback)
    if (eventType == nil or callback == nil) then return end
    local obj = {
        _trigger = cj.CreateTrigger(),
        _target = target,
        _eventType = eventType,
    }
    setmetatable(obj, _mt)

    -- 根据类型选择注册方式
    if (eventType == EVENT_UNIT_DAMAGED or eventType == EVENT_UNIT_ATTACKED) then
        -- 单位事件
        if (target == nil) then
            -- 全局单位事件：遍历玩家注册
            local playerIndex
            for i = 0, bj_MAX_PLAYERS - 1 do
                playerIndex = cj.Player(i)
                cj.TriggerRegisterPlayerUnitEvent(obj._trigger, playerIndex, eventType, nil)
            end
        else
            cj.TriggerRegisterUnitEvent(obj._trigger, target, eventType)
            Event.registerUnitTrigger(target, obj._trigger)   -- ★ 绑定到具体单位，登记以便死亡时统一清理
        end

    elseif (eventType == EVENT_PLAYER_LEAVE or eventType == EVENT_PLAYER_END_CINEMATIC or eventType == EVENT_PLAYER_STATE_LIMIT) then
        -- 玩家事件
        if (target == nil) then
            local p
            for i = 0, bj_MAX_PLAYERS - 1 do
                p = cj.Player(i)
                cj.TriggerRegisterPlayerEvent(obj._trigger, p, eventType)
            end
        else
            cj.TriggerRegisterPlayerEvent(obj._trigger, target, eventType)
        end

    elseif (
        eventType == EVENT_PLAYER_UNIT_DEATH or
        eventType == EVENT_PLAYER_UNIT_SELECTED or
        eventType == EVENT_PLAYER_UNIT_DESELECTED or
        eventType == EVENT_PLAYER_UNIT_CONSTRUCT_START or
        eventType == EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL  or
        eventType == EVENT_PLAYER_UNIT_CONSTRUCT_FINISH or
        eventType == EVENT_PLAYER_UNIT_SELL_ITEM or
        eventType == EVENT_PLAYER_UNIT_SELL or
        eventType == EVENT_PLAYER_UNIT_PICKUP_ITEM or
        eventType == EVENT_PLAYER_UNIT_DROP_ITEM or
        eventType == EVENT_PLAYER_UNIT_USE_ITEM or
        eventType == EVENT_PLAYER_UNIT_SPELL_CHANNEL or
        eventType == EVENT_PLAYER_UNIT_SPELL_CAST or
        eventType == EVENT_PLAYER_UNIT_SPELL_EFFECT or
        eventType == EVENT_PLAYER_UNIT_SPELL_FINISH or
        eventType == EVENT_PLAYER_UNIT_SPELL_ENDCAST
    ) then
        -- 玩家单位事件
        -- if eventType == EVENT_PLAYER_UNIT_DEATH then return obj end
        if (target == nil) then
            local p
            for i = 0, 15 do
                p = cj.Player(i)
                cj.TriggerRegisterPlayerUnitEvent(obj._trigger, p, eventType, nil)
            end
        else
            cj.TriggerRegisterPlayerUnitEvent(obj._trigger, target, eventType, nil)
            Event.registerUnitTrigger(target, obj._trigger)   -- ★ 绑定到具体单位，登记以便死亡时统一清理
        end

    elseif (eventType == EVENT_UNIT_SPELL_CHANNEL or 
        eventType == EVENT_UNIT_SPELL_CAST or
        eventType == EVENT_UNIT_SPELL_EFFECT or
        eventType == EVENT_UNIT_SPELL_FINISH or
        eventType == EVENT_UNIT_SPELL_ENDCAST or
        eventType == EVENT_UNIT_HERO_SKILL or
        eventType == EVENT_UNIT_HERO_LEVEL or
        eventType == EVENT_UNIT_USE_ITEM or eventType == EVENT_UNIT_DROP_ITEM
        or eventType == EVENT_UNIT_PICKUP_ITEM
        or eventType == EVENT_UNIT_UPGRADE_START or eventType == EVENT_UNIT_UPGRADE_CANCEL
        or eventType == EVENT_UNIT_UPGRADE_FINISH
        or eventType == EVENT_UNIT_ISSUED_ORDER
        or eventType == EVENT_UNIT_DEATH) then
        -- 单位事件（技能/物品/升级/死亡等）- 需要绑定到特定单位
        if (target ~= nil) then
            cj.TriggerRegisterUnitEvent(obj._trigger, target, eventType)
            Event.registerUnitTrigger(target, obj._trigger)   -- ★ 绑定到具体单位，登记以便死亡时统一清理
        end

    else
        -- fallback：注册为游戏事件
        cj.TriggerRegisterGameEvent(obj._trigger, eventType)
    end

    -- 添加动作（使 self 为 Event 对象）
    cj.TriggerAddAction(obj._trigger, function()
        callback(obj)
    end)

    return obj
end

--- 销毁事件（销毁触发器）
---@return Event
function Event:destroy()
    if (self._trigger ~= nil) then
        _untrackTrigger(self._trigger)   -- 从单位绑定登记表移除
        cj.DestroyTrigger(self._trigger)
        self._trigger = nil
    end
    self._target = nil
    self._eventType = nil
    return self
end

--- 启用
---@return Event
function Event:enable()
    if (self._trigger ~= nil) then
        cj.EnableTrigger(self._trigger)
    end
    return self
end

--- 禁用
---@return Event
function Event:disable()
    if (self._trigger ~= nil) then
        cj.DisableTrigger(self._trigger)
    end
    return self
end

--- 执行
---@return Event
function Event:execute()
    if (self._trigger ~= nil) then
        cj.TriggerExecute(self._trigger)
    end
    return self
end

--- 存储结构：handleId -> { rect = userdata, region = userdata, trigger = userdata, actions = {func, ..} }
local _rectEvents = {}

--- 任意单位进入矩形事件
---@param rect Rect
---@param callback fun(Event) 回调函数（self 为 Event 对象）
---@return Event
function Event:newRect(rect, callback)
    if rect == nil then return end
    local key = cj.GetHandleId(rect)
    
    local entry = _rectEvents[key]
    if not entry then
        local region = cj.CreateRegion()
        cj.RegionAddRect(region, rect)
        
        local trig = cj.CreateTrigger()
        cj.TriggerRegisterEnterRegion(trig, region, nil)
        
        local obj = {
            _trigger = trig,
            _rect = rect,
            _region = region,
            _unit = nil,
        }
        setmetatable(obj, _mt)
        
        cj.TriggerAddAction(trig, function()
            local entry = _rectEvents[key]
            if not entry then return end
            for _, cb in ipairs(entry.actions) do
                obj._unit = cj.GetEnteringUnit()
                cb(obj)
            end
        end)
        
        entry = { rect = rect, region = region, trigger = trig, actions = {}, obj = obj }
        _rectEvents[key] = entry
    end
    
    if callback then
        table.insert(entry.actions, callback)
    end
    
    return entry.obj
end

--- 移除矩形事件的某个回调
---@param rect Rect
---@param callback function 要移除的回调函数
function Event:offRect(rect, callback)
    if rect == nil then return end
    local key = cj.GetHandleId(rect)
    local entry = _rectEvents[key]
    if not entry then return end
    for i, cb in ipairs(entry.actions) do
        if cb == callback then
            table.remove(entry.actions, i)
            return
        end
    end
end

--- 销毁矩形事件（销毁触发器和区域）
---@param rect Rect
function Event:destroyRect(rect)
    if rect == nil then return end
    local key = cj.GetHandleId(rect)
    local entry = _rectEvents[key]
    if not entry then return end
    cj.DestroyTrigger(entry.trigger)
    cj.RemoveRectFromRegion(entry.region, rect)
    cj.DestroyRegion(entry.region)
    _rectEvents[key] = nil
end

-----------------------------------------------------------------
-- 任意单位伤害系统
-- 每个单位独立注册伤害事件，"一个事件多个动作"模式
--
-- 设计要点：
--   1. 每个单位一个 trigger → 多个 callback → 精准监听、批量扩展
--   2. 初始扫描全图已有单位全部注册
--   3. 监听训练完成/建造完成 → 新单位自动注册（判断去重）
--   4. 监控计时器每 3 秒清理已销毁单位的 trigger
--   5. ★ 元表对象风格：回调接收带 _mt 元表的 Event 对象 self，可通过
--      self.unit / self.damage / self.damageSource 直接读取 War3 事件数据，
--      通过 self:setDamage() / self:getFinalDamage() 等方法操作本次伤害；
--      Event 层在所有回调执行完后调用 cdz.EXSetEventDamage() 设置最终结算伤害
--
-- 使用方式：
--   Event.anyUnitDamageEvent(callback)                    -- ★ 最简入口：自动初始化 + 所有单位（推荐）
--   Event.lastDamageEvent(callback)                       -- ★ 设为底层【最后执行】回调（所有伤害修正完成后再结算，如 GameDamage）
--   Event.initDamageSystem()                              -- 初始化（全图扫描 + 入场监听 + 清理计时器）
--   Event.onUnitDamage(unitHandle, callback)              -- 为指定单位添加受伤回调
--   Event.offUnitDamage(unitHandle, callback)             -- 移除指定单位的某个回调
--   Event.registerDamageUnit(unitHandle)                  -- 手动注册单位（用于 CreateUnit 创建的单位）
--
--   回调签名：function(self)  —— self 为伤害事件对象（带 _mt 元表）
--     self.unit         — 受伤单位 handle（GetTriggerUnit）
--     self.damage       — 引擎原始伤害值（GetEventDamage），如需修改请用 self:setDamage()
--     self.damageSource — 伤害来源 handle（GetEventDamageSource）
--     self:setDamage(finalDmg)    — 设置最终伤害值
--     self:getOriginalDamage()    — 获取原始伤害值（只读）
--     self:getFinalDamage()       — 获取当前最终伤害值
--     self:isPhysicalDamage()     — 是否物理伤害
--     self:isDamageType(t)        — 是否指定伤害类型
-----------------------------------------------------------------


-- 全局伤害回调：自动应用到所有单位（当前 + 未来）
local _dmgGlobalActions = {}
-- 预留的【最后执行】伤害回调（底层结算用，如 GameDamage）：
-- 始终在所有 _dmgGlobalActions 之后执行，即便后续有模块再注册也不会被挤到前面
local _dmgLastAction = nil
local _dmgInitDone = false
local _dmgEnterTrig = nil

-- 伤害跟踪说明：
--   dmgRef = { original = number, final = number } 存储在每次伤害事件的
--   Event 对象 self._dmgRef 上（见 ensureDamageTrigger），回调中通过
--   self:setDamage() / self:getFinalDamage() 访问；所有回调结束后用
--   EXSetEventDamage 设置最终伤害。
-- 防递归锁：EXSetEventDamage 可能触发新伤害事件
local _dmgInProcess = false

--- 判断单位是否已被游戏移除（GetUnitTypeId == 0）
local function isUnitRemoved(h)
    if h == nil then return true end
    return cj.GetUnitTypeId(h) == 0
end

--- 核⼼：为单位创建伤害触发器（已存在则直接返回，不做重复注册）
---@param unitHandle userdata
---@return table|nil entry 对象 { handle, trigger, actions }
local function ensureDamageTrigger(unitHandle)
    if unitHandle == nil or isUnitRemoved(unitHandle) then return end
    local key = cj.GetHandleId(unitHandle)
    if _dmgUnits[key] then return _dmgUnits[key] end

    local trig = cj.CreateTrigger()
    cj.TriggerRegisterUnitEvent(trig, unitHandle, EVENT_UNIT_DAMAGED)
    cj.TriggerAddAction(trig, function()
        local entry = _dmgUnits[key]
        if not entry then return end
        if _dmgInProcess then
            -- 防递归：嵌套伤害事件（回调中再造成伤害）不执行回调，但需显式
            -- 调用 EXSetEventDamage 让原伤害生效，否则 EX 伤害系统会吞掉伤害。
            cdz.EXSetEventDamage(cj.GetEventDamage())
            return
        end

        _dmgInProcess = true

        local originalDmg = cj.GetEventDamage()
        local src = cj.GetEventDamageSource()

        -- 创建伤害事件对象（带元表 _mt）：回调中 self.unit / self.damage /
        -- self.damageSource 直接映射 War3 查询函数；self._dmgRef 跟踪原始/最终
        -- 伤害，回调可通过 self:setDamage() 修改最终值。
        local dmgRef = { original = originalDmg, final = originalDmg }
        local dmgEvent = setmetatable({
            _trigger = trig,
            _target = unitHandle,
            _eventType = EVENT_UNIT_DAMAGED,
            _dmgRef = dmgRef,
        }, _mt)

        pcall(function()
            for _, cb in ipairs(entry.actions) do
                cb(dmgEvent)
            end
        end)

        -- ★ 底层最后回调：在所有普通回调执行完后运行（独立于普通回调，
        --   即便前面回调报错也保证执行），适合读取“最终伤害”做结算/统计的
        --   模块（如 GameDamage），确保伤害排行与伤害数值基于最终结算值。
        if _dmgLastAction then
            pcall(_dmgLastAction, dmgEvent)
        end

        -- 所有回调执行完后，用 EXSetEventDamage 设置最终结算伤害
        if dmgRef.final ~= originalDmg then
            cdz.EXSetEventDamage(dmgRef.final)
        end

        _dmgInProcess = false
    end)

    local entry = { handle = unitHandle, trigger = trig, actions = {}, seq = nextMachineSeq() }
    _dmgUnits[key] = entry

    -- ★ 登记到单位绑定触发器表，供本文件死亡单位清理系统（scanDeadUnits）在单位死亡时统一销毁
    Event.registerUnitTrigger(unitHandle, trig)

    -- 新注册的单位自动挂上所有全局伤害回调
    for _, cb in ipairs(_dmgGlobalActions) do
        table.insert(entry.actions, cb)
    end

    return entry
end

--- 手动注册单位到伤害系统（用于 CreateUnit 创建的单位）
---@param unitHandle userdata
function Event.registerDamageUnit(unitHandle)
    ensureDamageTrigger(unitHandle)
end

--- 为单位添加受伤回调（自动注册，可多次调用添加多个回调）
---@param unitHandle userdata
---@param callback fun(self:Event) 回调函数（self 为伤害事件对象）
function Event.onUnitDamage(unitHandle, callback)
    if unitHandle == nil or callback == nil then return end
    local entry = ensureDamageTrigger(unitHandle)
    if entry then table.insert(entry.actions, callback) end
end

--- 移除单位的某个受伤回调
---@param unitHandle userdata
---@param callback function 要移除的回调函数
function Event.offUnitDamage(unitHandle, callback)
    if unitHandle == nil then return end
    local entry = _dmgUnits[cj.GetHandleId(unitHandle)]
    if not entry then return end
    for i, cb in ipairs(entry.actions) do
        if cb == callback then
            table.remove(entry.actions, i)
            return
        end
    end
end

--- ★ 任意单位伤害事件 — 最简调用入口
--- 自动初始化系统，自动注册所有现有+未来单位，一行代码搞定
--- 支持多次调用添加多个回调
---@param callback fun(self:Event) 回调函数（self 为伤害事件对象，带 _mt 元表）
function Event.anyUnitDamageEvent(callback)
    if callback == nil then return end
    -- 防止同一 callback 被重复注册（如模块被多次 require），
    -- 避免一次伤害事件被同一个回调处理多次。去重在此层做，外部无需碰内部引用。
    for _, cb in ipairs(_dmgGlobalActions) do
        if cb == callback then return end
    end
    -- 自动初始化（幂等，仅首次生效）
    if not _dmgInitDone then
        Event.initDamageSystem()
    end
    -- 存入全局回调列表（未来新单位在 ensureDamageTrigger 中自动挂载）
    table.insert(_dmgGlobalActions, callback)
    -- 挂载到当前已注册的所有单位
    for _, entry in pairs(_dmgUnits) do
        table.insert(entry.actions, callback)
    end
end

--- ★ 将指定回调设为【最后执行】的底层伤害回调
--- 该回调会在所有其他伤害回调（_dmgGlobalActions）执行完毕后再执行，
--- 适合需要在“所有伤害修正完成后”才读取/结算最终伤害的模块（如 GameDamage 的统计与数值显示）。
--- 即便之后有其他模块再注册普通伤害回调，该回调依然保持最后执行，不会被挤到前面。
--- 若同一回调此前以普通方式（anyUnitDamageEvent）注册过，会自动从普通列表中移除，避免重复执行。
---@param callback fun(self:Event) 回调函数（self 为伤害事件对象，带 _mt 元表）
function Event.lastDamageEvent(callback)
    if callback == nil then return end
    -- 若之前以普通回调形式注册过，先从全局列表与各单位 actions 中移除，避免重复执行
    for i = #_dmgGlobalActions, 1, -1 do
        if _dmgGlobalActions[i] == callback then
            table.remove(_dmgGlobalActions, i)
        end
    end
    for _, entry in pairs(_dmgUnits) do
        for i = #entry.actions, 1, -1 do
            if entry.actions[i] == callback then
                table.remove(entry.actions, i)
            end
        end
    end
    -- 设为全局唯一“最后执行”槽位
    _dmgLastAction = callback
    -- 确保伤害系统已初始化（若尚未初始化，先初始化以便后续新单位也能触发本回调）
    if not _dmgInitDone then
        Event.initDamageSystem()
    end
end

--- 清理已销毁单位的伤害触发器（计时器回调）
local function cleanupRemovedUnits()
    local removed = {}
    for key, entry in pairs(_dmgUnits) do
        if isUnitRemoved(entry.handle) then
            table.insert(removed, key)
        end
    end
    if #removed > 0 then
        -- [PROBE] 周期清理分步计数（双机 console diff 定位：哪一步的数量两机不等 → 分叉点）
        _G._PT = _G._PT or {}; _G._PT.clRemoved = (_G._PT.clRemoved or 0) + #removed
        dbg(string.format("[Event.cleanupRemovedUnits] 发现 %d 个已移除单位，开始清理", #removed))
        -- ★ 确定性销毁顺序（desync 防护）：_dmgUnits 的 key 是机器本地 handle id，
        --   双机 id 错位时按 key 排序会给同一批单位不同的清理顺序 → 改用机器无关排序键
        --   （seq tie-break：登记序跨机一致，避免同 key 记录 sort 分叉）
        for i, key in ipairs(removed) do
            local entry = _dmgUnits[key]
            local uk = (entry ~= nil and entry.handle ~= nil) and Event.unitKey(entry.handle) or ("u" .. tostring(key))
            removed[i] = {
                key = key,
                uk = uk,
                tuk = uk .. string.format("|%010d", (entry and entry.seq) or 0),
            }
        end
        table.sort(removed, function(a, b) return a.tuk < b.tuk end)
    end
    for _, e in ipairs(removed) do
        local entry = _dmgUnits[e.key]
        if entry then
            -- 统一走 clearUnitTriggers：清空动作 + 销毁触发器 + 清理单位绑定登记表
            Event.clearUnitTriggers(entry.handle)
        end
    end
end

--- 新单位入场时自动注册伤害事件
local function onUnitEntersMap()
    local u = cj.GetTriggerUnit()
    if u == nil then return end
    local key = cj.GetHandleId(u)
    -- 已有注册 or 已移除 → 跳过
    if _dmgUnits[key] then return end
    if isUnitRemoved(u) then return end
    ensureDamageTrigger(u)
end

--- 初始化伤害系统
--- 1) 扫描全图所有现有单位注册
--- 2) 监听训练完成/建造完成 → 新单位自动注册
--- 3) 启动监控计时器，每 3 秒清理已销毁单位的 trigger
--- 多次调用幂等，只执行一次
function Event.initDamageSystem()
    if _dmgInitDone then return end
    _dmgInitDone = true

    -- 1) 扫描全图已有单位
    local group = cj.CreateGroup()
    cj.GroupEnumUnitsInRect(group, cj.GetWorldBounds(), nil)
    -- ★ 铁律C（desync 根治）：原生 GroupEnumUnitsInRect 的枚举顺序跨机不保证一致；
    --   若按枚举序逐个 ensureDamageTrigger（每单位 CreateTrigger=建句柄），两机触发器
    --   句柄分配顺序分叉 → 词条爆炸伤害 / 死亡清理等依赖 _dmgUnits 触发器句柄的链路
    --   全部错位 → 概率 desync（单位越多越易触发，与"词条/清理开启即概率异步"吻合）。
    --   修复：先收集全部单位 → 按 Event.unitKey（机器无关：类型/坐标/UserData）排序 → 再注册。
    local _scanUnits = {}
    local u = cj.FirstOfGroup(group)
    while u ~= nil do
        if not isUnitRemoved(u) then
            _scanUnits[#_scanUnits + 1] = u
        end
        cj.GroupRemoveUnit(group, u)
        u = cj.FirstOfGroup(group)
    end
    cj.DestroyGroup(group)
    table.sort(_scanUnits, function(a, b)
        return Event.unitKey(a) < Event.unitKey(b)
    end)
    for _i = 1, #_scanUnits do
        ensureDamageTrigger(_scanUnits[_i])
    end

    -- 2) 监听新单位入场（训练完成 / 建造完成）
    _dmgEnterTrig = cj.CreateTrigger()
    for i = 0, bj_MAX_PLAYERS - 1 do
        local p = cj.Player(i)
        cj.TriggerRegisterPlayerUnitEvent(_dmgEnterTrig, p, EVENT_PLAYER_UNIT_TRAIN_FINISH, nil)
        cj.TriggerRegisterPlayerUnitEvent(_dmgEnterTrig, p, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, nil)
    end
    cj.TriggerAddAction(_dmgEnterTrig, onUnitEntersMap)

    -- 提示初始化完成
    -- print("[Event] 伤害系统初始化完成，已注册 " .. #_dmgUnits .. " 个单位")
end

-----------------------------------------------------------------
-- 伤害事件对象方法（元表对象风格）
-- 在伤害事件回调中通过 self:setDamage() / self:getFinalDamage() 等调用，
-- Event 层会在所有回调执行完后自动调用 cdz.EXSetEventDamage() 做 HP 修正。
-- 这些方法定义在 Event 表上，借助 _mt.__index 的「Event[key] 优先」规则，
-- 伤害事件对象可直接用 self:method() 语法访问。
-----------------------------------------------------------------

--- 设置本次伤害的最终伤害值
--- 在伤害事件回调中调用 self:setDamage(finalDamage)，Event 层会在所有回调
--- 执行完后调用 cdz.EXSetEventDamage() 设置最终值。不在事件回调中调用则无效。
---@param finalDamage number 最终伤害值
function Event:setDamage(finalDamage)
    local r = type(self) == "table" and self._dmgRef or nil
    if r then r.final = finalDamage end
end

--- 获取本次伤害的最终值（所有回调执行完后的值）
---@return number|nil
function Event:getFinalDamage()
    local r = type(self) == "table" and self._dmgRef or nil
    return r and r.final or nil
end

--- 判断本次伤害是否为指定伤害类型
---@param damageType integer 伤害类型枚举值（如 DAMAGE_TYPE_PHYSICAL, DAMAGE_TYPE_MAGICAL, 等）
---@return boolean
function Event:isDamageType(damageType)
    return cj.ConvertDamageType(cdz.EXGetEventDamageData(EVENT_DAMAGE_DATA_DAMAGE_TYPE)) == damageType
end

--- 判断本次伤害是否为物理伤害
---@return boolean
function Event:isPhysicalDamage()
    return cdz.EXGetEventDamageData(EVENT_DAMAGE_DATA_IS_PHYSICAL) ~= 0
end

-----------------------------------------------------------
-- 死亡单位清理系统（原 Game_.GameCleanDead 已并入本文件）
--   目标：单位死亡后，若 10 秒内仍保持死亡状态（未被复活），则：
--     ★ 清除其绑定的所有触发器（受伤/攻击/技能/死亡等），释放闭包，
--       避免触发器及其闭包随死亡单位泄漏。
--   [TEMP] _G.DEAD_KEEP_CORPSE=true 时只清事件、不删尸体（尸体保留）；
--          false 恢复「清事件 + Unit:destroy() 移除尸体」的完整清理。
--   节奏：每 3 秒扫描一次（DEAD_CLEAN_INTERVAL=2s × DEAD_CLEAN_TICKS=5 = 10s）。
--   排除：英雄单位（需回祭坛复活，绝不能被清理）。
-----------------------------------------------------------

-- 扫描间隔（秒）
local DEAD_CLEAN_INTERVAL = 2
-- 死亡后等待的扫描次数（2s × 1 = 2s）★ 2026-08-13 由 5(10s) 缩短为 1(2s)
local DEAD_CLEAN_TICKS = 1

-- 清理表：handleId -> { handle = userdata, ticks = integer }
local _deadUnits = {}

-- 是否跳过清理（英雄等需要复活的单位）
local function _deadShouldSkip(h)
    if h == nil then return true end
    return cj.IsUnitType(h, UNIT_TYPE_HERO)
end

-- 判断单位是否「仍存在、非英雄、且仍处于死亡状态」
--   已被引擎移除（GetUnitTypeId==0）的单位由 cleanupRemovedUnits 先行处理，
--   这里直接返回 false，避免对游离句柄调用 IsUnitType 造成的隐患（句柄复用等）。
local function _isStillDead(h)
    if h == nil or _deadShouldSkip(h) then return false end
    if isUnitRemoved(h) then return false end
    return cj.IsUnitType(h, UNIT_TYPE_DEAD)
end

-- 单位死亡 10 秒（5 ticks）仍未被复活：清除事件触发器/绑定表
--   [TEMP] _G.DEAD_KEEP_CORPSE=true → 不删除尸体（保留尸体，仅清事件）
local function _finalizeDeadUnit(h)
    if h == nil then return end
    -- 清除该单位绑定的所有触发器（受伤/攻击/技能/死亡等）
    Event.clearUnitTriggers(h)
    if _G.DEAD_KEEP_CORPSE then return end
    -- 销毁单位：释放原生 handle + 清理框架缓存 + 向 LeakDetect 销账
    local u = Unit.fromHandle(h)
    if u ~= nil then
        u:destroy()
    else
        cj.RemoveUnit(h)
    end
end

-- 周期扫描：每 2 秒扣一次计次，归零且仍死亡则清理
local function scanDeadUnits()
    -- ★ 确定性销毁顺序（desync 防护，与 reverseSweepTriggers 同理）：
    --   pairs(_deadUnits) 的遍历顺序依赖表的插入历史，两台机器历史一旦分叉，
    --   DestroyTrigger/RemoveUnit 顺序就不同 -> handle id 回收/复用错位 -> desync。
    --   ★ 排序键必须机器无关：handle id 是机器本地的（双机 id 已错位时按 hid 排序
    --     会给同一批逻辑单位不同的销毁顺序）→ 统一用 Event.unitKey(类型/拥有者/UserData/坐标)。
    local list, n = {}, 0
    for hid, entry in pairs(_deadUnits) do
        entry.ticks = entry.ticks - 1

        if entry.ticks <= 0 then
            n = n + 1
            list[n] = { hid = hid, entry = entry }
        end
    end

    local nCleaned = 0
    if n > 0 then
        -- [PROBE] 周期清理分步计数（双机 console diff 定位：哪一步的数量两机不等 → 分叉点）
        _G._PT = _G._PT or {}; _G._PT.clDead = (_G._PT.clDead or 0) + n
        -- ★ 排序键带 seq tie-break：unitKey 含坐标/类型/ud，同出生于中心点且未移动的单位会撞 key，
        --   相等键 sort 不稳定 + pairs 哈希序机器相关 → 两机销毁顺序可能分叉；seq（死亡事件序）兜底保证全序
        for i = 1, n do
            list[i].uk  = Event.unitKey(list[i].entry.handle)
            list[i].tuk = list[i].uk .. string.format("|%010d", list[i].entry.seq or 0)
        end
        table.sort(list, function(a, b) return a.tuk < b.tuk end)
        for i = 1, n do
            local hid, entry = list[i].hid, list[i].entry
            local h = entry.handle
            -- 15 秒后仍保持死亡状态 → 清除绑定触发器并销毁单位
            if _isStillDead(h) then
                _G._PT = _G._PT or {}; _G._PT.destroyUnitLastKey = list[i].uk  -- [PROBE] 金丝雀：纯机器无关键（去除 hid 后缀，避免污染跨机 diff）
                nCleaned = nCleaned + 1
                pcall(_finalizeDeadUnit, h)
            end
            -- 无论是否删除，都从表中移除（避免重复处理 / 句柄复用污染）
            _deadUnits[hid] = nil
        end
    end

    -- 每 30 秒输出一次统计摘要（配合 3s 扫描周期，每 10 次输出一次）
    _cleanupStats.lastLogTime = (_cleanupStats.lastLogTime or 0) + 1
    if _cleanupStats.lastLogTime % 10 == 0 then
        local utSize, duSize, ddSize = 0, 0, 0
        local abSize = 0
        for _ in pairs(_unitTriggers) do utSize = utSize + 1 end
        for _ in pairs(_dmgUnits) do duSize = duSize + 1 end
        for _ in pairs(_deadUnits) do ddSize = ddSize + 1 end
        for _ in pairs(_allUnitBindings) do abSize = abSize + 1 end
        -- dbg(string.format(
        --     "[Event.cleanup.30s] _unitTriggers=%d | _allUnitBindings=%d(全局绑定) | " ..
        --     "_dmgUnits=%d | _deadUnits=%d(待清理) | " ..
        --     "clearUnitTriggers调用%d次 反向扫描%d次(累计兜底销毁%d黑户) 累计总销毁trigger=%d个",
        --     utSize, abSize, duSize, ddSize,
        --     _cleanupStats.clearUnitTriggersCalls,
        --     _cleanupStats.reverseSweepCalls,
        --     _cleanupStats.reverseSweepCleaned,
        --     _cleanupStats.triggersDestroyed
        -- ))
        -- 同时输出事件分布诊断（见 Event.dumpTriggerEvents）
        -- Event.dumpTriggerEvents()
    end
end

-----------------------------------------------------------------
-- ★ 反向扫描（万能兜底清理）
--   遍历全局绑定表 _allUnitBindings 中所有 [trigger → unit] 记录，
--   检查单位是否已被引擎移除（GetUnitTypeId == 0）。
--   若单位已移除 → 销毁触发器并清除记录。
--   这能捕获所有"创建了触发器绑到单位、但从不走 Event:destroy / clearUnitTriggers"
--   的黑户路径——不管谁创建的、走哪条代码，只要通过 TriggerRegisterUnitEvent 绑了单位，
--   就会被本函数兜住销毁。
-----------------------------------------------------------------
local function isTriggerDestroyed(trig)
    if trig == nil then return true end
    local ok, enabled = pcall(cj.IsTriggerEnabled, trig)
    return not ok or enabled == nil
end

local function reverseSweepTriggers()
    _cleanupStats.reverseSweepCalls = _cleanupStats.reverseSweepCalls + 1
    local cleanedThisRound = 0
    local toRemoveUnit = {}
    local toRemovePlayer = {}

    -- ★ 确定性销毁顺序（desync）：_allUnitBindings 以 trigger(userdata) 作 key，
    -- Lua 按内存地址哈希 userdata，两台机器地址不同 -> pairs 顺序必然不同。
    -- 这里直接 DestroyTrigger，销毁顺序不同会让 War3 的 handle id 回收/复用顺序
    -- 各机错开，后续新建的 trigger/unit 拿到的 id 全面错位 -> desync。
    -- 注意：DesyncGuard 对 userdata 参数只按"类型"哈希，两次 DestroyTrigger 在
    -- 流指纹里长得一模一样，这类顺序分叉指纹检测不到，必须在源头保证有序。
-- ★ 排序键必须机器无关：按绑定的【单位】排序（类型/拥有者/UserData/坐标），
        --   触发器的 handle id 是机器本地的（双机已错位时按 hid 排序顺序仍会分叉）；
        --   无绑定单位（rec.unit==nil）的记录以类型/事件名兜底排序。
        --   seq tie-break：同 key 记录（同单位多触发器/同事件无主绑定）按登记序兜底，防 sort 分叉
    local sweepList, sweepN = {}, 0
    for trig, rec in pairs(_allUnitBindings) do
        sweepN = sweepN + 1
        local unitHandle = (type(rec) == "table") and rec.unit or rec
        local ukey
        if unitHandle ~= nil then
            ukey = Event.unitKey(unitHandle)
        else
            local ev = (type(rec) == "table") and tostring(rec.event or 0) or tostring(rec)
            ukey = "z" .. ev
        end
        local seq = (type(rec) == "table") and (rec.seq or 0) or 0
        sweepList[sweepN] = { trig = trig, rec = rec, tuk = ukey .. string.format("|%010d", seq) }
    end
    table.sort(sweepList, function(a, b) return a.tuk < b.tuk end)

    for _, e in ipairs(sweepList) do
        local trig, rec = e.trig, e.rec
        local unitHandle = (type(rec) == "table") and rec.unit or rec
        if unitHandle ~= nil then
            if isUnitRemoved(unitHandle) then
                cj.TriggerClearActions(trig)
                cj.DestroyTrigger(trig)
                toRemoveUnit[#toRemoveUnit + 1] = trig
                cleanedThisRound = cleanedThisRound + 1
            end
        else
            toRemoveUnit[#toRemoveUnit + 1] = trig
        end
    end

    for trig in pairs(_allPlayerBindings) do
        if isTriggerDestroyed(trig) then
            toRemovePlayer[#toRemovePlayer + 1] = trig
            cleanedThisRound = cleanedThisRound + 1
        end
    end

    for _, trig in ipairs(toRemoveUnit) do
        _allUnitBindings[trig] = nil
    end
    for _, trig in ipairs(toRemovePlayer) do
        _allPlayerBindings[trig] = nil
    end

    if cleanedThisRound > 0 then
        -- [PROBE] 周期清理分步计数（双机 console diff 定位：哪一步的数量两机不等 → 分叉点）
        _G._PT = _G._PT or {}; _G._PT.clSweep = (_G._PT.clSweep or 0) + cleanedThisRound
        _cleanupStats.reverseSweepCleaned = _cleanupStats.reverseSweepCleaned + cleanedThisRound
        _cleanupStats.triggersDestroyed = _cleanupStats.triggersDestroyed + cleanedThisRound
        local abSize = 0
        for _ in pairs(_allUnitBindings) do abSize = abSize + 1 end
        local pbSize = 0
        for _ in pairs(_allPlayerBindings) do pbSize = pbSize + 1 end
        dbg(string.format(
            "[Event.reverseSweep] 本轮销毁 %d 个孤儿触发器 | 剩余单位绑定=%d | 玩家绑定=%d | 累计兜底销毁=%d",
            cleanedThisRound, abSize, pbSize, _cleanupStats.reverseSweepCleaned
        ))
    end

    return cleanedThisRound
end

-----------------------------------------------------------------
-- ★ 诊断函数：按事件类型列出当前所有"活着"的绑定触发器分布
--   目的：定位"到底是哪些事件在堆积、处理不掉"（用户需求）。
--   两类输出：
--     [A] per-unit 绑定（TriggerRegisterUnitEvent）：每个事件类型共绑定多少，
--         其中单位【存活】/【已移除】各多少（已移除=孤儿，本应被反向扫描销毁）
--     [B] player 绑定（TriggerRegisterPlayerUnitEvent，Event:new 全局/玩家事件走这里）：
--         每个事件类型多少个（这类没有具体单位，无法按"单位生死"判断，是黑户主力嫌疑）
--   可在控制台执行 Event.dumpTriggerEvents() 随时查看，也会纳入 30s 周期日志。
-----------------------------------------------------------------
function Event.dumpTriggerEvents()
    -- [A] per-unit 绑定
    local byUnitEvent = {}   -- name -> { total, alive, removed }
    local uTotal, uAlive, uRemoved = 0, 0, 0
    for trig, rec in pairs(_allUnitBindings) do
        local en = _eventName(rec and rec.event)
        local t = byUnitEvent[en] or { total = 0, alive = 0, removed = 0 }
        t.total = t.total + 1
        if rec and rec.unit ~= nil and not isUnitRemoved(rec.unit) then
            t.alive = t.alive + 1
            uAlive = uAlive + 1
        else
            t.removed = t.removed + 1
            uRemoved = uRemoved + 1
        end
        byUnitEvent[en] = t
        uTotal = uTotal + 1
    end

    -- [B] player 绑定（Event:new 全局/玩家事件）
    local byPlayerEvent = {}
    local pTotal = 0
    for trig, rec in pairs(_allPlayerBindings) do
        local en = _eventName(rec and rec.event)
        byPlayerEvent[en] = (byPlayerEvent[en] or 0) + 1
        pTotal = pTotal + 1
    end

    print(string.format("[Event.dump] === 触发器事件分布 ==="))
    print(string.format("[Event.dump] [A] per-unit绑定 共%d (单位存活%d / 已移除%d)", uTotal, uAlive, uRemoved))
    local arrA = {}
    for k, v in pairs(byUnitEvent) do arrA[#arrA + 1] = { k, v } end
    table.sort(arrA, function(a, b) return a[2].total > b[2].total end)
    for _, e in ipairs(arrA) do
        print(string.format("[Event.dump]   %s : 共%d (存活%d/已移除%d)", e[1], e[2].total, e[2].alive, e[2].removed))
    end

    print(string.format("[Event.dump] [B] player绑定(全局/玩家事件) 共%d", pTotal))
    local arrB = {}
    for k, v in pairs(byPlayerEvent) do arrB[#arrB + 1] = { k, v } end
    table.sort(arrB, function(a, b) return a[2] > b[2] end)
    for _, e in ipairs(arrB) do
        print(string.format("[Event.dump]   %s : %d", e[1], e[2]))
    end
end

-- 合并的周期清理：每 2 秒执行一次
--   [BISECT] _G.CLEAN_REMOVED_OFF / CLEAN_DEAD_OFF / CLEAN_SWEEP_OFF 可单独关闭某步定位 desync 源
local function periodicCleanup()
    if not _G.CLEAN_REMOVED_OFF then
        cleanupRemovedUnits()
    end
    if not _G.CLEAN_DEAD_OFF then
        scanDeadUnits()
    end
    if not _G.CLEAN_SWEEP_OFF then
        reverseSweepTriggers()
    end
end

-- 延迟 0.5s 启动，确保所有依赖模块（Timer/Unit/Event）已就绪
Timer:new(0.5, false, function()
    -- 监听任意单位死亡（e.unit 由 Event 元表映射为 cj.GetTriggerUnit()）
    -- [SUSPICIOUS] 中风险：_deadUnits 登记由 3s 扫描驱动 → 跨机统一销毁单位/释放原生句柄；
    --              登记集合跨机必须逐条一致，否则一机销毁而另一机未销毁 → 句柄ID错位 → 强 desync
    Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(e)
        if not _G.DEAD_CLEAN_ENABLED then return end  -- 死亡清理记账总开关（lua.lua）
        local dyingHandle = e.unit
        if dyingHandle == nil then return end

        -- 英雄等特殊单位不纳入清理
        if _deadShouldSkip(dyingHandle) then return end

        local hid = cj.GetHandleId(dyingHandle)
        if hid == nil or hid == 0 then return end

        -- 已在表中则不重复加入
        if _deadUnits[hid] ~= nil then return end

        -- 登记死亡单位，赋予 15 秒（5 次扫描）超时；seq=死亡事件序（跨机一致，排序兜底键）
        _deadUnits[hid] = {
            handle = dyingHandle,
            ticks  = DEAD_CLEAN_TICKS,
            seq    = nextMachineSeq(),
        }
        _G._PT = _G._PT or {}; _G._PT.deadq = (_G._PT.deadq or 0) + 1  -- [PROBE] 临时诊断
    end)

    -- 周期扫描：每 3 秒判断一次，同时清理已移除单位和死亡单位
    if _G.DEAD_CLEAN_ENABLED then  -- 总开关开启：周期清理链(清理已移除单位/死亡超时/反向孤儿扫描)启动
        Timer:new(DEAD_CLEAN_INTERVAL, true, periodicCleanup)
    end
end)