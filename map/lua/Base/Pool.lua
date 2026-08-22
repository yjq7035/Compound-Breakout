-- ============================================================
-- ItemPool / UnitPool 类 — 物品池与单位池
-- 通过 common.lua 已注册函数封装
-- 调用方式：
--   local ip = ItemPool:new()
--   ip:addType(FourCC("I000"), 1)
--   ip:addType(FourCC("I001"), 2)
--   local item = ip:placeRandom(512, 512)
--   ip:destroy()
--
--   local up = UnitPool:new()
--   up:addType(FourCC("hfoo"), 1)
--   local unit = up:placeRandom(Player(0), 512, 512, 270)
--   up:destroy()
-- ============================================================

-----------------------------------------------------------------
-- ItemPool 类 — 物品池
-- ============================================================

---@class ItemPool 物品池
ItemPool = {}
ItemPool.__index = ItemPool

local function newItemPool()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, ItemPool)
    return obj
end

--- 创建物品池
---@return ItemPool
function ItemPool:new()
    local obj = newItemPool()
    obj._handle = cj.CreateItemPool()
    return obj
end

--- 从已有 handle 创建 ItemPool 对象
---@param h userdata itempool handle
---@return ItemPool
function ItemPool.fromHandle(h)
    if (h == nil) then return end
    local obj = newItemPool()
    obj._handle = h
    return obj
end

--- 添加物品类型到池中
---@param itemId integer 物品ID
---@param weight number 权重（越高越容易被随机选中）
---@return ItemPool
function ItemPool:addType(itemId, weight)
    if (self._handle ~= nil and itemId ~= nil) then
        cj.ItemPoolAddItemType(self._handle, itemId, weight or 1)
    end
    return self
end

--- 从池中移除物品类型
---@param itemId integer 物品ID
---@return ItemPool
function ItemPool:removeType(itemId)
    if (self._handle ~= nil and itemId ~= nil) then
        cj.ItemPoolRemoveItemType(self._handle, itemId)
    end
    return self
end

--- 随机放置一个物品到坐标位置
---@param x number
---@param y number
---@return userdata item
function ItemPool:placeRandom(x, y)
    if (self._handle == nil) then return end
    return cj.PlaceRandomItem(self._handle, x, y)
end

--- 销毁物品池
---@return ItemPool
function ItemPool:destroy()
    if (self._handle ~= nil) then
        cj.DestroyItemPool(self._handle)
        self._handle = nil
    end
    return self
end

--- 保存 itempool handle 到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function ItemPool:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveItemPoolHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取 itempool handle 并返回 ItemPool 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return ItemPool
function ItemPool.loadHandle(t, pk, ck)
    local h = cj.LoadItemPoolHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newItemPool()
    obj._handle = h
    return obj
end


-----------------------------------------------------------------
-- UnitPool 类 — 单位池
-- ============================================================

---@class UnitPool 单位池
UnitPool = {}
UnitPool.__index = UnitPool

local function newUnitPool()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, UnitPool)
    return obj
end

--- 创建单位池
---@return UnitPool
function UnitPool:new()
    local obj = newUnitPool()
    obj._handle = cj.CreateUnitPool()
    return obj
end

--- 从已有 handle 创建 UnitPool 对象
---@param h userdata unitpool handle
---@return UnitPool
function UnitPool.fromHandle(h)
    if (h == nil) then return end
    local obj = newUnitPool()
    obj._handle = h
    return obj
end

--- 添加单位类型到池中
---@param unitId integer 单位ID
---@param weight number 权重
---@return UnitPool
function UnitPool:addType(unitId, weight)
    if (self._handle ~= nil and unitId ~= nil) then
        cj.UnitPoolAddUnitType(self._handle, unitId, weight or 1)
    end
    return self
end

--- 从池中移除单位类型
---@param unitId integer 单位ID
---@return UnitPool
function UnitPool:removeType(unitId)
    if (self._handle ~= nil and unitId ~= nil) then
        cj.UnitPoolRemoveUnitType(self._handle, unitId)
    end
    return self
end

--- 随机放置一个单位到坐标位置
---@param whichPlayer userdata 单位所属玩家
---@param x number
---@param y number
---@param facing number|nil 面向角度
---@return userdata unit
function UnitPool:placeRandom(whichPlayer, x, y, facing)
    if (self._handle == nil or whichPlayer == nil) then return end
    return cj.PlaceRandomUnit(self._handle, whichPlayer, x, y, facing or 0)
end

--- 销毁单位池
---@return UnitPool
function UnitPool:destroy()
    if (self._handle ~= nil) then
        cj.DestroyUnitPool(self._handle)
        self._handle = nil
    end
    return self
end

--- 保存 unitpool handle 到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function UnitPool:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveUnitPoolHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取 unitpool handle 并返回 UnitPool 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return UnitPool
function UnitPool.loadHandle(t, pk, ck)
    local h = cj.LoadUnitPoolHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newUnitPool()
    obj._handle = h
    return obj
end
