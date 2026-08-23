-- ============================================================
-- Tooltip — 通用鼠标提示框
-- 背景：FDF 定义（带黄边框的半透明黑色，参考 _sl_border_backdrop）
-- TEXT：Lua 手工创建（避免 FDF FramePoint 导致的 GetLayoutFrame）
-- 功能：
--   1. Tooltip.show(title, desc) — 通用显示
--   2. Tooltip.showBuff(buffCode) — 快捷显示 Buff 信息
--   3. Tooltip.attach(frame, contentFn) — 挂载到按钮自动显隐
--   4. 自行管理帧更新，无需外部调用 onFrameUpdate
--   5. 其他模块通过 Tooltip.addUpdateHook(fn) 注册帧回调
--
-- FDF：map/UI/CustomTooltip.fdf → CustomTooltip (FRAME) → CTooltipBg (BACKDROP)
-- ============================================================
-- 
Frame.loadToc("UI\\CustomTooltip.toc")

---@class Tooltip
Tooltip = {}

-- ============================================================
-- 常量
-- ============================================================
Tooltip.WIDTH         = 225          -- 提示框宽度（像素，对应 FDF Width 0.068 * 2400）
Tooltip.LINE_HEIGHT   = 18           -- 每行高度（像素）
Tooltip.PADDING       = 6            -- 内边距（像素）
Tooltip.FONT_PATH     = "UI\\Fonts\\ARHei.TTF"
Tooltip.FONT_SIZE     = 0.014

-- ============================================================
-- 内部状态
-- ============================================================
Tooltip._frame   = nil   -- FRAME 根（FDF: CustomTooltip）
Tooltip._bg      = nil   -- BACKDROP 背景（FDF: CTooltipBg，带黄边框）
Tooltip._title   = nil   -- TEXT 标题
Tooltip._desc    = nil   -- TEXT 描述
Tooltip._visible = false
Tooltip._hooks   = {}    -- 外部帧更新回调列表

-----------------------------------------------------------------
-- 初始化
-----------------------------------------------------------------
function Tooltip.init()
    local gameUI = Frame.getGameUI()
    if gameUI == nil then
        print("[Tooltip] 无法获取 GameUI")
        return false
    end

    -- 创建根 FRAME
    Tooltip._frame = Frame:newByTag("FRAME", "", gameUI)
    -- 创建 BACKDROP（使用 FDF 中的 CTooltipBg 模板）
    Tooltip._bg = Frame:newByTag("BACKDROP", "", Tooltip._frame, "CTooltipBg", 0)
    
    Tooltip._bg:setSize(Tooltip.WIDTH, -1)
    -- 创建 TEXT 控件
    Tooltip._title = Frame:newByTag("TEXT", "", Tooltip._frame)
    Tooltip._desc  = Frame:newByTag("TEXT", "", Tooltip._frame)

    -- 标题：左下相对描述左上，金色
    Tooltip._title:setPoint(FRAME_ALIGN_LEFT_BOTTOM, Tooltip._desc, FRAME_ALIGN_LEFT_TOP, 0, -10)
    -- 标题：右下相对描述右上，金色
    Tooltip._title:setPoint(FRAME_ALIGN_RIGHT_BOTTOM, Tooltip._desc, FRAME_ALIGN_RIGHT_TOP, -10, -10)
   
    -- 背景：左上角相对标题左上角
    Tooltip._bg:setPoint(FRAME_ALIGN_LEFT_TOP, Tooltip._title, FRAME_ALIGN_LEFT_TOP, -10, -10)
    -- 背景：右下角相对描述右下角
    Tooltip._bg:setPoint(FRAME_ALIGN_RIGHT_BOTTOM, Tooltip._desc, FRAME_ALIGN_RIGHT_BOTTOM, 10, 10)

    Tooltip._desc:setFont (Tooltip.FONT_PATH, Tooltip.FONT_SIZE, 0)
    Tooltip._title:setFont(Tooltip.FONT_PATH, Tooltip.FONT_SIZE, 0)

    Tooltip._desc:setAbsolutePoint(FRAME_ALIGN_RIGHT_BOTTOM, 1910, 780)
    Tooltip._desc:setSize(520, -1)

    -- Tooltip._title:setText("标题")
    -- Tooltip._desc:setText("描述1|n描述2|n描述3|n描述4|n描述5")

    -- 注册全局帧更新回调（Tooltip 自管理，其他模块通过 addUpdateHook 接入）
    Frame.onUpdate(Tooltip._onFrameUpdate)
    Tooltip._frame:hide()
    print("[Tooltip] 初始化完成（FDF BACKDROP 模板 + Lua TEXT）")
    return true
end

-----------------------------------------------------------------
-- 外部接口
-----------------------------------------------------------------

--- 显示提示框
---@param title string 标题
---@param desc string 描述
function Tooltip.show(title, desc)
    Tooltip._title:setText(title or "")
    Tooltip._desc:setText(desc or "")
    Tooltip._frame:show()
    Tooltip._visible = true
end

--- 隐藏提示框
function Tooltip.hide()
    Tooltip._frame:hide()
    Tooltip._visible = false
end

--- 显示 Buff 信息
---@param buffCode string Buff 编码（如 "B000"）
---@param buffedUnit Unit|nil 拥有该 Buff 的单位（实时读取层数/持续时间）。可 nil，nil 时只显示基础信息。
function Tooltip.showBuff(buffCode, buffedUnit)
    if buffCode == nil then
        Tooltip.hide()
        return
    end
    local name = Obj.getBuffData(buffCode, "Bufftip")
    local desc = Obj.getBuffData(buffCode, "Buffubertip")
    if name == nil or name == "" then
        name = buffCode
    end
    if desc == nil then desc = "" end

    -- 实时层数 + 剩余持续时间（每层独立计时，永久层显示"永久"）
    local extra = ""
    if buffedUnit ~= nil and buffedUnit._data and buffedUnit._data.buffs then
        local key = buffCode
        if type(buffCode) == "string" then
            key = c2i(buffCode)
        end
        local buff = buffedUnit._data.buffs[key]
        if buff ~= nil then
            local counter = buff.counter or 0
            local hasPermanent = false
            local maxDur = 0
            if buff.layers then
                for _, layer in ipairs(buff.layers) do
                    if layer.permanent then
                        hasPermanent = true
                    elseif layer.duration and layer.duration > maxDur then
                        maxDur = layer.duration
                    end
                end
            end
            local durText
            if hasPermanent then
                durText = "永久"
            else
                durText = string.format("%.1f 秒", maxDur)
            end
            extra = string.format("\n\n层数：%d\n剩余持续时间：%s", counter, durText)
        end
    end

    Tooltip.show(name, desc .. extra)
end

--- 注册帧更新回调
---@param fn function 每帧回调函数
function Tooltip.addUpdateHook(fn)
    table.insert(Tooltip._hooks, fn)
end

-----------------------------------------------------------------
-- 帧更新（Tooltip 自管理，通过全局 Frame.onUpdate 注册）
-----------------------------------------------------------------
function Tooltip._onFrameUpdate()
    for _, hook in ipairs(Tooltip._hooks) do
        hook()
    end
end

Tooltip.init()