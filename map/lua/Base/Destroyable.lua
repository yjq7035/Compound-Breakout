-- ============================================================
-- Destroyable 类 — 可破坏物
-- 风格参照 Item.lua：单一 fromHandleCache、isValid 守卫、链式返回
-- ============================================================

---@class Destroyable 可破坏物
Destroyable = {}
Destroyable.__index = Destroyable

------------------------------------------------------------------
-- 内部工厂 / 工具
------------------------------------------------------------------

local fromHandleCache = {}

local function newDestroyable()
    local obj = {
        _handle = nil,
        _index  = nil,
        _id     = nil,
        _type   = nil,
    }
    setmetatable(obj, Destroyable)
    return obj
end

--- 检查 handle 有效性
---@return boolean
local function isValid(self)
    return self._handle ~= nil and type(self._handle) == "userdata"
end

------------------------------------------------------------------
-- 构造 / 销毁
------------------------------------------------------------------

--- 创建可破坏物到坐标
---@param x number X 坐标
---@param y number Y 坐标
---@param typeId string|integer 对象 ID（四字符码或整数）
---@param facing number|nil 面向角度
---@param scale number|nil 缩放比例
---@param variation integer|nil 变异类型
---@return Destroyable|nil
function Destroyable:new(x, y, typeId, facing, scale, variation)
    if x == nil or y == nil or typeId == nil then return nil end
    if type(typeId) == "string" then typeId = c2i(typeId) end

    local handle = cj.CreateDestructable(
        typeId, x, y, facing or 0, scale or 1, variation or 0
    )
    if type(handle) ~= "userdata" then return nil end

    local obj = newDestroyable()
    obj._handle = handle
    obj._index  = cj.GetHandleId(handle)
    obj._id     = typeId
    obj._type   = i2c(typeId)

    Unit.embed(handle, { id = obj._type, destroyable = obj._index })
    fromHandleCache[obj._index] = obj

    return obj
end

--- 从已有 handle 创建/获取 Destroyable 对象（带缓存）
---@param h userdata 可破坏物 handle
---@return Destroyable|nil
function Destroyable.fromHandle(h)
    if h == nil then return nil end
    local key = cj.GetHandleId(h)
    local cached = fromHandleCache[key]
    if cached and cached._handle == h then
        return cached
    end
    local obj = newDestroyable()
    obj._handle = h
    obj._index  = key
    obj._id     = cj.GetDestructableTypeId(h)
    obj._type   = i2c(obj._id)
    fromHandleCache[key] = obj
    return obj
end

--- 销毁可破坏物
---@return Destroyable
function Destroyable:destroy()
    if not isValid(self) then return self end

    if self._index then
        fromHandleCache[self._index] = nil
        Unit.removeData(self._handle)
    end

    cj.RemoveDestructable(self._handle)
    self._handle = nil
    return self
end

--- 检查是否有效（handle 存在且未销毁）
---@return boolean
function Destroyable:isValid()
    return isValid(self)
end

------------------------------------------------------------------
-- 标识
------------------------------------------------------------------

--- 获取对象 ID（数字）
---@return integer
function Destroyable:getId()
    if not isValid(self) then return 0 end
    return cj.GetDestructableTypeId(self._handle)
end

--- 获取类型码（四字符）
---@return string
function Destroyable:getTypeCode()
    return i2c(self:getId())
end

--- 获取名称
---@return string
function Destroyable:getName()
    if not isValid(self) then return "" end
    return cj.GetDestructableName(self._handle)
end

------------------------------------------------------------------
-- 位置
------------------------------------------------------------------

--- 获取 X 坐标
---@return number
function Destroyable:getX()
    if not isValid(self) then return 0 end
    return cj.GetDestructableX(self._handle)
end

--- 获取 Y 坐标
---@return number
function Destroyable:getY()
    if not isValid(self) then return 0 end
    return cj.GetDestructableY(self._handle)
end

------------------------------------------------------------------
-- 生命值
------------------------------------------------------------------

--- 获取当前生命值
---@return number
function Destroyable:getLife()
    if not isValid(self) then return 0 end
    return cj.GetDestructableLife(self._handle)
end

--- 获取最大生命值
---@return number
function Destroyable:getMaxLife()
    if not isValid(self) then return 0 end
    return cj.GetDestructableMaxLife(self._handle)
end

--- 设置生命值
---@param life number 生命值
---@return Destroyable
function Destroyable:setLife(life)
    if not isValid(self) or life == nil then return self end
    cj.SetDestructableLife(self._handle, life)
    return self
end

--- 设置最大生命值（当前生命会被限制到新最大值）
---@param maxLife number 最大生命值
---@return Destroyable
function Destroyable:setMaxLife(maxLife)
    if not isValid(self) or maxLife == nil or maxLife <= 0 then return self end
    cj.SetDestructableMaxLife(self._handle, maxLife)
    -- 若当前生命超过新最大值，同步压低
    if self:getLife() > maxLife then
        cj.SetDestructableLife(self._handle, maxLife)
    end
    return self
end

--- 增加生命值（不会超过最大值）
---@param amount number 增加量
---@return Destroyable
function Destroyable:addLife(amount)
    if not isValid(self) or amount == nil or amount <= 0 then return self end
    local newLife = math.min(self:getMaxLife(), self:getLife() + amount)
    cj.SetDestructableLife(self._handle, newLife)
    return self
end

--- 受到伤害（生命值减少，不会低于 0）
---@param amount number 伤害量
---@return Destroyable
function Destroyable:takeDamage(amount)
    if not isValid(self) or amount == nil or amount <= 0 then return self end
    local newLife = math.max(0, self:getLife() - amount)
    cj.SetDestructableLife(self._handle, newLife)
    return self
end

--- 减少生命值（takeDamage 别名）
---@param amount number 减少量
---@return Destroyable
function Destroyable:subLife(amount)
    return self:takeDamage(amount)
end

------------------------------------------------------------------
-- 状态
------------------------------------------------------------------

--- 设置无敌
---@param flag boolean 是否无敌
---@return Destroyable
function Destroyable:setInvulnerable(flag)
    if not isValid(self) then return self end
    cj.SetDestructableInvulnerable(self._handle, flag == true)
    return self
end

--- 是否无敌
---@return boolean
function Destroyable:isInvulnerable()
    if not isValid(self) then return false end
    return cj.IsDestructableInvulnerable(self._handle)
end

--- 设置可见性（显示/隐藏）
---@param flag boolean|showhideoption 可见性
---@return Destroyable
function Destroyable:setVisible(flag)
    if not isValid(self) then return self end
    cj.ShowDestructable(self._handle, flag)
    return self
end

------------------------------------------------------------------
-- 闭塞高度
------------------------------------------------------------------

--- 获取闭塞高度
---@return number
function Destroyable:getOccluderHeight()
    if not isValid(self) then return 0 end
    return cj.GetDestructableOccluderHeight(self._handle)
end

--- 设置闭塞高度
---@param height number 高度
---@return Destroyable
function Destroyable:setOccluderHeight(height)
    if not isValid(self) or height == nil then return self end
    cj.SetDestructableOccluderHeight(self._handle, height)
    return self
end

------------------------------------------------------------------
-- 动画
------------------------------------------------------------------

--- 播放动画（队列式）
---@param animName string 动画名称
---@return Destroyable
function Destroyable:queueAnimation(animName)
    if not isValid(self) or animName == nil then return self end
    cj.QueueDestructableAnimation(self._handle, animName)
    return self
end

--- 立即设置动画
---@param animName string 动画名称
---@return Destroyable
function Destroyable:setAnimation(animName)
    if not isValid(self) or animName == nil then return self end
    cj.SetDestructableAnimation(self._handle, animName)
    return self
end

--- 设置动画速度
---@param speed number 速度倍率
---@return Destroyable
function Destroyable:setAnimationSpeed(speed)
    if not isValid(self) or speed == nil then return self end
    cj.SetDestructableAnimationSpeed(self._handle, speed)
    return self
end

------------------------------------------------------------------
-- 静态工具
------------------------------------------------------------------

--- 获取缓存中的所有 Destroyable 对象
---@return table
function Destroyable.getAll()
    local result = {}
    for _, obj in pairs(fromHandleCache) do
        if isValid(obj) then
            table.insert(result, obj)
        end
    end
    return result
end

--- 清理缓存中已失效的对象（定期调用）
function Destroyable.cleanInvalid()
    for key, obj in pairs(fromHandleCache) do
        if not isValid(obj) then
            fromHandleCache[key] = nil
        end
    end
end

--- 清空所有缓存
function Destroyable.clearAll()
    for key in pairs(fromHandleCache) do
        fromHandleCache[key] = nil
    end
end

------------------------------------------------------------------
-- 死亡事件
------------------------------------------------------------------

--- 为可破坏物注册死亡事件
--- @param self Destroyable 可破坏物对象
--- @param trig trigger 触发器对象
--- @return event 事件对象
--- @usage 
function Destroyable:registerDeathEvent(trig)
    if not isValid(self) or trig == nil then return nil end
    return cj.TriggerRegisterDeathEvent(trig, self._handle)
end

--- 取消死亡事件注册
--- @param self Destroyable 可破坏物对象
--- @param trig trigger 触发器对象
--- @return boolean 是否成功取消
function Destroyable:unregisterDeathEvent(trig)
    if not isValid(self) or trig == nil then return false end
    -- 使用空 widget 取消注册
    cj.TriggerRegisterDeathEvent(trig, nil)
    return true
end

--- 为多个可破坏物批量注册死亡事件
--- @param self Destroyable 可破坏物对象
--- @param trigs table 触发器表 { [widget1] = trig1, [widget2] = trig2, ... }
--- @return table 事件表 { [widget1] = event1, [widget2] = event2, ... }
--- @usage 
function Destroyable.batchRegisterDeathEvent(destructables, trigs)
    if #destructables ~= #trigs then return {} end
    local events = {}
    for i, destructable in ipairs(destructables) do
        if isValid(destructable) and trigs[i] then
            events[trigs[i]] = destructable:registerDeathEvent(trigs[i])
        end
    end
    return events
end

--- 批量取消死亡事件注册
--- @param self Destroyable 可破坏物对象
--- @param trigs table 触发器表 { [widget1] = trig1, [widget2] = trig2, ... }
--- @return boolean 是否全部取消成功
function Destroyable.batchUnregisterDeathEvent(destructables, trigs)
    local success = true
    for i, destructable in ipairs(destructables) do
        if trigs[i] then
            local ok = destructable:unregisterDeathEvent(trigs[i])
            if not ok then success = false end
        end
    end
    return success
end

------------------------------------------------------------------
-- 区域枚举
------------------------------------------------------------------

--- 枚举矩形区域内的所有可破坏物
--- @param r table|rect 矩形区域，可以是：
--- @param filter function|nil 过滤函数，接收 destructable 对象，返回 true 保留，false 跳过
--- @return table 可破坏物列表 {Destroyable, Destroyable, ...}
function Destroyable.EnumDestructablesInRect(r, filter)
    if type(r) == "table" then
        local minx = r.minx or r[1]
        local maxx = r.maxx or r[3]
        local miny = r.miny or r[2]
        local maxy = r.maxy or r[4]
        r = cj.CreateRect(minx, miny, maxx, maxy)
    end

    if type(r) ~= "rect" then return {} end

    local result = {}
    cj.EnumDestructablesInRect(r, nil, function(handle)
        local obj = Destroyable.fromHandle(handle)
        if obj and isValid(obj) then
            if not filter or filter(obj) then
                table.insert(result, obj)
            end
        end
        return true  -- 继续枚举
    end)

    return result
end

--- 枚举矩形区域内的可破坏物数量
--- @param r table|rect 矩形区域
--- @param filter function|nil 过滤函数
--- @return integer 数量
function Destroyable.EnumDestructablesInRectCount(r, filter)
    return #Destroyable.EnumDestructablesInRect(r, filter)
end

return Destroyable
