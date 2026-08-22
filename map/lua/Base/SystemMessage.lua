-- ============================================================
-- SystemMessage 类 — 系统消息提示（屏幕中央，带渐隐）
-- 子控件锚定到容器 FRAME，容器自动包裹居中
--
-- 使用方式：
--   SystemMessage.send({
--       {"STR", "文本"},
--       {"art", "图标路径.blp"},
--       {"STR", "更多文本"},
--   }, 3.0)
--
-- 布局原理：
--   1. 首个子控件 TOPLEFT → 容器 TOPLEFT
--   2. 后续子控件 LEFT → 前一个 RIGHT  链式排列
--   3. 容器 BOTTOMRIGHT → 最高子控件的 BOTTOMRIGHT
--   4. 容器 CENTER → 屏幕中央偏上
-- ============================================================

---@class SystemMessage
SystemMessage = {}

SystemMessage.DEBUG = false

-----------------------------------------------------------------
-- 内部状态
-----------------------------------------------------------------
SystemMessage._counter = 0
SystemMessage._active  = {}
SystemMessage._timer   = nil
SystemMessage._needsReposition = false

-----------------------------------------------------------------
-- 常量
-----------------------------------------------------------------
SystemMessage.LEFT_X       = 700           -- 容器左边缘 X（靠左对齐，距屏幕左边 60）
SystemMessage.BASE_Y       = 800          -- 容器中心 Y（较原 350 再下移 300，首个消息落在屏幕中下）
SystemMessage.MSG_GAP      = 4            -- 上下消息间隔（缩小，避免间隔过大）
SystemMessage.SEG_GAP      = 0            -- 段间距
SystemMessage.PAD          = 0            -- 容器内边距

SystemMessage.FONT_PATH    = "UI\\Fonts\\ARHei.TTF"
SystemMessage.FONT_SIZE    = 0.011
SystemMessage.FONT_COLOR   = 0xFFFFCC00

-- 预设文本颜色（0xAARRGGBB），供 send 的 {"STR", text, color} 段使用第 3 个元素
SystemMessage.COLOR_INFO    = 0xFFFFCC00   -- 金色（默认/信息）
SystemMessage.COLOR_SUCCESS = 0xFF33FF66   -- 绿色（成功）
SystemMessage.COLOR_FAIL    = 0xFFFF4444   -- 红色（失败）
SystemMessage.COLOR_RETURN  = 0xFF33CCFF   -- 青色（返还）
SystemMessage.COLOR_WARN    = 0xFFFF9933   -- 橙色（警告）
SystemMessage.ICON_SIZE    = 18           -- 图标尺寸（较原 28 再缩小）

-----------------------------------------------------------------
-- 获取单位头像(命令按钮图标)路径，失败返回空串（send 会跳过空图标）
-----------------------------------------------------------------
function SystemMessage.getUnitIcon(handle)
    if handle == nil then return "" end
    -- 方式一（最可靠）：通过单位类型 id 读物编 Art 字段（与 GameStart 英雄选择消息一致）
    local ok, typeId = pcall(cj.GetUnitTypeId, handle)
    if ok and typeId and typeId ~= 0 then
        local ok2, idStr = pcall(i2c, typeId)
        if ok2 and type(idStr) == "string" then
            local ok3, art = pcall(Obj.getUnitData, idStr, "Art")
            if ok3 and type(art) == "string" and art ~= "" then
                return art
            end
        end
    end
    -- 方式二（兜底）：EX 直接读单位字符串字段，并规范化路径（补 .blp / 补命令按钮目录）
    local candidates = { {4, 0}, {4, 1}, {1, 0} }
    for _, c in ipairs(candidates) do
        local okv, v = pcall(cdz.EXGetUnitString, handle, c[1], c[2])
        if okv and type(v) == "string" and v ~= "" then
            local low = v:lower()
            if low:find("commandbuttons") or low:match("btn") then
                if not (v:match("%.blp$") or v:match("%.tga$")) then v = v .. ".blp" end
                if not v:find("[\\/]") then v = "ReplaceableTextures\\CommandButtons\\" .. v end
                return v
            end
        end
    end
    return ""
end

--- 获取玩家英雄头像路径，失败返回空串
function SystemMessage.getPlayerHeroIcon(player)
    if player == nil then return "" end
    local ok, heroHandle = pcall(function()
        local h = player.hero
        return (h and h._handle) or nil
    end)
    if ok and heroHandle then
        return SystemMessage.getUnitIcon(heroHandle)
    end
    return ""
end

SystemMessage.DISPLAY_DURATION = 3.0
SystemMessage.FADE_DURATION    = 0.5
SystemMessage.UPDATE_INTERVAL  = 0.03
SystemMessage.ENTER_DURATION   = 0.35   -- 新消息滑入时长（右→左）
SystemMessage.SLIDE_DIST       = 320    -- 滑入起始横向偏移（像素，从右侧滑入）

SystemMessage.ALPHA_INVERTED = false

local function _alpha(v)
    if SystemMessage.ALPHA_INVERTED then return 255 - v end
    return v
end

local function _log(fmt, ...)
    if SystemMessage.DEBUG then
        print("[SysMsg] " .. string.format(fmt, ...))
    end
end

local function utf8Len(s)
    if not s then return 0 end
    local _, count = s:gsub("[^\128-\191]", "")
    return count
end

-----------------------------------------------------------------
-- 文本宽度估算（仅用于初步排布，文字大小由 WC3 引擎决定）
-----------------------------------------------------------------
local function estimateTextWidth(text)
    -- 去除颜色转义码 |cAARRGGBB 与 |r，避免宽度估算偏大导致布局错位
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    local len = utf8Len(text)
    local w = 0
    for i = 1, len do
        local byte = text:byte(i)
        w = w + (byte and byte > 127 and 30 or 15)
    end
    return math.floor(w * 1.1 + 0.5)
end

-----------------------------------------------------------------
-- 销毁消息
-----------------------------------------------------------------
local function destroyMessage(msg)
    _log("销毁消息 #%d", msg._id or 0)
    if msg.container and not msg.container._destroyed then
        msg.container:destroy()
    end
    msg.children = {}
end

-----------------------------------------------------------------
-- 重新定位：设置容器 CENTER 到屏幕位置
-- 同时重新锚定 LEFT_TOP 和 RIGHT_BOTTOM 使容器大小正确
-----------------------------------------------------------------
local function repositionMessages()
    local cy = SystemMessage.BASE_Y

    for idx, msg in ipairs(SystemMessage._active) do
        if msg.container and not msg.container._destroyed then
            local offset = (msg.state == "enter" and msg.enterOffset) or 0
            msg.y = cy
            msg.container:clearAllPoints()
            msg.container:setAbsolutePoint(FRAME_ALIGN_LEFT,
                SystemMessage.LEFT_X + offset, cy)
            if msg.estW and msg.estH then
                msg.container:setSize(msg.estW, msg.estH)
            end

            if SystemMessage.DEBUG then
                _log("  消息#%d(索引%d): LEFT=(%d,%d) size=%dx%d",
                    msg._id or 0, idx, SystemMessage.LEFT_X + offset, cy,
                    msg.estW or 0, msg.estH or 0)
            end
        end
        cy = cy - msg.height - SystemMessage.MSG_GAP
    end
    SystemMessage._needsReposition = false
end

-----------------------------------------------------------------
-- 帧更新
-----------------------------------------------------------------
local function onTimerTick()
    if #SystemMessage._active == 0 then
        if SystemMessage._timer then
            SystemMessage._timer:destroy()
            SystemMessage._timer = nil
        end
        return
    end

    local dt = SystemMessage.UPDATE_INTERVAL
    local i = #SystemMessage._active
    while i >= 1 do
        local msg = SystemMessage._active[i]
        if msg.state == "enter" then
            -- 滑入 + 淡入：从右侧偏移滑到原位，alpha 0→255（easeOutQuad）
            msg.elapsed = msg.elapsed + dt
            local p = math.min(1, msg.elapsed / SystemMessage.ENTER_DURATION)
            local e = 1 - (1 - p) * (1 - p)
            msg.enterOffset = SystemMessage.SLIDE_DIST * (1 - e)
            local alpha = math.floor(255 * e + 0.5)
            alpha = math.max(0, math.min(255, alpha))
            if not msg.hidden and msg.container and not msg.container._destroyed then
                msg.container:setAlpha(_alpha(alpha))
            end
            SystemMessage._needsReposition = true
            if p >= 1 then
                msg.state = "display"
                msg.elapsed = 0
                msg.enterOffset = 0
            end
        elseif msg.state == "display" then
            msg.elapsed = msg.elapsed + dt
            if msg.elapsed >= msg.duration then
                _log("消息#%d 显示结束，进入渐隐", msg._id)
                msg.state = "fade"
                msg.elapsed = 0
            end
        elseif msg.state == "fade" then
            msg.elapsed = msg.elapsed + dt
            local progress = msg.elapsed / SystemMessage.FADE_DURATION
            if progress >= 1.0 then
                destroyMessage(msg)
                table.remove(SystemMessage._active, i)
                SystemMessage._needsReposition = true
            else
                local alpha = math.floor(255 * (1 - progress) + 0.5)
                alpha = math.max(0, math.min(255, alpha))
                -- 容器 alpha → 影响所有子控件
                if msg.container and not msg.container._destroyed then
                    msg.container:setAlpha(_alpha(alpha))
                end
            end
        end
        i = i - 1
    end

    if SystemMessage._needsReposition and #SystemMessage._active > 0 then
        repositionMessages()
    end
end

-----------------------------------------------------------------
-- 启动定时器
-----------------------------------------------------------------
local function ensureTimer()
    if not SystemMessage._timer then
        SystemMessage._timer = Timer:new(SystemMessage.UPDATE_INTERVAL, true, onTimerTick)
    end
end

-----------------------------------------------------------------
-- 发送消息（公开 API）
-----------------------------------------------------------------
---@param segments table 消息段列表，每个段为 {type, value, color}，type 为 "STR" 或 "IMG"，value 为字符串或图片路径，color 为颜色值（可选）
---@param duration number 消息显示时间（秒），默认 2.0
---@param pl Player|nil 消息所属玩家（可选），默认所有玩家
---@return number 消息索引
function SystemMessage.send(segments, duration, pl)
    if not segments or #segments == 0 then return end

    local dur  = duration or SystemMessage.DISPLAY_DURATION
    local gameUI = Frame.getGameUI()
    if not gameUI then _log("错误：getGameUI 返回 nil"); return end

    -- 判定本机是否为目标玩家：
    --   pl 为 nil          -> 全员可见（保持原 43+ 处调用语义不变）
    --   pl 为非 nil Player  -> 仅该玩家本机可见；其余本机仍创建完全相同数量的帧
    --                          （句柄计数全机一致 -> 不会 desync），只是内容清空+折叠成 0 高度，
    --                          视觉上与“没有这条消息”完全一致，但帧依然存在。
    --   该判定依赖 GetLocalPlayer，本质上在“异步/本机”环境里完成，符合需求。
    local isTarget = true
    if pl then
        local ok, pid = pcall(function() return pl:getId() end)
        if ok and type(pid) == "number" then
            isTarget = (pid == cj.GetPlayerId(cj.GetLocalPlayer()))
        else
            local ok2, h = pcall(function() return pl._handle end)
            if ok2 and h then
                isTarget = (h == cj.GetLocalPlayer())
            end
        end
    end

    local msgIdx = SystemMessage._counter
    SystemMessage._counter = SystemMessage._counter + 1
    _log("=== send #%d segments=%d ===", msgIdx, #segments)

    -- ========== 1. 创建容器（无纹理，不可见）==========
    local containerName = "SysMsgFrm_" .. msgIdx
    local container = Frame:newByTag("BACKDROP", containerName, gameUI)
    if not container._handle then
        _log("容器创建失败，放弃"); return
    end
    container:setTexture([[UI\Widgets\EscMenu\Human\blank-background.blp]], 0)   -- 全透明纹理，无背景
    container:show()

    -- ========== 2. 创建子控件（挂到容器下）==========
    local children   = {}
    local childSizes = {}  -- {w, h} 估算值
    local totalWidth = 0
    local maxHeight  = 0

    for _, seg in ipairs(segments) do
        local segType  = seg[1]
        local segValue = seg[2]

        if segType == "STR" and segValue then
            local textStr = tostring(segValue)
            local tfName = "SysMsgTxt_" .. msgIdx .. "_" .. (#children + 1)
            local textFrame = Frame:newByTag("TEXT", tfName, container._handle)

            if textFrame._handle then
                textFrame:disable()
                textFrame:setText(textStr)
                textFrame:setFont(SystemMessage.FONT_PATH, SystemMessage.FONT_SIZE, 0)
                local segColor = seg[3]
                textFrame:setTextColor(type(segColor) == "number" and segColor or SystemMessage.FONT_COLOR)
                textFrame:show()
                _log("  TEXT[%d] %s OK", #children + 1, textStr)

                local estW = estimateTextWidth(textStr)
                local estH = math.floor(SystemMessage.FONT_SIZE / 0.6 * 1080 + 0.5)
                table.insert(children, textFrame)
                table.insert(childSizes, {w = estW, h = estH})
                if #children > 1 then totalWidth = totalWidth + SystemMessage.SEG_GAP end
                totalWidth = totalWidth + estW
                if estH > maxHeight then maxHeight = estH end
            end

        elseif segType == "art" and segValue and segValue ~= "" then
            local icName = "SysMsgIc_" .. msgIdx .. "_" .. (#children + 1)
            local iconFrame = Frame:newByTag("BACKDROP", icName, container._handle)
            if iconFrame._handle then
                local ok = pcall(function()
                    iconFrame:setTexture(segValue, 0)
                end)
                if not ok then
                    _log("  ART[%d] setTexture 失败，销毁", #children + 1)
                    iconFrame:destroy()
                else
                    iconFrame:setSize(SystemMessage.ICON_SIZE, SystemMessage.ICON_SIZE)
                    iconFrame:show()
                    _log("  ART[%d] %s OK", #children + 1, segValue)

                    table.insert(children, iconFrame)
                    table.insert(childSizes, {w = SystemMessage.ICON_SIZE, h = SystemMessage.ICON_SIZE})
                    if #children > 1 then totalWidth = totalWidth + SystemMessage.SEG_GAP end
                    totalWidth = totalWidth + SystemMessage.ICON_SIZE
                    if SystemMessage.ICON_SIZE > maxHeight then maxHeight = SystemMessage.ICON_SIZE end
                end
            end
        end
    end

    if #children == 0 then _log("无子控件，放弃"); container:destroy(); return end

    -- 非目标玩家本机：保留帧（句柄计数全机一致 -> 不会 desync），但清空内容并折叠成 0 高度，
    -- 视觉上等同“没有这条消息”，而帧依然存在（用户要求：图标/文本 set 为 ""、图标高度 0、行高偏移）。
    if not isTarget then
        for _, child in ipairs(children) do
            if child and not child._destroyed then
                pcall(function() child:setText("") end)
                pcall(function() child:setSize(0, 0) end)
            end
        end
        container:setAlpha(0)
    end

    local realHeight = math.max(maxHeight, SystemMessage.ICON_SIZE)
    if not isTarget then realHeight = 0 end
    _log("消息#%d: 子控件=%d 估算W=%d H=%d", msgIdx, #children, totalWidth, realHeight)

    -- ========== 3. 子控件链式锚点（相对容器）==========
    -- 改用左下锚点：所有子控件底部对齐，图标与文本基线/底边整齐
    -- 第1个: LEFT_BOTTOM → 容器 LEFT_BOTTOM + (PAD, PAD)
    -- 后续:   LEFT_BOTTOM → 前一个 RIGHT_BOTTOM + (gap, 0)
    -- 容器创建时已 show，子控件可以直接锚定
    local pad = SystemMessage.PAD
    local gap = SystemMessage.SEG_GAP

    children[1]:clearAllPoints()
    children[1]:setPoint(FRAME_ALIGN_LEFT_BOTTOM, container, FRAME_ALIGN_LEFT_BOTTOM, pad, pad)

    for ci = 2, #children do
        if children[ci] and not children[ci]._destroyed then
            children[ci]:clearAllPoints()
            children[ci]:setPoint(FRAME_ALIGN_LEFT_BOTTOM, children[ci-1],
                                  FRAME_ALIGN_RIGHT_BOTTOM, gap, 0)
        end
    end

    -- 估算容器尺寸（用于 repositionMessages 设容器大小）
    local containerW = totalWidth + pad * 2
    local containerH = realHeight + pad * 2

    -- ========== 4. 构建消息对象 ==========
    local msg = {
        _id         = msgIdx,
        container   = container,
        children    = children,
        estW        = containerW,
        estH        = containerH,
        height      = realHeight + (isTarget and SystemMessage.MSG_GAP or 0),
        hidden      = not isTarget,     -- 非目标玩家本机：折叠隐藏（帧仍在，仅不可见/0 高度）
        state       = "enter",          -- 新消息：先滑入+淡入
        elapsed     = 0,
        enterOffset = SystemMessage.SLIDE_DIST,
        duration    = dur,
    }

    -- 滑入起始：先隐藏，等首个 tick 渐显（避免瞬间满透明闪现）
    container:setAlpha(_alpha(0))

    table.insert(SystemMessage._active, 1, msg)
    repositionMessages()
    ensureTimer()
end

-----------------------------------------------------------------
-- 清空
-----------------------------------------------------------------
function SystemMessage.clear()
    for _, msg in ipairs(SystemMessage._active) do destroyMessage(msg) end
    SystemMessage._active = {}
    if SystemMessage._timer then
        SystemMessage._timer:destroy()
        SystemMessage._timer = nil
    end
end

-----------------------------------------------------------------
-- 配置
-----------------------------------------------------------------
function SystemMessage.setConfig(config)
    if not config then return end
    for k, v in pairs(config) do
        if SystemMessage[k] ~= nil then SystemMessage[k] = v end
    end
end

-----------------------------------------------------------------
-- 测试模式（默认关闭）
-- 每 TEST_INTERVAL 秒自动发送一条带图标的消息，方便观察布局/对齐
-- 开启：SystemMessage.setTestMode(true)  或  SystemMessage.startTest()
-----------------------------------------------------------------
SystemMessage.TEST_MODE     = false
SystemMessage.TEST_INTERVAL = 0.5
SystemMessage.TEST_ICON     = [[ReplaceableTextures\CommandButtons\BTNScroll.blp]]
SystemMessage._testTimer    = nil
SystemMessage._testCount    = 0

local function _testTick()
    SystemMessage._testCount = SystemMessage._testCount + 1
    local n = SystemMessage._testCount
    SystemMessage.send({
        {"art", SystemMessage.TEST_ICON},
        {"STR", string.format("测试消息 #%d  观察左对齐/图标/字号", n)},
    }, 3.0)
    if SystemMessage.DEBUG then
        _log("测试消息 #%d 已发送", n)
    end
end

function SystemMessage.startTest(interval)
    if SystemMessage._testTimer then return end
    local iv = interval or SystemMessage.TEST_INTERVAL
    SystemMessage._testTimer = Timer:new(iv, true, _testTick)
    _log("测试模式已启动，间隔 %.2fs", iv)
end

function SystemMessage.stopTest()
    if SystemMessage._testTimer then
        SystemMessage._testTimer:destroy()
        SystemMessage._testTimer = nil
    end
    _log("测试模式已停止")
end

function SystemMessage.setTestMode(on)
    SystemMessage.TEST_MODE = (on and true or false)
    if SystemMessage.TEST_MODE then
        SystemMessage.startTest()
    else
        SystemMessage.stopTest()
    end
end

-- 默认开启：模块加载后自动启动测试。
-- 若当时 gameUI 尚未就绪，前几次发送会静默跳过，待就绪后自动正常显示。
if SystemMessage.TEST_MODE then
    SystemMessage.startTest()
end
