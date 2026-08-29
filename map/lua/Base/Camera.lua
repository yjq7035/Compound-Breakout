-- ============================================================
-- Camera 类 — 镜头控制
-- CameraSetup 类 — 镜头设置
-- 调用方式：
--   Camera.panTo(0, 0, 2.0)
--   Camera.setField(CAMERA_FIELD_TARGET_DISTANCE, 2000, 1)
--   local cs = CameraSetup:new()
--   cs:setField(CAMERA_FIELD_ANGLE_OF_ATTACK, 320, 0)
--   cs:apply(0.5)
-- ============================================================

---@class Camera 镜头控制（静态工具）
Camera = {}

---@class CameraSetup 镜头设置
CameraSetup = {}
CameraSetup.__index = CameraSetup
CameraSetup._handle = nil
CameraSetup._index = nil

-----------------------------------------------------------------
-- CameraSetup
-----------------------------------------------------------------
local function newSetup()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, CameraSetup)
    return obj
end

--- 创建镜头设置
---@return CameraSetup
function CameraSetup:new()
    local obj = newSetup()
    obj._handle = cj.CreateCameraSetup()
    return obj
end

--- 从 handle 创建
---@param h userdata camerasetup handle
---@return CameraSetup
function CameraSetup.fromHandle(h)
    if (h == nil) then return end
    local obj = newSetup()
    obj._handle = h
    return obj
end

--- 设置镜头属性
---@param field camerafield 镜头属性
---@param value number 值
---@param duration number 过渡时间
---@return CameraSetup
function CameraSetup:setField(field, value, duration)
    if (self._handle ~= nil) then
        cj.CameraSetupSetField(self._handle, field, value, duration or 0)
    end
    return self
end

--- 获取镜头属性
---@param field camerafield
---@return number
function CameraSetup:getField(field)
    if (self._handle == nil) then return 0 end
    return cj.CameraSetupGetField(self._handle, field)
end

--- 设置目标点位置
---@param x number X
---@param y number Y
---@param duration number|nil
---@return CameraSetup
function CameraSetup:setDest(x, y, duration)
    if (self._handle ~= nil) then
        cj.CameraSetupSetDestPosition(self._handle, x, y, duration or 0)
    end
    return self
end

--- 获取目标点X
---@return number
function CameraSetup:getDestX()
    if (self._handle == nil) then return 0 end
    return cj.CameraSetupGetDestPositionX(self._handle)
end

--- 获取目标点Y
---@return number
function CameraSetup:getDestY()
    if (self._handle == nil) then return 0 end
    return cj.CameraSetupGetDestPositionY(self._handle)
end

--- 应用镜头设置（当前玩家）
---@param doPan boolean 是否平移
function CameraSetup:apply(doPan)
    if (self._handle ~= nil) then
        cj.CameraSetupApply(self._handle, (doPan ~= nil) and doPan or true, false)
    end
end

--- 强制应用镜头设置（限时，默认 0.5 秒快速）
---@param doPan boolean
---@param duration number (默认 0.5)
function CameraSetup:applyForce(doPan, duration)
    if (self._handle ~= nil) then
        cj.CameraSetupApplyForceDuration(self._handle, (doPan ~= nil) and doPan or true, duration or 0.5)
    end
end

--- 应用镜头设置（带Z轴）
---@param zOffset number Z偏移
function CameraSetup:applyWithZ(zOffset)
    if (self._handle ~= nil) then
        cj.CameraSetupApplyWithZ(self._handle, zOffset or 0)
    end
end

--- 强制应用镜头设置（带 Z 轴 + 限时，默认 0.5 秒快速）
---@param zOffset number
---@param duration number (默认 0.5)
function CameraSetup:applyForceWithZ(zOffset, duration)
    if (self._handle ~= nil) then
        cj.CameraSetupApplyForceDurationWithZ(self._handle, zOffset or 0, duration or 0.5)
    end
end

-----------------------------------------------------------------
-- Camera — 镜头操作（所有玩家）
-----------------------------------------------------------------

--- 平移镜头到坐标
---@param x number X
---@param y number Y
function Camera.panTo(x, y)
    cj.PanCameraTo(x, y)
end

--- 平移镜头（限时，默认 0.5 秒快速移动）
---@param x number
---@param y number
---@param duration number 过渡秒数 (默认 0.5)
function Camera.panToTimed(x, y, duration)
    cj.PanCameraToTimed(x, y, duration or 0.5)
end

--- 平移镜头到坐标（带Z轴偏移）
---@param x number
---@param y number
---@param zOffset number Z偏移
function Camera.panToWithZ(x, y, zOffset)
    cj.PanCameraToWithZ(x, y, zOffset or 0)
end

--- 平移镜头（限时 + 带 Z 轴，默认 0.5 秒快速移动）
---@param x number
---@param y number
---@param zOffset number
---@param duration number (默认 0.5)
function Camera.panToTimedWithZ(x, y, zOffset, duration)
    cj.PanCameraToTimedWithZ(x, y, zOffset or 0, duration or 0.5)
end

--- 设置镜头位置（立即）
---@param x number
---@param y number
function Camera.setPos(x, y)
    cj.SetCameraPosition(x, y)
end

--- 设置空格键转向点
---@param x number
---@param y number
function Camera.setQuickPos(x, y)
    cj.SetCameraQuickPosition(x, y)
end

--- 设置镜头属性
---@param field camerafield 属性
---@param value number 值
---@param duration number 过渡时间
function Camera.setField(field, value, duration)
    cj.SetCameraField(field, value, duration or 0)
end

--- 调整镜头属性（相对值）
---@param field camerafield
---@param offset number 偏移量
---@param duration number
function Camera.adjustField(field, offset, duration)
    cj.AdjustCameraField(field, offset, duration or 0)
end

--- 设置镜头边界
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@param x4 number
---@param y4 number
function Camera.setBounds(x1, y1, x2, y2, x3, y3, x4, y4)
    cj.SetCameraBounds(x1, y1, x2, y2, x3, y3, x4, y4)
end

--- 锁定镜头到单位（固定镜头源）
---@param unit userdata 单位
---@param xOffset number X偏移
---@param yOffset number Y偏移
function Camera.lockOrient(unit, xOffset, yOffset)
    cj.SetCameraOrientController(unit, xOffset or 0, yOffset or 0)
end

--- 锁定镜头到单位（镜头跟随）
---@param unit userdata
---@param xOffset number
---@param yOffset number
---@param inherit boolean 是否继承朝向
function Camera.lockTarget(unit, xOffset, yOffset, inherit)
    cj.SetCameraTargetController(unit, xOffset or 0, yOffset or 0, (inherit ~= nil) and inherit or true)
end

--- 旋转镜头（默认 0.5 秒快速旋转）
---@param x number 旋转中心 X
---@param y number 旋转中心 Y
---@param radians number 弧度
---@param duration number (默认 0.5)
function Camera.rotate(x, y, radians, duration)
    cj.SetCameraRotateMode(x, y, radians or 0, duration or 0.5)
end

--- 重置镜头到游戏默认（快速重置，默认 0.5 秒）
---@param duration number 过渡秒数 (默认 0.5)
function Camera.reset(duration)
    cj.ResetToGameCamera(duration or 0.5)
end

--- 播放电影镜头（所有玩家）
---@param cameraModelFile string 镜头模型文件名
function Camera.playCinematic(cameraModelFile)
    cj.PlayCinematic(cameraModelFile)
end

--- 设置平滑参数
---@param factor number 平滑因子
function Camera.setSmoothing(factor)
    cj.CameraSetSmoothingFactor(factor)
end

-----------------------------------------------------------------
-- 镜头抖动（源抖动 / 目标抖动）
-----------------------------------------------------------------

--- 镜头源抖动
---@param mag number 幅度
---@param velocity number 速度
function Camera.shakeSource(mag, velocity)
    cj.CameraSetSourceNoise(mag, velocity)
end

--- 镜头源抖动（仅垂直，所有玩家）
---@param mag number
---@param velocity number
---@param vertOnly boolean 仅垂直方向
function Camera.shakeSourceEx(mag, velocity, vertOnly)
    cj.CameraSetSourceNoiseEx(mag, velocity, (vertOnly ~= nil) and vertOnly or false)
end

--- 镜头目标抖动
---@param mag number
---@param velocity number
function Camera.shakeTarget(mag, velocity)
    cj.CameraSetTargetNoise(mag, velocity)
end

--- 镜头目标抖动（仅垂直，所有玩家）
---@param mag number
---@param velocity number
---@param vertOnly boolean
function Camera.shakeTargetEx(mag, velocity, vertOnly)
    cj.CameraSetTargetNoiseEx(mag, velocity, (vertOnly ~= nil) and vertOnly or false)
end

--- 停止所有镜头抖动
function Camera.stopShake()
    cj.CameraSetSourceNoise(0, 0)
    cj.CameraSetTargetNoise(0, 0)
end

-----------------------------------------------------------------
-- 镜头查询（当前玩家）
-----------------------------------------------------------------

--- 获取镜头属性
---@param field camerafield
---@return number
function Camera.getField(field)
    return cj.GetCameraField(field)
end

--- 获取镜头眼睛位置X
---@return number
function Camera.getEyeX()
    return cj.GetCameraEyePositionX()
end

--- 获取镜头眼睛位置Y
---@return number
function Camera.getEyeY()
    return cj.GetCameraEyePositionY()
end

--- 获取镜头眼睛位置Z
---@return number
function Camera.getEyeZ()
    return cj.GetCameraEyePositionZ()
end

--- 获取镜头目标位置X
---@return number
function Camera.getTargetX()
    return cj.GetCameraTargetPositionX()
end

--- 获取镜头目标位置Y
---@return number
function Camera.getTargetY()
    return cj.GetCameraTargetPositionY()
end

--- 获取镜头目标位置Z
---@return number
function Camera.getTargetZ()
    return cj.GetCameraTargetPositionZ()
end

--- 获取镜头边界最小值X
---@return number
function Camera.getBoundMinX()
    return cj.GetCameraBoundMinX()
end

--- 获取镜头边界最小值Y
---@return number
function Camera.getBoundMinY()
    return cj.GetCameraBoundMinY()
end

--- 获取镜头边界最大值X
---@return number
function Camera.getBoundMaxX()
    return cj.GetCameraBoundMaxX()
end

--- 获取镜头边界最大值Y
---@return number
function Camera.getBoundMaxY()
    return cj.GetCameraBoundMaxY()
end

--- 获取镜头边距
---@return number
function Camera.getMargin()
    return cj.GetCameraMargin()
end

-----------------------------------------------------------------
-- 镜头效果（滤镜）
-----------------------------------------------------------------
-- 注：以下函数实际为滤镜/电影模式相关，与镜头位置无关
-- 但常被用于镜头过渡效果，一并提供

--- 设置滤镜混合模式
---@param mode blendmode
function Camera.setFilterBlend(mode)
    cj.SetCineFilterBlendMode(mode)
end

--- 设置滤镜纹理
---@param texFile string 纹理文件
function Camera.setFilterTexture(texFile)
    cj.SetCineFilterTexture(texFile)
end

--- 设置滤镜开始颜色
---@param r integer
---@param g integer
---@param b integer
---@param a integer
function Camera.setFilterStartColor(r, g, b, a)
    cj.SetCineFilterStartColor(r, g, b, a)
end

--- 设置滤镜结束颜色
---@param r integer
---@param g integer
---@param b integer
---@param a integer
function Camera.setFilterEndColor(r, g, b, a)
    cj.SetCineFilterEndColor(r, g, b, a)
end

--- 设置滤镜持续时间
---@param duration number
function Camera.setFilterDuration(duration)
    cj.SetCineFilterDuration(duration)
end

--- 显示滤镜
---@param flag boolean
function Camera.showFilter(flag)
    cj.DisplayCineFilter((flag ~= nil) and flag or true)
end

--- 结束电影模式
function Camera.endCinematic()
    cj.EndCinematicScene()
end

--- 强制结束电影模式
function Camera.forceCinematicEnd()
    cj.ForceCinematicSubtitles(false) -- this is for subtitles, not quite right
    cj.EndCinematicScene()
end
