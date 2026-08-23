-- ============================================================
-- Visibility 类 — 可见度修正器
-- 调用方式：
--   local v = Visibility.newRect(Player:new(0), rect, FOG_OF_WAR_VISIBLE)
--   v:start()
--   local v2 = Visibility.newRadius(Player:new(0), x, y, 1200, FOG_OF_WAR_VISIBLE)
--   v2:start()
--   v:stop():destroy()
--
--   Visibility.fromHandle(h)  -- 从 handle 还原（静态，用点号）
-- ============================================================

---@class Visibility 可见度修正器
Visibility = {}
Visibility.__index = Visibility

local function newVisibility()
    local obj = { _handle = nil }
    setmetatable(obj, Visibility)
    return obj
end

--- 解析 Player 参数为 player handle
---@param p Player|userdata|number|nil
---@return userdata|nil
local function resolvePlayer(p)
    if p == nil then return nil end
    if type(p) == "number" then
        return cj.Player(p)
    end
    if type(p) == "table" and p._handle ~= nil then
        return p._handle
    end
    return p
end

-----------------------------------------------------------------
-- 构造
-----------------------------------------------------------------

--- 创建矩形区域可见度修正器（未自动启用，需 :start()）
---@param player Player|userdata 玩家对象或 handle
---@param rect Rect|userdata 矩形对象或 handle
---@param fogState fogstate|nil 迷雾状态（默认 FOG_OF_WAR_VISIBLE）
---@param useSharedVision boolean|nil 是否共享视野（默认 true）
---@param afterUnits boolean|nil 是否在单位之后（默认 false）
---@return Visibility|nil
function Visibility.newRect(player, rect, fogState, useSharedVision, afterUnits)
    local pHandle = resolvePlayer(player)
    if pHandle == nil or rect == nil then return nil end
    local rHandle = rect._handle or rect
    if rHandle == nil then return nil end
    fogState = fogState or FOG_OF_WAR_VISIBLE
    if useSharedVision == nil then useSharedVision = true end
    if afterUnits == nil then afterUnits = false end
    local obj = newVisibility()
    obj._handle = cj.CreateFogModifierRect(pHandle, fogState, rHandle, useSharedVision, afterUnits)
    return obj
end

--- 创建圆形范围可见度修正器（未自动启用，需 :start()）
---@param player Player|userdata
---@param x number 圆心X
---@param y number 圆心Y
---@param radius number 半径
---@param fogState fogstate|nil
---@param useSharedVision boolean|nil
---@param afterUnits boolean|nil
---@return Visibility|nil
function Visibility.newRadius(player, x, y, radius, fogState, useSharedVision, afterUnits)
    local pHandle = resolvePlayer(player)
    if pHandle == nil or x == nil or y == nil or radius == nil then return nil end
    fogState = fogState or FOG_OF_WAR_VISIBLE
    if useSharedVision == nil then useSharedVision = true end
    if afterUnits == nil then afterUnits = false end
    local obj = newVisibility()
    obj._handle = cj.CreateFogModifierRadius(pHandle, fogState, x, y, radius, useSharedVision, afterUnits)
    return obj
end

--- 从已有 handle 创建对象
---@param h userdata fogmodifier handle
---@return Visibility|nil
function Visibility.fromHandle(h)
    if h == nil then return nil end
    local obj = newVisibility()
    obj._handle = h
    return obj
end

-----------------------------------------------------------------
-- 控制
-----------------------------------------------------------------

--- 启用可见度修正器
---@return Visibility
function Visibility:start()
    if self._handle ~= nil then
        cj.FogModifierStart(self._handle)
    end
    return self
end

--- 禁用可见度修正器
---@return Visibility
function Visibility:stop()
    if self._handle ~= nil then
        cj.FogModifierStop(self._handle)
    end
    return self
end

--- 销毁可见度修正器
---@return Visibility
function Visibility:destroy()
    if self._handle ~= nil then
        cj.DestroyFogModifier(self._handle)
        self._handle = nil
    end
    return self
end
