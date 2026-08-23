-- ============================================================
-- 属性按钮：攻击 / 护甲
--  · 原生攻击/护甲图标已按《原生UI详解》移出屏幕
--  · 按钮图标改为攻击/护甲图标（infocard-neutral-attack/armor-hero）
--  · 按钮右侧 标题(上)/数值(下) 实时显示 攻击力 X-Y / 护甲 X
--  · 仅“选中且有攻击”的单位才显示；悬停按钮弹对应全套数据
--  · 悬停攻击按钮 → 提示框显示攻击全部数据
--  · 悬停护甲按钮 → 提示框显示防御全部数据
-- ============================================================

local gameUI = Frame.getGameUI()
if gameUI == nil then return end

-- 确保 Tooltip 已初始化（其他 Frame 模块通常已提前 require）
if Tooltip._frame == nil then Tooltip.init() end

-- ------------------------------------------------------------
-- 把原生图标/文字移出屏幕（图片说明：部分 UI 需先缩小才能移动）
-- ------------------------------------------------------------
-- fType 按图片中的 UI 类型：frame=SimpleFrame / texture=SimpleTexture / font=SimpleFontString
-- 注：各 find 方法返回原生 handle，需 Frame.wrap 才能用 :setSize / :setAbsolutePoint
---@param fType string 框架类型（frame/texture/font）
---@param name string 框架名称
---@param id integer 框架 ID（如 0）
---@return Frame
local function moveNativeIconOffscreen(fType, name, id)
    local h
    if fType == "frame" then
        h = Frame.findSimpleFrame(name, id)
    elseif fType == "texture" then
        h = Frame.findSimpleTexture(name, id)
    elseif fType == "font" then
        h = Frame.findSimpleFontString(name, id)
    end
    if h == nil then return end
    local f = Frame.wrap(h)
    -- 先改小尺寸，再移到屏幕外，确保原生图标不遮挡自定义按钮
    f:setSize(1, 1)
    f:setAbsolutePoint(FRAME_ALIGN_LEFT_BOTTOM, -1000, -1000)
    return f
end

-- 攻击（SimpleTexture 图标 + SimpleFontString 标签/数值）
moveNativeIconOffscreen("texture", "InfoPanelIconBackdrop", 0)   -- 攻击图标
moveNativeIconOffscreen("font",    "InfoPanelIconLabel",    0)   -- 攻击标签
moveNativeIconOffscreen("font",    "InfoPanelIconValue",    0)   -- 攻击数值

-- 护甲（ID=2）
moveNativeIconOffscreen("texture", "InfoPanelIconBackdrop", 2)   -- 护甲图标
moveNativeIconOffscreen("font",    "InfoPanelIconLabel",    2)   -- 护甲标签
moveNativeIconOffscreen("font",    "InfoPanelIconValue",    2)   -- 护甲数值

-- 保险：把整个单位属性面板主框架（SimpleFrame）也移到屏幕外
--（图片说明该框架会随 F10 等事件重置位置，所以子控件也要单独处理）
-- moveNativeIconOffscreen("frame", "SimpleInfoPanelUnitDetail", 0)


-- ------------------------------------------------------------
-- 选中单位跟踪（仅本地玩家；“有攻击”才显示）
-- 沿用 ItemTooltip 的事件模式：SELECTED 记录 handle，DESELECTED 清空
-- ------------------------------------------------------------
StatTooltip = {}
StatTooltip._hover = nil          -- 当前悬停：nil / "atk" / "armor"
StatTooltip._selectedUnit = nil   -- 本地玩家当前选中单位 handle

Event:new(nil, EVENT_PLAYER_UNIT_SELECTED, function(e)
    local p = e.player
    local u = e.unit
    if p == nil or p ~= cj.GetLocalPlayer() then return end
    if u == nil then return end
    -- [DES20260808] 原实现在仅本机选择事件里用 Group:new():enumSelected(p)
    --   -> cj.CreateGroup() 建句柄，各机句柄计数分叉 -> 选中任意单位即 desync。
    --   StatTooltip 纯属本地 UI，直接记录选中单位，不再创建任何句柄。
    StatTooltip._selectedUnit = u
end)

Event:new(nil, EVENT_PLAYER_UNIT_DESELECTED, function(e)
    if e.player == nil or e.player ~= cj.GetLocalPlayer() then return end
    if e.unit ~= nil and e.unit == StatTooltip._selectedUnit then
        StatTooltip._selectedUnit = nil
    end
end)

-- 取得当前应显示的 unit：选中且“有攻击”才返回，否则 nil
-- （Hero 不继承 Unit，必须 Unit.fromHandle 包一层才能 getState / 读 .state）
local function getActiveUnit()
    local h = StatTooltip._selectedUnit
    if h == nil then return nil end
    -- local g = Group:new():enumSelected(cj.GetLocalPlayer())
    -- if g:getCount() > 1 then return nil end
    local u = Unit.fromHandle(h)
    if u == nil then return nil end
    local atkWhite = u:getState(UNIT_STATE_ATTACK_WHITE) or 0
    local atkRange = u:getState(UNIT_STATE_ATTACK_RANGE) or 0
    if atkWhite > 0 or atkRange > 0 then
        return u
    end
    return nil
end


-- ------------------------------------------------------------
-- 创建按钮（攻击 / 护甲）+ 图标 + 右侧数值文字
-- ------------------------------------------------------------
local ATK_ICON   = [[UI\Widgets\Console\Human\infocard-neutral-attack-hero.blp]]
local ARMOR_ICON = [[UI\Widgets\Console\Human\infocard-neutral-armor-medium.blp]]

-- 攻击按钮
local btn1 = Frame:newByTag("BUTTON", "TestBtnAtk", gameUI)
if btn1._handle == nil then return end
btn1:setSize(66, 50)
btn1:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, 754, 932)

local icon1 = Frame:newByTag("BACKDROP", "TestBtnAtk_Icon", btn1)
if icon1._handle == nil then return end
icon1:setAllPoints(btn1)
icon1:setTexture(ATK_ICON, 0)

-- 护甲按钮
local btn2 = Frame:newByTag("BUTTON", "TestBtnArmor", gameUI)
if btn2._handle == nil then return end
btn2:setSize(66, 50)
btn2:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, 754, 989)

local icon2 = Frame:newByTag("BACKDROP", "TestBtnArmor_Icon", btn2)
if icon2._handle == nil then return end
icon2:setAllPoints(btn2)
icon2:setTexture(ARMOR_ICON, 0)

-- 右侧数值文字（标题在上、数值在下，均相对图标右侧）
local NATIVE_FONT = "Fonts\\dfst-m3u.ttf"        -- 空串 = 原生字体（不加载自定义 TTF）
local NATIVE_SIZE = 0.008     -- 字号与原生单位面板相仿（比 Tooltip 略小）

-- 基础暴击倍率（与 GameDamage.lua 一致）：暴击伤害默认 +200%
local BASE_CRIT_MULT = 2.0

-- 攻击：标题（左上 相对 图标右上）
local atkTitle = Frame:newByTag("TEXT", "StatAtkTitle", gameUI)
if atkTitle._handle == nil then return end
atkTitle:setSize(200, 20)
atkTitle:setFont(NATIVE_FONT, NATIVE_SIZE, 0)
atkTitle:setTextColor(0xFFFFFFFF)
atkTitle:setPoint(FRAME_ALIGN_LEFT_TOP, icon1, FRAME_ALIGN_RIGHT_TOP, 6, 3)
atkTitle:setText("|cffFFE28C攻击力：|r")

-- 攻击：数值（左下 相对 图标右下）
local atkValue = Frame:newByTag("TEXT", "StatAtkValue", gameUI)
if atkValue._handle == nil then return end
atkValue:setSize(200, 20)
atkValue:setFont(NATIVE_FONT, NATIVE_SIZE, 0)
atkValue:setTextColor(0xFFFFFFFF)
atkValue:setPoint(FRAME_ALIGN_LEFT_BOTTOM, icon1, FRAME_ALIGN_RIGHT_BOTTOM, 6, -5)
atkValue:setText("-")

-- 护甲：标题（左上 相对 图标右上）
local armorTitle = Frame:newByTag("TEXT", "StatArmorTitle", gameUI)
if armorTitle._handle == nil then return end
armorTitle:setSize(200, 20)
armorTitle:setFont(NATIVE_FONT, NATIVE_SIZE, 0)
armorTitle:setTextColor(0xFFFFFFFF)
armorTitle:setPoint(FRAME_ALIGN_LEFT_TOP, icon2, FRAME_ALIGN_RIGHT_TOP, 6, 3)
armorTitle:setText("|cffFFE28C护甲：|r")

-- 护甲：数值（左下 相对 图标右下）
local armorValue = Frame:newByTag("TEXT", "StatArmorValue", gameUI)
if armorValue._handle == nil then return end
armorValue:setSize(200, 20)
armorValue:setFont(NATIVE_FONT, NATIVE_SIZE, 0)
armorValue:setTextColor(0xFFFFFFFF)
armorValue:setPoint(FRAME_ALIGN_LEFT_BOTTOM, icon2, FRAME_ALIGN_RIGHT_BOTTOM, 6, -5)
armorValue:setText("-")

-- 面板整体显隐（选中且有攻击才显示）
local function setPanelVisible(v)
    if v then
        btn1:show(); btn2:show()
        atkTitle:show(); atkValue:show()
        armorTitle:show(); armorValue:show()
    else
        btn1:hide(); btn2:hide()
        atkTitle:hide(); atkValue:hide()
        armorTitle:hide(); armorValue:hide()
    end
end
setPanelVisible(false)   -- 初始隐藏，等选中单位


-- ------------------------------------------------------------
-- 数据构造（攻击 / 防御全套）
-- ------------------------------------------------------------
local function fmtAtk(hero)
    local base = math.floor(hero:getState(UNIT_STATE_ATTACK_WHITE) or 0)
    local maxA = math.floor(hero:getState(UNIT_STATE_ATTACK_MAX) or 0)
    if maxA <= base then maxA = base end
    local space = hero:getState(UNIT_STATE_ATTACK_SPACE) or 0
    local speed = hero:getState(UNIT_STATE_ATTACK_SPEED) or 0
    local critP  = hero.state.critPhys   or 0
    local critM  = hero.state.critMag    or 0
    local amp    = hero.state.attackStr  or 0
    local mamp   = hero.state.magicAmp   or 0
    local cdmgP  = hero.state.critDmgPhys or 0
    local cdmgM  = hero.state.critDmgMag  or 0
    local penP   = hero.state.penPhys    or 0
    local penM   = hero.state.penMag     or 0
    -- 配色：字段名=原生金，数值=攻击红
    local L = "|cffFFE28C"   -- 字段名（相仿原生标签金）
    local A = "|cffFF9999"   -- 攻击数值（红）
    local R = "|r"
    -- 灰白色说明文字：属性作用解释
    local G = "|cFFaaaaaa"   -- 说明文字（灰白）
    return string.format(
        L.."物理攻击：|r "..A.."%d - %d|r\n"..
        L.."攻击强化：|r "..A.."%d|r\n"..
        G.."每1000点提升100%%最终伤害|r\n"..
        L.."魔法强化：|r "..A.."%d|r\n"..
        G.."每1000点提升100%%魔法伤害|r\n\n"..
        L.."物理穿透：|r "..A.."%d|r\n"..
        L.."魔法穿透：|r "..A.."%d|r\n"..
        G.."直接抵消目标部分物理/魔法防御|r\n\n"..
        L.."物理暴击：|r "..A.."%d%%|r\n"..
        L.."魔法暴击：|r "..A.."%d%%|r\n"..
        L.."暴击伤害：|r "..A.."%d%%/%d%%|r\n\n"..
        L.."攻击间隔：|r "..A.."%.2f 秒|r\n"..
        L.."攻击速度：|r "..A.."%d%%|r\n",

        base, maxA,
        math.floor(amp),
        math.floor(mamp),
        math.floor(penP), math.floor(penM),
        math.floor(critP), math.floor(critM),
        math.floor(BASE_CRIT_MULT * 100) + math.floor(cdmgP),
        math.floor(BASE_CRIT_MULT * 100) + math.floor(cdmgM),
        space,
        math.floor(speed * 100))
end

local function fmtDef(hero)
    local armor    = math.floor(hero:getState(UNIT_STATE_DEFEND_WHITE) or 0)
    local resMag   = math.floor(hero.state.resMag or 0)
    local moveSpd  = math.floor(hero:getMoveSpeed() or 0)
    local lifeReg  = 0
    local manaReg  = 0
    if cdz and cdz.DzGetUnitLifeRegen then
        lifeReg = cdz.DzGetUnitLifeRegen(hero._handle) or 0
    end
    if cdz and cdz.DzGetUnitManaRegen then
        manaReg = cdz.DzGetUnitManaRegen(hero._handle) or 0
    end
    -- 配色：字段名=原生金，数值=防御蓝
    local L = "|cffFFE28C"   -- 字段名（相仿原生标签金）
    local D = "|cff99CCFF"   -- 防御数值（蓝）
    local R = "|r"
    return string.format(
        L.."物理抗性：|r "..D.."%d|r\n"..
        L.."魔法抗性：|r "..D.."%d|r\n\n"..
        L.."移动速度：|r "..D.."%d|r\n\n"..
        L.."生命恢复：|r "..D.."%.1f|r\n"..
        L.."魔法恢复：|r "..D.."%.1f|r",
        armor, resMag, moveSpd, lifeReg, manaReg)
end

-- 刷新右侧数值（每帧，仅更新数值文本）
local function refreshValues(u)
    local white = math.floor(u:getState(UNIT_STATE_ATTACK_WHITE) or 0)
    local maxA  = math.floor(u:getState(UNIT_STATE_ATTACK_MAX) or 0)
    if maxA <= white then maxA = white end   -- 无浮动范围时保护，避免 X - 0
    atkValue:setText(string.format("%d - %d", white, maxA))
    local armor = math.floor(u:getState(UNIT_STATE_DEFEND_WHITE) or 0)
    armorValue:setText(string.format("%d", armor))
end


-- ------------------------------------------------------------
-- 悬停事件（内容随当前显示单位变化）
-- ------------------------------------------------------------
btn1:onEvent(MOUSE_ORDER_ENTER, function()
    StatTooltip._hover = "atk"
    local u = getActiveUnit()
    if u then Tooltip.show("|cffFF8888攻击|r", fmtAtk(u)) end
end)
btn1:onEvent(MOUSE_ORDER_LEAVE, function()
    StatTooltip._hover = nil
    Tooltip.hide()
end)

btn2:onEvent(MOUSE_ORDER_ENTER, function()
    StatTooltip._hover = "armor"
    local u = getActiveUnit()
    if u then Tooltip.show("|cff88BBFF防御|r", fmtDef(u)) end
end)
btn2:onEvent(MOUSE_ORDER_LEAVE, function()
    StatTooltip._hover = nil
    Tooltip.hide()
end)

-- ------------------------------------------------------------
-- 每帧刷新（显隐 + 数值变化 + 悬停时 tooltip 实时刷新）
-- ------------------------------------------------------------
Tooltip.addUpdateHook(function()
    local u = getActiveUnit()
    setPanelVisible(u ~= nil)
    if u == nil then
        if StatTooltip._hover ~= nil then
            StatTooltip._hover = nil
            Tooltip.hide()
        end
        return
    end
    refreshValues(u)
    if StatTooltip._hover == "atk" then
        Tooltip.show("|cffFF8888攻击|r", fmtAtk(u))
    elseif StatTooltip._hover == "armor" then
        Tooltip.show("|cff88BBFF防御|r", fmtDef(u))
    end
end)
