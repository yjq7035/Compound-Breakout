-- ============================================================
-- Weather 类 — 天气效果
-- 通过 common.lua / KK_japi.lua 已注册函数封装
-- 调用方式：
--   local w = Weather:new(rect, FourCC("RAlr"))
--   w:enable()
--   w:disable()
--   w:remove()
-- ============================================================

WEATHER_SUN         = c2i("LRaa") --日光
WEATHER_MOON        = c2i("LRma") --月光
WEATHER_SHIELD      = c2i("MEds") --紫光盾
WEATHER_RAIN        = c2i("RAlr") --雨
WEATHER_RAINSTORM   = c2i("RAhr") --大雨
WEATHER_SNOW        = c2i("SNls") --雪
WEATHER_SNOWSTORM   = c2i("SNhs") --大雪
WEATHER_WIND        = c2i("WOlw") --风  
WEATHER_WINDSTORM   = c2i("WNcw") --大风
WEATHER_MIST_WHITE  = c2i("FDwh") --白雾
WEATHER_MIST_GREEN  = c2i("FDgh") --绿雾
WEATHER_MIST_BLUE   = c2i("FDbh") --蓝雾
WEATHER_MIST_RED    = c2i("FDrh") --红雾



---@class Weather 天气效果
Weather = {}
Weather.__index = Weather
Weather._handle = nil

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newWeather()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Weather)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建天气效果
---@param where rect 区域
---@param effectID integer 效果ID（可用 FourCC 转换，如 FourCC("RAlr") 雷雨）
---@return Weather
function Weather:new(where, effectID)
    if (where == nil or effectID == nil) then return end
    local obj = newWeather()
    obj._handle = cj.AddWeatherEffect(where, effectID)
    obj._where = where
    obj._effectID = effectID
    return obj
end

--- 从已有 handle 创建 Weather 对象
---@param h userdata weathereffect handle
---@return Weather
function Weather.fromHandle(h)
    if (h == nil) then return end
    local obj = newWeather()
    obj._handle = h
    return obj
end

--- 删除天气效果
---@return Weather
function Weather:remove()
    if (self._handle ~= nil) then
        cj.RemoveWeatherEffect(self._handle)
        self._handle = nil
    end
    return self
end

-----------------------------------------------------------------
-- 启用 / 禁用
-----------------------------------------------------------------

--- 设置启用/禁用
---@param enable boolean true=启用 false=禁用
---@return Weather
function Weather:setEnable(enable)
    if (self._handle ~= nil and enable ~= nil) then
        cj.EnableWeatherEffect(self._handle, enable)
    end
    return self
end

--- 启用天气效果
---@return Weather
function Weather:enable()
    return self:setEnable(true)
end

--- 禁用天气效果
---@return Weather
function Weather:disable()
    return self:setEnable(false)
end
