-- ============================================================
-- Frame 类 — FDF 框架控件
-- 通过 cdz.DzCreateFrame / cdz.DzCreateFrameByTagName 创建
--
-- 所有位置/尺寸参数均使用 整数像素（基 1920×1080）：
--   X/W → 0.8 = 1920px    Y/H → 0.6 = 1080px
--
-- 调用方式：
--   local f = Frame:new("EscMenuBackdrop", cdz.DzGetGameUI())
--   f:setSize(768, 324):setAbsolutePoint(FRAME_ALIGN_CENTER, 960, 540)
--   f:show()
--
--   如需传原生相对值，使用 xxxRel() 后缀方法：
--   f:setSizeRel(0.4, 0.3):setAbsolutePointRel(FRAME_ALIGN_CENTER, 0.4, 0.3)
--
--   local btn = Frame:newByTag("GLUEBUTTON", "ok_btn", f._handle)
--   btn:setSize(192, 43):setPoint(FRAME_ALIGN_CENTER, f, FRAME_ALIGN_CENTER, 0, -22)
--   btn:onEvent(MOUSE_ORDER_CLICK, function()
--       print("clicked!")
--   end)
--
--   local txt = Frame.newText("hello world", f._handle)
--   txt:setFont("Fonts\\FZBWJW.TTF", 0.02, 0)
--   txt:setTextColor(0xFFFFCC00)
-- ============================================================

---@class Frame 框架控件
Frame = {}
Frame.__index = Frame
Frame._handle = nil

-----------------------------------------------------------------
-- 像素坐标转换（固定屏幕 1920×1080）
-- WC3 原生 Frame API 使用相对坐标系（X: 0~0.8, Y: 0~0.6）
--
-- 转换规则：
--   X / W（水平方向）：px / 1920 * 0.8  — 方向一致，无需翻转
--   H（高度绝对值）：  px / 1080 * 0.6  — 纯大小，不翻转
--   Y（位置）：        (1080-py)/1080*0.6 — 魔兽 Y 轴 0=底部，与屏幕像素相反，需翻转
-----------------------------------------------------------------

--- 屏幕参考宽度（像素）
Frame.SCREEN_W = 1920
--- 屏幕参考高度（像素）
Frame.SCREEN_H = 1080

--- 像素 → WC3 相对坐标（X 方向）  0.8 = 1920px
---@param px integer
---@return real
function Frame._pxX(px)
    return px / Frame.SCREEN_W * 0.8
end

--- 像素 → WC3 相对坐标（Y 方向）  0.6 = 1080px
--- 用于尺寸（高度绝对值），不翻转
---@param px integer
---@return real
function Frame._pxY(px)
    return px / Frame.SCREEN_H * 0.6
end

--- 像素 → WC3 相对坐标（Y 位置，翻转）
--- 魔兽 Y 轴 0=底部 0.6=顶部，与屏幕像素相反，故翻转
---@param py integer Y 像素（0=顶部）
---@return real
function Frame._pxYPos(py)
    return (Frame.SCREEN_H - py) / Frame.SCREEN_H * 0.6
end

--- 二维像素位置 → WC3 相对坐标（X 直接，Y 翻转）
---@param px integer
---@param py integer
---@return real, real
function Frame._pxXY(px, py)
    return Frame._pxX(px), Frame._pxYPos(py)
end

--- 二维像素尺寸 → WC3 相对尺寸（W / H 均不翻转）
---@param pw integer
---@param ph integer
---@return real, real
function Frame._pxWH(pw, ph)
    return Frame._pxX(pw), Frame._pxY(ph)
end

--- 原样返回（相对值不转换），用于保留旧接口
---@param x real
---@param y real
---@return real, real
function Frame._relXY(x, y)
    return x, y
end

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newFrame()
    local obj = { _handle = nil, _index = nil, _destroyed = false }
    setmetatable(obj, Frame)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 通过 FDF 类型名创建 Frame
---@param frameType string FDF 中定义的框架类型名（如 "EscMenuBackdrop"）
---@param parent frame|Frame 父控件 handle 或 Frame 对象
---@param context integer|nil 自定义上下文（默认 0）
---@return Frame
function Frame:new(frameType, parent, context)
    local p = parent
    if (type(p) == "table" and p._handle ~= nil) then p = p._handle end
    local ctx = context or 0
    local obj = newFrame()
    obj._handle = cdz.DzCreateFrame(frameType, p, ctx)
    return obj
end

--- 通过 Tag 名创建 Frame（更灵活，可指定名称）
---@param tagName string 框架标签（如 "BACKDROP", "GLUEBUTTON", "TEXT"）
---@param name string 框架名称
---@param parent frame|Frame 父控件
---@param templateName string|nil 模板名（默认 "TEMPLATE"）
---@param context integer|nil 上下文（默认 0）
---@return Frame
function Frame:newByTag(tagName, name, parent, templateName, context)
    local p = parent
    if (type(p) == "table" and p._handle ~= nil) then p = p._handle end
    local tpl = templateName or "TEMPLATE"
    local ctx = context or 0
    local obj = newFrame()
    obj._handle = cdz.DzCreateFrameByTagName(tagName, name, p, tpl, ctx)
    if tagName == "TEXT" then
        cdz.DzFrameSetEnable(obj._handle, true)
    end
    return obj
end

--- 基于已有 handle 包裹为 Frame 对象（用于原生 Frame handle 适配）
---@param handle frame 现有框架 handle
---@return Frame
function Frame.wrap(handle)
    if (handle == nil) then return nil end
    local obj = newFrame()
    obj._handle = handle
    return obj
end

--- 销毁
---@return Frame
function Frame:destroy()
    if (self._handle ~= nil and not self._destroyed) then
        cdz.DzDestroyFrame(self._handle)
        self._destroyed = true
    end
    self._handle = nil
    return self
end

-----------------------------------------------------------------
-- 锚点 / 布局
-----------------------------------------------------------------

--- 清空所有锚点
---@return Frame
function Frame:clearAllPoints()
    cdz.DzFrameClearAllPoints(self._handle)
    return self
end

--- 设置绝对位置锚点（像素坐标，基于 1920×1080）
---@param point integer 锚点类型（FRAME_ALIGN_*）
---@param x integer X 坐标（像素）
---@param y integer Y 坐标（像素）
---@return Frame
function Frame:setAbsolutePoint(point, x, y)
    cdz.DzFrameSetAbsolutePoint(self._handle, point, Frame._pxX(x), Frame._pxYPos(y))
    return self
end

--- 设置绝对位置锚点（原生相对坐标，跳过像素转换）
---@param point integer
---@param x real
---@param y real
---@return Frame
function Frame:setAbsolutePointRel(point, x, y)
    cdz.DzFrameSetAbsolutePoint(self._handle, point, x, y)
    return self
end

--- 设置相对锚点（像素偏移，基于 1920×1080）
--- 注意：像素 Y 正方向为向下（0=顶部），WC3 Y 正方向为向上（0=底部），
--- 所以 Y 偏移取负值以保持一致
---@param point integer 自身的锚点
---@param relative frame|Frame 参考控件
---@param relativePoint integer 参考控件的锚点
---@param x integer X 偏移（像素）
---@param y integer Y 偏移（像素）
---@return Frame
function Frame:setPoint(point, relative, relativePoint, x, y)
    local r = relative
    if (type(r) == "table" and r._handle ~= nil) then r = r._handle end
    cdz.DzFrameSetPoint(self._handle, point, r, relativePoint, Frame._pxX(x), -Frame._pxY(y))
    return self
end

--- 设置相对锚点（原生相对坐标，跳过像素转换）
---@param point integer
---@param relative frame|Frame
---@param relativePoint integer
---@param x real
---@param y real
---@return Frame
function Frame:setPointRel(point, relative, relativePoint, x, y)
    local r = relative
    if (type(r) == "table" and r._handle ~= nil) then r = r._handle end
    cdz.DzFrameSetPoint(self._handle, point, r, relativePoint, x, y)
    return self
end

--- 移所有锚点到目标 Frame（尺寸和位置完全跟随）
---@param target frame|Frame 目标控件
---@return Frame
function Frame:setAllPoints(target)
    local t = target
    if (type(t) == "table" and t._handle ~= nil) then t = t._handle end
    cdz.DzFrameSetAllPoints(self._handle, t)
    return self
end

--- 设置大小（像素，基于 1920×1080）
---@param width integer | nil 宽度（像素）
---@param height integer | nil 高度（像素）
---@return Frame
function Frame:setSize(width, height)
    local w = (width ~= nil) and Frame._pxX(width) or -1
    local h = (height ~= nil) and Frame._pxY(height) or -1
    cdz.DzFrameSetSize(self._handle, w, h)
    return self
end

--- 设置大小（原生相对坐标，跳过像素转换）
---@param width real
---@param height real
---@return Frame
function Frame:setSizeRel(width, height)
    cdz.DzFrameSetSize(self._handle, width, height)
    return self
end

--- 设置缩放
---@param scale real 缩放倍率
---@return Frame
function Frame:setScale(scale)
    cdz.DzFrameSetScale(self._handle, scale)
    return self
end

--- 设置优先级（层级）
---@param priority integer 优先级
---@return Frame
function Frame:setPriority(priority)
    cdz.DzFrameSetPriority(self._handle, priority)
    return self
end

--- 设置父窗口
---@param parent frame|Frame 父控件
---@return Frame
function Frame:setParent(parent)
    local p = parent
    if (type(p) == "table" and p._handle ~= nil) then p = p._handle end
    cdz.DzFrameSetParent(self._handle, p)
    return self
end

-----------------------------------------------------------------
-- 外观
-----------------------------------------------------------------

--- 设置透明度（0-255）
---@param alpha integer 透明度，0=全透明，255=不透明
---@return Frame
function Frame:setAlpha(alpha)
    cdz.DzFrameSetAlpha(self._handle, alpha)
    return self
end

--- 设置顶点颜色
---@param color integer ARGB 颜色值（如 0xFFFF0000 为红色）
---@return Frame
function Frame:setVertexColor(color)
    cdz.DzFrameSetVertexColor(self._handle, color)
    return self
end

--- 设置贴图
---@param texture string 贴图路径
---@param flag integer|nil 标志位（默认 0）
---@return Frame
function Frame:setTexture(texture, flag)
    if texture == "" then return self end
    cdz.DzFrameSetTexture(self._handle, texture, flag or 0)
    return self
end

--- 设置纹理坐标
---@param left real
---@param right real
---@param top real
---@param bottom real
---@return Frame
function Frame:setTexCoord(left, right, top, bottom)
    cdz.DzFrameSetTexCoord(self._handle, left, right, top, bottom)
    return self
end

-----------------------------------------------------------------
-- 文本
-----------------------------------------------------------------

--- 设置文本
---@param text string 文本内容
---@return Frame
function Frame:setText(text)
    cdz.DzFrameSetText(self._handle, text)
    return self
end

--- 追加文本
---@param text string 追加的文本
---@return Frame
function Frame:addText(text)
    cdz.DzFrameAddText(self._handle, text)
    return self
end

--- 设置字体
---@param fontFile string 字体文件路径
---@param size number  字号
---@param flag integer|nil 标志位（默认 0）
---@return Frame
function Frame:setFont(fontFile, size, flag)
    cdz.DzFrameSetFont(self._handle, fontFile, size, flag or 0)
    return self
end

--- 设置文本颜色
---@param color integer ARGB 颜色值
---@return Frame
function Frame:setTextColor(color)
    cdz.DzFrameSetTextColor(self._handle, color)
    return self
end

--- 设置对齐方式
---@param align integer 对齐方式（TEXT_ALIGN_*）
---@return Frame
function Frame:setTextAlignment(align)
    cdz.DzFrameSetTextAlignment(self._handle, align)
    return self
end

--- 设置字数限制
---@param limit integer 最大字符数
---@return Frame
function Frame:setTextSizeLimit(limit)
    cdz.DzFrameSetTextSizeLimit(self._handle, limit)
    return self
end

--- 设置字间距
---@param spacing real 字间距
---@return Frame
function Frame:setTextFontSpacing(spacing)
    cdz.DzFrameSetTextFontSpacing(self._handle, spacing)
    return self
end

--- 添加文字阴影
---@param offsetX real
---@param offsetY real
---@param color integer ARGB
---@return Frame
function Frame:addTextShadow(offsetX, offsetY, color)
    cdz.DzFrameAddTextShadow(self._handle, offsetX, offsetY, color)
    return self
end

--- 复制文字阴影（模拟描边）
---@param flag integer
---@return Frame
function Frame:duplicateTextShadow(flag)
    cdz.DzFrameDuplicateTextShadow(self._handle, flag)
    return self
end

--- 设置禁用态文本
---@param text string
---@return Frame
function Frame:setDisabledText(text)
    cdz.DzFrameSetDisabledText(self._handle, text)
    return self
end

--- 设置高亮文本
---@param text string
---@return Frame
function Frame:setHighlightText(text)
    cdz.DzFrameSetHighlightText(self._handle, text)
    return self
end

-----------------------------------------------------------------
-- 模型
-----------------------------------------------------------------

--- 设置模型
---@param modelFile string 模型文件路径
---@param modelType integer 模型类型
---@param flag integer 标志位
---@return Frame
function Frame:setModel(modelFile, modelType, flag)
    cdz.DzFrameSetModel(self._handle, modelFile, modelType, flag)
    return self
end

--- 设置模型（KKAPI v2 版）
---@param modelFile string 模型文件路径
---@param flag integer 标志位
---@return Frame
function Frame:setModel2(modelFile, flag)
    cdz.DzFrameSetModel2(self._handle, modelFile, flag)
    return self
end

--- 添加模型控件
---@param modelFile string 模型文件路径
---@return frame 返回模型子控件 handle
function Frame:addModel(modelFile)
    return cdz.DzFrameAddModel(self._handle, modelFile)
end

--- 添加模型绑定特效
---@param modelFile string 特效模型文件
---@return frame 返回特效子控件 handle
function Frame:addModelEffect(modelFile)
    return cdz.DzFrameAddModelEffect(self._handle, modelFile)
end

--- 移除模型绑定特效
---@param effect frame 特效子控件
---@return Frame
function Frame:removeModelEffect(effect)
    cdz.DzFrameRemoveModelEffect(self._handle, effect)
    return self
end

--- 播放动画（按名称）
---@param animName string 动画名
---@return Frame
function Frame:setModelAnimation(animName)
    cdz.DzFrameSetModelAnimation(self._handle, animName)
    return self
end

--- 播放动画（按索引）
---@param index integer 动画索引
---@return Frame
function Frame:setModelAnimationByIndex(index)
    cdz.DzFrameSetModelAnimationByIndex(self._handle, index)
    return self
end

--- 播放动画（编号）
---@param animIndex integer 动画编号
---@param timeTrack integer 时间轴
---@return Frame
function Frame:setAnimateByIndex(animIndex, timeTrack)
    cdz.DzFrameSetAnimateByIndex(self._handle, animIndex, timeTrack)
    return self
end

--- 设置模型大小
---@param size real
---@return Frame
function Frame:setModelSize(size)
    cdz.DzFrameSetModelSize(self._handle, size)
    return self
end

--- 设置模型缩放
---@param x real
---@param y real
---@param z real
---@return Frame
function Frame:setModelScale(x, y, z)
    cdz.DzFrameSetModelScale(self._handle, x, y, z)
    return self
end

--- 设置模型旋转 X 轴
---@param angle real 角度
---@return Frame
function Frame:setModelRotateX(angle)
    cdz.DzFrameSetModelRotateX(self._handle, angle)
    return self
end

--- 设置模型旋转 Y 轴
---@param angle real 角度
---@return Frame
function Frame:setModelRotateY(angle)
    cdz.DzFrameSetModelRotateY(self._handle, angle)
    return self
end

--- 设置模型旋转 Z 轴
---@param angle real 角度
---@return Frame
function Frame:setModelRotateZ(angle)
    cdz.DzFrameSetModelRotateZ(self._handle, angle)
    return self
end

--- 设置模型矩阵重置
---@return Frame
function Frame:setModelMatReset()
    cdz.DzFrameSetModelMatReset(self._handle)
    return self
end

--- 设置模型场景坐标
---@param x real
---@param y real
---@param z real
---@return Frame
function Frame:setModelPosition(x, y, z)
    cdz.DzFrameSetModelPosition(self._handle, x, y, z)
    return self
end

--- 设置模型场景 X 坐标
---@param x real
---@return Frame
function Frame:setModelX(x)
    cdz.DzFrameSetModelX(self._handle, x)
    return self
end

--- 设置模型场景 Y 坐标
---@param y real
---@return Frame
function Frame:setModelY(y)
    cdz.DzFrameSetModelY(self._handle, y)
    return self
end

--- 设置模型场景 Z 坐标
---@param z real
---@return Frame
function Frame:setModelZ(z)
    cdz.DzFrameSetModelZ(self._handle, z)
    return self
end

--- 设置模型颜色
---@param color integer ARGB
---@return Frame
function Frame:setModelColor(color)
    cdz.DzFrameSetModelColor(self._handle, color)
    return self
end

--- 设置模型动画速度
---@param speed real
---@return Frame
function Frame:setModelSpeed(speed)
    cdz.DzFrameSetModelSpeed(self._handle, speed)
    return self
end

--- 设置模型相机源点
---@param x real
---@param y real
---@param z real
---@return Frame
function Frame:setModelCameraSource(x, y, z)
    cdz.DzFrameSetModelCameraSource(self._handle, x, y, z)
    return self
end

--- 设置模型相机目标点
---@param x real
---@param y real
---@param z real
---@return Frame
function Frame:setModelCameraTarget(x, y, z)
    cdz.DzFrameSetModelCameraTarget(self._handle, x, y, z)
    return self
end

--- 设置模型宽屏补丁
---@param flag boolean
---@return Frame
function Frame:setModelEnableWideScreen(flag)
    cdz.DzFrameSetModelEnableWideScreen(self._handle, flag)
    return self
end

--- 设置模型粒子2缩放
---@param size real
---@return Frame
function Frame:setModelParticle2Size(size)
    cdz.DzFrameSetModelParticle2Size(self._handle, size)
    return self
end

--- 替换模型 id 贴图
---@param imageFile string 贴图路径
---@param flag integer
---@return Frame
function Frame:setModelTexture(imageFile, flag)
    cdz.DzFrameSetModelTexture(self._handle, imageFile, flag)
    return self
end

-----------------------------------------------------------------
-- 动画（非模型 Frame 通用）
-----------------------------------------------------------------

--- 设置动画
---@param animId integer 动画 ID
---@param loop boolean 是否循环
---@return Frame
function Frame:setAnimate(animId, loop)
    cdz.DzFrameSetAnimate(self._handle, animId, loop)
    return self
end

--- 设置动画进度
---@param offset real 偏移值（0.0 - 1.0）
---@return Frame
function Frame:setAnimateOffset(offset)
    cdz.DzFrameSetAnimateOffset(self._handle, offset)
    return self
end

-----------------------------------------------------------------
-- 启用 / 显示 / 焦点
-----------------------------------------------------------------

--- 显示
---@return Frame
function Frame:show()
    cdz.DzFrameShow(self._handle, true)
    return self
end

--- 隐藏
---@return Frame
function Frame:hide()
    cdz.DzFrameShow(self._handle, false)
    return self
end

--- 设置显示/隐藏
---@param flag boolean true=显示，false=隐藏
---@return Frame
function Frame:setVisible(flag)
    cdz.DzFrameShow(self._handle, flag)
    return self
end

--- 启用
---@return Frame
function Frame:enable()
    cdz.DzFrameSetEnable(self._handle, true)
    return self
end

--- 禁用
---@return Frame
function Frame:disable()
    cdz.DzFrameSetEnable(self._handle, false)
    return self
end

--- 设置启用/禁用
---@param flag boolean true=启用，false=禁用
---@return Frame
function Frame:setEnable(flag)
    cdz.DzFrameSetEnable(self._handle, flag)
    return self
end

--- 设置焦点
---@param flag boolean true=获取焦点
---@return Frame
function Frame:setFocus(flag)
    cdz.DzFrameSetFocus(self._handle, flag)
    return self
end

--- 设置忽略点击事件
---@param flag boolean
---@return Frame
function Frame:setIgnoreTrackEvents(flag)
    cdz.DzFrameSetIgnoreTrackEvents(self._handle, flag)
    return self
end

--- 设置裁剪视口
---@param flag boolean
---@return Frame
function Frame:setClip(flag)
    cdz.DzFrameSetClip(self._handle, flag)
    return self
end

-----------------------------------------------------------------
-- 数值类控件（进度条、滑块等）
-----------------------------------------------------------------

--- 设置当前值
---@param value real
---@return Frame
function Frame:setValue(value)
    cdz.DzFrameSetValue(self._handle, value)
    return self
end

--- 设置最小/最大值
---@param min real
---@param max real
---@return Frame
function Frame:setMinMaxValue(min, max)
    cdz.DzFrameSetMinMaxValue(self._handle, min, max)
    return self
end

--- 设置步进值
---@param step real
---@return Frame
function Frame:setStepValue(step)
    cdz.DzFrameSetStepValue(self._handle, step)
    return self
end

-----------------------------------------------------------------
-- 复选框
-----------------------------------------------------------------

--- 设置复选框勾选状态
---@param checked boolean
---@return Frame
function Frame:setCheckBoxState(checked)
    cdz.DzFrameSetCheckBoxState(self._handle, checked)
    return self
end

--- 获取复选框勾选状态
---@return boolean
function Frame:getCheckBoxState()
    return cdz.DzFrameGetCheckBoxState(self._handle)
end

-----------------------------------------------------------------
-- 编辑框
-----------------------------------------------------------------

--- 设置编辑框激活状态
---@param active boolean
---@return Frame
function Frame:setEditBoxActive(active)
    cdz.DzFrameSetEditBoxActive(self._handle, active)
    return self
end

--- 设置编辑框禁用输入法
---@param disable boolean true=禁用输入法
---@return Frame
function Frame:setEditBoxDisableIme(disable)
    cdz.DzFrameSetEditBoxDisableIme(self._handle, disable)
    return self
end

-----------------------------------------------------------------
-- 事件绑定
-----------------------------------------------------------------

--- 注册 UI 事件回调（闭包方式，防止 GC 回收）
---@param eventType integer 事件类型（MOUSE_ORDER_*，包括 MOUSE_ORDER_RIGHT_CLICK）
---@param callback fun(self, pl: Player) 回调函数，参数为 self 和触发玩家
---@param useSync boolean|nil true=使用同步模式（观战/录像不响应），默认 false（异步，观战/录像可响应）
---@return Frame
function Frame:onEvent(eventType, callback, useSync)
    -- 在 self 上保存 callback 引用，防止被 GC 回收
    self._eventCbs = self._eventCbs or {}
    self._eventCbs[eventType] = callback

    -- 右键点击事件：使用硬件鼠标模拟
    if eventType == MOUSE_ORDER_RIGHT_CLICK then
        -- 注册到右键表
        Frame._rightClickRegistry[self._handle] = callback
        -- ★ 监听器由 Frame._ensureRightClickListener() 在模块加载（同步环境）预建；
        --   绝不能在本地/异步上下文（F2 按键、frame 点击）惰性创建原生 trigger，
        --   否则只有触发者本机建 trigger -> 句柄计数分叉 -> desync（2026-08-13 实测）。
        Frame._ensureRightClickListener()
        return self
    end

    -- 持久闭包：获取触发玩家并传入回调
    local handle  = self._handle
    local evtType = eventType
    local closure = function()
        local cb = self._eventCbs[evtType]
        if cb then
            local jPl = cdz.DzGetTriggerUIEventPlayer()
            cb(self, Player.fromHandle(jPl))
        end
    end

    if (useSync) then
        cdz.DzFrameSetScriptByCode(handle, eventType, closure, false)
    else
        cdz.DzFrameSetScriptByCodeAsync(handle, eventType, closure)
    end
    return self
end

--- 注册 UI 事件回调（按函数名，支持观战/录像响应）
---@param eventType integer 事件类型
---@param funcName string 全局函数名
---@return Frame
function Frame:onEventByName(eventType, funcName)
    cdz.DzFrameSetScript(self._handle, eventType, funcName, false)
    return self
end

--- 注册 UI 事件回调（func handle，观战/录像不响应）
---@param eventType integer 事件类型
---@param callback function 回调函数
---@return Frame
function Frame:onEventBlock(eventType, callback)
    cdz.DzFrameSetScriptBlock(self._handle, eventType, callback, false)
    return self
end

--- 设置全局帧更新回调（每帧触发）
---@param callback function|nil 回调函数，传入 nil 清除
function Frame.onUpdate(callback)
    if (callback) then
        cdz.DzFrameSetUpdateCallbackByCode(callback)
    else
        cdz.DzFrameSetUpdateCallbackByCode(nil)
    end
end

--- 设置全局帧更新回调（按函数名）
---@param funcName string|nil 全局函数名
function Frame.onUpdateByName(funcName)
    if (funcName) then
        cdz.DzFrameSetUpdateCallback(funcName)
    else
        cdz.DzFrameSetUpdateCallback("")
    end
end

-----------------------------------------------------------------
-- 右键事件（硬件鼠标模拟）
-- WC3 原生 Frame 事件不支持右键点击，通过硬件鼠标右键事件 + DzGetMouseFocus 模拟
-- 使用方式：frame:onEvent(MOUSE_ORDER_RIGHT_CLICK, callback)
-- 回调签名：function(frame: Frame, player: Player)
-- 注意：右键事件的 player 为硬件触发玩家（DzGetTriggerKeyPlayer），非 UI 事件玩家
-----------------------------------------------------------------

--- 右键事件注册表（frame handle -> callback）
---@type table<frame, fun(frame:Frame, player:Player)>
Frame._rightClickRegistry = {}

--- 硬件鼠标右键事件是否已注册
Frame._rightClickInitialized = false

--- 预建全局硬件鼠标右键监听器（模块加载 = 全机同步环境）
---   2026-08-13：首次右键绑定若在本地/异步上下文惰性创建 cj.CreateTrigger()，
---   只有触发者本机建原生句柄 -> 句柄计数分叉 -> desync（F2 档案面板实测）。
---   改为模块加载时全机同时预建，此后任何本地建帧绑定右键都不再创建原生句柄。
function Frame._ensureRightClickListener()
    if Frame._rightClickInitialized then return end
    Frame._rightClickInitialized = true
    local trig = cj.CreateTrigger()
    cdz.DzTriggerRegisterMouseEventByCode(trig, 2, 1, true, nil)
    cj.TriggerAddAction(trig, function()
        local focusHandle = cdz.DzGetMouseFocus()
        if focusHandle == nil then return end
        local cb = Frame._rightClickRegistry[focusHandle]
        if cb then
            -- 用 handle 包裹为 Frame 传入回调，玩家使用硬件触发玩家
            cb(Frame.wrap(focusHandle), Player.fromHandle(cdz.DzGetTriggerKeyPlayer()))
        end
    end)
end

-- 模块加载即预建（全机同步环境；任何本地建帧之前必须已存在）
Frame._ensureRightClickListener()

-----------------------------------------------------------------
-- 绑定（世界坐标跟踪）
-----------------------------------------------------------------

--- 绑定到单位（实时跟踪）
---@param unit Unit 单位
---@param offsetX number X 偏移
---@param offsetY number Y 偏移
---@param offsetZ number Z 偏移
---@param sizeX number 宽度
---@param sizeY number 高度
---@param adjustSize boolean
---@param clampToScreen boolean
---@param faceCamera boolean
---@return Frame
function Frame:bindToUnit(unit, offsetX, offsetY, offsetZ, sizeX, sizeY, adjustSize, clampToScreen, faceCamera)
    if not JassDz["DzFrameBindWidget"] then return end
    cdz.DzFrameBindWidget(self._handle, unit._handle, offsetX, offsetY, offsetZ, sizeX, sizeY, adjustSize, clampToScreen, faceCamera)
    return self
end

--- 绑定到世界坐标（实时跟踪）
---@param x unknown 世界 X
---@param y unknown 世界 Y
---@param z unknown 世界 Z
---@param offsetX unknown 界面 X 偏移
---@param offsetY unknown 界面 Y 偏移
---@param sizeX unknown 宽度
---@param sizeY unknown 高度
---@param keepSize boolean
---@return Frame
function Frame:bindToWorld(x, y, z, offsetX, offsetY, sizeX, sizeY, keepSize)
    cdz.DzFrameBindWorldPos(self._handle, x, y, z, offsetX, offsetY, sizeX, sizeY, keepSize)
    return self
end

--- 解除绑定
---@return Frame
function Frame:unbind()
    cdz.DzFrameUnBind(self._handle)
    return self
end

--- 添加隐藏区域（用于世界坐标绑定时控制可见性）
---@param x number
---@param y number
---@param z number
---@param facing number
---@param sizeX number
---@param sizeY number
---@return Frame
function Frame:addHideRect(x, y, z, facing, sizeX, sizeY)
    cdz.DzFrameBindAddHideRect(self._handle, x, y, z, facing, sizeX, sizeY)
    return self
end

-----------------------------------------------------------------
-- 提示 / 工具提示
-----------------------------------------------------------------

--- 设置工具提示
---@param tooltip frame|Frame 提示框
---@return Frame
function Frame:setTooltip(tooltip)
    local t = tooltip
    if (type(t) == "table" and t._handle ~= nil) then t = t._handle end
    cdz.DzFrameSetTooltip(self._handle, t)
    return self
end

-----------------------------------------------------------------
-- 名称 / 上下文 / 查找
-----------------------------------------------------------------

--- 设置名称和绑定整数
---@param name string 全局唯一名称
---@param context integer 自定义数据
---@return Frame
function Frame:setNameContext(name, context)
    cdz.DzFrameSetNameContext(self._handle, name, context)
    return self
end

--- 获取控件的全局名字
---@return string
function Frame:getName()
    return cdz.DzFrameGetName(self._handle)
end

--- 获取控件的绑定整数
---@return integer
function Frame:getContext()
    return cdz.DzFrameGetContext(self._handle)
end

--- 通过名称查找子 Frame
---@param name string 子控件名称
---@param index integer|nil 索引（默认 0）
---@return Frame
function Frame.findByName(name, index)
    local h = cdz.DzFrameFindByName(name, index or 0)
    if (h == nil) then return nil end
    return Frame.wrap(h)
end

-----------------------------------------------------------------
-- 查询
-----------------------------------------------------------------

--- 获取透明度（0-255）
---@return integer
function Frame:getAlpha()
    return cdz.DzFrameGetAlpha(self._handle)
end

--- 获取实际高度
---@return real
function Frame:getRealHeight()
    return cdz.DzFrameGetRealHeight(self._handle)
end

--- 获取实际宽度
---@return real
function Frame:getRealWidth()
    return cdz.DzFrameGetRealWidth(self._handle)
end

--- 获取高度
---@return real
function Frame:getHeight()
    return cdz.DzFrameGetHeight(self._handle)
end

--- 获取宽度
---@return real
function Frame:getWidth()
    return cdz.DzFrameGetWidth(self._handle)
end

--- 获取文本
---@return string
function Frame:getText()
    return cdz.DzFrameGetText(self._handle)
end

--- 获取字数限制
---@return integer
function Frame:getTextSizeLimit()
    return cdz.DzFrameGetTextSizeLimit(self._handle)
end

--- 获取当前值
---@return real
function Frame:getValue()
    return cdz.DzFrameGetValue(self._handle)
end

--- 获取父控件
---@return frame
function Frame:getParent()
    return cdz.DzFrameGetParent(self._handle)
end

--- 获取子控件数量
---@return integer
function Frame:getChildrenCount()
    return cdz.DzFrameGetChildrenCount(self._handle)
end

--- 获取指定索引的子控件
---@param index integer 索引
---@return frame
function Frame:getChild(index)
    return cdz.DzFrameGetChild(self._handle, index)
end

--- 控件是否启用
---@return boolean
function Frame:getEnable()
    return cdz.DzFrameGetEnable(self._handle)
end

--- 控件是否显示
---@return boolean
function Frame:isVisible()
    return cdz.DzFrameIsVisible(self._handle)
end

--- 控件是否焦点
---@return boolean
function Frame:isFocus()
    return cdz.DzFrameIsFocus(self._handle)
end

--- 是否已销毁
---@return boolean
function Frame:isDestroyed()
    return self._destroyed
end

--- 获取模型大小
---@return real
function Frame:getModelSize()
    return cdz.DzFrameGetModelSize(self._handle)
end

--- 获取模型速度
---@return real
function Frame:getModelSpeed()
    return cdz.DzFrameGetModelSpeed(self._handle)
end

--- 获取模型颜色
---@return integer
function Frame:getModelColor()
    return cdz.DzFrameGetModelColor(self._handle)
end

--- 获取模型 X
---@return real
function Frame:getModelX()
    return cdz.DzFrameGetModelX(self._handle)
end

--- 获取模型 Y
---@return real
function Frame:getModelY()
    return cdz.DzFrameGetModelY(self._handle)
end

--- 获取模型 Z
---@return real
function Frame:getModelZ()
    return cdz.DzFrameGetModelZ(self._handle)
end

--- 获取优先级
---@return integer
function Frame:getPriority()
    return cdz.DzFrameGetPriority(self._handle)
end

--- 获取锚点相对控件
---@param point integer 锚点类型
---@return frame
function Frame:getPointRelative(point)
    return cdz.DzFrameGetPointRelative(self._handle, point)
end

--- 获取锚点相对类型
---@param point integer 锚点
---@return integer
function Frame:getPointRelativePoint(point)
    return cdz.DzFrameGetPointRelativePoint(self._handle, point)
end

--- 是否有指定锚点
---@param point integer
---@return boolean
function Frame:getPointValid(point)
    return cdz.DzFrameGetPointValid(self._handle, point)
end

--- 获取锚点 X
---@param point integer
---@return real
function Frame:getPointX(point)
    return cdz.DzFrameGetPointX(self._handle, point)
end

--- 获取锚点 Y
---@param point integer
---@return real
function Frame:getPointY(point)
    return cdz.DzFrameGetPointY(self._handle, point)
end

-----------------------------------------------------------------
-- 鼠标 / 交互
-----------------------------------------------------------------

--- 限制鼠标移动范围
---@param flag boolean
---@return Frame
function Frame:cageMouse(flag)
    cdz.DzFrameCageMouse(self._handle, flag)
    return self
end

--- 启用裁剪矩形
---@param enable boolean
---@return Frame
function Frame:enableClipRect(enable)
    cdz.DzFrameEnableClipRect(self._handle, enable)
    return self
end

--- 解锁鼠标矩形限制
---@return Frame
function Frame:unlockMouseRectLimit()
    cdz.DzFrameUnlockMouseRectLimit(self._handle)
    return self
end

--- 点击
---@return Frame
function Frame:click()
    cdz.DzClickFrame(self._handle)
    return self
end

-----------------------------------------------------------------
-- 静态工具 — 原生系统 Frame 获取
-----------------------------------------------------------------

--- 获取游戏主 UI
---@return frame
function Frame.getGameUI()
    return cdz.DzGetGameUI()
end

--- 获取聊天输入栏控件
---@return frame
function Frame.getChatEditBar()
    return cdz.DzFrameGetChatEditBar()
end

--- 获取聊天消息框
---@return frame
function Frame.getChatMessage()
    return cdz.DzFrameGetChatMessage()
end

--- 获取技能按钮
---@param row integer 行
---@param col integer 列
---@return frame
function Frame.getCommandBarButton(row, col)
    return cdz.DzFrameGetCommandBarButton(row, col)
end

--- 获取英雄按钮
---@param index integer 索引
---@return frame
function Frame.getHeroBarButton(index)
    return cdz.DzFrameGetHeroBarButton(index)
end

--- 获取英雄血条
---@return frame
function Frame:getHeroHPBar()
    return cdz.DzFrameGetHeroHPBar(self._handle)
end

--- 获取英雄蓝条
---@return frame
function Frame:getHeroManaBar()
    return cdz.DzFrameGetHeroManaBar(self._handle)
end

--- 获取物品栏按钮
---@param index integer 索引
---@return frame
function Frame.getItemBarButton(index)
    return cdz.DzFrameGetItemBarButton(index)
end

--- 获取小地图
---@return frame
function Frame.getMinimap()
    return cdz.DzFrameGetMinimap()
end

--- 获取小地图按钮
---@return frame
function Frame:getMinimapButton()
    return cdz.DzFrameGetMinimapButton(self._handle)
end

--- 获取单位大头像
---@return frame
function Frame:getPortrait()
    return cdz.DzFrameGetPortrait()
end

--- 获取鼠标提示
---@return frame
function Frame:getTooltip()
    return cdz.DzFrameGetTooltip()
end

--- 获取上方消息框
---@return frame
function Frame:getTopMessage()
    return cdz.DzFrameGetTopMessage()
end

--- 获取系统消息框
---@return frame
function Frame:getUnitMessage()
    return cdz.DzFrameGetUnitMessage()
end

--- 获取界面按钮
---@param index integer 索引
---@return frame
function Frame:getUpperButtonBarButton(index)
    return cdz.DzFrameGetUpperButtonBarButton(index)
end

--- 获取鼠标控件
---@return frame
function Frame:getMouse()
    return cdz.DzFrameGetMouse()
end

--- 获取鼠标所在控件
---@return frame
function Frame:getCursorFrame()
    return cdz.DzGetMouseFocus()
end

--- 获取触发事件的控件
---@return frame
function Frame:getTriggerUIEventFrame()
    return cdz.DzGetTriggerUIEventFrame()
end

--- 获取农民控件
---@return frame
function Frame:getPeonBar()
    return cdz.DzFrameGetPeonBar()
end

--- 获取提示信息框
---@return frame
function Frame:getWorldFrameMessage()
    return cdz.DzFrameGetWorldFrameMessage()
end

--- 获取简单 UI 父控件
---@return frame
function Frame:getSimpleUIParent()
    return cdz.DzGetSimpleUIParent()
end

--- 获取底层 Frame
---@return frame
function Frame.getLowerLevelFrame()
    return cdz.DzFrameGetLowerLevelFrame()
end

--- 获取单位血条
---@param unit unit|Unit
---@return frame
function Frame:getUnitHpBar(unit)
    local u = unit
    if (type(u) == "table" and u._handle ~= nil) then u = u._handle end
    return cdz.DzFrameGetUnitHpBar(u)
end

--- 获取触发的血条
---@return frame
function Frame:getTriggerHpBar()
    return cdz.DzFrameGetTriggerHpBar()
end

--- 获取触发血条的单位
---@return unit
function Frame:getTriggerHpBarUnit()
    return cdz.DzFrameGetTriggerHpBarUnit()
end

--- 钩子血条
---@return Frame
function Frame.hookHpBar()
    return cdz.DzFrameHookHpBar()
end

--- 获取 BUFF 控件
---@param index integer
---@return frame
function Frame.getInfoPanelBuffButton(index)
    return cdz.DzFrameGetInfoPanelBuffButton(index)
end

--- 获取框选控件
---@param index integer
---@return frame
function Frame.getInfoPanelSelectButton(index)
    return cdz.DzFrameGetInfoPanelSelectButton(index)
end

--- 获取技能冷却指示器
---@param button frame 技能按钮
---@return frame
function Frame.getCommandBarButtonCooldownIndicator(button)
    return cdz.DzFrameGetCommandBarButtonCooldownIndicator(button)
end

--- 获取技能自动施法指示器
---@param button frame 技能按钮
---@return frame
function Frame.getCommandBarButtonAutoCastIndicator(button)
    return cdz.DzFrameGetCommandBarButtonAutoCastIndicator(button)
end

--- 获取技能右下角数字文本框体
---@param button frame 技能按钮
---@return frame
function Frame.getCommandBarButtonNumberOverlay(button)
    return cdz.DzFrameGetCommandBarButtonNumberOverlay(button)
end

--- 获取技能右下角数字文本控件
---@param button frame 技能按钮
---@return frame
function Frame.getCommandBarButtonNumberText(button)
    return cdz.DzFrameGetCommandBarButtonNumberText(button)
end

-----------------------------------------------------------------
-- 全局 UI 控制
-----------------------------------------------------------------

--- 隐藏游戏主界面
---@param flag boolean true=隐藏
function Frame.hideInterface(flag)
    cdz.DzFrameHideInterface(flag)
end

--- 显示游戏提示信息
---@param frame frame|Frame 提示框
---@param text string 文本
---@param color integer ARGB 颜色
---@param duration real 显示时长
---@param flag boolean 标志
function Frame.showMessage(frame, text, color, duration, flag)
    local f = frame
    if (type(f) == "table" and f._handle ~= nil) then f = f._handle end
    cdz.DzSimpleMessageFrameAddMessage(f, text, color, duration, flag)
end

--- 清理游戏提示信息
---@param frame frame|Frame
function Frame.clearMessage(frame)
    local f = frame
    if (type(f) == "table" and f._handle ~= nil) then f = f._handle end
    cdz.DzSimpleMessageFrameClear(f)
end

--- 编辑黑边
---@param top real 上边距
---@param bottom real 下边距
function Frame.editBlackBorders(top, bottom)
    cdz.DzFrameEditBlackBorders(top, bottom)
end

--- 开启/关闭宽屏模式
---@param enable boolean
function Frame.enableWideScreen(enable)
    cdz.DzEnableWideScreen(enable)
end

--- 加载 Toc 文件
---@param tocFile string .toc 文件路径
function Frame.loadToc(tocFile)
    cdz.DzLoadToc(tocFile)
end

--- 设置 UI 自动重置锚点
---@param flag boolean
function Frame.setOriginalUIAutoResetPoint(flag)
    cdz.DzOriginalUIAutoResetPoint(flag)
end

-----------------------------------------------------------------
-- 世界坐标 ↔ 小地图坐标转换
-----------------------------------------------------------------

--- 世界坐标转小地图 X
---@param x real
---@param y real
---@return real
function Frame.worldToMinimapX(x, y)
    return cdz.DzFrameWorldToMinimapPosX(x, y)
end

--- 世界坐标转小地图 Y
---@param x real
---@param y real
---@return real
function Frame.worldToMinimapY(x, y)
    return cdz.DzFrameWorldToMinimapPosY(x, y)
end

-----------------------------------------------------------------
-- SimpleFrame 快捷工具
-----------------------------------------------------------------

--- 创建 SimpleFrame
---@param name string
---@param owner integer 所有者 ID
---@param context integer 上下文
---@return frame
function Frame.createSimple(name, owner, context)
    return cdz.DzCreateSimpleFrame(name, owner or 0, context or 0)
end

--- 按名称查找 SimpleFrame
---@param name string
---@param index integer|nil
---@return frame
function Frame.findSimpleFrame(name, index)
    return cdz.DzSimpleFrameFindByName(name, index or 0)
end

--- 显示/隐藏 SimpleFrame
---@param frame frame|Frame
---@param show boolean
function Frame.showSimpleFrame(frame, show)
    local f = frame
    if (type(f) == "table" and f._handle ~= nil) then f = f._handle end
    cdz.DzSimpleFrameShow(f, show)
end

--- 判断 SimpleFrame 是否显示
---@param frame frame|Frame
---@return boolean
function Frame.isSimpleFrameVisible(frame)
    local f = frame
    if (type(f) == "table" and f._handle ~= nil) then f = f._handle end
    return cdz.KKSimpleFrameIsVisible(f)
end

--- 从注册表移除 SimpleFrame
---@param frame frame|Frame
function Frame.removeSimpleFrame(frame)
    local f = frame
    if (type(f) == "table" and f._handle ~= nil) then f = f._handle end
    cdz.DzSimpleFrameRemoveFromRegistry(f)
end

--- 按名称查找 SimpleTexture
---@param name string
---@param index integer|nil
---@return frame
function Frame.findSimpleTexture(name, index)
    return cdz.DzSimpleTextureFindByName(name, index or 0)
end

--- 按名称查找 SimpleFontString
---@param name string
---@param index integer|nil
---@return frame
function Frame.findSimpleFontString(name, index)
    return cdz.DzSimpleFontStringFindByName(name, index or 0)
end

-----------------------------------------------------------------
-- 技能按钮创建
-----------------------------------------------------------------

--- 创建技能按钮
---@param name string 按钮名称
---@param parent frame|Frame 父控件
---@param icon string 图标路径
---@param tooltip string 提示文本
---@return frame
function Frame.createCommandButton(name, parent, icon, tooltip)
    local p = parent
    if (type(p) == "table" and p._handle ~= nil) then p = p._handle end
    return cdz.DzCreateCommandButton(name, p, icon, tooltip)
end
