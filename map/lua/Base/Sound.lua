-- ============================================================
-- Sound 类 — 音效/音乐系统
-- 调用方式：
--   local s = Sound:new([[Sound\Ambient\LoopBGM.wav]], 5000)
--   s:setVolume(80):setPitch(1.2):play()
--   s:attachUnit(unit):play()
--   Sound.playMusic("War3Music.mp3")
-- ============================================================

---@class Sound 音效
Sound = {}
Sound.__index = Sound
Sound._handle = nil

---@class SoundMusic 音乐控制（静态工具集）
SoundMusic = {}

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newSound()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Sound)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建音效
---@param path string 音频文件路径
---@param duration integer|nil 音频时长（毫秒）
---@param is3D boolean|nil 是否3D音效（默认false）
---@param channel integer|nil 声道编号
---@param volume integer|nil 音量 0-127（默认127）
---@param pitch number|nil 音高 0.10-2.00（默认1.0）
---@return Sound
function Sound:new(path, duration, is3D, channel, volume, pitch)
    if (path == nil) then return end
    local obj = newSound()
    is3D = is3D or false
    obj._handle = cj.CreateSound(path, false, is3D, is3D, 10, 10, "")
    if (duration ~= nil) then
        cj.SetSoundDuration(obj._handle, duration)
    end
    cj.SetSoundVolume(obj._handle, volume or 127)
    if (channel ~= nil) then
        cj.SetSoundChannel(obj._handle, channel)
    end
    if (pitch ~= nil) then
        cj.SetSoundPitch(obj._handle, pitch)
    end
    return obj
end

--- 根据文件名和标签创建音效
---@param path string 音频文件路径
---@param label string SLK标签名（如 "Spell"）
---@param looping boolean|nil 是否循环
---@param is3D boolean|nil 是否3D
---@return Sound
function Sound:newWithLabel(path, label, looping, is3D)
    if (path == nil or label == nil) then return end
    local obj = newSound()
    looping = looping or false
    is3D = is3D or false
    obj._handle = cj.CreateSoundFilenameWithLabel(path, looping, is3D, is3D, 10, 10, label)
    return obj
end

--- 从标签创建音效
---@param label string SLK标签名
---@param looping boolean|nil 是否循环
---@param is3D boolean|nil 是否3D
---@return Sound
function Sound:newFromLabel(label, looping, is3D)
    if (label == nil) then return end
    local obj = newSound()
    looping = looping or false
    is3D = is3D or false
    obj._handle = cj.CreateSoundFromLabel(label, looping, is3D, is3D, 10, 10)
    return obj
end

--- 销毁音效
---@return Sound
function Sound:destroy()
    if (self._handle ~= nil) then
        cj.DestroySound(self._handle)
        self._handle = nil
    end
    return self
end

-----------------------------------------------------------------
-- 播放 / 停止
-----------------------------------------------------------------

--- 播放音效
---@return Sound
function Sound:play()
    if (self._handle ~= nil) then
        cj.StartSound(self._handle)
    end
    return self
end

--- 停止音效
---@param killWhenDone boolean|nil 是否播放完再停止
---@param fadeOut boolean|nil 是否渐弱
---@return Sound
function Sound:stop(killWhenDone, fadeOut)
    if (self._handle ~= nil) then
        killWhenDone = (killWhenDone ~= nil) and killWhenDone or false
        fadeOut = (fadeOut ~= nil) and fadeOut or false
        cj.StopSound(self._handle, killWhenDone, fadeOut)
    end
    return self
end

--- 只对本地玩家播放
---@return Sound
function Sound:playLocal()
    -- 只播放给本地玩家，其他玩家跳过
    if (self._handle ~= nil) then
        cj.StartSound(self._handle)
    end
    return self
end

-----------------------------------------------------------------
-- 位置 / 绑定
-----------------------------------------------------------------

--- 设置3D音效位置
---@param x number X
---@param y number Y
---@param z number|nil Z（默认0）
---@return Sound
function Sound:setPosition(x, y, z)
    if (self._handle ~= nil) then
        cj.SetSoundPosition(self._handle, x, y, z or 0)
    end
    return self
end

--- 绑定音效到单位（3D音效）
---@param unit userdata 目标单位
---@param volumePercent number|nil 音量百分比 0-100（默认100）
---@return Sound
function Sound:attachUnit(unit)
    if (self._handle ~= nil and unit ~= nil) then
        cj.AttachSoundToUnit(self._handle, unit)
    end
    return self
end

--- 绑定到单位并播放
---@param unit userdata
---@param volumePercent number|nil 音量百分比 0-100（默认100）
---@return Sound
function Sound:playAtUnit(unit, volumePercent)
    if (self._handle == nil or unit == nil) then return self end
    cj.AttachSoundToUnit(self._handle, unit)
    if (volumePercent ~= nil) then
        cj.SetSoundVolume(self._handle, math.floor(volumePercent * 127 * 0.01))
    end
    cj.StartSound(self._handle)
    return self
end

--- 移动到坐标并播放（3D音效）
---@param x number X
---@param y number Y
---@param z number|nil Z（默认0）
---@return Sound
function Sound:playAtXYZ(x, y, z)
    if (self._handle == nil) then return self end
    cj.SetSoundPosition(self._handle, x, y, z or 0)
    cj.StartSound(self._handle)
    return self
end

-----------------------------------------------------------------
-- 音量 / 音高 / 声道
-----------------------------------------------------------------

--- 设置音量
---@param volume integer 0-127
---@return Sound
function Sound:setVolume(volume)
    if (self._handle ~= nil and volume ~= nil) then
        cj.SetSoundVolume(self._handle, volume)
    end
    return self
end

--- 设置音高
---@param pitch number 0.10 - 2.00
---@return Sound
function Sound:setPitch(pitch)
    if (self._handle ~= nil and pitch ~= nil) then
        cj.SetSoundPitch(self._handle, pitch)
    end
    return self
end

--- 设置声道
---@param channel integer
---@return Sound
function Sound:setChannel(channel)
    if (self._handle ~= nil and channel ~= nil) then
        cj.SetSoundChannel(self._handle, channel)
    end
    return self
end

--- 设置音频时长
---@param duration integer 毫秒
---@return Sound
function Sound:setDuration(duration)
    if (self._handle ~= nil and duration ~= nil) then
        cj.SetSoundDuration(self._handle, duration)
    end
    return self
end

--- 设置3D衰减范围
---@param minDist number 最小距离
---@param maxDist number 最大距离
---@return Sound
function Sound:setDistances(minDist, maxDist)
    if (self._handle ~= nil) then
        cj.SetSoundDistances(self._handle, minDist, maxDist)
    end
    return self
end

--- 设置截断距离
---@param cutoff number
---@return Sound
function Sound:setCutoff(cutoff)
    if (self._handle ~= nil and cutoff ~= nil) then
        cj.SetSoundDistanceCutoff(self._handle, cutoff)
    end
    return self
end

--- 设置声音锥体角度
---@param inside number 内角
---@param outside number 外角
---@param outsideVolume integer 外部音量
---@return Sound
function Sound:setConeAngles(inside, outside, outsideVolume)
    if (self._handle ~= nil) then
        cj.SetSoundConeAngles(self._handle, inside, outside, outsideVolume)
    end
    return self
end

--- 设置声音传播方向
---@param x number X
---@param y number Y
---@param z number Z
---@return Sound
function Sound:setConeOrientation(x, y, z)
    if (self._handle ~= nil) then
        cj.SetSoundConeOrientation(self._handle, x, y, z)
    end
    return self
end

--- 设置声音速度
---@param x number X
---@param y number Y
---@param z number Z
---@return Sound
function Sound:setVelocity(x, y, z)
    if (self._handle ~= nil) then
        cj.SetSoundVelocity(self._handle, x, y, z)
    end
    return self
end

--- 设置声音标签
---@param label string
---@return Sound
function Sound:setLabel(label)
    if (self._handle ~= nil and label ~= nil) then
        cj.SetSoundLabel(self._handle, label)
    end
    return self
end

--- 设置播放时间点
---@param ms integer 毫秒
---@return Sound
function Sound:setPlayingTime(ms)
    if (self._handle ~= nil and ms ~= nil) then
        cj.SetSoundPlayingTime(self._handle, ms)
    end
    return self
end

-----------------------------------------------------------------
-- 状态查询
-----------------------------------------------------------------

--- 是否正在加载
---@return boolean
function Sound:isLoading()
    if (self._handle == nil) then return false end
    return cj.GetSoundIsLoading(self._handle)
end

--- 是否正在播放
---@return boolean
function Sound:isPlaying()
    if (self._handle == nil) then return false end
    return cj.GetSoundIsPlaying(self._handle)
end

--- 获取音频时长（毫秒）
---@return integer
function Sound:getDuration()
    if (self._handle == nil) then return 0 end
    return cj.GetSoundDuration(self._handle)
end

-----------------------------------------------------------------
-- 堆叠音效（区域环绕声效）
-----------------------------------------------------------------

--- 注册为堆叠音效（基于矩形范围）
---@param width number 矩形宽
---@param height number 矩形高
---@return Sound
function Sound:registerStack(width, height)
    if (self._handle ~= nil) then
        cj.RegisterStackedSound(self._handle, true, width, height)
    end
    return self
end

--- 取消注册堆叠音效
---@param width number 矩形宽
---@param height number 矩形高
---@return Sound
function Sound:unregisterStack(width, height)
    if (self._handle ~= nil) then
        cj.UnregisterStackedSound(self._handle, true, width, height)
    end
    return self
end

--- 设置堆叠音效（基于矩形范围）
---@param width number
---@param height number
---@return Sound
function Sound:setStack(width, height)
    if (self._handle ~= nil) then
        cj.SetStackedSound(self._handle, true, width, height)
    end
    return self
end

--- 设置矩形区域堆叠音效
---@param r rect 区域
---@return Sound
function Sound:setStackRect(r)
    if (self._handle ~= nil and r ~= nil) then
        cj.SetStackedSoundRect(self._handle, r)
    end
    return self
end

--- 清除堆叠音效
---@param width number
---@param height number
---@return Sound
function Sound:clearStack(width, height)
    if (self._handle ~= nil) then
        cj.ClearStackedSound(self._handle, true, width, height)
    end
    return self
end

--- 清除矩形区域堆叠音效
---@param r rect
---@return Sound
function Sound:clearStackRect(r)
    if (self._handle ~= nil and r ~= nil) then
        cj.ClearStackedSoundRect(self._handle, r)
    end
    return self
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Sound:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveSoundHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Sound
function Sound.loadHandle(t, pk, ck)
    local h = cj.LoadSoundHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newSound()
    obj._handle = h
    return obj
end

-----------------------------------------------------------------
-- 环境 / 全局音效设置（非实例）
-----------------------------------------------------------------

--- 设置环境音效
---@param envName string 环境名称（如 "City"、"Forest"）
function Sound.setEnvironment(envName)
    if (envName ~= nil) then
        cj.SetSoundEnvironment(envName)
    end
end

--- 多通道音量设置
---@param group volumegroup 音量组
---@param scale number 音量比例 0-1
function Sound.setVolumeGroup(group, scale)
    cj.VolumeGroupSetVolume(group, scale)
end

--- 重置音量组
function Sound.resetVolumeGroup()
    cj.VolumeGroupReset()
end

--- 转换整型为声音类型
---@param i integer
---@return soundtype
function Sound.convertType(i)
    return cj.ConvertSoundType(i)
end

--- 转换整型为音量组
---@param i integer
---@return volumegroup
function Sound.convertVolumeGroup(i)
    return cj.ConvertVolumeGroup(i)
end

--- 获取技能音效路径（通过技能字符串）
---@param abilityString string
---@param soundType soundtype
---@return string
function Sound.getAbilitySound(abilityString, soundType)
    return cj.GetAbilitySound(abilityString, soundType)
end

--- 获取技能音效路径（通过技能ID）
---@param abilityId integer
---@param soundType soundtype
---@return string
function Sound.getAbilitySoundById(abilityId, soundType)
    return cj.GetAbilitySoundById(abilityId, soundType)
end

--- 获取音频文件时长
---@param fileName string
---@return integer
function Sound.getFileDuration(fileName)
    return cj.GetSoundFileDuration(fileName)
end


-- ============================================================
-- SoundMusic 类 — 背景音乐控制
-- ============================================================

--- 播放背景音乐
---@param fileName string 音乐文件路径
function SoundMusic.play(fileName)
    cj.PlayMusic(fileName)
end

--- 播放背景音乐（扩展：指定起始时间和淡入时间）
---@param fileName string 音乐文件路径
---@param fromMs integer|nil 起始毫秒（默认0）
---@param fadeInMs integer|nil 淡入毫秒（默认0）
function SoundMusic.playEx(fileName, fromMs, fadeInMs)
    cj.PlayMusicEx(fileName, fromMs or 0, fadeInMs or 0)
end

--- 播放主题音乐（不会被音乐列表覆盖）
---@param fileName string
function SoundMusic.playThematic(fileName)
    cj.PlayThematicMusic(fileName)
end

--- 跳播主题音乐
---@param fileName string
---@param fromMs integer|nil 起始毫秒（默认0）
function SoundMusic.playThematicEx(fileName, fromMs)
    cj.PlayThematicMusicEx(fileName, fromMs or 0)
end

--- 停止背景音乐
---@param fadeOut boolean|nil 是否渐弱（默认true）
function SoundMusic.stop(fadeOut)
    cj.StopMusic((fadeOut ~= nil) and fadeOut or true)
end

--- 设置背景音乐音量
---@param percent integer 0-100
function SoundMusic.setVolume(percent)
    cj.SetMusicVolume(percent)
end

--- 设置背景音乐列表（地图自定义音乐）
---@param musicName string
---@param random boolean
---@param index integer
function SoundMusic.setList(musicName, random, index)
    cj.SetMusicList(musicName, random, index)
end
