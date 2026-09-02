-- ============================================================
-- Rect 类 — 矩形区域
-- 调用方式：
--   local r = Rect:new(0, 0, 128, 128)
--   local cx = r:getCenterX()
--   r:moveTo(256, 256)
--   Rect.playable()       -- 获取可玩地图区域
-- ============================================================

---@class Rect 矩形区域
Rect = {}
Rect.__index = Rect
Rect._handle = nil

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newRect()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Rect)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建矩形区域（通过边角坐标）
---@param minX number 左下X
---@param minY number 左下Y
---@param maxX number 右上X
---@param maxY number 右上Y
---@return Rect
function Rect:new(minX, minY, maxX, maxY)
    local obj = newRect()
    obj._handle = cj.Rect(minX, minY, maxX, maxY)
    return obj
end

--- 创建矩形区域（通过中心 + 宽高）
---@param cx number 中心X
---@param cy number 中心Y
---@param w number 宽度
---@param h number 高度
---@return Rect
function Rect:newCenter(cx, cy, w, h)
    local halfW = w / 2
    local halfH = h / 2
    return Rect:new(cx - halfW, cy - halfH, cx + halfW, cy + halfH)
end

--- 从已有 handle 创建 Rect 对象
---@param h userdata rect handle
---@return Rect
function Rect.fromHandle(h)
    if (h == nil) then return end
    local obj = newRect()
    obj._handle = h
    return obj
end

--- 销毁
---@param delay number|nil 延迟秒数（nil或<=0=立即）
---@return Rect
function Rect:destroy(delay)
    if (self._handle == nil) then return self end
    delay = delay or 0
    if (delay <= 0) then
        cj.RemoveRect(self._handle)
        self._handle = nil
    else
        Timer:new(delay, false, function()
            if (self._handle ~= nil) then
                cj.RemoveRect(self._handle)
                self._handle = nil
            end
        end)
    end
    return self
end

-----------------------------------------------------------------
-- 位置 / 大小
-----------------------------------------------------------------

--- 获取左下角X
---@return number
function Rect:getMinX()
    if (self._handle == nil) then return 0 end
    return cj.GetRectMinX(self._handle)
end

--- 获取左下角Y
---@return number
function Rect:getMinY()
    if (self._handle == nil) then return 0 end
    return cj.GetRectMinY(self._handle)
end

--- 获取右上角X
---@return number
function Rect:getMaxX()
    if (self._handle == nil) then return 0 end
    return cj.GetRectMaxX(self._handle)
end

--- 获取右上角Y
---@return number
function Rect:getMaxY()
    if (self._handle == nil) then return 0 end
    return cj.GetRectMaxY(self._handle)
end

--- 获取中心X
---@return number
function Rect:getCenterX()
    if (self._handle == nil) then return 0 end
    return cj.GetRectCenterX(self._handle)
end

--- 获取中心Y
---@return number
function Rect:getCenterY()
    if (self._handle == nil) then return 0 end
    return cj.GetRectCenterY(self._handle)
end

--- 获取宽度
---@return number
function Rect:getWidth()
    if (self._handle == nil) then return 0 end
    return self:getMaxX() - self:getMinX()
end

--- 获取高度
---@return number
function Rect:getHeight()
    if (self._handle == nil) then return 0 end
    return self:getMaxY() - self:getMinY()
end

-----------------------------------------------------------------
-- 移动 / 设置
-----------------------------------------------------------------

--- 移动矩形区域中心到坐标
---@param cx number 新中心X
---@param cy number 新中心Y
---@return Rect
function Rect:moveTo(cx, cy)
    if (self._handle ~= nil) then
        cj.MoveRectTo(self._handle, cx, cy)
    end
    return self
end

--- 设置矩形区域边角坐标
---@param minX number
---@param minY number
---@param maxX number
---@param maxY number
---@return Rect
function Rect:set(minX, minY, maxX, maxY)
    if (self._handle ~= nil) then
        cj.SetRect(self._handle, minX, minY, maxX, maxY)
    end
    return self
end

-----------------------------------------------------------------
-- 包含判断
-----------------------------------------------------------------

--- 点是否在矩形内
---@param x number X
---@param y number Y
---@return boolean
function Rect:contains(x, y)
    if (self._handle == nil) then return false end
    return x >= self:getMinX() and x <= self:getMaxX()
       and y >= self:getMinY() and y <= self:getMaxY()
end

-----------------------------------------------------------------
-- 预定义区域
-------------------------------------------------------------------

--- 获取完整地图区域
---@return Rect
function Rect.world()
    return Rect.fromHandle(cj.GetWorldBounds())
end

--- 获取可玩地图区域 (bj_mapInitialPlayableArea 无法使用，暂时用GetWorldBounds)
---@return Rect
function Rect.playable()
    return Rect.fromHandle(cj.GetWorldBounds())
end

-----------------------------------------------------------------
-- 枚举（简化包装）
-----------------------------------------------------------------

--- 枚举矩形内的可破坏物
---@param action fun() 回调函数
function Rect:enumDestructables(action)
    if (self._handle == nil) then return end
    cj.EnumDestructablesInRect(self._handle, nil or nil, action)
end

--- 枚举矩形内的物品
---@param filter boolexpr|nil
---@param action fun()
function Rect:enumItems(filter, action)
    if (self._handle == nil) then return end
    cj.EnumItemsInRect(self._handle, filter or nil, action)
end


-----------------------------------------------------------------
-- 哈希表
-----------------------------------------------------------------

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Rect:save(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveRectHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Rect
function Rect.load(t, pk, ck)
    local h = cj.LoadRectHandle(t, pk, ck)
    if (h == nil) then return end
    return Rect.fromHandle(h)
end
