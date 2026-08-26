-- ============================================================
-- Unit 类 — 单位
-- 调用方式：
--   local p = Player:new(0)
--   local u = Unit:new(p, 'hfoo', 0, 0, 270)
--   u:setName("步兵")
--   u:setLife(500)
--   u:order("move", 100, 200)
--   u:destroy()
--
--   Unit.embed(hUnit, { id = "hfoo" })  -- 单位注册到框架
-- ============================================================

---@class Unit 单位
Unit = {}
Unit.__index = Unit

---@class UnitState 单位状态
Unit._handle = nil
---@class integer
Unit._index = nil
--- 单位ID
Unit._id = nil


Unit.state = {
    -- 物理暴击率
    critPhys = 0.,
    -- 法术暴击率
    critMag = 0.,
    -- 移动速度溢出量（超出[1,520]限制的部分）
    moveSpeed = nil,
    -- 移动速度期望值（用于 resetMoveSpeed 还原）
    _moveSpeedDesired = nil,
    -- 物理爆伤率
    critDmgPhys = 0.,
    -- 法术爆伤率
    critDmgMag = 0.,
    --魔法抗性
    resMag = 0.,
    --魔法穿透
    penMag = 0.,
    --物理穿透
    penPhys = 0.,
    -- 缩放
    scale = nil,
    -- 攻击强化
    attackStr = 0.,
    -- 魔法强化（仅魔法伤害生效，由 GameDamage 读取：每1000点 = +100% 魔法伤害）
    magicAmp = 0.,

}
Unit._data = {}

-- 单位框架映射表
local unitMap = {}

-- fromHandle 对象缓存（handle → Unit 对象）
-- 保证同一 handle 返回同一 Lua 对象，避免 _data 丢失
-- 注意：不能用弱引用值模式（__mode="v"）。applyMonsterStats 等会把 resMag/penPhys/penMag
-- 等自定义战斗属性写到 Unit.state 上；若函数返回后该 Unit 对象仅被弱表引用，GC 会回收它，
-- 下次伤害结算 Unit.fromHandle(targetHandle) 会重建对象并丢失这些属性（表现为护甲生效、魔抗/穿透丢失）。
-- 改为强引用表；handle id 复用时 fromHandle 会校验 _handle 并重建，旧死对象自然被覆盖，不会泄漏。
local fromHandleCache = {}

------------------------------------------------------------------
-- 内部工厂 / 工具
------------------------------------------------------------------
local function newUnit()
    local obj = { _handle = nil, _index = nil, _id = nil, _type = nil, _data = {}, _shopItems = {}, state = {} }
    -- 从 Unit.state 复制默认值到实例（避免类级别共享）
    for k, v in pairs(Unit.state) do
        obj.state[k] = v
    end
    setmetatable(obj, Unit)
    return obj
end

--- 从 Player/Unit 对象或裸 handle/ID 中提取 handle
---@param obj table|userdata|number|nil Player对象 | Unit对象 | handle | 玩家ID (0-23)
---@return userdata|nil
local function resolveHandle(obj)
    if (obj == nil) then return nil end
    if (type(obj) == "number") then
        -- 原始玩家ID（0-23）→ 转为 player handle
        return cj.Player(obj)
    end
    if (type(obj) == "table") then
        -- Player: ._handle
        -- Unit:   ._handle
        if (obj._handle ~= nil) then return obj._handle end
    end
    return obj -- 已有 handle，直接返回
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建单位到坐标
---@param pl Player|userwdata 玩家对象 或 玩家handle
---@param unitId integer|string 单位ID
---@param x number X坐标
---@param y number Y坐标
---@param facing number|nil 面向角度（默认 bj_UNIT_FACING）
---@return Unit
function Unit:new(pl, unitId, x, y, facing)
    if (pl == nil or unitId == nil) then return end
    local p = resolveHandle(pl)
    if (type(unitId) == "string") then unitId = c2i(unitId) end
    facing = facing or bj_UNIT_FACING

    local obj = newUnit()
    obj._handle = cj.CreateUnit(p, unitId, x, y, facing)
    -- 创建失败（如 handle 溢出）返回 nil，避免后续对 nil 调 GetHandleId 报错
    if (obj._handle == nil) then return nil end
    _G._PT = _G._PT or {}; _G._PT.unit = (_G._PT.unit or 0) + 1  -- [PROBE] 临时诊断
    _G._PT.unitLastId = cj.GetHandleId(obj._handle)  -- [PROBE] 金丝雀：最新单位句柄ID（跨机对照 id 流）
    obj._index = cj.GetHandleId(obj._handle)
    obj._id = unitId
    obj._type = i2c(unitId)
    Unit.embed(obj._handle, { id = obj._type })
    fromHandleCache[obj._index] = obj

    -- 自动注册伤害触发器（如果伤害系统已就绪）
    Event.registerDamageUnit(obj._handle)

    -- [LAN-SYNC] 主动注册到底层单位池：与 Hero 创建一致，创建即入池，
    -- 不依赖引擎 EnterRegion 事件（事件驱动入池的时机无法保证跨机一致，
    -- 会导致 enumRange 枚举集合在词条等系统的观察下分叉 → desync）
    Group.registerPoolUnit(obj._handle)

    return obj
end

--- 从已有handle创建 Unit 对象
---@param h userdata 单位handle
---@return Unit, userdata
function Unit.fromHandle(h)
    if (h == nil) then return end
    local key = cj.GetHandleId(h)
    local cached = fromHandleCache[key]
    if cached and cached._handle == h then
        return cached, h
    end
    local obj = newUnit()
    obj._handle = h
    obj._index = key
    obj._id = cj.GetUnitTypeId(h)
    obj._type = i2c(obj._id)
    fromHandleCache[key] = obj
    return obj, h
end

--- 销毁单位
---@param delay number|nil 延迟秒数（默认0=立即）
---@return Unit
function Unit:destroy(delay)
    if (self._handle == nil) then return self end
    _G._PT = _G._PT or {}; _G._PT.unitRemove = (_G._PT.unitRemove or 0) + 1  -- [PROBE] 单位销毁/移除计数
    if self._index then
        fromHandleCache[self._index] = nil
    end
    delay = delay or 0
    if (delay <= 0) then
        Group.unregisterPoolUnit(self._handle)
        cj.RemoveUnit(self._handle)
        self._handle = nil
    else
        Timer:new(delay, false, function()
            if (self._handle ~= nil) then
                if self._index then
                    fromHandleCache[self._index] = nil
                end
                Group.unregisterPoolUnit(self._handle)
                cj.RemoveUnit(self._handle)
                self._handle = nil
            end
        end)
    end
    return self
end

--- 杀死单位
---@return Unit
function Unit:kill()
    if (self._handle ~= nil) then
        cj.KillUnit(self._handle)
    end
    return self
end

--- 判断单位是否有效
---@return boolean
function Unit:isValid()
    return self._handle ~= nil
end

-----------------------------------------------------------------
-- 框架注册
-----------------------------------------------------------------

--- 将单位handle注册到框架映射表
---@param h userdata 单位handle
---@param data table 附加数据 { id = string }
function Unit.embed(h, data)
    if (h == nil) then return end
    local key = cj.GetHandleId(h)
    unitMap[key] = data or {}
end

--- 获取注册的框架数据
---@param h userdata 单位handle
---@return table|nil
function Unit.getData(h)
    if (h == nil) then return end
    return unitMap[cj.GetHandleId(h)]
end

--- 从框架映射中移除
---@param h userdata 单位handle
function Unit.removeData(h)
    if (h == nil) then return end
    unitMap[cj.GetHandleId(h)] = nil
end

-----------------------------------------------------------------
-- 标识
-----------------------------------------------------------------

--- 获取单位ID（数字）
---@return integer
function Unit:getId()
    if (self._handle == nil) then return 0 end
    return self._index or cj.GetUnitTypeId(self._handle)
end

--- 获取单位ID（四字符码）
---@return string|nil
function Unit:getTypeCode()
    return self._type
end

--- 获取单位名称
---@return string
function Unit:getName()
    if (self._handle == nil) then return "" end
    return cj.GetUnitName(self._handle)
end

--- 设置单位名称（DzAPI 扩展）
---@param name string
---@return Unit
function Unit:setName(name)
    if (self._handle ~= nil and name ~= nil) then
        cdz.DzSetUnitName(self._handle, name)
    end
    return self
end

--- 获取英雄称谓（如 "大魔法师"）
---@return string
function Unit:getProperName()
    if (self._handle == nil) then return "" end
    return cj.GetHeroProperName(self._handle)
end

--- 设置英雄称谓（DzAPI 扩展）
---@param name string
---@return Unit
function Unit:setProperName(name)
    if (self._handle ~= nil and name ~= nil) then
        cdz.DzSetUnitProperName(self._handle, name)
    end
    return self
end

--- 获取单位等级
---@return integer
function Unit:getLevel()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitLevel(self._handle)
end

--- 获取单位种族
---@return race
function Unit:getRace()
    if (self._handle == nil) then return end
    return cj.GetUnitRace(self._handle)
end

--- 获取单位自定义值
---@return integer
function Unit:getUserData()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitUserData(self._handle)
end

--- 设置单位自定义值
---@param val integer
---@return Unit
function Unit:setUserData(val)
    if (self._handle ~= nil) then
        cj.SetUnitUserData(self._handle, val)
    end
    return self
end

-----------------------------------------------------------------
-- 所有者
-----------------------------------------------------------------

--- 获取单位所有者
---@return Player
function Unit:getOwner()
    if (self._handle == nil) then return end
    return Player.fromHandle(cj.GetOwningPlayer(self._handle))
end

--- 改变单位所有者
---@param pl Player|userdata 新所有者（Player 对象 或 玩家handle）
---@param changeColor boolean 是否改变颜色
---@return Unit
function Unit:setOwner(pl, changeColor)
    if (self._handle ~= nil) then
        cj.SetUnitOwner(self._handle, resolveHandle(pl), (changeColor ~= nil) and changeColor or true)
    end
    return self
end

-----------------------------------------------------------------
-- 位置
-----------------------------------------------------------------

--- 获取X坐标
---@return number
function Unit:getX()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitX(self._handle)
end

--- 获取Y坐标
---@return number
function Unit:getY()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitY(self._handle)
end

--- 获取Z轴高度（DzAPI 扩展）
---@return number
function Unit:getZ()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetUnitZ(self._handle)
end

--- 移动单位到坐标（可触发事件）
---@param x number
---@param y number
---@return Unit
function Unit:setPosition(x, y)
    if (self._handle ~= nil) then
        cj.SetUnitPosition(self._handle, x, y)
    end
    return self
end

--- 设置X坐标（不触发事件）
---@param x number
---@return Unit
function Unit:setX(x)
    if (self._handle ~= nil) then
        cj.SetUnitX(self._handle, x)
    end
    return self
end

--- 设置Y坐标（不触发事件）
---@param y number
---@return Unit
function Unit:setY(y)
    if (self._handle ~= nil) then
        cj.SetUnitY(self._handle, y)
    end
    return self
end

--- 获取面向角度
---@return number
function Unit:getFacing()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitFacing(self._handle)
end

--- 设置面向角度
---@param angle number
---@return Unit
function Unit:setFacing(angle)
    if (self._handle ~= nil) then
        cj.SetUnitFacing(self._handle, angle)
    end
    return self
end

--- 设置面向角度（限时）
---@param angle number
---@param duration number
---@return Unit
function Unit:setFacingTimed(angle, duration)
    if (self._handle ~= nil) then
        cj.SetUnitFacingTimed(self._handle, angle, duration or 0)
    end
    return self
end

--- 获取当前飞行高度
---@return number
function Unit:getFlyHeight()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitFlyHeight(self._handle)
end

--- 设置飞行高度
---@param height number 目标高度
---@param rate number 变化速率
---@return Unit
function Unit:setFlyHeight(height, rate)
    if (self._handle ~= nil) then
        --检查单位是否有Amrf技能，没有则添加
        if self.state.amrf == nil then
            self.state.amrf = true
            self:addAbility("Amrf")
            self:removeAbility("Amrf")
        end 
        cj.SetUnitFlyHeight(self._handle, height, rate or 0)
    end
    return self
end

--- 获取移动速度（返回自定义设置的目标速度，未设置时回退到引擎原生值；不受原生移动buff干扰）
---@return number
function Unit:getMoveSpeed()
    if self.state._moveSpeedDesired ~= nil then
        return self.state._moveSpeedDesired
    end
    if self._handle ~= nil then
        return cj.GetUnitMoveSpeed(self._handle)
    end
    return 300
end

--- 设置移动速度（存入目标值，引擎值 clamp 到 [1, 520]）
---@param speed number
---@return Unit
function Unit:setMoveSpeed(speed)
    local actualSpeed = math.max(1, math.min(520, speed))
    self.state._moveSpeedDesired = speed
    if self._handle ~= nil then
        cj.SetUnitMoveSpeed(self._handle, actualSpeed)
    end
    return self
end

--- 增加/减少移动速度（基于内存值加减，不受520上限累积干扰）
---@param delta number 正数=加速，负数=减速
---@return Unit
function Unit:addMoveSpeed(delta)
    return self:setMoveSpeed(self:getMoveSpeed() + delta)
end

--- 恢复移动速度到期望值（用于临时加减速后还原）
---@return Unit
function Unit:resetMoveSpeed()
    if self.state._moveSpeedDesired ~= nil then
        self:setMoveSpeed(self.state._moveSpeedDesired)
    end
    return self
end

--- 获取默认移动速度
---@return number
function Unit:getDefaultMoveSpeed()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitDefaultMoveSpeed(self._handle)
end

--- 获取攻击范围
---@return number
function Unit:getAcquireRange()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitAcquireRange(self._handle)
end

--- 设置攻击范围
---@param range number
---@return Unit
function Unit:setAcquireRange(range)
    if (self._handle ~= nil) then
        cj.SetUnitAcquireRange(self._handle, range)
    end
    return self
end

--- 获取转身速度
---@return number
function Unit:getTurnSpeed()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitTurnSpeed(self._handle)
end

--- 设置转身速度
---@param speed number
---@return Unit
function Unit:setTurnSpeed(speed)
    if (self._handle ~= nil) then
        cj.SetUnitTurnSpeed(self._handle, speed)
    end
    return self
end

--- 获取碰撞体积（DzAPI 扩展）
---@return number
function Unit:getCollisionSize()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetUnitCollisionSize(self._handle)
end

--- 设置碰撞体积（DzAPI 扩展）
---@param size number
---@return Unit
function Unit:setCollisionSize(size)
    if (self._handle ~= nil) then
        cdz.DzSetUnitCollisionSize(self._handle, size)
    end
    return self
end

--- 获取头顶高度偏移（DzAPI 扩展）
---@return number
function Unit:getOverheadOffset()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetUnitOverheadOffset(self._handle)
end


-----------------------------------------------------------------
-- 生命 / 魔法 / 状态
-----------------------------------------------------------------
--- 获取单位属性
---@param state unitstate 状态类型
---@return number
function Unit:getState(state)
    if (self._handle == nil) then return 0 end
    return cj.GetUnitState(self._handle, state)
end

--- 设置单位属性
---@param state unitstate
---@param val number
---@return Unit
function Unit:setState(state, val)
    cj.SetUnitState(self._handle, state, val)
    return self
end

--- 增加单位属性(用负数来减少)
---@param state unitstate
---@param val number
---@return Unit
function Unit:addState(state, val)
    cj.SetUnitState(self._handle, state, cj.GetUnitState(self._handle, state) + val)
    return self
end

--- 暂停/恢复单位
---@param flag boolean true=暂停
---@return Unit
function Unit:pause(flag)
    if (self._handle ~= nil) then
        cj.PauseUnit(self._handle,flag)
    end
    return self
end

--- 是否暂停
---@return boolean
function Unit:isPaused()
    if (self._handle == nil) then return false end
    return cj.IsUnitPaused(self._handle)
end

--- 显示/隐藏单位
---@param show boolean
---@return Unit
function Unit:show(show)
    if (self._handle ~= nil) then
        cj.ShowUnit(self._handle, (show ~= nil) and show or true)
    end
    return self
end

--- 是否隐藏
---@return boolean
function Unit:isHidden()
    if (self._handle == nil) then return false end
    return cj.IsUnitHidden(self._handle)
end

--- 设置无敌/可攻击
---@param flag boolean true=无敌
---@return Unit
function Unit:setInvulnerable(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cj.SetUnitInvulnerable(self._handle, flag)
    end
    return self
end

--- 设置碰撞开关
---@param flag boolean true=有碰撞
---@return Unit
function Unit:setPathing(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cj.SetUnitPathing(self._handle, flag)
    end
    return self
end

-----------------------------------------------------------------
-- 命令
-----------------------------------------------------------------

--- 发布命令（无目标）
---@param order string|integer 命令
---@return boolean
function Unit:order(order)
    if (self._handle == nil) then return false end
    if (type(order) == "string") then
        return cj.IssueImmediateOrder(self._handle, order)
    else
        return cj.IssueImmediateOrderById(self._handle, order)
    end
end

--- 发布命令到坐标
---@param order string|integer
---@param x number
---@param y number
---@return boolean
function Unit:orderPoint(order, x, y)
    if (self._handle == nil) then return false end
    if (type(order) == "string") then
        return cj.IssuePointOrder(self._handle, order, x, y)
    else
        return cj.IssuePointOrderById(self._handle, order, x, y)
    end
end

--- 发布命令到目标单位
---@param order string|integer
---@param target Unit 目标widget 或 Unit 对象
---@return boolean
function Unit:orderTarget(order, target)
    if (self._handle == nil) then return false end
    if (type(order) == "string") then
        return cj.IssueTargetOrder(self._handle, order, target._handle)
    else
        return cj.IssueTargetOrderById(self._handle, order, target._handle)
    end
end

--- 发布建造命令
---@param unitId integer|string 要建造的单位ID
---@param x number
---@param y number
---@return boolean
function Unit:build(unitId, x, y)
    if (self._handle == nil) then return false end
    if (type(unitId) == "string") then unitId = c2i(unitId) end
    return cj.IssueBuildOrderById(self._handle, unitId, x, y)
end

--- 移动
---@param x number
---@param y number
---@return boolean
function Unit:move(x, y)
    return self:orderPoint("move", x, y)
end

--- 攻击移动
---@param x number
---@param y number
---@return boolean
function Unit:attack(x, y)
    return self:orderPoint("attack", x, y)
end

--- 攻击目标
---@param target Unit 目标widget 或 Unit 对象
---@return boolean
function Unit:attackTarget(target)
    return self:orderTarget("attack", target)
end

--- 停止
---@return boolean
function Unit:stop()
    return self:order("stop")
end

--- 保持原位
---@return boolean
function Unit:hold()
    return self:order("holdpos")
end

--- 获取当前命令ID
---@return integer
function Unit:getCurrentOrder()
    if (self._handle == nil) then return 0 end
    return cj.GetUnitCurrentOrder(self._handle)
end

-----------------------------------------------------------------
-- buff 模拟系统（纯特效，与晕眩共用同一全局计时器）
-----------------------------------------------------------------

-- 永久 buff 阈值：持续时间超过此值视为永久，不进入冷却计时逻辑
local PERMANENT_DURATION_THRESHOLD = 600  -- 10 分钟

-- 全局 buff 注册表
local _buffLookup = {}   -- 查找表（所有拥有 buff 的单位，供 getBuffedUnit 使用）
local buffedUnits = {}   -- 计时扫描表（仅包含拥有限时层的单位）
-- 全局晕眩注册表 & 全局计时器（所有受击单位共用）
local stunnedUnits = {}      -- key = unit._index, value = unit 对象
local stunGlobalTimer = nil
-- 预分配表，避免每 0.1 秒创建新表产生 GC 垃圾
local _nextStunned = {}
local _nextBuffed = {}

-- [LAN-SYNC] 注册序号追踪：跨机一致的确定性排序键
-- 原理：GetHandleId 跨机不同 → pairs() 遍历序不确定 → onLose 执行序分叉 → desync
-- 解法：用单调递增注册序号排序数组替代 pairs() 遍历，确保跨机迭代序一致
local _tickRegSeq = 0
local _tickReg = {}          -- _index -> 唯一递增序号

-- 排序数组（按注册序号排列，配合 swap 双表使用）
local _stunSorted = {}       -- 当前 tick 晕眩有序数组
local _nextStunSorted = {}   -- 下一 tick 晕眩有序数组
local _buffSorted = {}       -- 当前 tick buff 有序数组
local _nextBuffSorted = {}   -- 下一 tick buff 有序数组
local _lookupSorted = {}     -- _buffLookup 有序数组（死亡清理用）

--- 在排序数组中按注册序号插入（维护确定性顺序）
local function _sortedInsert(unit, arr)
    local seq = _tickReg[unit._index] or 0
    local n = #arr
    local pos = n + 1
    for i = n, 1, -1 do
        if (_tickReg[arr[i]._index] or 0) > seq then
            pos = i
        else
            break
        end
    end
    for i = n, pos, -1 do
        arr[i + 1] = arr[i]
    end
    arr[pos] = unit
end

--- 从排序数组移除（table.remove 自动前移，保持顺序）
local function _sortedRemove(idx, arr)
    for i = #arr, 1, -1 do
        if arr[i]._index == idx then
            table.remove(arr, i)
            break
        end
    end
end

--- 注册单位（分配序号 + 插入排序数组）
local function _tickRegUnit(idx, unit, sortedArr)
    if _tickReg[idx] == nil then
        _tickRegSeq = _tickRegSeq + 1
        _tickReg[idx] = _tickRegSeq
    end
    _sortedInsert(unit, sortedArr)
end

local function _clearTable(t)
    for k in pairs(t) do t[k] = nil end
end

local function stunGlobalTick()
    -- ---- 处理晕眩 ----
    _clearTable(_nextStunned)
    local _nextStunIdx = 1
    local hasStunActive = false

    for _, unit in ipairs(_stunSorted) do
        local idx = unit._index
        if (unit._handle == nil) then
            unit._data.stunLayers = {}
            unit._data.stunCounter = 0
            if (unit._data.stunEffect ~= nil) then
                unit._data.stunEffect:destroy()
                unit._data.stunEffect = nil
            end
        else
            local i = #unit._data.stunLayers
            while i >= 1 do
                unit._data.stunLayers[i].duration = unit._data.stunLayers[i].duration - 0.1
                if (unit._data.stunLayers[i].duration <= 0) then
                    table.remove(unit._data.stunLayers, i)
                    unit._data.stunCounter = unit._data.stunCounter - 1
                end
                i = i - 1
            end

            if (unit._data.stunCounter <= 0) then
                unit._data.stunCounter = 0
                if (unit._data.stunEffect ~= nil) then
                    unit._data.stunEffect:destroy()
                    unit._data.stunEffect = nil
                end
                cdz.EXPauseUnit(unit._handle, false)
            else
                _nextStunned[idx] = unit
                _nextStunSorted[_nextStunIdx] = unit
                _nextStunIdx = _nextStunIdx + 1
                hasStunActive = true
            end
        end
    end

    -- 交换引用而非赋值，避免创建新表
    _nextStunned, stunnedUnits = stunnedUnits, _nextStunned
    -- 清除 _nextStunSorted 尾部残留（避免上次遗留数据污染）
    for i = _nextStunIdx, #_nextStunSorted do _nextStunSorted[i] = nil end
    _nextStunSorted, _stunSorted = _stunSorted, _nextStunSorted

    -- ---- 处理 buff ----
    _clearTable(_nextBuffed)
    local _nextBuffIdx = 1
    local hasBuffActive = false

    -- 死亡清理：仅扫描 _buffLookup 中不在 buffedUnits 的永久-only 单位
    -- （限时单位的死亡清理在下方的限时扫描中一并处理）
    for _, unit in ipairs(_lookupSorted) do
        local idx = unit._index
        if buffedUnits[idx] == nil then
            if (unit._handle == nil or cj.IsUnitType(unit._handle, UNIT_TYPE_DEAD)) then
                local buffs = unit._data.buffs or {}
                -- [LAN-SYNC] 铁律C：buffs 整数 key，pairs 跨机哈希顺序不一致，循环体含 effect:destroy → desync。先排序。
                local _dcodes = {}
                for _dc in pairs(buffs) do _dcodes[#_dcodes + 1] = _dc end
                table.sort(_dcodes)
                for _di = 1, #_dcodes do
                    local buffCode = _dcodes[_di]
                    local buff = buffs[buffCode]
                    if buff ~= nil then
                    if (buff.effect ~= nil) then
                        buff.effect:destroy()
                    end
                    if (buff.stack) then
                        for _, layer in ipairs(buff.layers) do
                            if (layer.onLose ~= nil) then pcall(layer.onLose, unit) end
                        end
                    elseif (buff.onLose ~= nil) then
                        pcall(buff.onLose, unit)
                    end
                    end
                end
                unit._data.buffs = {}
                _buffLookup[idx] = nil
                _sortedRemove(idx, _lookupSorted)
            end
        end
    end

    -- 限时层扫描：仅处理拥有限时层的单位
    for _, unit in ipairs(_buffSorted) do
        local idx = unit._index
        if (unit._handle == nil or cj.IsUnitType(unit._handle, UNIT_TYPE_DEAD)) then
            -- 限时单位死亡清理
            local buffs = unit._data.buffs or {}
            -- [LAN-SYNC] 铁律C：buffs 整数 key，pairs 跨机哈希顺序不一致，循环体含
            -- effect:destroy()（特效句柄销毁）+ onLose（状态写回），顺序分叉 = 句柄/属性序列分叉 = desync。
            -- 与上方 _lookupSorted 死亡清理同法：收集 key 排序后按序遍历。
            local _dcodes = {}
            for _dc in pairs(buffs) do _dcodes[#_dcodes + 1] = _dc end
            table.sort(_dcodes)
            for _di = 1, #_dcodes do
                local buffCode = _dcodes[_di]
                local buff = buffs[buffCode]
                if buff ~= nil then
                    if (buff.effect ~= nil) then
                        buff.effect:destroy()
                    end
                    if (buff.stack) then
                        for _, layer in ipairs(buff.layers) do
                            if (layer.onLose ~= nil) then pcall(layer.onLose, unit) end
                        end
                    elseif (buff.onLose ~= nil) then
                        pcall(buff.onLose, unit)
                    end
                end
            end
            unit._data.buffs = {}
            _buffLookup[idx] = nil
            _sortedRemove(idx, _lookupSorted)
        else
            local buffs = unit._data.buffs or {}
            local hasTimedType = false

            -- [LAN-SYNC] 铁律C：buffs 以整数 buffCode 为 key，pairs 跨机哈希顺序不一致；
            -- 循环体含 buff.effect:destroy()（特效句柄销毁），顺序分叉 = 句柄序列分叉 = desync。
            -- 故先收集 key 排序，再按序遍历（各机结果严格一致）。
            local _bcodes = {}
            for _bc in pairs(buffs) do _bcodes[#_bcodes + 1] = _bc end
            table.sort(_bcodes)
            for _ki = 1, #_bcodes do
                local buffCode = _bcodes[_ki]
                local buff = buffs[buffCode]
                if buff ~= nil then
                local i = #buff.layers
                while i >= 1 do
                    if not buff.layers[i].permanent then
                        buff.layers[i].duration = buff.layers[i].duration - 0.1
                        if (buff.layers[i].duration <= 0) then
                            if (buff.stack and buff.layers[i].onLose ~= nil) then
                                pcall(buff.layers[i].onLose, unit)
                            end
                            table.remove(buff.layers, i)
                            buff.counter = buff.counter - 1
                        end
                    end
                    i = i - 1
                end

                if (buff.counter <= 0) then
                    buff.counter = 0
                    if (buff.effect ~= nil) then
                        buff.effect:destroy()
                        buff.effect = nil
                    end
                    if (not buff.stack and buff.onLose ~= nil) then
                        pcall(buff.onLose, unit)
                    end
                    buffs[buffCode] = nil
                else
                    -- 检查此 buff 是否还有限时层
                    local hasTimedLayers = false
                    for _, layer in ipairs(buff.layers) do
                        if not layer.permanent then
                            hasTimedLayers = true
                            break
                        end
                    end
                    if hasTimedLayers then
                        hasTimedType = true
                    end
                end
                end
            end

            if hasTimedType then
                _nextBuffed[idx] = unit
                _nextBuffSorted[_nextBuffIdx] = unit
                _nextBuffIdx = _nextBuffIdx + 1
                hasBuffActive = true
            end
            -- 否则：变为 permanent-only，不加入 _nextBuffed
            -- 交换后将从 buffedUnits 移除，但保留在 _buffLookup 中

            -- 所有 buff 已过期 → 从查找表移除
            if next(buffs) == nil then
                _buffLookup[idx] = nil
                _sortedRemove(idx, _lookupSorted)
            end
        end
    end

    _nextBuffed, buffedUnits = buffedUnits, _nextBuffed
    -- 清除 _nextBuffSorted 尾部残留
    for i = _nextBuffIdx, #_nextBuffSorted do _nextBuffSorted[i] = nil end
    _nextBuffSorted, _buffSorted = _buffSorted, _nextBuffSorted

    -- 仅当没有晕眩且没有任何 buff（含永久）时才销毁计时器
    local hasAnyBuff = next(_buffLookup) ~= nil
    if (not hasStunActive and not hasBuffActive and not hasAnyBuff and stunGlobalTimer ~= nil) then
        stunGlobalTimer:destroy()
        stunGlobalTimer = nil
    end
end

--- 添加buff（多层叠加，每层独立计时）
--- 每次调用添加一层，每层到期后递减，全部到期后移除特效。
--- onGain/onLose 为可选回调。
--- stack（第 5 参数，真值 / nil / false）：
---   · 缺省或 false → 旧逻辑：仅首次(0→1)执行 onGain 并保存唯一 onLose；
---     所有层掉光（到期 / 死亡 / removeBuff）时才执行一次 onLose（适合"有/无"型开关 buff）。
---   · 真值（true 或任意非 nil 非 false）→ 叠加模式：每层都独立执行自己的
---     onGain / onLose，"各算各的"，效果自然叠加；单层到期 / 失去即执行该层 onLose 恢复。
---   例：攻击时每层减少目标护甲，填真值即实现可叠加减甲。
---@param buffCode integer|string buffID
---@param duration number 持续时间
---@param onGain fun(u:Unit)|nil 获得回调（可 nil）
---@param onLose fun(u:Unit)|nil 失去回调（可 nil）
---@param stack boolean|nil 是否叠加（每层独立算回调）
---@return boolean
function Unit:addBuff(buffCode, duration, onGain, onLose, stack)
    if (self._handle == nil) then return false end
    if (buffCode == nil or duration == nil or duration <= 0) then return false end

    local buffCodeStr = buffCode
    if (type(buffCode) == "string") then
        buffCode = c2i(buffCode)
    elseif (type(buffCode) == "number") then
        buffCodeStr = i2c(buffCode)
    end

    if (self._data.buffs == nil) then
        self._data.buffs = {}
    end

    local buff = self._data.buffs[buffCode]
    if (buff == nil) then
        buff = { layers = {}, counter = 0, effect = nil, onLose = nil, stack = not not stack }
        self._data.buffs[buffCode] = buff
    end

    -- 叠层模式：每层携带自己独立的 onLose，便于到期时"各算各的"恢复
    -- 持续时间超过阈值的层标记为永久，不进入冷却计时逻辑
    local isPermanent = duration > PERMANENT_DURATION_THRESHOLD
    table.insert(buff.layers, {
        duration  = isPermanent and math.huge or duration,
        onLose    = buff.stack and onLose or nil,
        permanent = isPermanent
    })
    buff.counter = buff.counter + 1
    -- print("addBuff", buffCodeStr, "counter:",buff.counter)

    if (buff.counter == 1) then

        local targetart = Obj.Buff[buffCodeStr].targetart
        local targetattach = Obj.Buff[buffCodeStr].targetattach
        if (targetart == nil) then
            -- 无视觉对象：回退，不注册（避免半残 buff）
            self._data.buffs[buffCode] = nil
            return false
        end
        targetattach = type(targetattach) == "string" and targetattach or EFFECT_POINT_FOOT
        
        buff.effect = Effect:newAttach(
            targetart,
            self._handle,
            targetattach,
            -1
        )

        if (self._index == nil) then
            self._index = cj.GetHandleId(self._handle)
        end
        -- 查找表：所有拥在 buff 的单位都注册（供 getBuffedUnit 查询）
        _buffLookup[self._index] = self
        _tickRegUnit(self._index, self, _lookupSorted)
    end

    -- 计时扫描表：仅注册拥有限时层的单位
    -- 永久层单位不进入扫描表，避免每 0.1 秒的无效遍历
    if not isPermanent and buffedUnits[self._index] == nil then
        buffedUnits[self._index] = self
        _tickRegUnit(self._index, self, _buffSorted)
    end

    -- 计时器：任何 buff（含永久）都需启动，以确保死亡清理能运行
    -- 独立原生计时器（separate=true）：buff/stun 全局 tick 脱离内核桶，由引擎直接派发
    if (stunGlobalTimer == nil) then
        stunGlobalTimer = Timer:new(0.1, true, stunGlobalTick, true)
    end

    -- 回调派发
    if (buff.stack) then
        -- 叠加模式：每层独立施加并各自恢复（"各算各的"）
        if (onGain ~= nil) then pcall(onGain, self) end
    else
        -- 旧逻辑：仅首次赋予（0→1）执行 onGain 并保存唯一 onLose
        if (buff.counter == 1) then
            buff.onLose = onLose
            if (onGain ~= nil) then pcall(onGain, self) end
        end
    end

    return true
end

--- 删除buff (移除所有该buff的层数 + 特效)
---@param buffCode integer|string buffID
---@return boolean
function Unit:removeBuff(buffCode)
    if (self._handle == nil) then return false end
    if (type(buffCode) == "string") then buffCode = c2i(buffCode) end

    local buffs = self._data.buffs
    if (buffs == nil) then return false end

    local buff = buffs[buffCode]
    if (buff == nil) then return false end

    -- 执行失去回调（与到期/死亡一致，确保属性精确恢复）
    if (buff.stack) then
        -- 叠加模式：每层各自恢复
        for _, layer in ipairs(buff.layers) do
            if (layer.onLose ~= nil) then pcall(layer.onLose, self) end
        end
    elseif (buff.onLose ~= nil) then
        pcall(buff.onLose, self)
    end

    -- 清除特效
    if (buff.effect ~= nil) then
        buff.effect:destroy()
        buff.effect = nil
    end
    -- 清除所有层
    buff.layers = {}
    buff.counter = 0
    buffs[buffCode] = nil

    -- 没有更多 buff 类型 → 从两个全局表注销
    local hasAny = false
    local hasTimed = false
    for _, remainingBuff in pairs(buffs) do
        hasAny = true
        if not hasTimed then
            for _, layer in ipairs(remainingBuff.layers) do
                if not layer.permanent then
                    hasTimed = true
                    break
                end
            end
        end
    end
    if self._index ~= nil then
        if not hasAny then
            _buffLookup[self._index] = nil
            buffedUnits[self._index] = nil
            _sortedRemove(self._index, _lookupSorted)
            _sortedRemove(self._index, _buffSorted)
        elseif not hasTimed then
            -- 仍有 buff 但全部为永久层 → 只需从计时扫描表移除
            buffedUnits[self._index] = nil
            _sortedRemove(self._index, _buffSorted)
        end
    end

    return true
end



--- 移除 buff 的一层（层数 -1）；减到 0 时整体移除（特效 + 注销）
--- 用于「重生十字章」等按层消耗型 buff：每次致命伤只消耗一层而非全部。
---@param buffCode integer|string buffID
---@return boolean 是否成功移除一层
function Unit:removeBuffLayer(buffCode)
    if (self._handle == nil) then return false end
    if (type(buffCode) == "string") then buffCode = c2i(buffCode) end

    local buffs = self._data.buffs
    if (buffs == nil) then return false end

    local buff = buffs[buffCode]
    if (buff == nil or buff.counter <= 0) then return false end

    -- 弹出一层（各层独立计时，弹出最后加入的一层即可）
    if (#buff.layers > 0) then
        table.remove(buff.layers)
    end
    buff.counter = buff.counter - 1

    if (buff.counter <= 0) then
        -- 全部消耗：清层 + 销毁特效 + 注销全局表
        if (buff.effect ~= nil) then
            buff.effect:destroy()
            buff.effect = nil
        end
        buff.layers = {}
        buffs[buffCode] = nil

        local hasAny = false
        local hasTimed = false
        for _, remainingBuff in pairs(buffs) do
            hasAny = true
            if not hasTimed then
                for _, layer in ipairs(remainingBuff.layers) do
                    if not layer.permanent then
                        hasTimed = true
                        break
                    end
                end
            end
        end
        if self._index ~= nil then
            if not hasAny then
                _buffLookup[self._index] = nil
                buffedUnits[self._index] = nil
                _sortedRemove(self._index, _lookupSorted)
                _sortedRemove(self._index, _buffSorted)
            elseif not hasTimed then
                buffedUnits[self._index] = nil
                _sortedRemove(self._index, _buffSorted)
            end
        end
    end

    return true
end

--- buff是否存在
---@param buffCode integer|string buffID
---@return boolean
function Unit:isBuff(buffCode)
    if (self._handle == nil) then return false end
    if (type(buffCode) == "string") then buffCode = c2i(buffCode) end

    local buffs = self._data.buffs
    if (buffs == nil) then return false end

    local buff = buffs[buffCode]
    return buff ~= nil
end

--- 获取指定 buff 对象（含 meta），用于读取/更新 buff 携带的自定义数据
---@param buffCode integer|string buffID
---@return table|nil
function Unit:getBuff(buffCode)
    if (self._handle == nil) then return nil end
    if (type(buffCode) == "string") then buffCode = c2i(buffCode) end

    local buffs = self._data.buffs
    if (buffs == nil) then return nil end

    return buffs[buffCode]
end

--- 通过 handle 获取拥有 buff 的 Unit 对象
--- 用于 BuffPanel 等外部系统读取 buff 数据
---@param h userdata 单位 handle
---@return Unit|nil
function Unit.getBuffedUnit(h)
    if h == nil then return nil end
    local id = cj.GetHandleId(h)
    return _buffLookup[id]
end

--- 添加晕眩（多层叠加）
--- 每次调用添加一层晕眩，每层独立计时。
--- 所有受击单位共用同一个全局计时器（每 0.1s tick）。
--- 当所有层数持续时间耗尽后自动恢复单位。
---@param duration number 持续时间（秒）
---@return boolean
function Unit:addStun(duration)
    if (self._handle == nil) then return false end
    if (duration == nil or duration <= 0) then return false end

    -- 初始化晕眩数据
    if (self._data.stunLayers == nil) then
        self._data.stunLayers = {}
        self._data.stunCounter = 0
    end

    -- 添加一层晕眩
    table.insert(self._data.stunLayers, { duration = duration })
    self._data.stunCounter = self._data.stunCounter + 1

    -- 第一层触发：应用晕眩效果、绑定头顶特效、注册到全局计时器
    if (self._data.stunCounter == 1) then
        cdz.EXPauseUnit(self._handle, true)
        
        -- 绑定晕眩特效到头顶
        self._data.stunEffect = Effect:newAttach(
            [[Abilities\Spells\Human\Thunderclap\ThunderclapTarget.mdl]],
            self._handle,
            EFFECT_POINT_HEADTOP,
            -1  -- 负值：不自动销毁，手动管理
        )

        -- 注册到全局晕眩表
        if (self._index == nil) then
            self._index = cj.GetHandleId(self._handle)
        end
        stunnedUnits[self._index] = self
        _tickRegUnit(self._index, self, _stunSorted)

        -- 延时启动全局计时器（确保当前帧其他初始化完成）
        -- 独立原生计时器（separate=true）：buff/stun 全局 tick 脱离内核桶，由引擎直接派发
        if (stunGlobalTimer == nil) then
            stunGlobalTimer = Timer:new(0.1, true, stunGlobalTick, true)
        end
    end

    return true
end

--- 移除所有晕眩（立即清除全部层数 + 特效 + 恢复单位 + 注销全局表）
---@return boolean
function Unit:removeStun()
    if (self._handle == nil) then return false end

    -- 清除头顶特效
    if (self._data.stunEffect ~= nil) then
        self._data.stunEffect:destroy()
        self._data.stunEffect = nil
    end

    -- 清除所有晕眩层
    if (self._data.stunLayers ~= nil) then
        self._data.stunLayers = {}
        self._data.stunCounter = 0
    end

    -- 从全局注册表移除
    if (self._index ~= nil) then
        stunnedUnits[self._index] = nil
        _sortedRemove(self._index, _stunSorted)
    end

    -- 恢复单位
    return cdz.EXPauseUnit(self._handle, false)
end

-----------------------------------------------------------------
-- 技能
-----------------------------------------------------------------

--- 添加技能
---@param abilCode integer|string 技能ID
---@return boolean
function Unit:addAbility(abilCode)
    if (self._handle == nil) then return false end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.UnitAddAbility(self._handle, abilCode)
end

--- 删除技能
---@param abilCode integer|string
---@return boolean
function Unit:removeAbility(abilCode)
    if (self._handle == nil) then return false end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.UnitRemoveAbility(self._handle, abilCode)
end

--- 获取技能等级
---@param abilCode integer|string
---@return integer
function Unit:getAbilityLevel(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.GetUnitAbilityLevel(self._handle, abilCode)
end

--- 设置技能等级
---@param abilCode integer|string
---@param level integer
---@return integer 实际设置后的等级
function Unit:setAbilityLevel(abilCode, level)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.SetUnitAbilityLevel(self._handle, abilCode, level)
end

--- 提升技能等级
---@param abilCode integer|string
---@return integer
function Unit:incAbilityLevel(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.IncUnitAbilityLevel(self._handle, abilCode)
end

--- 降低技能等级
---@param abilCode integer|string
---@return integer
function Unit:decAbilityLevel(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.DecUnitAbilityLevel(self._handle, abilCode)
end

--- 使技能永久化
---@param abilCode integer|string
---@param permanent boolean
---@return boolean
function Unit:makeAbilityPermanent(abilCode, permanent)
    if (self._handle == nil) then return false end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cj.UnitMakeAbilityPermanent(self._handle, permanent, abilCode)
end

--- 重置技能CD
---@return Unit
function Unit:resetCooldown()
    if (self._handle ~= nil) then
        cj.UnitResetCooldown(self._handle)
    end
    return self
end

--- 判断单位是否拥有技能（DzAPI 扩展，包含模版技能）
---@param abilCode integer|string
---@return boolean
function Unit:hasAbility(abilCode)
    if (self._handle == nil) then return false end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzUnitHasAbility(self._handle, abilCode)
end

--- 查找单位的指定技能 handle（DzAPI 扩展）
---@param abilCode integer|string
---@return ability|nil
function Unit:findAbility(abilCode)
    if (self._handle == nil) then return end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzUnitFindAbility(self._handle, abilCode)
end

--- 获取技能冷却时间（DzAPI 扩展）
---@param abilCode integer|string
---@return number
function Unit:getAbilityCool(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzGetUnitAbilityCool(self._handle, abilCode)
end

--- 设置技能冷却时间（DzAPI 扩展）
---@param abilCode integer|string
---@param coolDown number 冷却时间
---@param currentCool number|nil 当前冷却（默认 = coolDown）
---@return Unit
function Unit:setAbilityCool(abilCode, coolDown, currentCool)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityCool(self._handle, abilCode, coolDown, currentCool or coolDown)
    end
    return self
end

--- 获取技能魔法消耗（DzAPI 扩展）
---@param abilCode integer|string 技能ID
---@return integer
function Unit:getAbilityCost(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzGetUnitAbilityCost(self._handle, abilCode)
end

--- 设置技能魔法消耗（DzAPI 扩展）
---@param abilCode integer|string 技能ID
---@param cost integer 魔法消耗
---@return Unit
function Unit:setAbilityCost(abilCode, cost)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityCost(self._handle, abilCode, cost)
    end
    return self
end

--- 获取技能施法范围（DzAPI 扩展）
---@param abilCode integer|string
---@return number
function Unit:getAbilityRange(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzGetUnitAbilityRange(self._handle, abilCode)
end

--- 设置技能施法范围（DzAPI 扩展）
---@param abilCode integer|string
---@param range number
---@return Unit
function Unit:setAbilityRange(abilCode, range)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityRange(self._handle, abilCode, range)
    end
    return self
end

--- 禁用技能（DzAPI 扩展）
---@param abilCode integer|string
---@return Unit
function Unit:disableAbility(abilCode)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityDisable(self._handle, abilCode)
    end
    return self
end

--- 启用技能（DzAPI 扩展）
---@param abilCode integer|string
---@return Unit
function Unit:enableAbility(abilCode)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityEnable(self._handle, abilCode)
    end
    return self
end

-----------------------------------------------------------------
-- 物品
-----------------------------------------------------------------

--- 单位获得物品
---@param item userdata 物品handle
---@return boolean
function Unit:addItem(item)
    if (self._handle == nil) then return false end
    return cj.UnitAddItem(self._handle, item)
end

--- 添加指定ID的物品到单位
---@param itemId integer|string
---@return item
function Unit:addItemById(itemId)
    if (self._handle == nil) then return end
    if (type(itemId) == "string") then itemId = c2i(itemId) end
    return cj.UnitAddItemById(self._handle, itemId)
end

--- 添加物品到指定栏位
---@param itemId integer|string
---@param slot integer 栏位索引（0-5）
---@return boolean
function Unit:addItemToSlot(itemId, slot)
    if (self._handle == nil) then return false end
    if (type(itemId) == "string") then itemId = c2i(itemId) end
    return cj.UnitAddItemToSlotById(self._handle, itemId, slot)
end

--- 获取指定栏位的物品
---@param slot integer 栏位索引
---@return item|nil
function Unit:getItemInSlot(slot)
    if (self._handle == nil) then return end
    return cj.UnitItemInSlot(self._handle, slot)
end

--- 丢弃物品到坐标
---@param item userdata 物品handle
---@param x number
---@param y number
---@return boolean
function Unit:dropItemPoint(item, x, y)
    if (self._handle == nil) then return false end
    return cj.UnitDropItemPoint(self._handle, item, x, y)
end

--- 移除物品
---@param item userdata
function Unit:removeItem(item)
    if (self._handle ~= nil) then
        cj.UnitRemoveItem(self._handle, item)
    end
end

--- 从栏位移除物品
---@param slot integer
---@return item
function Unit:removeItemFromSlot(slot)
    if (self._handle == nil) then return end
    return cj.UnitRemoveItemFromSlot(self._handle, slot)
end

--- 使用物品（无目标）
---@param item userdata
---@return boolean
function Unit:useItem(item)
    if (self._handle == nil) then return false end
    return cj.UnitUseItem(self._handle, item)
end

--- 使用物品到坐标
---@param item userdata
---@param x number
---@param y number
---@return boolean
function Unit:useItemPoint(item, x, y)
    if (self._handle == nil) then return false end
    return cj.UnitUseItemPoint(self._handle, item, x, y)
end

--- 使用物品到目标
---@param item userdata
---@param target userdata
---@return boolean
function Unit:useItemTarget(item, target)
    if (self._handle == nil) then return false end
    return cj.UnitUseItemTarget(self._handle, item, target)
end

--- 是否持有指定物品
---@param item userdata
---@return boolean
function Unit:hasItem(item)
    if (self._handle == nil) then return false end
    return cj.UnitHasItem(self._handle, item)
end

--- 获取物品栏格数
---@return integer
function Unit:getInventorySize()
    if (self._handle == nil) then return 0 end
    return cj.UnitInventorySize(self._handle)
end

-----------------------------------------------------------------
-- 伤害 / 战斗
-----------------------------------------------------------------

--- 伤害目标单位
---@param target Unit 目标单位或 Unit 对象handle
---@param amount number 伤害值
---@param attack boolean 是否攻击
---@param ranged boolean 是否远程
---@param attackType attacktype 攻击类型
---@param damageType damagetype 伤害类型
---@param weaponType weapontype|nil 武器类型
---@return boolean
function Unit:damageTarget(target, amount, attack, ranged, attackType, damageType, weaponType)
    if (self._handle == nil) then return false end
    return cj.UnitDamageTarget(self._handle, resolveHandle(target), amount,
        (attack ~= nil) and attack or false,
        (ranged ~= nil) and ranged or false,
        attackType or ATTACK_TYPE_NORMAL,
        damageType or DAMAGE_TYPE_NORMAL,
        weaponType or WEAPON_TYPE_WHOKNOWS)
end

--- 伤害区域
---@param x number 中心X
---@param y number 中心Y
---@param radius number 范围
---@param amount number 伤害值
---@param attack boolean
---@param ranged boolean
---@param attackType attacktype
---@param damageType damagetype
---@return boolean
function Unit:damageArea(x, y, radius, amount, attack, ranged, attackType, damageType)
    if (self._handle == nil) then return false end
    return cj.UnitDamagePoint(self._handle, 0, radius, x, y, amount,
        (attack ~= nil) and attack or false,
        (ranged ~= nil) and ranged or false,
        attackType or ATTACK_TYPE_NORMAL,
        damageType or DAMAGE_TYPE_NORMAL,
        WEAPON_TYPE_WHOKNOWS)
end

--- 添加类别
---@param unitType unittype
---@return boolean
function Unit:addType(unitType)
    if (self._handle == nil) then return false end
    return cj.UnitAddType(self._handle, unitType)
end

--- 删除类别
---@param unitType unittype
---@return boolean
function Unit:removeType(unitType)
    if (self._handle == nil) then return false end
    return cj.UnitRemoveType(self._handle, unitType)
end

--- 是否拥有指定类别
---@param unitType unittype
---@return boolean
function Unit:isType(unitType)
    if (self._handle == nil) then return false end
    return cj.IsUnitType(self._handle, unitType)
end

--- 单位可见性判断
---@param pl Player|userdata 玩家对象 或 玩家handle
---@return boolean
function Unit:isVisible(pl)
    if (self._handle == nil) then return false end
    return cj.IsUnitVisible(self._handle, resolveHandle(pl))
end

--- 是否被检测到
---@param pl Player|userdata
---@return boolean
function Unit:isDetected(pl)
    if (self._handle == nil) then return false end
    return cj.IsUnitDetected(self._handle, resolveHandle(pl))
end

--- 分享视野
---@param pl Player|userdata
---@param share boolean
---@return Unit
function Unit:shareVision(pl, share)
    if (self._handle ~= nil) then
        cj.UnitShareVision(self._handle, resolveHandle(pl), (share ~= nil) and share or true)
    end
    return self
end




-----------------------------------------------------------------
-- 动画 / 视觉
-----------------------------------------------------------------

--- 播放动画
---@param anim string 动画名
---@return Unit
function Unit:playAnimation(anim)
    if (self._handle ~= nil) then
        cj.SetUnitAnimation(self._handle, anim)
    end
    return self
end

--- 播放指定序号的动画
---@param index integer
---@return Unit
function Unit:playAnimationByIndex(index)
    if (self._handle ~= nil) then
        cj.SetUnitAnimationByIndex(self._handle, index)
    end
    return self
end

--- 设置动画播放速度
---@param speed number 速度倍数
---@return Unit
function Unit:setTimeScale(speed)
    if (self._handle ~= nil) then
        cj.SetUnitTimeScale(self._handle, speed)
    end
    return self
end

--- 设置单位缩放
---@param scaleX number X轴缩放
---@param scaleY number|nil Y轴缩放
---@param scaleZ number|nil Z轴缩放
---@return Unit
function Unit:setScale(scaleX, scaleY, scaleZ)
    if (self._handle ~= nil) then
        self.state.scale = scaleX
        cj.SetUnitScale(self._handle, scaleX, scaleY or scaleX, scaleZ or scaleX)
    end
    return self
end

--- 增加单位缩放（用-减少）
---@param scale number 缩放倍数
---@return Unit
function Unit:addScale(scale)
    --- 如果缩放变量为nil，则从物编中获取当前缩放
    if (self.state.scale == nil) then
        self.state.scale = Obj.getUnitData(i2c(self._id), "Scale")
    end
    
    self.state.scale = self.state.scale + scale
    
    cj.SetUnitScale(self._handle, self.state.scale, self.state.scale, self.state.scale)

    return self
end

--- 设置单位颜色
---@param red integer 0-255
---@param green integer 0-255
---@param blue integer 0-255
---@param alpha integer|nil 0-255（默认255）
---@return Unit
function Unit:setVertexColor(red, green, blue, alpha)
    if (self._handle ~= nil) then
        cj.SetUnitVertexColor(self._handle, red, green, blue, alpha or 255)
    end
    return self
end

--- 设置队伍颜色
---@param color any
---@return Unit
function Unit:setColor(color)
    if (self._handle ~= nil) then
        cj.SetUnitColor(self._handle, color)
    end
    return self
end

--- 设置单位透明度（DzAPI 扩展）
---@param alpha integer 0-255（0=完全透明）
---@param changeTeamColor boolean 强制更新
---@return Unit
function Unit:setAlpha(alpha, changeTeamColor)
    if (self._handle ~= nil) then
        cdz.DzUnitChangeAlpha(self._handle, alpha, (changeTeamColor ~= nil) and changeTeamColor or true)
    end
    return self
end

--- 设置单位缩放（DzAPI 扩展，全局缩放）
---@param scale number
---@return Unit
function Unit:setSpriteScale(scale)
    if (self._handle ~= nil) then
        cdz.DzSetWidgetSpriteScale(self._handle, scale)
    end
    return self
end

--- 单位沉默（DzAPI 扩展）
---@param flag boolean true=沉默
---@return Unit
function Unit:silence(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzUnitSilence(self._handle, flag)
    end
    return self
end

--- 设置单位选择圈缩放（DzAPI 扩展）
---@param scale number
---@return Unit
function Unit:setSelectScale(scale)
    if (self._handle ~= nil) then
        cdz.DzSetUnitSelectScale(self._handle, scale)
    end
    return self
end

--- 设置单位是否可被选中（DzAPI 扩展）
---@param flag boolean
---@return Unit
function Unit:setCanSelect(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzUnitSetCanSelect(self._handle, flag)
    end
    return self
end

--- 设置单位是否可被设置为目标（DzAPI 扩展）
---@param flag boolean
---@return Unit
function Unit:setTargetable(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzUnitSetTargetable(self._handle, flag)
    end
    return self
end

--- 设置单位忽略点击（DzAPI 扩展）
---@param flag boolean
---@return Unit
function Unit:setHitIgnore(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzSetUnitHitIgnore(self._handle, flag)
    end
    return self
end

--- 设置单位头像模型（DzAPI 扩展）
---@param modelPath string 模型路径
---@return Unit
function Unit:setPortrait(modelPath)
    if (self._handle ~= nil and modelPath ~= nil) then
        cdz.DzSetUnitPortrait(self._handle, modelPath)
    end
    return self
end

--- 禁用攻击（DzAPI 扩展）
---@param flag boolean true=禁用
---@return Unit
function Unit:disableAttack(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzUnitDisableAttack(self._handle, flag)
    end
    return self
end

--- 禁用道具/物品栏（DzAPI 扩展）
---@param flag boolean true=禁用
---@return Unit
function Unit:disableInventory(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cdz.DzUnitDisableInventory(self._handle, flag)
    end
    return self
end

--- 设置单位移动类型（DzAPI 扩展）
---@param moveType string 移动类型名（如 "foot", "fly", "hover" 等）
---@return Unit
function Unit:setMoveType(moveType)
    if (self._handle ~= nil and moveType ~= nil) then
        cdz.DzUnitSetMoveType(self._handle, moveType)
    end
    return self
end

--- 设置单位描述（DzAPI 扩展）
---@param desc string
---@return Unit
function Unit:setDescription(desc)
    if (self._handle ~= nil and desc ~= nil) then
        cdz.DzSetUnitDescription(self._handle, desc)
    end
    return self
end

--- 添加生命周期（自动删除）
---@param buffId integer|string buffID
---@param duration number 持续时间
---@return Unit
function Unit:applyTimedLife(buffId, duration)
    if (self._handle ~= nil) then
        if (type(buffId) == "string") then buffId = c2i(buffId) end
        cj.UnitApplyTimedLife(self._handle, buffId, duration)
    end
    return self
end

--- 设置单位小地图图标（DzAPI 扩展）
---@param imagePath string 图标路径
---@return Unit
function Unit:setMinimapIcon(imagePath)
    if (self._handle ~= nil and imagePath ~= nil) then
        cdz.DzWidgetSetMinimapIcon(self._handle, imagePath)
    end
    return self
end

--- 启用/禁用单位小地图图标（DzAPI 扩展）
---@param enable boolean
---@return Unit
function Unit:enableMinimapIcon(enable)
    if (self._handle ~= nil) then
        cdz.DzWidgetSetMinimapIconEnable(self._handle, (enable ~= nil) and enable or true)
    end
    return self
end

--- 产生幻象单位（DzAPI 扩展）
---@param pl Player|userdata|nil 所有者（nil=原所有者，也可传 Player 对象）
---@return userdata 幻象单位handle
function Unit:createIllusion(pl)
    if (self._handle == nil) then return end
    local p = pl and resolveHandle(pl) or cj.GetOwningPlayer(self._handle)
    local x = cj.GetUnitX(self._handle)
    local y = cj.GetUnitY(self._handle)
    local facing = cj.GetUnitFacing(self._handle)
    local unitId = cj.GetUnitTypeId(self._handle)
    return cdz.DzUnitCreateIllusion(p, unitId, x, y, facing)
end

-----------------------------------------------------------------
-- 单位组操作（KK_japi 扩展）
-----------------------------------------------------------------

--- 判断单位是否在指定坐标范围内
---@param x number
---@param y number
---@param distance number
---@return boolean
function Unit:isInRangeXY(x, y, distance)
    if (self._handle == nil) then return false end
    return cj.IsUnitInRangeXY(self._handle, x, y, distance)
end

--- 判断单位是否在另一单位范围内
---@param other widget|Unit 目标widget 或 Unit 对象
---@param distance number
---@return boolean
function Unit:isInRange(other, distance)
    if (self._handle == nil) then return false end
    return cj.IsUnitInRange(self._handle, resolveHandle(other), distance)
end

--- 判断单位是否在指定矩形区域内
---@param rect userdata rect handle
---@return boolean
function Unit:isInRect(rect)
    if (self._handle == nil) then return false end
    if (rect == nil) then return false end
    local x = cj.GetUnitX(self._handle)
    local y = cj.GetUnitY(self._handle)
    local minX = cj.GetRectMinX(rect)
    local maxX = cj.GetRectMaxX(rect)
    local minY = cj.GetRectMinY(rect)
    local maxY = cj.GetRectMaxY(rect)
    return x >= minX and x <= maxX and y >= minY and y <= maxY
end

--- 选择/取消选择单位
---@param flag boolean
---@return Unit
function Unit:select(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cj.SelectUnit(self._handle, flag)
    end
    return self
end

--- 是否被指定玩家选中
---@param pl Player|userdata
---@return boolean
function Unit:isSelected(pl)
    if (self._handle == nil) then return false end
    return cj.IsUnitSelected(self._handle, resolveHandle(pl))
end

--- 共享视野给玩家
---@param pl Player|userdata
---@param share boolean
---@return Unit
function Unit:shareVisionTo(pl, share)
    if (self._handle ~= nil) then
        if share == nil then share = true end
        cj.UnitShareVision(self._handle, resolveHandle(pl), share)
    end
    return self
end

-----------------------------------------------------------------
--- 中立建筑相关操作
-----------------------------------------------------------------

--- 添加物品到商店库存
---@param itemId integer|string 物品ID
---@param count integer 物品数量
---@param goldCost integer 最大数量
---@return Unit
function Unit:stockAdd(itemId, count, goldCost)
    itemId = (type(itemId) ~= "integer") and c2i(itemId) or itemId
    if (self:getAbilityLevel('Asud') == 0) then
        self:addAbility('Asud')
        self:makeAbilityPermanent('Asud', true)
    end
    if (self:getAbilityLevel('Asid') == 0) then
        self:addAbility('Asid')
        self:makeAbilityPermanent('Asid', true)
    end
    cj.AddItemToStock(self._handle, itemId, count, goldCost)
    self._shopItems[itemId] = true
    return self
end

--移除物品从商店库存
---@param itemId integer|string 物品ID
---@param count integer 物品ID（原参数count未使用，保留签名）
---@return Unit
function Unit:stockDel(itemId, count)
    itemId = (type(itemId) ~= "integer") and c2i(itemId) or itemId
    cj.RemoveItemFromStock(self._handle, itemId)
    self._shopItems[itemId] = nil
    return self
end

--- 检查商店是否有指定物品
---@param itemId integer|string 物品ID
---@return boolean
function Unit:hasShopItem(itemId)
    itemId = (type(itemId) ~= "integer") and c2i(itemId) or itemId
    return self._shopItems[itemId] == true
end

--- 获取商店所有出售物品
---@return table 物品ID列表
function Unit:getShopItems()
    local items = {}
    for itemId, _ in pairs(self._shopItems) do
        table.insert(items, itemId)
    end
    return items
end


--- 清空商店所有物品
---@return Unit
function Unit:clearShopItems()
    for itemId, _ in pairs(self._shopItems) do
        cj.RemoveItemFromStock(self._handle, itemId)
    end
    self._shopItems = {}
    return self
end

--- 更新商店出售的物品（先移除旧记录，再用新数量重置）
--- 解决 AddItemToStock 叠加行为导致的库存脱节问题。
---@param itemId integer|string 物品ID
---@param count integer 当前库存数量
---@param goldCost integer 最大库存数量
---@return Unit
function Unit:updateShopItem(itemId, count, goldCost)
    itemId = (type(itemId) ~= "integer") and c2i(itemId) or itemId
    if (self:getAbilityLevel('Asud') == 0) then
        self:addAbility('Asud')
        self:makeAbilityPermanent('Asud', true)
    end
    if (self:getAbilityLevel('Asid') == 0) then
        self:addAbility('Asid')
        self:makeAbilityPermanent('Asid', true)
    end
    cj.RemoveItemFromStock(self._handle, itemId)
    cj.AddItemToStock(self._handle, itemId, count, goldCost)
    self._shopItems[itemId] = true
    return self
end

--- 设置单位小地图图标
---@param imagePath string 图标路径
---@return Unit
function Unit:setMinimapIcon(imagePath)
    if (self._handle ~= nil and imagePath ~= nil) then
        cdz.DzWidgetSetMinimapIcon(self._handle, imagePath)
    end
    return self
end

--- 启用/禁用单位小地图图标（DzAPI 扩展）
---@param enable boolean
---@return Unit
function Unit:enableMinimapIcon(enable)
    if (self._handle ~= nil) then
        if enable == nil then enable = true end
        cdz.DzWidgetSetMinimapIconEnable(self._handle, enable)
    end
    return self
end

--- 是否启用小地图特殊图标
---@param flag boolean|nil
---@return Unit
function Unit:setUsesAltIcon(flag)
    if (self._handle ~= nil) then
        if flag == nil then flag = true end
        cj.UnitSetUsesAltIcon(self._handle, flag)
    end
    return self
end


-----------------------------------------------------------------
-- 哈希表保存 / 加载
-----------------------------------------------------------------

--- 保存单位handle到哈希表
---@param t hashtable
---@param pk integer parentKey
---@param ck integer childKey
---@return boolean
function Unit:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveUnitHandle(t, pk, ck, self._handle)
end

--- 从哈希表加载单位handle
---@param t hashtable
---@param pk integer parentKey
---@param ck integer childKey
---@return userdata|nil
function Unit.loadHandle(t, pk, ck)
    return cj.LoadUnitHandle(t, pk, ck)
end

--- 保存整数到哈希表（关联单位）
---@param t hashtable
---@param pk integer parentKey
---@param ck integer childKey
---@param val integer
function Unit.saveInteger(t, pk, ck, val)
    cj.SaveInteger(t, pk, ck, val)
end

--- 从哈希表加载整数
---@param t hashtable
---@param pk integer
---@param ck integer
---@return integer
function Unit.loadInteger(t, pk, ck)
    return cj.LoadInteger(t, pk, ck)
end

--- 保存字符串到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@param val string
function Unit.saveStr(t, pk, ck, val)
    cj.SaveStr(t, pk, ck, val)
end

--- 从哈希表加载字符串
---@param t hashtable
---@param pk integer
---@param ck integer
---@return string
function Unit.loadStr(t, pk, ck)
    return cj.LoadStr(t, pk, ck)
end

--- 保存实数到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@param val number
function Unit.saveReal(t, pk, ck, val)
    cj.SaveReal(t, pk, ck, val)
end

--- 从哈希表加载实数
---@param t hashtable
---@param pk integer
---@param ck integer
---@return number
function Unit.loadReal(t, pk, ck)
    return cj.LoadReal(t, pk, ck)
end

--- 保存布尔值到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@param val boolean
function Unit.saveBoolean(t, pk, ck, val)
    cj.SaveBoolean(t, pk, ck, val)
end

--- 从哈希表加载布尔值
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Unit.loadBoolean(t, pk, ck)
    return cj.LoadBoolean(t, pk, ck)
end

-----------------------------------------------------------------
-- 静态工具
-----------------------------------------------------------------

--- 字符串ID转整数ID
---@param idStr string 四字符码
---@return integer
function Unit.c2i(idStr)
    return c2i(idStr)
end

--- 整数ID转字符串ID
---@param id integer
---@return string
function Unit.i2c(id)
    return i2c(id)
end

--- 获取单位HandleId
---@param h userdata 单位handle
---@return integer
function Unit.handleId(h)
    if (h == nil) then return 0 end
    return cj.GetHandleId(h)
end

