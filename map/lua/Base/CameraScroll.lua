-- ============================================================
-- CameraScroll 类 — 鼠标滚轮视距调整
-- 覆盖原生鼠标滚轮滚动行为，实现镜头距离（视距）的平滑缩放。
--
-- 调用方式：
--   CameraScroll.enable()                        -- 启用（所有玩家，默认配置）
--   CameraScroll.disable()                       -- 禁用
--   CameraScroll.setConfig({ minDist = 800 })    -- 动态修改配置
--   CameraScroll.getConfig()                     -- 查看当前配置（大数据方法）
--   CameraScroll.getDefaultConfig()              -- 查看默认配置
--   CameraScroll.resetConfig()                   -- 重置为默认配置
--   CameraScroll.isEnabled()                     -- 是否已启用
-- ============================================================

---@class CameraScroll 滚轮视距（静态）
CameraScroll = {}

-----------------------------------------------------------------
-- 默认配置（大数据方法 — 所有可调参数集中管理，运行时可见/可改）
-----------------------------------------------------------------
CameraScroll._defaultConfig = {
    -- 视距范围
    minDist     = 600,
    maxDist     = 3000,

    -- 滚动参数
    stepBase    = 80,
    stepScale   = 0.15,

    -- 平滑参数
    smoothDur   = 0.15,

    -- 初始值
    defaultDist = 2500,

    -- 行为开关
    invert      = false,
    uiBlock     = false,
}

-----------------------------------------------------------------
-- 私有状态
-----------------------------------------------------------------
CameraScroll._config = {}
CameraScroll._targetDist = nil
CameraScroll._displayDist = nil

CameraScroll._wheelTrigger = nil
CameraScroll._correctionTimer = nil
CameraScroll._initialized = false

local CORRECTION_INTERVAL = 0.01


-----------------------------------------------------------------
-- 配置操作
-----------------------------------------------------------------
function CameraScroll.getConfig()
    local cfg = {}
    for k, v in pairs(CameraScroll._config) do cfg[k] = v end
    return cfg
end

function CameraScroll.getDefaultConfig()
    local cfg = {}
    for k, v in pairs(CameraScroll._defaultConfig) do cfg[k] = v end
    return cfg
end

function CameraScroll.setConfig(overrides)
    if (overrides == nil) then return CameraScroll end
    local cfg = CameraScroll._config
    if (overrides.minDist ~= nil) then cfg.minDist = math.max(100, overrides.minDist) end
    if (overrides.maxDist ~= nil) then cfg.maxDist = math.max(cfg.minDist + 100, overrides.maxDist) end
    if (overrides.stepBase ~= nil) then cfg.stepBase = math.max(1, overrides.stepBase) end
    if (overrides.stepScale ~= nil) then cfg.stepScale = math.max(0, overrides.stepScale) end
    if (overrides.smoothDur ~= nil) then cfg.smoothDur = math.max(0.01, overrides.smoothDur) end
    if (overrides.defaultDist ~= nil) then cfg.defaultDist = math.max(cfg.minDist, math.min(cfg.maxDist, overrides.defaultDist)) end
    if (overrides.invert ~= nil) then cfg.invert = (overrides.invert == true) end
    if (overrides.uiBlock ~= nil) then cfg.uiBlock = (overrides.uiBlock == true) end
    if (cfg.minDist > cfg.maxDist) then cfg.minDist, cfg.maxDist = cfg.maxDist, cfg.minDist end
    return CameraScroll
end

function CameraScroll.resetConfig()
    CameraScroll._config = {}
    for k, v in pairs(CameraScroll._defaultConfig) do CameraScroll._config[k] = v end
    return CameraScroll
end

function CameraScroll.isEnabled()
    return CameraScroll._initialized
end


-----------------------------------------------------------------
-- 核心逻辑
-----------------------------------------------------------------

local function calcStep(currentDist)
    local cfg = CameraScroll._config
    return cfg.stepBase + currentDist * cfg.stepScale
end

--- 滚轮事件：更新距离 + 固定俯仰角
local function onMouseWheel()
    local delta = cdz.DzGetWheelDelta()
    if (delta == 0) then return end

    local cfg = CameraScroll._config
    if (cfg.uiBlock and cdz.DzIsMouseOverUI()) then return end

    local dir = (cfg.invert and -1 or 1) * ((delta > 0) and 1 or -1)

    local current = CameraScroll._targetDist
    if (current == nil) then
        current = Camera.getField(CAMERA_FIELD_TARGET_DISTANCE)
        CameraScroll._targetDist = current
        CameraScroll._displayDist = current
    end

    local step = calcStep(current)
    local newDist = current + dir * step
    newDist = math.max(cfg.minDist, math.min(cfg.maxDist, newDist))
    CameraScroll._targetDist = newDist

    -- 立即固定俯仰角，抵消原生滚轮对本帧的影响
    Camera.setField(CAMERA_FIELD_ANGLE_OF_ATTACK, 300, 0)
end

--- 逐帧压制：持续覆盖完整相机状态，不让原生滚轮有任何可乘之机
local function onCorrection()
    local target = CameraScroll._targetDist
    if (target == nil) then return end

    local cfg = CameraScroll._config

    -- 每帧固定俯仰角，持续压制原生滚轮的角度影响
    Camera.setField(CAMERA_FIELD_ANGLE_OF_ATTACK, 300, 0)

    -- 平滑插值距离
    local display = CameraScroll._displayDist
    if (display == nil) then
        display = target
        CameraScroll._displayDist = target
    end

    local diff = target - display
    if (math.abs(diff) > 0.5) then
        local totalFrames = cfg.smoothDur * 100
        local ratio = 1.0 / math.max(1, totalFrames)
        local stepPerFrame = math.max(15, math.abs(diff) * ratio)
        display = display + math.min(stepPerFrame, math.abs(diff)) * (diff > 0 and 1 or -1)
        CameraScroll._displayDist = display
    else
        display = target
        CameraScroll._displayDist = target
    end

    Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, display, 0)
end


-----------------------------------------------------------------
-- 启用 / 禁用
-----------------------------------------------------------------
function CameraScroll.enable(overrides)
    if (CameraScroll._initialized) then
        if (overrides ~= nil) then CameraScroll.setConfig(overrides) end
        return CameraScroll
    end

    CameraScroll.resetConfig()
    if (overrides ~= nil) then CameraScroll.setConfig(overrides) end

    -- 注册滚轮事件
    local trig = cj.CreateTrigger()
    cdz.DzTriggerRegisterMouseWheelEventByCode(trig, true, nil)
    cj.TriggerAddAction(trig, onMouseWheel)
    CameraScroll._wheelTrigger = trig

    -- 启动压制计时器
    local timer = Timer:new(CORRECTION_INTERVAL, true, onCorrection)
    CameraScroll._correctionTimer = timer

    -- 设置初始视距
    local cfg = CameraScroll._config
    if (cfg.defaultDist > 0) then
        CameraScroll._targetDist = cfg.defaultDist
        CameraScroll._displayDist = cfg.defaultDist
        Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, cfg.defaultDist, 0.3)
    end

    CameraScroll._initialized = true
    return CameraScroll
end

function CameraScroll.disable()
    if (not CameraScroll._initialized) then return CameraScroll end

    if (CameraScroll._wheelTrigger ~= nil) then
        cj.DestroyTrigger(CameraScroll._wheelTrigger)
        CameraScroll._wheelTrigger = nil
    end
    if (CameraScroll._correctionTimer ~= nil) then
        CameraScroll._correctionTimer:destroy()
        CameraScroll._correctionTimer = nil
    end

    CameraScroll._targetDist = nil
    CameraScroll._displayDist = nil
    CameraScroll._initialized = false
    return CameraScroll
end
