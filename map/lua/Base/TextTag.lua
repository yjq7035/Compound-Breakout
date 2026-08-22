-- ============================================================
-- TextTag 类 — 漂浮文字
-- 调用方式：
--   local tt = TextTag:new("+100", 0, 0, 10)
--   tt:setColor(255, 0, 0, 255)
--   tt:setLifespan(3):setFadepoint(1):show()
-- ============================================================

---@class TextTag 漂浮文字
TextTag = {}
TextTag.__index = TextTag
TextTag._handle = nil




-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newTag()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, TextTag)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建漂浮文字
---@param text string 文字内容
---@param x number X坐标
---@param y number Y坐标
---@param heightOffset number|nil Z高度偏移（默认0）
---@param fontSize number|nil 字号（默认10）
---@return TextTag
function TextTag:new(text, x, y, heightOffset, fontSize)
    if (text == nil) then return end
    local obj = newTag()
    obj._handle = cj.CreateTextTag()
    fontSize = fontSize or 10
    cj.SetTextTagText(obj._handle, text, fontSize)
    cj.SetTextTagPos(obj._handle, x or 0, y or 0, heightOffset or 0)
    return obj
end

--- 创建绑定到单位的漂浮文字
---@param text string 文字内容
---@param unit userdata 单位handle
---@param heightOffset number|nil Z高度偏移
---@param fontSize number|nil 字号
---@return TextTag
function TextTag:newUnit(text, unit, heightOffset, fontSize)
    if (text == nil or unit == nil) then return end
    local obj = newTag()
    obj._handle = cj.CreateTextTag()
    fontSize = fontSize or 10
    cj.SetTextTagText(obj._handle, text, fontSize)
    cj.SetTextTagPosUnit(obj._handle, unit, heightOffset or 0)
    return obj
end

--- 从 handle 创建
---@param h userdata texttag handle
---@return TextTag
function TextTag.fromHandle(h)
    if (h == nil) then return end
    local obj = newTag()
    obj._handle = h
    return obj
end

--- 销毁
---@return TextTag
function TextTag:destroy()
    if (self._handle ~= nil) then
        cj.DestroyTextTag(self._handle)
        self._handle = nil
    end
    return self
end

-----------------------------------------------------------------
-- 文字内容
-----------------------------------------------------------------

--- 设置文字内容
---@param text string 文字
---@param fontSize number|nil 字号（默认10）
---@return TextTag
function TextTag:setText(text, fontSize)
    if (self._handle ~= nil and text ~= nil) then
        cj.SetTextTagText(self._handle, text, fontSize or 10)
    end
    return self
end

-----------------------------------------------------------------
-- 位置
-----------------------------------------------------------------

--- 设置坐标位置
---@param x number X
---@param y number Y
---@param heightOffset number|nil Z偏移
---@return TextTag
function TextTag:setPos(x, y, heightOffset)
    if (self._handle ~= nil) then
        cj.SetTextTagPos(self._handle, x, y, heightOffset or 0)
    end
    return self
end

--- 绑定到单位位置
---@param unit userdata
---@param heightOffset number|nil Z偏移
---@return TextTag
function TextTag:setPosUnit(unit, heightOffset)
    if (self._handle ~= nil and unit ~= nil) then
        cj.SetTextTagPosUnit(self._handle, unit, heightOffset or 0)
    end
    return self
end

-----------------------------------------------------------------
-- 生命周期 / 显示
-----------------------------------------------------------------

--- 设置显示时间（秒）
---@param lifespan number
---@return TextTag
function TextTag:setLifespan(lifespan)
    if (self._handle ~= nil) then
        cj.SetTextTagLifespan(self._handle, lifespan or 0)
    end
    return self
end

--- 设置消逝时间点（秒）
---@param fadepoint number
---@return TextTag
function TextTag:setFadepoint(fadepoint)
    if (self._handle ~= nil) then
        cj.SetTextTagFadepoint(self._handle, fadepoint or 0)
    end
    return self
end

--- 设置已存在时间（秒）
---@param age number
---@return TextTag
function TextTag:setAge(age)
    if (self._handle ~= nil) then
        cj.SetTextTagAge(self._handle, age or 0)
    end
    return self
end

--- 设置永久显示
---@param permanent boolean
---@return TextTag
function TextTag:setPermanent(permanent)
    if (self._handle ~= nil) then
        cj.SetTextTagPermanent(self._handle, (permanent ~= nil) and permanent or true)
    end
    return self
end

--- 显示/隐藏（所有玩家）
---@param visible boolean
---@return TextTag
function TextTag:show(visible)
    if (self._handle ~= nil) then
        cj.SetTextTagVisibility(self._handle, (visible ~= nil) and visible or true)
    end
    return self
end

--- 暂停/恢复生命周期
---@param suspended boolean
---@return TextTag
function TextTag:setSuspended(suspended)
    if (self._handle ~= nil) then
        cj.SetTextTagSuspended(self._handle, (suspended ~= nil) and suspended or true)
    end
    return self
end

-----------------------------------------------------------------
-- 颜色 / 视觉效果
-----------------------------------------------------------------

--- 设置颜色
---@param red integer 0-255
---@param green integer 0-255
---@param blue integer 0-255
---@param alpha integer 0-255
---@return TextTag
function TextTag:setColor(red, green, blue, alpha)
    if (self._handle ~= nil) then
        cj.SetTextTagColor(self._handle, red or 255, green or 255, blue or 255, alpha or 255)
    end
    return self
end

--- 设置移动速度
---@param xvel number X方向速度
---@param yvel number Y方向速度
---@return TextTag
function TextTag:setVelocity(xvel, yvel)
    if (self._handle ~= nil) then
        cj.SetTextTagVelocity(self._handle, xvel or 0, yvel or 0)
    end
    return self
end

-----------------------------------------------------------------
-- KK_japi 扩展
-----------------------------------------------------------------

--- 设置字体
---@param fontName string 字体名（如 "war3mapImported\\myfont.ttf"）
---@param fontSize number 字号
---@return TextTag
function TextTag:setFont(fontName, fontSize)
    if (self._handle ~= nil) then
        cdz.DzTextTagSetFont(self._handle, fontName, fontSize or 10)
    end
    return self
end

--- 获取字体名
---@return string
function TextTag:getFont()
    if (self._handle == nil) then return "" end
    return cdz.DzTextTagGetFont(self._handle)
end

--- 设置阴影颜色
---@param color integer RGBA颜色值
---@return TextTag
function TextTag:setShadowColor(color)
    if (self._handle ~= nil and color ~= nil) then
        cdz.DzTextTagSetShadowColor(self._handle, color)
    end
    return self
end

--- 获取阴影颜色
---@return integer
function TextTag:getShadowColor()
    if (self._handle == nil) then return 0 end
    return cdz.DzTextTagGetShadowColor(self._handle)
end

--- 设置起始透明度
---@param alpha integer 0-255
---@return TextTag
function TextTag:setStartAlpha(alpha)
    if (self._handle ~= nil and alpha ~= nil) then
        cdz.DzTextTagSetStartAlpha(self._handle, alpha)
    end
    return self
end

--- 获取起始透明度
---@return integer
function TextTag:getStartAlpha()
    if (self._handle == nil) then return 255 end
    return cdz.DzTextTagGetStartAlpha(self._handle)
end

-----------------------------------------------------------------
-- 哈希表
-----------------------------------------------------------------

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function TextTag:save(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveTextTagHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return TextTag
function TextTag.load(t, pk, ck)
    local h = cj.LoadTextTagHandle(t, pk, ck)
    if (h == nil) then return end
    return TextTag.fromHandle(h)
end
