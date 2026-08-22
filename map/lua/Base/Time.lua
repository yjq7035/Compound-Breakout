-- ============================================================
-- Time / Timer 类 — 时间与单核计时器
-- 底层：全局只有 1 个原生内核计时器(0.01s 周期)驱动所有逻辑 Timer
-- 调用方式（API 不变）：
--   local t = Timer:new(2.0, true, function() print("tick") end)
--   t:pause():resume()
--   t:destroy()
-- 说明：单核模式下 Timer 不再持有原生 timer 句柄，
--       故原 TimerDialog(计时器窗口) 已废弃删除。
-- ============================================================

-----------------------------------------------------------------
-- Time — 时间工具（静态）
-----------------------------------------------------------------

---@class Time
Time = {}
Time.__index = Time
Time._handle = nil



--- 获取游戏开始时间（毫秒时间戳）
---@return integer
function Time.getGameStartTime()
    return cdz.DzAPI_Map_GetGameStartTime()
end

--- 获取当前 TOD 缩放速率
---@return number
function Time.getTimeOfDayScale()
    return cj.GetTimeOfDayScale()
end

--- 设置 TOD 缩放速率
---@param scale number 1.0=正常, 0.0=暂停
function Time.setTimeOfDayScale(scale)
    if (scale == nil) then return end
    cj.SetTimeOfDayScale(scale)
end

--- 暂停昼夜交替
function Time.suspendTimeOfDay()
    cj.SuspendTimeOfDay(true)
end

--- 恢复昼夜交替
function Time.resumeTimeOfDay()
    cj.SuspendTimeOfDay(false)
end

--- 获取当前游戏速度
---@return gamespeed
function Time.getGameSpeed()
    return cj.GetGameSpeed()
end

--- 设置游戏速度
---@param speed gamespeed
function Time.setGameSpeed(speed)
    if (speed == nil) then return end
    cj.SetGameSpeed(speed)
end

--- 获取锦标赛倒计时剩余时间
---@return number
function Time.getTournamentRemaining()
    return cj.GetTournamentFinishSoonTimeRemaining()
end

--- 注册计时器事件
---@param trigger userdata
---@param timeout number
---@param periodic boolean
---@return event
function Time.registerTimerEvent(trigger, timeout, periodic)
    if (trigger == nil or timeout == nil) then return end
    return cj.TriggerRegisterTimerEvent(trigger, timeout, (periodic ~= nil) and periodic or false)
end

--- 注册计时器到期事件
---@param trigger userdata
---@param timer userdata
---@return event
function Time.registerTimerExpire(trigger, timer)
    if (trigger == nil or timer == nil) then return end
    return cj.TriggerRegisterTimerExpireEvent(trigger, timer)
end


-----------------------------------------------------------------
-- 单核计时器内核
-- 仅 1 个原生计时器常驻，每 10ms(1 tick) 扫描对应桶并执行回调
-----------------------------------------------------------------
local _inc = 0                  -- 内核 tick 计数，每 10ms +1
local _kernel = {}              -- _kernel[tick] = { [id] = timerObj }
local _seq = 0                  -- Timer 自增 id
local _TICK = 0.01              -- 内核周期（秒）
local _realClockTimers = {}     -- useRealClock 计时器列表（独立于内核桶，按 os.clock 驱动）

-- 桶结构：保留插入顺序（数组 list）+ 按 id 索引（byId，供 unschedule 精确移除）
-- ★ [LAN-SYNC] 原实现用 pairs(bucket) 执行回调，Lua 表哈希迭代序跨机不保证一致；
--   同一 tick 内多个计时器（技能伤害帧、伤害锁清理、buff tick）的执行先后若各机不同，
--   RNG/句柄操作的交错顺序就会分叉 → 异步掉线。
--   改为按插入序数组执行 → 任意机器回调执行顺序严格一致。

--- 调度一个 Timer 到目标 tick 桶
---@param t Timer
---@param overrideTicks number|nil 覆盖周期(tick 数)，用于 resume 续期
local function _schedule(t, overrideTicks)
    local ticks = overrideTicks or t._periodTicks
    ticks = math.max(1, math.floor((ticks or 0) + 0.5))
    local target = _inc + ticks
    t._fireTick = target
    local bucket = _kernel[target]
    if (bucket == nil) then
        bucket = { list = {}, byId = {} }
        _kernel[target] = bucket
    end
    if (bucket.byId[t._id] == nil) then
        bucket.byId[t._id] = t
        bucket.list[#bucket.list + 1] = t
    end
end

--- 从内核桶中移除一个 Timer
---@param t Timer
local function _unschedule(t)
    if (t._fireTick ~= nil and _kernel[t._fireTick] ~= nil) then
        local bucket = _kernel[t._fireTick]
        bucket.byId[t._id] = nil
        if (next(bucket.byId) == nil) then
            _kernel[t._fireTick] = nil
            bucket.list = nil
        end
    end
    t._fireTick = nil
end

--- 内核 tick：每 10ms 触发一次
local function _tick()
    _inc = _inc + 1

    -- [真时钟] 扫描所有 useRealClock 计时器，按「同步游戏时钟」实际流逝时间判定是否到期
    -- [DESYNC-FIX 2026-08-14] ★ 原实现用 os.clock()（各机 CPU 时间）驱动：双机 CPU 时间
    -- 不同步 → 脉冲/到期在各自机器的不同游戏 tick 触发 → 循环体 addBuff/Effect/damageTarget
    -- 建句柄的帧不对齐 → desync（图腾"走出范围再走回必现"的真因，排序修再多也没用）。
    -- 改用内核 tick 计数 _inc×_TICK 作为同步游戏时钟：_inc 由原生 TimerStart 引擎同步派发，
    -- 跨机严格同一 tick 递增 → useRealClock 计时器全部同步化（语义不变：均不受游戏暂停影响）。
    local now = _inc * _TICK
    for i = #_realClockTimers, 1, -1 do
        local t = _realClockTimers[i]
        if (t._dead or t._paused) then
            table.remove(_realClockTimers, i)
        elseif (not t._dead and not t._paused and t._handler ~= nil) then
            local elapsed = now - t._realStart
            if (elapsed >= t._timeout) then
                local ok, err = xpcall(t._handler, debug.traceback, t)
                if (not ok) then
                    print("[Timer] 回调出错: " .. tostring(err))
                end
                t._runCount = t._runCount + 1
                if (t._periodic and not t._dead) then
                    t._realStart = now    -- 周期计时器：重置起始时间
                else
                    t._dead = true        -- 一次性：自动死亡
                    t._handler = nil
                    -- ★ [FIX 2026-08-14] 防 double-remove：回调内若已自行 t:destroy()，本元素已被移除，
                    --   此处再 remove 会误删相邻兄弟计时器（其管理的特效/循环永久残留）或越界报错；仅原位才移除。
                    if (_realClockTimers[i] == t) then
                        table.remove(_realClockTimers, i)
                    end
                end
            end
        end
    end

    local bucket = _kernel[_inc]
    if (bucket ~= nil) then
        _kernel[_inc] = nil
        -- 按插入顺序（非 pairs 哈希序）执行，保证跨机回调顺序一致（见 _schedule 注释）
        local list = bucket.list
        for i = 1, #list do
            local t = list[i]
            if (not t._dead and not t._paused and t._handler ~= nil) then
                local ok, err = xpcall(t._handler, debug.traceback, t)
                if (not ok) then
                    print("[Timer] 回调出错: " .. tostring(err))
                end
                t._runCount = t._runCount + 1
                if (t._periodic and not t._dead) then
                    _schedule(t)              -- 周期计时器：自动续期
                else
                    t._dead = true            -- 一次性：自动死亡
                    t._handler = nil
                end
            end
        end
    end
end

-- 拉起内核（仅 1 个原生计时器常驻，永不销毁）
cj.TimerStart(cj.CreateTimer(), _TICK, true, _tick)

-----------------------------------------------------------------
-- 独立原生计时器模式（separate=true）
-- 不走单核内核桶（内核桶按插入序执行，但同 tick 多计时器仍共享一个回调现场；
-- 高频/高并发伤害结算类计时器改用独立原生计时器，由引擎按精确到期时刻派发，
-- 彻底脱离内核桶的批次调度，跨机触发先后完全由引擎确定，进一步消除交错分叉风险）
-----------------------------------------------------------------

--- 以独立原生计时器方式启动（重复调用会先销毁旧句柄）
---@param t Timer
---@param timeout number 秒
local function _nativeStart(t, timeout)
    if (t._nativeTimer ~= nil) then
        cj.DestroyTimer(t._nativeTimer)
        t._nativeTimer = nil
    end
    t._nativeTimer = cj.CreateTimer()
    t._nativeCb = function()
        if (t._dead or t._paused) then return end
        local ok, err = xpcall(t._handler, debug.traceback, t)
        if (not ok) then
            print("[Timer] 回调出错: " .. tostring(err))
        end
        t._runCount = t._runCount + 1
        if (not t._periodic) then
            -- 一次性原生计时器：到期后主动销毁句柄并复位状态
            -- （回调内可能已自行 destroy()，此处需判空）
            if (t._nativeTimer ~= nil) then
                cj.DestroyTimer(t._nativeTimer)
                t._nativeTimer = nil
            end
            t._dead = true
            t._handler = nil
        end
    end
    cj.TimerStart(t._nativeTimer, timeout, t._periodic, t._nativeCb)
end


-----------------------------------------------------------------
-- Timer 类 — 单核逻辑计时器
-- ============================================================
-- 创建：
--   local t = Timer:new(1.0, false, function() ... end)
--   t:pause()
--   t:resume()
--   t:destroy()
-- 说明：Timer 不再持有原生 timer 句柄，所有调度由单核内核驱动。
--       周期计时器不会自动销毁，仍需手动 :destroy() 避免闭包钉死。
-- ============================================================

---@class Timer
Timer = {}
Timer.__index = Timer

local function newTimer()
    _seq = _seq + 1
    local obj = {
        _id = "T" .. _seq,
        _timeout = 0,
        _periodTicks = 0,
        _periodic = false,
        _runCount = 0,
        _handler = nil,
        _dead = false,
        _paused = false,
        _fireTick = nil,
        _remainTicks = nil,
        _separate = false,
        _nativeTimer = nil,
        _nativeCb = nil,
        _useRealClock = false,
        _realStart = nil,
    }
    setmetatable(obj, Timer)
    return obj
end

--- 创建并启动计时器
---@param timeout number 超时秒数
---@param periodic boolean 是否循环
---@param handlerFunc fun(timer: Timer) 回调
---@param separate boolean|nil true=使用独立原生计时器（引擎直接派发，不走单核内核桶）；nil/false=走单核内核
---@param useRealClock boolean|nil true=使用真时钟(os.clock)驱动，不受游戏暂停/速度影响
---@return Timer
function Timer:new(timeout, periodic, handlerFunc, separate, useRealClock)
    if (timeout == nil or handlerFunc == nil) then return end
    local obj = newTimer()
    obj._timeout = timeout
    obj._periodTicks = timeout * 100          -- 秒 → tick(1 tick = 10ms)
    obj._periodic = (periodic ~= nil) and periodic or false
    obj._handler = handlerFunc
    obj._separate = (separate == true)
    obj._useRealClock = (useRealClock == true)
    if (obj._useRealClock) then
        -- 真时钟模式：不走内核桶，也不走独立原生计时器，由内核 tick 中 _realClockTimers 扫描驱动
        -- [DESYNC-FIX] 同步时钟：_inc×_TICK（跨机一致），勿改回 os.clock（双机 CPU 时间不同步）
        obj._realStart = _inc * _TICK
        _realClockTimers[#_realClockTimers + 1] = obj
    elseif (obj._separate) then
        _nativeStart(obj, timeout)
    else
        _schedule(obj)
    end
    return obj
end

--- 重新启动计时器
---@param timeout number|nil 省略则保持原值
---@param periodic boolean|nil 省略则保持原值
---@param handlerFunc function|nil 省略则保持原值
---@return Timer
function Timer:start(timeout, periodic, handlerFunc)
    if (self._dead) then return self end
    local t = timeout or self._timeout
    local p = (periodic ~= nil) and periodic or self._periodic
    local h = handlerFunc or self._handler
    if (t == nil or h == nil) then return self end
    if (self._useRealClock) then
        self._timeout = t
        self._periodTicks = t * 100
        self._periodic = p
        self._handler = h
        self._runCount = 0
        self._paused = false
        self._remainTicks = nil
        self._realStart = _inc * _TICK    -- [DESYNC-FIX] 同步时钟（勿改回 os.clock）
        return self
    end
    if (self._separate) then
        self._timeout = t
        self._periodTicks = t * 100
        self._periodic = p
        self._handler = h
        self._runCount = 0
        self._paused = false
        self._remainTicks = nil
        _nativeStart(self, t)
        return self
    end
    _unschedule(self)
    self._timeout = t
    self._periodTicks = t * 100
    self._periodic = p
    self._handler = h
    self._runCount = 0
    self._paused = false
    self._remainTicks = nil
    _schedule(self)
    return self
end

--- 暂停计时器（逻辑暂停；独立模式暂停原生计时器并记录剩余秒数）
---@return Timer
function Timer:pause()
    if (self._dead or self._paused) then return self end
    if (self._useRealClock) then
        -- 真时钟：记录已流逝秒数（同步时钟 _inc×_TICK）
        self._remainTicks = (_inc * _TICK) - self._realStart
    elseif (self._separate) then
        if (self._nativeTimer ~= nil) then
            cj.PauseTimer(self._nativeTimer)
            self._remainTicks = cj.TimerGetRemaining(self._nativeTimer)
        end
    elseif (self._fireTick ~= nil) then
        self._remainTicks = self._fireTick - _inc
        _unschedule(self)
    end
    self._paused = true
    return self
end

--- 恢复计时器（按剩余时间续期）
---@return Timer
function Timer:resume()
    if (self._dead or not self._paused) then return self end
    self._paused = false
    local remain = self._remainTicks
    self._remainTicks = nil
    if (self._useRealClock) then
        -- 真时钟：重置起始时间，减去已流逝时间（同步时钟 _inc×_TICK）
        self._realStart = (_inc * _TICK) - (remain or 0)
    elseif (self._separate) then
        if (self._nativeTimer ~= nil and self._nativeCb ~= nil) then
            -- PauseTimer 后同一句柄可直接重新启动（_remainTicks 为秒）
            cj.TimerStart(self._nativeTimer, math.max(0.01, remain or self._timeout), self._periodic, self._nativeCb)
        end
    else
        _schedule(self, remain or self._periodTicks)
    end
    return self
end

--- 销毁计时器（独立模式销毁原生句柄；内核模式从桶中移除；真时钟从列表移除）
---@return Timer
function Timer:destroy()
    if (self._dead) then return self end
    if (self._useRealClock) then
        -- 真时钟：从列表中移除
        for i = #_realClockTimers, 1, -1 do
            if (_realClockTimers[i] == self) then
                table.remove(_realClockTimers, i)
                break
            end
        end
    elseif (self._separate) then
        if (self._nativeTimer ~= nil) then
            cj.DestroyTimer(self._nativeTimer)
            self._nativeTimer = nil
        end
        self._nativeCb = nil
    else
        _unschedule(self)
    end
    self._dead = true
    self._handler = nil
    self._paused = false
    self._remainTicks = nil
    return self
end

--- 获取已逝去时间（秒）
---@return number
function Timer:getElapsed()
    if (self._dead) then return self._timeout end
    if (self._useRealClock) then
        if (self._paused) then
            return self._remainTicks or 0
        end
        return math.max(0, (_inc * _TICK) - self._realStart)
    end
    return math.max(0, self._timeout - self:getRemaining())
end

--- 获取剩余时间（秒）
---@return number
function Timer:getRemaining()
    if (self._dead) then return 0 end
    if (self._useRealClock) then
        if (self._paused) then
            return math.max(0, self._timeout - (self._remainTicks or 0))
        end
        return math.max(0, self._timeout - ((_inc * _TICK) - self._realStart))
    end
    if (self._separate) then
        if (self._nativeTimer ~= nil) then
            return math.max(0, cj.TimerGetRemaining(self._nativeTimer))
        end
        return 0
    end
    local ticks
    if (self._paused) then
        ticks = self._remainTicks or 0
    else
        ticks = (self._fireTick or _inc) - _inc
    end
    return math.max(0, ticks) / 100
end

--- 获取超时设定值（秒）
---@return number
function Timer:getTimeout()
    return self._timeout
end
