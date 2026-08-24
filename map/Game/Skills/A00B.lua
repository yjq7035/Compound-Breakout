-- ============================================================
-- A00B 狂暴恢复 — 通过 Unit:addBuff 实现
--
-- 技能模板：A00B (_parent = ANcl, Order = banish, Rng = 0)
-- 效果：释放时获得生命恢复速度加成，持续 10 秒
--   等级 1: 50  点/秒
--   等级 2: 100 点/秒
--   等级 3: 150 点/秒
--
-- 实现方式：
--   监听 EVENT_PLAYER_UNIT_SPELL_EFFECT (spellId == A00B)
--   施法者 Unit:addBuff(B00B, 10, onGain, onLose)
--   onGain 启动周期治疗 Timer (0.25s 一跳)，onLose 销毁 Timer
--   重复施法时先清理旧 buff/旧 Timer 再重新施加，保证等级更新
--
-- 依赖：
--   Base: Unit, Event, Timer, Effect (通过 Unit:addBuff 间接)
--   Obj : buff B00B 需在 table/buff.ini 中定义 targetart/targetattach
-- ============================================================

local A00B_ID = c2i("A00B")
local B00B_ID = c2i("B00B")

-- 每级每秒恢复量（与 ability.ini Researchubertip/Ubertip 保持一致）
local REGEN_PER_LEVEL = { 50, 100, 150 }
local DURATION = 10.0        -- 持续 10 秒
local TICK = 0.25            -- 治疗间隔（秒），越小越平滑

-- 对单个 Unit 施加/刷新回血 buff
local function applyBerserkHeal(casterHandle, level)
    if casterHandle == nil then return end
    local u = Unit.fromHandle(casterHandle)
    if u == nil then return end

    level = level or cj.GetUnitAbilityLevel(casterHandle, A00B_ID)
    if level <= 0 then level = 1 end
    if level > #REGEN_PER_LEVEL then level = #REGEN_PER_LEVEL end
    local regen = REGEN_PER_LEVEL[level]
    local healPerTick = regen * TICK

    -- 若已存在旧 buff，先清理旧 Timer 并移除 buff（保证 onLose 被精确调用且 regen 更新）
    if u:isBuff(B00B_ID) then
        -- 手动清理上一次的治疗 Timer（onLose 也会清理，双重保险）
        if u._data._A00B_healTimer ~= nil then
            pcall(function() u._data._A00B_healTimer:destroy() end)
            u._data._A00B_healTimer = nil
        end
        u:removeBuff(B00B_ID)
    end

    local function onGain(unitObj)
        -- 启动周期治疗 Timer
        -- 用局部变量持有 Timer，onLose 通过 unitObj._data 找回并销毁
        local t = Timer:new(TICK, true, function()
            -- 单位已死亡/已移除则自毁
            if unitObj._handle == nil then
                if t then t:destroy() end
                return
            end
            if cj.GetUnitTypeId(unitObj._handle) == 0 then
                if t then t:destroy() end
                return
            end
            if cj.IsUnitType(unitObj._handle, UNIT_TYPE_DEAD) then
                return
            end
            local cur = cj.GetWidgetLife(unitObj._handle)
            local maxLife = cj.GetUnitState(unitObj._handle, UNIT_STATE_MAX_LIFE)
            if cur < maxLife then
                local newLife = cur + healPerTick
                if newLife > maxLife then newLife = maxLife end
                cj.SetWidgetLife(unitObj._handle, newLife)
            end
        end)
        unitObj._data._A00B_healTimer = t
        unitObj._data._A00B_regen = regen
    end

    local function onLose(unitObj)
        local t = unitObj._data._A00B_healTimer
        if t ~= nil then
            pcall(function() t:destroy() end)
            unitObj._data._A00B_healTimer = nil
        end
        unitObj._data._A00B_regen = nil
    end

    -- 非叠加模式（stack = false/nil）：单层 buff，重复施法通过上方 remove 再 add 实现刷新
    u:addBuff(B00B_ID, DURATION, onGain, onLose, false)
end

-- 全局监听：任意单位释放 A00B 时触发
Event:new(nil, EVENT_PLAYER_UNIT_SPELL_EFFECT, function(ev)
    if ev.spellId ~= A00B_ID then return end
    local caster = ev.unit
    if caster == nil then return end
    local lvl = cj.GetUnitAbilityLevel(caster, A00B_ID)
    applyBerserkHeal(caster, lvl)
end)

-- 可选：导出供外部调用（如测试、其他系统联动）
A00B_Skill = {
    apply = applyBerserkHeal,
    regenTable = REGEN_PER_LEVEL,
    duration = DURATION,
    buffId = B00B_ID,
    abilityId = A00B_ID,
}
