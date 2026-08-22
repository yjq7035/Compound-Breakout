-- ============================================================
-- LeakDetect — 游戏资源泄露检测（底层模块）
-- 位置：map/lua/api/LeakDetect.lua
-- 加载：在 lua.lua 末尾 require "lua.api.LeakDetect"
-- 默认开启；通过 UI TXT（SystemMessage）播报泄露信息。
--
-- 原理
--   钩住各资源类 new / destroy，以及原生句柄创建/销毁：
--     · 创建时登记（弱引用 + 创建调用栈）
--     · 销毁(destroy/remove)时销账
--   周期性 GC 扫描（SWEEP_INTERVAL）：
--     · 对象已被回收却从未 destroy  -> 原生句柄泄露（确定）
--     · 短生命周期对象存活 > TTL 且未销毁 -> 疑似泄露（警告）
--   调用栈定位泄露源头，UI TXT 播报。
--
-- 设计取舍
--   · Group 为纯 Lua 封装（无原生 handle），不监控。
--   · Effect 仅监控 duration<0 的手动生命周期档（duration>=0 由引擎定时回收，
--     若也监控会产生大量误报）。
--   · Item / Unit 多为有意为之的长期实体，默认关闭，可用 LD.enable 开启。
--   · Trigger 直接钩住 cj.CreateTrigger / cj.DestroyTrigger（原生句柄），
--     覆盖 Event 类、任意单位伤害事件(ensureDamageTrigger/initDamageSystem)、
--     CameraScroll、Dialog、Talent、矩形事件等所有建 trigger 的路径，
--     不存在“漏网”的建 trigger 调用。原生句柄无法挂 _leakId，改用
--     “按 handleId 存活表 + 创建调用栈 + 弱引用孤儿检测”追踪。
-- ============================================================

LeakDetect = LeakDetect or {}
do
    local LD = LeakDetect

    -- ---------------- 配置 ----------------
    LD.ENABLED         = true          -- 默认开启泄露检测
    LD.DEBUG           = false         -- 调试输出开关（默认关闭，仅影响内部诊断日志，不影响泄露报告/面板）
    LD.SWEEP_INTERVAL  = 5.0           -- 扫描周期（秒）
    LD.TTL             = 8.0           -- 短生命周期对象“疑似泄露”阈值（秒）
    LD.AUTO_CLEANUP    = true          -- 智能排泄：自动销毁超 TTL 的短生命周期对象
    LD.CLEANUP_DELAY   = 5.0           -- 疑似泄露后延迟多久自动销毁（秒）
    LD.CAPTURE_TRACE   = true          -- 捕获创建调用栈
    LD.MAX_TRACE_LINES = 6             -- 调用栈展示行数
    LD.MAX_REPORT      = 10            -- 每次扫描 UI 最多播报条数
    LD.FORCE_GC        = false         -- 扫描时强制执行 collectgarbage("collect")
    LD.REPORT_STYLE    = "console"     -- system=SystemMessage / chat=DisplayTextToPlayer / console=print（默认仅 print，不刷模拟信息）
    LD.MEM_WATCH       = false         -- 额外采样 Lua 内存增长（仅控制台）
    LD.ICON            = [[ReplaceableTextures\CommandButtons\BTNScroll.blp]]

    -- 左侧监视面板（提示框样式）
    LD.PANEL           = false         -- 显示左侧监视面板
    LD.PANEL_X         = 12            -- 面板左上角 X（像素，0=左）
    LD.PANEL_Y         = 300           -- 面板左上角 Y（像素，0=顶部）
    LD.PANEL_W         = 300           -- 面板宽度
    LD.PANEL_H         = 300           -- 面板高度（含触发器行，加高避免溢出）
    LD.PANEL_FONT      = "UI\\Fonts\\ARHei.TTF"
    LD.PANEL_FTITLE    = 0.012         -- 标题字号
    LD.PANEL_FBODY     = 0.012         -- 正文字号
    LD.PANEL_CTITLE    = 0xFFFFCC00    -- 金色标题
    LD.PANEL_CBODY     = 0xFFCFCFCF    -- 浅灰正文

    -- 防止重复 require 重复初始化
    if LD._init then return end

    local tracked      = {}            -- id -> record
    local rawByHandle  = {}            -- handleId(字符串) -> record（原生句柄存活表）
    local nextId       = 1
    LD.totalLeaks      = 0
    LD.staleCount      = 0     -- 疑似泄露（短生命周期超 TTL）累计计数
    LD.ignored         = 0
    local ignorePats   = {}            -- 调用栈含这些子串则只计数不播报
    local enabledTypes = {}            -- 类型开关
    local _clock       = 0

    -- 调试输出：仅 LD.DEBUG=true 时生效
    local function dbg(...)
        if LD.DEBUG then
            print(...)
        end
    end

    -- 受监控的资源类
    --   ctors      : 会被钩住的构造方法
    --   destroys   : 会被钩住的销毁方法
    --   trackIf    : 可选谓词，返回 true 才登记（Effect 仅手动时长）
    --   stale      : 是否参与“疑似泄露(TTL)”检测（短生命周期类）
    --   periodicArg: new 参数中标识是否循环的序号（Timer）
    --   defaultOff : 默认关闭
    --   hookTable  : 钩子所在表（默认 _G[clsName]）；原生句柄类用 "cj"
    --   raw        : true=原生句柄（无 Lua 对象，按 handleId 追踪，如 Trigger）
    local SPECS = {
        Effect = {
            ctors    = { "new", "newAttach" },
            destroys = { "destroy", "remove" },
            trackIf  = function(ctor, args)
                -- new(model,x,y,z,duration) -> args[5]
                -- newAttach(model,u,pt,duration) -> args[4]
                local dur = (ctor == "newAttach") and args[4] or args[5]
                return dur ~= nil and dur < 0   -- 仅手动生命周期(duration<0)会泄露
            end,
            stale = false,  -- 特效常作长持 buff，仅用 GC 检测避免误报
        },
        Timer = {
            ctors      = { "new" },
            destroys   = { "destroy" },
            periodicArg = 2,  -- new(timeout, periodic, fn) -> args[2]
            stale = true,
        },
        Lightning = {
            ctors    = { "new", "newEx", "fromHandle", "loadHandle" },
            destroys = { "destroy" },
            stale = true,
        },
        TextTag = {
            ctors    = { "new", "newUnit", "fromHandle", "load" },
            destroys = { "destroy" },
            stale = true,
        },
        Item = {
            ctors     = { "new" },
            destroys  = { "destroy" },
            stale     = false,
        },
        Unit = {
            ctors     = { "new" },
            destroys  = { "destroy" },
            stale     = false,
        },
        Frame = {
            ctors     = { "new", "newByTag", "wrap" },
            destroys  = { "destroy" },
            stale     = false,
        },
        Rect = {
            ctors     = { "new", "newCenter", "fromHandle", "load" },
            destroys  = { "destroy" },
            stale     = true,
        },
        -- 触发器（原生句柄 cj.CreateTrigger / cj.DestroyTrigger）
        --   · 直接挂 cj 这一层，覆盖所有触发器：Event:new、任意单位伤害事件内部
        --     ensureDamageTrigger / initDamageSystem、CameraScroll、Dialog、Talent、
        --     矩形事件等，不再有“漏网”的建 trigger 路径。
        --   · 原生 trigger 是引擎句柄（userdata/整数），没有 Lua 对象可挂 _leakId，
        --     故用“按 handleId 存活表 + 创建调用栈”追踪：cj.DestroyTrigger 时销账；
        --     Lua 端引用丢失（weak 句柄变 nil）却从未 DestroyTrigger = 确定泄露(孤儿)。
        --   · stale=false：句柄由引擎管理，不靠 TTL 判定（常驻 trigger 会误报）。
        Trigger = {
            hookTable = "cj",
            raw       = true,
            ctors     = { "CreateTrigger" },
            destroys  = { "DestroyTrigger" },
            stale     = false,
        },
    }

    -- 默认开启类型
    for name, spec in pairs(SPECS) do
        enabledTypes[name] = not spec.defaultOff
    end

    -- ---------------- 时间 ----------------
    local function now()
        local ok, t = pcall(os.clock)
        if ok and type(t) == "number" then return t end
        return _clock
    end

    -- ---------------- 调用栈裁剪 ----------------
    local function trimTrace(trace)
        if not trace or trace == "" then return "(无调用栈)" end
        local lines = {}
        local n = 0
        for line in trace:gmatch("[^\n]+") do
            -- 去掉 LeakDetect 自身内部帧，仅保留业务调用栈
            if not line:find("LeakDetect%.lua") then
                lines[#lines + 1] = line:gsub("^%s*", "")
                n = n + 1
                if n >= LD.MAX_TRACE_LINES then break end
            end
        end
        if #lines == 0 then return "(调用栈位于 LeakDetect 内部)" end
        return table.concat(lines, "  >  ")
    end

    -- 原生句柄的唯一标识（用于存活表与销毁销账匹配）
    local function handleIdOf(h)
        local ok, id = pcall(function() return cj.GetHandleId(h) end)
        if ok and id then return tostring(id) end
        return "h:" .. tostring(h)
    end

    -- ---------------- 登记 / 销账 ----------------
    local function register(obj, clsName, spec, args)
        if type(obj) ~= "table" then return end
        if rawget(obj, "_leakIgnore") then return end
        local id = nextId
        nextId = nextId + 1
        obj._leakId = id
        local trace = ""
        if LD.CAPTURE_TRACE then
            local ok, tb = pcall(debug.traceback, "", 3)
            if ok then trace = trimTrace(tb) end
        end
        local periodic = false
        if spec.periodicArg then periodic = not not args[spec.periodicArg] end
        tracked[id] = {
            id           = id,
            cls          = clsName,
            t0           = now(),
            trace        = trace,
            released     = false,
            periodic     = periodic,
            staleReported = false,
            ignoredFlag  = false,
            weak         = setmetatable({ o = obj }, { __mode = "v" }),
        }
    end

    -- 原生句柄（触发器）登记：按 handleId 建存活表，weak 引用用于孤儿检测
    local function registerRaw(handle, clsName, spec, args)
        if handle == nil then return end
        local id = nextId
        nextId = nextId + 1
        local trace = ""
        if LD.CAPTURE_TRACE then
            local ok, tb = pcall(debug.traceback, "", 3)
            if ok then trace = trimTrace(tb) end
        end
        local rec = {
            id            = id,
            cls           = clsName,
            t0            = now(),
            trace         = trace,
            released      = false,
            periodic      = false,
            staleReported = false,
            ignoredFlag   = false,
            handle        = handle,
            handleId      = handleIdOf(handle),
            -- 原生句柄(userdata/整数)的弱引用：Lua 端引用丢失后 weak.h 变 nil，
            -- 但引擎 trigger 仍因被注册而存活 -> 判定为“确定泄露(孤儿)”。
            -- 若句柄为整数(不可 GC)，weak.h 永远非 nil，则不会误报、也不自动发现，
            -- 仅作为存活计数与 dump 依据（仍很有用）。
            weak          = setmetatable({ h = handle }, { __mode = "v" }),
        }
        tracked[id] = rec
        rawByHandle[rec.handleId] = rec
    end

    local function markReleased(obj)
        if type(obj) ~= "table" then return end
        local id = rawget(obj, "_leakId")
        if id and tracked[id] then
            tracked[id] = nil
        end
    end

    -- 原生句柄销毁销账：按 handleId 找到存活表记录并移除
    local function markRawReleased(handle)
        if handle == nil then return end
        local hid = handleIdOf(handle)
        local rec = rawByHandle[hid]
        if rec then
            tracked[rec.id] = nil
            rawByHandle[hid] = nil
        end
    end

    -- ---------------- 钩子安装 ----------------
    -- 支持重复调用：对“之前未找到的类/表”自动重试（应对模块加载顺序差异，
    -- 例如 cj / Event 类可能晚于 LeakDetect 初始化），已成功钩住的类不会重复包裹。
    local function installHooks()
        LD._hooked = LD._hooked or {}
        LD._hooksInstalledWarned = LD._hooksInstalledWarned or {}
        LD._hooksInstalled = true
        for clsName, spec in pairs(SPECS) do
            if not LD._hooked[clsName] then
                local tblName = spec.hookTable or clsName
                local tbl = _G[tblName]
                if type(tbl) ~= "table" then
                    if not LD._hooksInstalledWarned[clsName] then
                        print("[LeakDetect] 警告：未找到表 " .. tblName .. "（类 " .. clsName .. "），跳过钩子（后续重试）")
                        LD._hooksInstalledWarned[clsName] = true
                    end
                else
                    for _, ctorName in ipairs(spec.ctors) do
                        local orig = tbl[ctorName]
                        if type(orig) == "function" then
                            if spec.raw then
                                tbl[ctorName] = function(...)
                                    local args = { ... }
                                    _G._PT = _G._PT or {}; _G._PT.trigC = (_G._PT.trigC or 0) + 1  -- [PROBE] 触发区创建计数
                                    local obj = orig(table.unpack(args))
                                    if enabledTypes[clsName]
                                       and obj ~= nil
                                       and (spec.trackIf == nil or spec.trackIf(ctorName, args)) then
                                        registerRaw(obj, clsName, spec, args)
                                    end
                                    return obj
                                end
                            else
                                tbl[ctorName] = function(self, ...)
                                    local args = { ... }
                                    local obj = orig(self, table.unpack(args))
                                    if enabledTypes[clsName]
                                       and obj ~= nil
                                       and (spec.trackIf == nil or spec.trackIf(ctorName, args)) then
                                        register(obj, clsName, spec, args)
                                    end
                                    return obj
                                end
                            end
                        end
                    end
                    for _, dn in ipairs(spec.destroys) do
                        local orig = tbl[dn]
                        if type(orig) == "function" then
                            if spec.raw then
                                tbl[dn] = function(...)
                                    local args = { ... }
                                    _G._PT = _G._PT or {}; _G._PT.trigD = (_G._PT.trigD or 0) + 1  -- [PROBE] 触发区销毁计数
                                    markRawReleased(args[1])
                                    return orig(table.unpack(args))
                                end
                            else
                                tbl[dn] = function(self, ...)
                                    markReleased(self)
                                    return orig(self, ...)
                                end
                            end
                        end
                    end
                    LD._hooked[clsName] = true
                end
            end
        end
    end

    -- ---------------- 播报 ----------------
    local function sendSystem(text)
        if type(SystemMessage) == "table" and type(SystemMessage.send) == "function" then
            SystemMessage.send({ { "art", LD.ICON }, { "STR", text } })
        else
            print("[LeakDetect] " .. text)
        end
    end

    local function sendChat(text)
        local ok, gp = pcall(function() return cj.GetLocalPlayer() end)
        if ok and gp then
            pcall(function() cj.DisplayTextToPlayer(gp, 0, 0, text) end)
        else
            print("[LeakDetect] " .. text)
        end
    end

    local function report(lines)
        if LD.REPORT_STYLE == "chat" then
            for _, l in ipairs(lines) do sendChat(l) end
        elseif LD.REPORT_STYLE == "console" then
            for _, l in ipairs(lines) do print("[LeakDetect] " .. l) end
        else
            -- system：标题 + 合并明细（限行）
            sendSystem(lines[1])
            if #lines > 1 then
                sendSystem(table.concat(lines, "\n", 2))
            end
        end
    end

    -- ---------------- 扫描 ----------------
    local function sweep()
        _clock = _clock + LD.SWEEP_INTERVAL
        if LD.FORCE_GC then pcall(collectgarbage, "collect") end

        if LD.MEM_WATCH then
            local ok, kb = pcall(collectgarbage, "count")
            if ok and type(kb) == "number" then
                dbg(string.format("[LeakDetect] Lua 内存：%.1f KB", kb))
            end
        end

        local found = {}
        for id, rec in pairs(tracked) do
            if rec.released or rec.ignoredFlag then
                tracked[id] = nil
            elseif rec.handle then
                -- 原生句柄（触发器）：孤儿检测
                --   weak.h 变 nil = Lua 端引用已全部丢失，但引擎 trigger 仍因被注册而存活
                --   -> 确定泄露（从未 DestroyTrigger）。
                --   若 weak.h 仍非 nil：仍被某处引用（含闭包持有），存活；
                --   闭包钉死型泄漏无法靠弱引用发现，仅表现为存活数只增不减（见 dump）。
                if rec.weak.h == nil then
                    rec.kind = "gc"
                    found[#found + 1] = rec
                    tracked[id] = nil
                elseif LD.AUTO_CLEANUP and not rec._cleanupScheduled then
                    -- 智能排泄：只处理未绑定具体单位的触发器（Event:new(nil, ...) 等全局事件），
                    -- per-unit 触发器由 Event 死亡队列系统管理，不在这里处理。
                    local h = rec.handle
                    if h and type(Event) == "table" and type(Event.getUnitBinding) == "function" then
                        local unitHandle = Event.getUnitBinding(h)
                        if unitHandle == nil then
                            local age = now() - rec.t0
                            if age >= LD.TTL then
                                rec._cleanupScheduled = true
                                dbg(string.format("[LeakDetect] 智能排泄标记未绑定单位的触发器 (handle=%s, age=%.1f)",
                                    tostring(rec.handleId or "?"), age))
                            end
                        end
                    end
                end
            else
                -- Lua 类对象（Effect/Timer/...）：原有 GC 弱引用逻辑
                if rec.weak.o == nil then
                    -- 已被回收却从未 destroy -> 确定泄露
                    rec.kind = "gc"
                    found[#found + 1] = rec
                    tracked[id] = nil
                else
                    local spec = SPECS[rec.cls]
                    if spec and spec.stale and not rec.periodic and not rec.staleReported then
                        local age = now() - rec.t0
                        if age >= LD.TTL then
                            rec.kind = "stale"
                            rec.age = age
                            rec.staleReported = true
                            found[#found + 1] = rec
                        end
                    end
                end
            end
        end

        if #found == 0 then return end

        -- 仅计数，不自动刷屏：面板实时显示各项存活数与累计计数，
        -- 详情由用户点击面板按钮触发 LD.dump（手动、不刷屏）。
        for _, rec in ipairs(found) do
            local ignored = false
            for _, pat in ipairs(ignorePats) do
                if rec.trace:find(pat) then ignored = true; break end
            end
            if ignored then
                LD.ignored = LD.ignored + 1
            elseif rec.kind == "stale" then
                LD.staleCount = (LD.staleCount or 0) + 1
            else
                LD.totalLeaks = LD.totalLeaks + 1
            end
        end
    end

    -- ---------------- 对外 API ----------------
    function LD.enable(name)  enabledTypes[name] = true end
    function LD.disable(name) enabledTypes[name] = false end

    function LD.setAutoCleanup(enable) LD.AUTO_CLEANUP = enable end
    function LD.setCleanupDelay(delay) LD.CLEANUP_DELAY = delay end

    -- 按创建调用栈子串过滤（匹配则只计数、不播报 UI）
    function LD.ignorePattern(pat) ignorePats[#ignorePats + 1] = pat end

    -- 显式豁免某个对象（长期持有但确为有意，如常驻 buff 特效、常驻 trigger）
    --   支持 Lua 对象（带 _leakId）与原生句柄（按 handleId 查存活表）两种传入。
    function LD.ignore(obj)
        -- 原生句柄（触发器/计时器等）也可能传入：按 handleId 豁免
        local ok, hid = pcall(handleIdOf, obj)
        if ok and hid then
            local rec = rawByHandle[hid]
            if rec then
                tracked[rec.id] = nil
                rawByHandle[hid] = nil
            end
        end
        if type(obj) == "table" then
            obj._leakIgnore = true
            local id = rawget(obj, "_leakId")
            if id and tracked[id] then tracked[id].ignoredFlag = true end
        end
    end
    LD.keep = LD.ignore

    -- 暴露钩子安装（require 阶段可安全预装，仅包裹函数、不涉及 UI/Timer）
    LD.installHooks = installHooks

    -- 当前仍存活（已登记未销毁）的对象快照，打印到控制台
    function LD.snapshot()
        local n = 0
        for _, rec in pairs(tracked) do
            local alive = rec.weak.o or rec.handle
            if alive and not rec.released and not rec.ignoredFlag then
                local tag = rec.cls == "Trigger" and ("handle=" .. tostring(rec.handleId or "?")) or ""
                n = n + 1
                print(string.format("[LeakDetect][存活] %s %s 存活%.1fs | %s",
                    rec.cls, tag, now() - rec.t0, rec.trace))
            end
        end
        print(string.format("[LeakDetect] 当前存活 %d 个已登记对象，累计泄露 %d，忽略 %d",
            n, LD.totalLeaks, LD.ignored))
    end

    -- 点击面板按钮时一次性打印某类型（或全部）的泄露/可疑信息（仅控制台，不刷模拟信息）
    function LD.dump(cls)
        local list = {}
        for _, rec in pairs(tracked) do
            if not rec.released and (cls == nil or cls == "ALL" or rec.cls == cls) then
                list[#list + 1] = rec
            end
        end
        local tag = cls or "ALL"
        if #list == 0 then
            print(string.format("[LeakDetect][dump] %s：无存活/未销账对象", tag))
            return
        end

        -- 明确提示用户按 F9 查看；单位数量大时只打印前 30 个摘要，其余省略
        local isUnit = (cls == "Unit")
        local isTrig = (cls == "Trigger")
        local maxPrint = isUnit and 30 or (isTrig and 100 or 100)
        print("\n========================================")
        print(string.format("[LeakDetect][dump] === %s 共 %d 个（点击按钮触发）===", tag, #list))
        print("[LeakDetect][dump] 请按 F9 打开日志查看本次明细")
        print("========================================")

        local printed = 0
        for _, rec in ipairs(list) do
            local status = rec.kind == "stale" and "疑似" or ((rec.handle or rec.weak.o) and "存活" or "已泄露")
            local age = rec.age and rec.age or (now() - rec.t0)
            local detail = ""
            if rec.cls == "Trigger" then
                -- 原生句柄：显示 handleId（配合调用栈即可定位创建点）
                detail = string.format(" | handle=%s", tostring(rec.handleId or "?"))
            else
                local obj = rec.weak.o
                if obj then
                    -- 单位：显示名称、ID、所有者；名称为空时回退到类型ID或数字ID
                    if rec.cls == "Unit" and type(obj.getName) == "function" then
                        local rawName = obj:getName() or ""
                        local name = (rawName ~= "" and rawName) or (obj._type and tostring(obj._type)) or "?"
                        local uid = (obj.getId and obj:getId()) or (obj._id and tostring(obj._id)) or "?"
                        local owner = ""
                        if type(obj.getOwner) == "function" then
                            local p = obj:getOwner()
                            if p and p.getName then
                                owner = string.format(" 所有者[%s|P%d]", p:getName(), p:getId())
                            end
                        end
                        detail = string.format(" | %s(%s)%s", name, uid, owner)
                    -- 物品：显示名称、ID
                    elseif rec.cls == "Item" and type(obj.getName) == "function" then
                        local name = obj:getName() or "?"
                        local iid = obj.getId and obj:getId() or "?"
                        detail = string.format(" | %s(%s)", name, iid)
                    -- 其他：尝试显示对象内部信息
                    elseif obj._handle then
                        detail = string.format(" | handle=%s", tostring(obj._handle))
                    end
                end
            end
            print(string.format("  [%s] %s 存活%.1fs%s", status, rec.cls, age, detail))
            print("       " .. rec.trace:gsub("\n", "\n       "))
            printed = printed + 1
            if printed >= maxPrint then
                print(string.format("[LeakDetect][dump] ... 省略 %d 个，请按 F9 查看完整日志 ...", #list - printed))
                break
            end
        end

        -- 调用栈聚合：按创建点统计数量，直接暴露“泄漏大户”来源（最多 TOP 15）
        local byTrace = {}
        for _, rec in ipairs(list) do
            local t = (rec.trace and rec.trace ~= "") and rec.trace or "(无调用栈)"
            byTrace[t] = (byTrace[t] or 0) + 1
        end
        local agg = {}
        for t, c in pairs(byTrace) do agg[#agg + 1] = { trace = t, count = c } end
        table.sort(agg, function(a, b) return a.count > b.count end)
        local topN = math.min(15, #agg)
        print(string.format("[LeakDetect][dump] === %s 创建点 TOP %d（按数量降序）===", tag, topN))
        for i = 1, topN do
            print(string.format("  ×%-4d  %s", agg[i].count, agg[i].trace))
        end

        -- 游戏内横幅提示：让用户知道点击生效了，并去 F9 查看
        local typeName = (cls == "ALL" and "全部") or (cls and tostring(cls)) or "ALL"
        local hint = string.format("[LeakDetect] %s 详情已输出到 F9 日志（共 %d 个）", typeName, #list)
        print(hint)
        pcall(function()
            SystemMessage.send({ {"art", LD.ICON}, {"STR", hint} })
        end)
    end
    -- ---------------- 左侧监视面板 ----------------
    local PANEL_ROWS = {
        { cls = "Unit",      name = "单位" },
        { cls = "Item",      name = "物品" },
        { cls = "Effect",    name = "特效" },
        { cls = "Lightning", name = "闪电" },
        { cls = "TextTag",   name = "文字标签" },
        { cls = "Rect",      name = "矩形" },
        { cls = "Timer",     name = "计时器" },
        { cls = "Frame",     name = "框架" },
        { cls = "Trigger",   name = "触发器" },
    }
    function LD.dumpLeaks()
        print("\n========================================")
        print("[LeakDetect][dumpLeaks] === 累计泄露统计 ===")
        print("========================================")
        print(string.format("累计确定泄露: %d", LD.totalLeaks or 0))
        print(string.format("累计疑似泄露: %d", LD.staleCount or 0))
        print(string.format("累计忽略: %d", LD.ignored or 0))
        print("----------------------------------------")
        local aliveCounts = {}
        for _, r in ipairs(PANEL_ROWS) do
            aliveCounts[r.cls] = LD.count(r.cls)
        end
        for cls, n in pairs(aliveCounts) do
            if n > 0 then
                print(string.format("  %s: %d 存活", cls, n))
            end
        end
        print("----------------------------------------")
        print("提示：点击各类型右侧的「打印」按钮可查看详细调用栈")
        print("========================================\n")
        pcall(function()
            SystemMessage.send({ {"art", LD.ICON}, {"STR", "[LeakDetect] 泄露统计已输出到 F9 日志"} })
        end)
    end



    -- 对外查询
    function LD.isEnabled(name) return not not enabledTypes[name] end
    function LD.count(name)
        local n = 0
        for _, rec in pairs(tracked) do
            if rec.cls == name and not rec.released and not rec.ignoredFlag then
                -- 原生句柄看 rec.handle，Lua 对象看 weak.o
                if rec.handle or rec.weak.o then n = n + 1 end
            end
        end
        return n
    end
    LD._elapsed = 0
    function LD.elapsed() return LD._elapsed end

    local function fmtClock(sec)
        sec = math.floor(sec or 0)
        local h = math.floor(sec / 3600)
        local m = math.floor((sec % 3600) / 60)
        local s = sec % 60
        return string.format("%02d:%02d:%02d", h, m, s)
    end

    LD._prevCounts = LD._prevCounts or {}

    function LD._refreshPanel()
        local P = LD._panel
        if P == nil or P.body == nil then return end
        local active = 0
        for _, r in ipairs(PANEL_ROWS) do
            if LD.isEnabled(r.cls) then active = active + 1 end
        end
        local lines = {}
        lines[#lines + 1] = string.format("● 资源监视 (%d/9 在用)", active)
        lines[#lines + 1] = "———————————"
        lines[#lines + 1] = "游戏时间 " .. fmtClock(LD._elapsed)
        lines[#lines + 1] = "———————————"
        for _, r in ipairs(PANEL_ROWS) do
            local n = LD.count(r.cls)
            local prev = LD._prevCounts[r.cls] or n
            local diff = n - prev
            LD._prevCounts[r.cls] = n
            local diffStr = ""
            if diff > 0 then
                diffStr = " |cFF00FF00(+" .. diff .. ")|r"
            elseif diff < 0 then
                diffStr = " |cFFFF0000(" .. diff .. ")|r"
            end
            lines[#lines + 1] = string.format("  %s：%d%s", r.name, n, diffStr)
        end
        lines[#lines + 1] = "———————————"
        lines[#lines + 1] = string.format("累计泄露 %d  疑似 %d  忽略 %d",
            LD.totalLeaks or 0, LD.staleCount or 0, LD.ignored or 0)
        local cleanupStatus = LD.AUTO_CLEANUP and "|cFF00FF00[自动排泄]|r" or "|cFFFF0000[排泄关闭]|r"
        lines[#lines + 1] = string.format("智能排泄: %s (延迟%ds)", cleanupStatus, LD.CLEANUP_DELAY)
        P.body:setText(table.concat(lines, "\n"))
        if P.title then
            P.title:setText("")
        end
    end

    function LD._initPanel()
        if not LD.PANEL then return end
        if type(Frame) ~= "table" or type(cdz) ~= "table" then return end
        pcall(Frame.loadToc, "UI\\CustomTooltip.toc")   -- 确保 CTooltipBg 模板可用

        local gameUI = Frame.getGameUI()
        if gameUI == nil then return false end

        LD._panel = {}
        local P = LD._panel
        local bg = Frame:newByTag("BACKDROP", "LeakPanel_BG", gameUI, "CTooltipBg", 0)
        -- 标题（已合并到正文，此控件保留作占位，避免残留默认文本）
        local title = Frame:newByTag("TEXT", "LeakPanel_Title", gameUI)
        if title._handle then
            title:setFont(LD.PANEL_FONT, LD.PANEL_FTITLE, 0)
            title:setTextColor(LD.PANEL_CTITLE)
            title:setText("")
            title:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, LD.PANEL_X + 10, LD.PANEL_Y - 10)
            title:show()
            P.title = title
        end

        -- 正文（多行）
        local body = Frame:newByTag("TEXT", "LeakPanel_Body", gameUI)
        if body._handle then
            body:setFont(LD.PANEL_FONT, LD.PANEL_FBODY, 0)
            body:setTextColor(LD.PANEL_CBODY)
            body:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, LD.PANEL_X + 10, LD.PANEL_Y - 28)
            body:show()
            P.body = body
        end

        -- 背景：提示框样式（黄边半透明黑），不可用时回退纯黑
        -- 使用相对定位：左上对齐标题的左上，右下对齐正文的右下
        
        if bg._handle == nil then
            bg = Frame:newByTag("BACKDROP", "LeakPanel_BG", gameUI)
            if bg._handle then bg:setTexture([[UI\black.tga]], 0) end
        end
        if bg._handle and P.title and P.body then
            bg:setPoint(FRAME_ALIGN_LEFT_TOP, P.title, FRAME_ALIGN_LEFT_TOP, -10, -25)
            bg:setPoint(FRAME_ALIGN_RIGHT_BOTTOM, P.body, FRAME_ALIGN_RIGHT_BOTTOM, 10, 10)
            bg:show()
            P.bg = bg
        end

        -- 每行标签右侧按钮：点击一次性打印该类型全部泄露/可疑信息（仅控制台）
        local btnX  = LD.PANEL_X + LD.PANEL_W - 56
        local btnW  = 50
        local btnH  = 14
        local rowH  = 14
        local btnY0 = LD.PANEL_Y - 52
        for i, r in ipairs(PANEL_ROWS) do
            local b = Frame:newByTag("BUTTON", "LeakBtn_" .. r.cls, gameUI)
            if b._handle then
                b:setSize(btnW, btnH)
                b:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, btnX, btnY0 - (i - 1) * rowH)
                pcall(function() b:setText("打印") end)
                pcall(function() b:setFont(LD.PANEL_FONT, 0.01, 0) end)
                b:onEvent(MOUSE_ORDER_CLICK, function() pcall(LD.dump, r.cls) end)
                b:show()
            end
        end
        -- 全部按钮
        local ball = Frame:newByTag("BUTTON", "LeakBtn_ALL", gameUI)
        if ball._handle then
            ball:setSize(btnW, btnH)
            ball:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, btnX, btnY0 - #PANEL_ROWS * rowH - 4)
            pcall(function() ball:setText("全部") end)
            pcall(function() ball:setFont(LD.PANEL_FONT, 0.01, 0) end)
            ball:onEvent(MOUSE_ORDER_CLICK, function() pcall(LD.dump, "ALL") end)
            ball:show()
        end
        -- 泄露按钮：查看累计泄露详情
        local bLeak = Frame:newByTag("BUTTON", "LeakBtn_Leaks", gameUI)
        if bLeak._handle then
            bLeak:setSize(btnW, btnH)
            bLeak:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, btnX, btnY0 - #PANEL_ROWS * rowH - 4 - btnH - 2)
            pcall(function() bLeak:setText("泄露") end)
            pcall(function() bLeak:setFont(LD.PANEL_FONT, 0.01, 0) end)
            bLeak:onEvent(MOUSE_ORDER_CLICK, function() pcall(LD.dumpLeaks) end)
            bLeak:show()
        end
        -- 排泄按钮：切换智能排泄开关
        local bClean = Frame:newByTag("BUTTON", "LeakBtn_Cleanup", gameUI)
        if bClean._handle then
            bClean:setSize(btnW, btnH)
            bClean:setAbsolutePoint(FRAME_ALIGN_LEFT_TOP, btnX, btnY0 - #PANEL_ROWS * rowH - 4 - btnH * 2 - 4)
            pcall(function() bClean:setText("排泄") end)
            pcall(function() bClean:setFont(LD.PANEL_FONT, 0.01, 0) end)
            bClean:onEvent(MOUSE_ORDER_CLICK, function()
                LD.AUTO_CLEANUP = not LD.AUTO_CLEANUP
                local status = LD.AUTO_CLEANUP and "开启" or "关闭"
                dbg("[LeakDetect] 智能排泄已" .. status)
                pcall(SystemMessage.send, { {"art", LD.ICON}, {"STR", "[LeakDetect] 智能排泄已" .. status} })
            end)
            bClean:show()
        end

        LD._refreshPanel()
        -- 每秒刷新（同时累加游戏时间；此为长生命周期计时器，豁免泄露检测）
        local t = Timer:new(1.0, true, function()
            LD._elapsed = LD._elapsed + 1
            local ok, e = pcall(LD._refreshPanel)
            if not ok then
                print("[LeakDetect] 面板刷新错误: " .. tostring(e) .. "\n" .. debug.traceback())
            end
        end)
        LD.ignore(t)
        return true
    end

    -- ---------------- 启动 ----------------
    -- 面板与扫描计时器应在游戏真正开始后（UI 就绪）启动；
    -- 整个启动过程包 pcall，任何失败只打印错误栈，绝不中断地图加载。
    function LD.start()
        if LD._started then return end
        local ok, err = pcall(function()
            LD._started = true
            LD.installHooks()
            LD._initPanel()

            -- 扫描计时器（自身为周期 Timer，忽略以免误报）
            local sweepTimer = Timer:new(LD.SWEEP_INTERVAL, true, function()
                local ok2, e2 = pcall(sweep)
                if not ok2 then
                    print("[LeakDetect] sweep 运行错误: " .. tostring(e2) .. "\n" .. debug.traceback())
                end
            end)
            LD.ignore(sweepTimer)

            -- 启动横幅（延迟 1s 等 UI 就绪；仅 print，不刷模拟信息）
            local banner = Timer:new(1.0, false, function()
                local extra = ""
                if enabledTypes.Item then extra = extra .. "，Item" end
                if enabledTypes.Unit then extra = extra .. "，Unit" end
                dbg("[LeakDetect] 泄露检测已启动：监控 Effect/Timer/Lightning/TextTag/Trigger" .. extra)
            end)
            LD.ignore(banner)
        end)
        if not ok then
            LD._started = false
            print("[LeakDetect] 启动失败: " .. tostring(err) .. "\n" .. debug.traceback())
        end
    end

    LD._init = true
end

LD = LeakDetect

-- require 阶段：仅安全地预装钩子（只包裹函数，不创建 Frame/Timer，
-- 可在地图初始化期早期捕获泄露，且绝不会因 UI 未就绪而报错）。
-- 面板与扫描计时器延迟到游戏开始：GameStart:startGame 会调用 LD.start()，
-- 这里再补一个首帧后的兜底定时器，确保即使启动入口不同也能正常启动（幂等）。
if LeakDetect.ENABLED then
    local ok, e = pcall(LD.installHooks)
    if not ok then
        print("[LeakDetect] 钩子预装失败: " .. tostring(e))
    end
    pcall(function()
        Timer:new(0.5, false, function() pcall(LeakDetect.start) end)
    end)
end
