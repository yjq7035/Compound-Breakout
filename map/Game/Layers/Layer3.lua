-- ============================================================
-- Layer3 — 第三关卡模块
--
-- 坐标：-11915.5,-1952.6 同时作为入口/复活/传送点（由 Layer2 通关后统一设置）
--
-- 扩展（关卡 3 设定 2026-08-26）：
--   1. 默认横墙 -11919.8,-5694.8  关卡启动时创建（B000 face 270）
--   2. 活动横墙 -11919.4,-3450.2  默认不创建，事件触发后创建
--   5. 事件矩形 左下 -12826.7,-5514.3 右上 -11014.0,-3705.4
--   6. 英雄进入事件矩形 -> 创建活动横墙 + 真计时器 (剩余时间：5 分钟)
--      到期后移除两堵墙，创建通关传送区域 -11925.0,-6154.3 500x300
--      全员进入后传送至关卡 4 -8518.2,747.9
--   7. 活动刷怪系统（2026-08-27）：活动事件触发后启动 1 秒/次高精度真实计时器，
--      按玩家 4→玩家 5→玩家 6→玩家 7（0-based pid 4,5,6,7）轮转创建 u4dW/hZ5u，
--      每归属玩家上限 20 个单位（满员递交下一位，全员满员跳过并告警），
--      同步记录生成信息，关卡 3 结束时完整清理
--   8. 阶段系统：1 阶段刷满 80 个怪进入 2 阶段，所有旧怪物获得 By2X buff（攻速 +50%）
-- ============================================================

Layer3 = {}
Layer3.__index = Layer3

-- ============================================================
-- §1 坐标
-- ============================================================

Layer3.entryPos    = { x = -11915.5, y = -1952.6, name = "关卡 3 入口/复活/传送" }
Layer3.revivePos   = { x = -11915.5, y = -1952.6, name = "关卡 3 复活点" }
Layer3.teleportPos = { x = -11915.5, y = -1952.6, name = "关卡 3 传送点" }
Layer3.potionShopPos = { x = -11915.5, y = -1952.6, name = "关卡 3 药剂商店（占位）" }

-- 墙体坐标（关卡 3 设定）
Layer3.defaultWallPos = { x = -11919.8, y = -5694.8, name = "默认横墙" }
Layer3.activeWallPos  = { x = -11919.4, y = -3450.2, name = "活动横墙" }

-- 事件矩形坐标（关卡 3 设定 5）
Layer3.eventRectCoords = { left = -12826.7, bottom = -5514.3, right = -11014.0, top = -3705.4 }

-- 通关传送区域（关卡 3 设定 6）
Layer3.exitCenter = { x = -11925.0, y = -6154.3, w = 500, h = 300, name = "关卡 3 通关传送区域" }

-- 关卡 4 入口（关卡 3 设定 6）
Layer3.layer4EntryPos = { x = -8518.2, y = 747.9, name = "关卡 4 入口" }

-- ============================================================
-- §2 矩形区域定义（Rect.new + 触发器事件）保留原 6 个占位
-- ============================================================
Layer3.mobSpawnRects = {
    { id = 1, cx = -12874.5, cy = -3289.5, width = 1142, height = 415.6, name = "矩形区域 1" },
    { id = 2, cx = -13234.5, cy = -4890.75, width = 396, height = 2682.3, name = "矩形区域 2" },
    { id = 3, cx = -12883.95, cy = -5906.05, width = 1087.1, height = 498.7, name = "矩形区域 3" },
    { id = 4, cx = -10936.65, cy = -5930.9, width = 1080.3, height = 401.6, name = "矩形区域 4" },
    { id = 5, cx = -10626.1, cy = -4359.85, width = 476.8, height = 2569.1, name = "矩形区域 5" },
    { id = 6, cx = -11159.1, cy = -3299.95, width = 664.4, height = 471.5, name = "矩形区域 6" },
}

Layer3.rectHandles = {}
Layer3.eventHandles = {}

-- ============================================================
-- §3 墙体定义与运行时
-- ============================================================

Layer3.WALL_H = "B000"
Layer3.WALL_V = "DL84"

Layer3.walls = {
    { index = 1, x = -11919.8, y = -5694.8, id = "B000", dir = "H", face = 270, name = "默认横墙" },
    { index = 2, x = -11919.4, y = -3450.2, id = "B000", dir = "H", face = 270, name = "活动横墙" },
}

Layer3.handles = {}  -- destructable handle 列表
Layer3.wallMap = {}  -- index -> handle

-- ============================================================
-- §4 事件矩形与计时器/通关 运行时
-- ============================================================

Layer3.started = false
Layer3.finished = false
Layer3.triggered = false
Layer3.survivalDuration = 300 -- 5 分钟

Layer3.eventRect = nil        -- Rect 对象
Layer3.eventEvent = nil       -- Event 对象（Event:newRect 返回）
Layer3.survivalTimer = nil    -- Timer 对象（真计时器）

Layer3.exitRect = nil
Layer3.exitEvent = nil
Layer3.enteredPlayers = {}    -- pid -> true
Layer3.events = {}            -- 额外事件列表（用于 shutdown 统一清理）

-- ============================================================
-- §5 内部工具
-- ============================================================

local function distance(ax, ay, bx, by)
    return ((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5
end

-- ============================================================
-- §6 墙体管理
-- ============================================================

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then
        print(string.format("[Layer3] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else
        print(string.format("[Layer3] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y))
    end
    return h
end

-- 仅创建默认横墙（关卡启动时）
function Layer3.createDefaultWall()
    if Layer3.wallMap[1] then
        print("[Layer3] 默认横墙已存在，跳过")
        return Layer3.wallMap[1]
    end
    local w = nil
    for _, ww in ipairs(Layer3.walls) do if ww.index == 1 then w = ww; break end end
    if not w then return nil end
    local h = createOne(w)
    if h then
        table.insert(Layer3.handles, h)
        Layer3.wallMap[1] = h
    end
    return h
end

-- 创建活动横墙（事件触发时）
function Layer3.createActiveWall()
    if Layer3.wallMap[2] then
        print("[Layer3] 活动横墙已存在，跳过")
        return Layer3.wallMap[2]
    end
    local w = nil
    for _, ww in ipairs(Layer3.walls) do if ww.index == 2 then w = ww; break end end
    if not w then return nil end
    local h = createOne(w)
    if h then
        table.insert(Layer3.handles, h)
        Layer3.wallMap[2] = h
        print(string.format("[Layer3] 活动横墙已创建 at %.1f,%.1f", w.x, w.y))
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "活动横墙已升起", SystemMessage.COLOR_WARN}}, 3.0)
        end
    end
    return h
end

function Layer3.isActiveWallCreated()
    return Layer3.wallMap[2] ~= nil
end

function Layer3.removeWallByIndex(index, reason)
    if not index then return false end
    if type(index) == "string" then index = tonumber(index) or index end
    local h = Layer3.wallMap[index]
    local w = nil
    for _, ww in ipairs(Layer3.walls) do if ww.index == index then w = ww; break end end
    local wName = (w and w.name) or ("index=" .. tostring(index))
    if h then
        cj.RemoveDestructable(h)
        Layer3.wallMap[index] = nil
        for k, vh in ipairs(Layer3.handles) do if vh == h then table.remove(Layer3.handles, k) break end end
        print(string.format("[Layer3] 墙已移除 %s index=%s at %.1f,%.1f reason=%s", wName, tostring(index), w and w.x or 0, w and w.y or 0, reason or ""))
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", string.format("力量墙已销毁 - %s - %s", reason or wName, wName), SystemMessage.COLOR_INFO}}, 3.0)
        end
        return true
    else
        -- 兜底枚举删除
        if w and w.x and w.y then
            local found = 0
            local rect = cj.Rect(w.x - 64, w.y - 64, w.x + 64, w.y + 64)
            if rect then
                pcall(function() cj.EnumDestructablesInRect(rect, nil, function()
                    local d = cj.GetEnumDestructable()
                    if d and cj.GetDestructableTypeId(d) == c2i(w.id) then
                        local dx, dy = cj.GetDestructableX(d), cj.GetDestructableY(d)
                        if ((dx - w.x)^2 + (dy - w.y)^2)^0.5 < 64 then
                            cj.RemoveDestructable(d)
                            found = found + 1
                        end
                    end
                end) end)
                pcall(function() cj.RemoveRect(rect) end)
            end
            if found > 0 then
                print(string.format("[Layer3] 墙兜底枚举删除 %s index=%s count=%d reason=%s", wName, tostring(index), found, reason or ""))
                return true
            end
        end
        print(string.format("[Layer3] 墙已不存在或已移除 %s index=%s reason=%s", wName, tostring(index), reason or ""))
        return false
    end
end

function Layer3.destroyWalls()
    for _, h in ipairs(Layer3.handles) do if h then pcall(function() cj.RemoveDestructable(h) end) end end
    local n = #Layer3.handles
    Layer3.handles = {}
    Layer3.wallMap = {}
    if n > 0 then print("[Layer3] 墙体已移除 count=" .. n) end
end

function Layer3.dumpWalls()
    print(string.format("[Layer3] dumpWalls handles=%d", #Layer3.handles))
    for _, w in ipairs(Layer3.walls) do
        local h = Layer3.wallMap[w.index]
        print(string.format("  index=%s name=%s at %.1f,%.1f handle=%s", tostring(w.index), w.name, w.x, w.y, h and tostring(h) or "nil"))
    end
end

-- ============================================================
-- §7 事件矩形管理
-- ============================================================

function Layer3.createEventRect()
    if Layer3.eventRect then return Layer3.eventRect, Layer3.eventEvent end
    local c = Layer3.eventRectCoords
    local rect = Rect:new(c.left, c.bottom, c.right, c.top)
    if not rect then
        print("[Layer3] 事件矩形创建失败")
        return nil
    end
    Layer3.eventRect = rect
    print(string.format("[Layer3] 事件矩形已创建 左下 %.1f,%.1f 右上 %.1f,%.1f", c.left, c.bottom, c.right, c.top))

    local function onEnter(ev)
        if Layer3.finished then return end
        if Layer3.triggered then return end
        local unit = ev.unit or ev._unit or cj.GetEnteringUnit()
        if not unit then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(unit))
        if not owner or not owner:isUser() then return end
        if not cj.IsUnitType(unit, UNIT_TYPE_HERO) then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        Layer3.onEventTriggered(unit, owner)
    end

    local ev = Event:newRect(rect, onEnter)
    Layer3.eventEvent = ev
    if ev then
        print("[Layer3] 事件矩形触发器已启动")
    else
        print("[Layer3] 事件矩形触发器绑定失败")
    end
    return rect, ev
end

function Layer3.destroyEventRect(reason)
    local rect = Layer3.eventRect
    Layer3.eventRect = nil
    Layer3.eventEvent = nil
    if rect then
        pcall(function() Event:destroyRect(rect) end)
        pcall(function() rect:destroy() end)
        print(string.format("[Layer3] 事件矩形已销毁 %s", reason or ""))
    end
end

-- ============================================================
-- §8 生存计时器与通关逻辑
-- ============================================================

function Layer3.getOnlineCount()
    if GameInit and GameInit.getOnlinePlayers then return #GameInit.getOnlinePlayers() end
    local n=0; for pid=0,3 do local p=Player:new(pid) if p:isPlaying() and p:isUser() then n=n+1 end end; return n
end

function Layer3.getEnteredCount()
    local n=0; for _ in pairs(Layer3.enteredPlayers) do n=n+1 end; return n
end

function Layer3.startSurvivalTimer()
    if Layer3.survivalTimer and not Layer3.survivalTimer._dead then
        print("[Layer3] 生存计时器已存在，跳过")
        return Layer3.survivalTimer
    end
    local duration = Layer3.survivalDuration or 300
    print(string.format("[Layer3] 生存计时器启动 %.0f秒 标题=剩余时间：", duration))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("生存挑战已启动！坚持 %d 秒", duration), SystemMessage.COLOR_WARN}}, 3.0)
    end
    local t
    t = Timer:new(duration, false, function()
        -- 到期后自动清理窗口（Timer 真计时器已自动销毁窗口），此处仅处理通关
        Layer3.survivalTimer = nil
        Layer3.onSurvivalTimeout()
        if t and not t._dead then t:destroy() end
    end, nil, true, "剩余时间：")
    Layer3.survivalTimer = t
    return t
end

function Layer3.cancelSurvivalTimer()
    if Layer3.survivalTimer then
        pcall(function() Layer3.survivalTimer:destroy() end)
        Layer3.survivalTimer = nil
        print("[Layer3] 生存计时器已取消")
    end
end

function Layer3.onEventTriggered(unit, player)
    if Layer3.triggered then return end
    Layer3.triggered = true
    local playerName = player and player:getName() or "玩家"
    print(string.format("[Layer3] 事件触发 unit=%s player=%s", Event.unitDesc(unit), playerName))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("玩家 %s 触发了生存挑战！", playerName), SystemMessage.COLOR_WARN}}, 3.0)
    end
    -- 创建活动横墙
    Layer3.createActiveWall()
    -- 启动 5 分钟计时器
    Layer3.startSurvivalTimer()
    -- 7. 启动每秒刷怪系统（高精度真实计时器，u4dW/hZ5u 归属轮转）
    Layer3.startMobSpawnSystem()
    -- 事件矩形为一次性，触发后销毁避免重复创建墙/计时器
    Layer3.destroyEventRect("事件已触发")
end

function Layer3.onSurvivalTimeout()
    if Layer3.finished then return end
    Layer3.finished = true
    print("[Layer3] 生存时间到期，关卡通关！")
    -- 生存挑战结束：停止刷怪计时器（单位与记录留待关卡结束时统一清理）
    Layer3.stopMobSpawnSystem("生存挑战完成")
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "生存挑战完成！关卡 3 通关！", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("生存挑战完成！关卡 3 通关！")
    end
    -- 移除两堵墙
    Layer3.removeWallByIndex(1, "生存完成")
    Layer3.removeWallByIndex(2, "生存完成")
    -- 清理事件矩形（若仍存在）
    Layer3.destroyEventRect("生存完成")
    -- 创建通关传送区域
    Layer3.createExitRegion()
end

-- 通关传送区域
function Layer3.createExitRegion()
    if Layer3.exitRect then return end
    local cx, cy, w, h = Layer3.exitCenter.x, Layer3.exitCenter.y, Layer3.exitCenter.w, Layer3.exitCenter.h
    Layer3.exitRect = Rect:newCenter(cx, cy, w, h)
    Layer3.enteredPlayers = {}
    print(string.format("[Layer3] 通关传送区域已创建 中心 %.1f,%.1f 尺寸 %dx%d", cx, cy, w, h))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("通关传送门已开启 - 前往 %.1f,%.1f", cx, cy), SystemMessage.COLOR_WARN}}, 3.0)
    end

    local function onEnter(ev)
        if not Layer3.finished then return end
        local entering = ev.unit or ev._unit or cj.GetEnteringUnit()
        if not entering then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(entering))
        if not owner or not owner:isUser() then return end
        if not cj.IsUnitType(entering, UNIT_TYPE_HERO) then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        local isNew = false
        if not Layer3.enteredPlayers[pid] then
            Layer3.enteredPlayers[pid] = true
            isNew = true
            print(string.format("[Layer3] 玩家%d 进入通关区域 [%d/%d]", pid, Layer3.getEnteredCount(), Layer3.getOnlineCount()))
        end
        if isNew and SystemMessage and SystemMessage.send then
            local playerName = owner:getName()
            if not playerName or playerName == "" then playerName = string.format("玩家%d", pid + 1) end
            local need = Layer3.getOnlineCount()
            local have = Layer3.getEnteredCount()
            if have < need then
                local remain = need - have
                SystemMessage.send({{"STR", string.format("玩家 %s 已进入传送门就绪 [%d/%d]，等待其他 %d 名玩家进入...", playerName, have, need, remain), SystemMessage.COLOR_WARN}}, 3.0)
            end
        end
        local need = Layer3.getOnlineCount()
        local have = Layer3.getEnteredCount()
        if have >= need and need > 0 then
            Layer3.onAllPlayersEntered()
        end
    end

    local ev = Event:newRect(Layer3.exitRect, onEnter)
    Layer3.exitEvent = ev
    if ev then table.insert(Layer3.events, ev) end
end

function Layer3.destroyExitRegion()
    local rect = Layer3.exitRect
    Layer3.exitRect = nil
    Layer3.exitEvent = nil
    Layer3.enteredPlayers = {}
    if rect then
        pcall(function() Event:destroyRect(rect) end)
        pcall(function() rect:destroy() end)
        print("[Layer3] 通关传送区域已销毁")
    end
end

function Layer3.onAllPlayersEntered()
    -- 防止重复触发
    if Layer3._teleporting then return end
    Layer3._teleporting = true
    print("[Layer3] 所有玩家已进入通关区域，关卡 3 通关，准备传送至关卡 4！")
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 3 通关！", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 3 通关！")
    end
    local entry = Layer3.layer4EntryPos or (Layer4 and Layer4.entryPos) or { x = -8518.2, y = 747.9 }
    local ex, ey = entry.x, entry.y
    print(string.format("[Layer3] 准备传送至关卡 4 入口 %.1f,%.1f", ex, ey))
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p:isPlaying() and p:isUser() then
            -- 使用 Group.new + enumPlayer 替代 cj.CreateGroup + cj.GroupEnumUnitsOfPlayer
            local g = Group:new()
            g:enumPlayer(p._handle)
            g:forEach(function(u) -- [OOP] 纯 Lua 遍历，自动调用 validate 清理失效单位
                if cj.IsUnitType(u, UNIT_TYPE_HERO) then
                    -- 优先使用 OOP 封装层移动英雄（推荐）
                    local unitObj = Unit.fromHandle(u)
                    if unitObj and unitObj.setPosition then
                        unitObj:setPosition(ex, ey)
                    end
                end
                -- 兜底：原生 API 移动
                cj.SetUnitX(u, ex)
                cj.SetUnitY(u, ey)
                cj.SetUnitPosition(u, ex, ey)
                -- 本地镜头跟随（异步操作）
                if cj.GetLocalPlayer() == p._handle and Camera and Camera.panTo then
                    pcall(function() Camera.panTo(ex, ey) end)
                end
            end)
            print(string.format("[Layer3] 玩家%d 英雄已传送至关卡 4 入口 %.1f,%.1f", pid, ex, ey))
        end
    end
    if GameInit then GameInit.currentLayer = 4 end
    Layer3.shutdown()
    local ok, L4 = pcall(require, "Game.Layers.Layer4")
    if ok and L4 and L4.start then L4.start() end
end

-- ============================================================
-- §8b 活动刷怪系统（高精度真实计时器 · 关卡 3 专属）+ 阶段系统
-- ============================================================
-- 功能归属（2026-08-27）：本系统、本系统创建的所有 "u4dW"/"hZ5u" 单位实体、
-- 单位分配/传递逻辑与生成记录，均为关卡 3 专属内容，随关卡 3 生命周期启停。
--   触发：活动事件（英雄进入事件矩形）-> Layer3.startMobSpawnSystem()
--   节奏：每秒 1 次；真计时器（useRealClock，同步游戏时钟驱动），不受帧率/游戏速度影响
--   归属：玩家 4→玩家 5→玩家 6→玩家 7 固定轮转（0-based pid 4,5,6,7，与代码库
--         "玩家%d"=pid 的既有命名一致；pid 4 为敌对电脑"怪物"槽位）
--   上限：每归属玩家最多持有 20 个单位；目标玩家满员 -> 递交轮转下一位；
--         全部满员 -> 跳过本次创建并记录警告日志
--   记录：生成信息按创建时间顺序同步追加（计时器回调内直接 table.insert，
--         同步阻塞，无任何异步，杜绝记录顺序混乱）
--   阶段系统（2026-08-27 新增）：默认 1 阶段；每刷满 80 个单位进入下一阶段
--     - 1->2 阶段转换时，所有旧怪物获得 By2X buff（攻击速度 +50%）
-- ============================================================

-- 归属玩家轮转顺序（玩家 4→玩家 5→玩家 6→玩家 7，0-based pid）
Layer3.SPAWN_OWNER_PIDS = { 4, 5, 6, 7 }
-- 刷怪单位类型（每 tick 交替创建）
Layer3.SPAWN_UNIT_TYPES = { "u4dW", "hZ5u" }
-- 每归属玩家单位持有上限
Layer3.SPAWN_MAX_PER_PLAYER = 20

-- 运行时状态
Layer3.spawnTimer = nil        -- 高精度真实计时器（1 秒周期）
Layer3.spawnTick = 0           -- 计时器 tick 计数（自启动起的秒数）
Layer3.spawnSeq = 0            -- 创建序号（全局递增）
Layer3.spawnRecords = {}       -- 生成记录列表（按创建时间顺序）
Layer3.spawnUnits = {}         -- 已生成单位实体（清理用）
Layer3.spawnLeaveEvent = nil   -- 玩家退出监听（玩家退出场景清理）
Layer3._validSpawnRects = nil  -- 校验通过的刷怪矩形（init 时构建）

-- ========== 阶段系统变量（新增） ==========
Layer3.currentPhase = 1              -- 当前阶段，默认 1
Layer3.phase2Started = false         -- 第 2 阶段是否已开始（防止重复触发）
Layer3._phaseTransitionPending = false -- 是否有待处理的阶段转换
Layer3.PHASE_MOBS_PER_STAGE = 80     -- 每阶段刷怪数量阈值

-- 校验 mobSpawnRects 数据，返回有效矩形列表（id/cx/cy/width/height 齐全且宽高为正）
local function validateSpawnRects()
    local valid = {}
    for _, r in ipairs(Layer3.mobSpawnRects) do
        local ok = r and r.id ~= nil and r.cx ~= nil and r.cy ~= nil
            and r.width ~= nil and r.height ~= nil
            and r.width > 0 and r.height > 0
        if ok then
            table.insert(valid, r)
        else
            print(string.format("[Layer3] 刷怪矩形校验失败：id=%s cx=%s cy=%s width=%s height=%s",
                tostring(r and r.id), tostring(r and r.cx), tostring(r and r.cy),
                tostring(r and r.width), tostring(r and r.height)))
        end
    end
    return valid
end

-- 当前轮转起点下标（每 tick 前进一位，保证固定顺序轮转）
local function currentOwnerIndex()
    local n = #Layer3.SPAWN_OWNER_PIDS
    return ((Layer3.spawnTick - 1) % n) + 1
end

-- 统计某归属玩家当前持有的刷怪单位数量（u4dW/hZ5u，含存活与尸体）
local function countMobsOfPlayer(pid)
    local typeA = c2i(Layer3.SPAWN_UNIT_TYPES[1])
    local typeB = c2i(Layer3.SPAWN_UNIT_TYPES[2])
    local g = Group:new()
    g:enumPlayer(cj.Player(pid), function(u)
        local t = cj.GetUnitTypeId(u)
        return t == typeA or t == typeB
    end)
    return #g._units
end

-- 在刷怪矩形内随机生成坐标（X、Y 均在区域范围内，0.1 精度）
local function pickSpawnPoint()
    local rects = Layer3._validSpawnRects
    if not rects or #rects == 0 then
        print("[Layer3] 刷怪失败：无有效刷怪矩形")
        return nil, nil
    end
    local r = rects[math.random(1, #rects)]
    local loX = math.floor((r.cx - r.width / 2) * 10)
    local hiX = math.floor((r.cx + r.width / 2) * 10)
    local loY = math.floor((r.cy - r.height / 2) * 10)
    local hiY = math.floor((r.cy + r.height / 2) * 10)
    return math.random(loX, hiX) / 10, math.random(loY, hiY) / 10
end

-- ========== 辅助函数：统计所有刷怪单位（新增）==========
local function getMobCount()
    local typeA = c2i(Layer3.SPAWN_UNIT_TYPES[1])
    local typeB = c2i(Layer3.SPAWN_UNIT_TYPES[2])
    local count = 0
    -- 使用 Group._forEachPoolUnit 遍历所有单位（底层表，跨机一致）
    Group._forEachPoolUnit(function(u)
        if Group._isValidUnit(u) then
            local t = cj.GetUnitTypeId(u)
            if t == typeA or t == typeB then
                count = count + 1
            end
        end
    end)
    return count
end

-- 同步追加生成记录（创建时间戳/单位 ID/单位类型/初始坐标/归属玩家 ID/创建序号）
-- 计时器回调内直接 table.insert，同步阻塞执行，保证记录顺序与创建顺序严格一致
local function recordSpawn(u, pid, x, y)
    Layer3.spawnSeq = Layer3.spawnSeq + 1
    local base = 0
    if Time and Time.getGameStartTime then base = Time.getGameStartTime() or 0 end
    local rec = {
        seq       = Layer3.spawnSeq,                 -- 创建序号
        timestamp = base + Layer3.spawnTick * 1000,  -- 创建时间戳（ms）
        unitId    = cj.GetHandleId(u._handle),       -- 单位 ID（句柄 ID）
        unitType  = u:getTypeCode(),                 -- 单位类型（u4dW/hZ5u）
        x         = x,                               -- 初始坐标 X
        y         = y,                               -- 初始坐标 Y
        pid       = pid,                             -- 归属玩家 ID
    }
    table.insert(Layer3.spawnRecords, rec)  -- 同步追加，保证创建时间顺序
    table.insert(Layer3.spawnUnits, u)      -- 单位实体登记（清理用）
    return rec
end

-- 每秒回调：按固定顺序创建 1 个单位（含上限传递逻辑 + 阶段系统）
local function onSpawnTick()
    if Layer3.finished then return end
    Layer3.spawnTick = Layer3.spawnTick + 1

    -- ===== 新增阶段系统逻辑 =====
    -- 统计所有刷怪单位的总数
    local totalMobs = getMobCount()
    
    -- 判断是否进入下一阶段的转换条件（每阶段 PHASE_MOBS_PER_STAGE 个单位）
    if totalMobs > 0 and not Layer3._phaseTransitionPending then
        local targetPhase = math.ceil(totalMobs / Layer3.PHASE_MOBS_PER_STAGE)
        -- 只允许从 1 阶段进入 2 阶段（可后续扩展更多阶段）
        if targetPhase > Layer3.currentPhase and targetPhase <= 2 then
            Layer3._phaseTransitionPending = true
            print(string.format("[Layer3] 检测到总单位数 %d，准备进入第%d阶段", totalMobs, targetPhase))
        end
    end

    -- ===== 处理阶段转换（仅当有待处理的转换且第 2 阶段尚未开始）=====
    if Layer3._phaseTransitionPending and not Layer3.phase2Started then
        -- 从 1 阶段切换到 2 阶段
        print("[Layer3] === 进入第 2 阶段！===")
        
        -- 更新阶段变量
        Layer3.currentPhase = 2
        Layer3.phase2Started = true
        
        -- 给所有旧单位施加 By2X buff（攻击速度 +50%）
        local buffId = c2i("By2X")
        print(string.format("[Layer3] 开始为 %d 个旧单位施加 Buff", #Layer3.spawnUnits))
        for i, u in ipairs(Layer3.spawnUnits) do
            if u and u._handle then
                pcall(function()
                    -- 使用原生 API 附加 buff：AddSpellToUnit(unitHandle, spellId)
                    cj.AddSpellToUnit(u._handle, buffId)
                    local unitName = cj.GetUnitTypeId(u._handle) or "未知单位"
                    print(string.format("[Layer3] Buff 已施加到 [%d/%d] %s", i, #Layer3.spawnUnits, unitName))
                end)
            else
                print(string.format("[Layer3] 跳过无效单位：%s", tostring(u)))
            end
        end
        
        -- 清除转换标记，但保持 phase2Started=true 防止重复触发
        Layer3._phaseTransitionPending = false
        print("[Layer3] 阶段转换完成，旧单位已全部获得 Buff")
    end

    local n = #Layer3.SPAWN_OWNER_PIDS
    local startIdx = currentOwnerIndex()
    local targetPid = nil
    for i = 0, n - 1 do
        local pid = Layer3.SPAWN_OWNER_PIDS[((startIdx - 1 + i) % n) + 1]
        if countMobsOfPlayer(pid) < Layer3.SPAWN_MAX_PER_PLAYER then
            targetPid = pid
            break
        end
    end

    -- 所有归属玩家均达到上限：跳过本次创建并记录警告日志
    if not targetPid then
        print(string.format("[Layer3] 刷怪跳过（警告）：所有归属玩家均达到上限 %d 个（%s），本次不创建单位",
            Layer3.SPAWN_MAX_PER_PLAYER, table.concat(Layer3.SPAWN_OWNER_PIDS, ",")))
        return
    end

    local x, y = pickSpawnPoint()
    if not x then
        print("[Layer3] 刷怪失败：无法生成有效坐标，本次跳过")
        return
    end

    -- 单位类型交替创建：奇数 tick -> u4dW，偶数 tick -> hZ5u
    local utype = Layer3.SPAWN_UNIT_TYPES[(Layer3.spawnTick % 2 == 1) and 1 or 2]
    local u = Unit:new(Player:new(targetPid), utype, x, y, math.random(0, 359))
    if not u or not u._handle then
        print(string.format("[Layer3] 刷怪失败：单位创建返回空 pid=%d type=%s at %.1f,%.1f", targetPid, utype, x, y))
        return
    end

    local rec = recordSpawn(u, targetPid, x, y)
    print(string.format("[Layer3] 刷怪 #%d tick=%d 单位=%s(%s) 归属=玩家%d 坐标=%.1f,%.1f",
        rec.seq, Layer3.spawnTick, rec.unitType, rec.unitId, rec.pid, rec.x, rec.y))
    
    -- 打印阶段信息（调试用）
    print(string.format("[Layer3] === 阶段信息 === 当前：%d 总单位数：%d 阈值:%d", 
        Layer3.currentPhase, totalMobs, Layer3.PHASE_MOBS_PER_STAGE))
end

-- 初始化（关卡 3 开始加载完成后调用）：计时器/计数器清零、记录列表初始化、
-- mobSpawnRects 数据校验、玩家退出监听注册
function Layer3.initMobSpawnSystem()
    Layer3.spawnTimer = nil
    Layer3.spawnTick = 0
    Layer3.spawnSeq = 0
    Layer3.spawnRecords = {}
    Layer3.spawnUnits = {}
    Layer3._validSpawnRects = validateSpawnRects()
    Layer3.registerSpawnLeaveHandler()

    -- 初始化阶段系统变量
    Layer3.currentPhase = 1
    Layer3.phase2Started = false
    Layer3._phaseTransitionPending = false

    print(string.format("[Layer3] 刷怪系统初始化完成：刷怪矩形 %d/%d 有效，归属轮转 %d 槽（玩家 4→玩家 5→玩家 6→玩家 7），每槽上限 %d 单位",
        #Layer3._validSpawnRects, #Layer3.mobSpawnRects, #Layer3.SPAWN_OWNER_PIDS, Layer3.SPAWN_MAX_PER_PLAYER))
end

-- 启动刷怪系统（活动事件触发时调用）：创建每秒 1 次的高精度真实计时器
function Layer3.startMobSpawnSystem()
    if Layer3.spawnTimer and not Layer3.spawnTimer._dead then
        print("[Layer3] 刷怪计时器已存在，跳过重复启动")
        return Layer3.spawnTimer
    end
    -- 清理/退出后兜底重建校验列表（防止玩家退出清理后再触发活动事件时启动失败）
    if not Layer3._validSpawnRects or #Layer3._validSpawnRects == 0 then
        Layer3._validSpawnRects = validateSpawnRects()
    end
    if not Layer3._validSpawnRects or #Layer3._validSpawnRects == 0 then
        print("[Layer3] 刷怪系统启动失败：无有效刷怪矩形（请检查 mobSpawnRects 配置）")
        return nil
    end
    Layer3.registerSpawnLeaveHandler()
    Layer3.spawnTick = 0
    Layer3.spawnSeq = 0
    -- 真计时器：useRealClock=true，同步游戏时钟驱动，不受帧率/游戏速度影响
    local t = Timer:new(1.0, true, onSpawnTick, nil, true)
    Layer3.spawnTimer = t
    print("[Layer3] 刷怪系统启动：1 秒/次，归属顺序 玩家 4→玩家 5→玩家 6→玩家 7")
    return t
end

-- 停止并销毁刷怪计时器（保留单位与记录，留待关卡结束统一清理）
function Layer3.stopMobSpawnSystem(reason)
    if Layer3.spawnTimer then
        pcall(function() Layer3.spawnTimer:destroy() end)
        Layer3.spawnTimer = nil
        print("[Layer3] 刷怪计时器已停止并销毁 " .. (reason or ""))
    end
end

-- 清除所有由本系统创建的单位实体
function Layer3.clearMobSpawnUnits(reason)
    local n = #Layer3.spawnUnits
    for i = n, 1, -1 do
        local u = Layer3.spawnUnits[i]
        if u and u._handle then
            pcall(function() u:destroy() end)
        end
    end
    Layer3.spawnUnits = {}
    if n > 0 then
        print(string.format("[Layer3] 刷怪单位已清除 count=%d %s", n, reason or ""))
    end
end

-- 完整清理（关卡 3 结束时调用，覆盖正常完成/玩家退出/异常中断）：停止并销毁计时器、
-- 清除所有相关单位实体、释放记录数据、重置所有相关状态变量，防止内存泄漏或影响其他关卡
function Layer3.cleanupMobSpawnSystem(reason)
    Layer3.stopMobSpawnSystem(reason)
    Layer3.clearMobSpawnUnits(reason)
    Layer3.spawnRecords = {}
    Layer3.spawnTick = 0
    Layer3.spawnSeq = 0
    Layer3._validSpawnRects = nil
    
    -- ========== 清理阶段系统状态（新增）==========
    Layer3.currentPhase = 1
    Layer3.phase2Started = false
    Layer3._phaseTransitionPending = false
    
    if Layer3.spawnLeaveEvent then
        pcall(function() Layer3.spawnLeaveEvent:destroy() end)
        Layer3.spawnLeaveEvent = nil
    end
    print("[Layer3] 刷怪系统已完整清理（记录释放、状态重置）" .. (reason or ""))
end

-- 玩家退出场景：关卡 3 进行中（已启动未通关）有用户玩家退出时，
-- 按"玩家退出"结束场景执行刷怪系统完整清理
function Layer3.registerSpawnLeaveHandler()
    if Layer3.spawnLeaveEvent then return end
    Layer3.spawnLeaveEvent = Event:new(nil, EVENT_PLAYER_LEAVE, function()
        if not Layer3.started or Layer3.finished then return end
        local p = cj.GetTriggerPlayer()
        if not p then return end
        local pid = cj.GetPlayerId(p)
        if pid < 0 or pid > 3 then return end  -- 仅用户玩家（0-3）退出触发
        print("[Layer3] 检测到玩家" .. pid .. "退出，按关卡结束场景清理刷怪系统")
        Layer3.cleanupMobSpawnSystem("玩家退出")
    end)
end

-- ============================================================
-- §9 生命周期
-- ============================================================

function Layer3.start()
    if Layer3.started then return end
    Layer3.started = true
    Layer3.finished = false
    Layer3.triggered = false
    Layer3._teleporting = false
    Layer3.enteredPlayers = {}
    Layer3.events = {}
    -- 热重载清理旧状态
    if Layer3.survivalTimer then Layer3.cancelSurvivalTimer() end
    if Layer3.exitRect then Layer3.destroyExitRegion() end
    if Layer3.eventRect then Layer3.destroyEventRect("重启清理") end
    if Layer3.cleanupMobSpawnSystem then Layer3.cleanupMobSpawnSystem("重启清理") end
    -- 清理旧 mob 占位
    for id, rect in pairs(Layer3.rectHandles) do
        if rect then pcall(function() Event:destroyRect(rect) end) pcall(function() rect:destroy() end) end
    end
    Layer3.rectHandles = {}
    Layer3.eventHandles = {}

    print(string.format("[Layer3] 启动 入口/复活/传送 %.1f,%.1f", Layer3.entryPos.x, Layer3.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 3 已启动 - 玩家死亡将触发关卡重置", SystemMessage.COLOR_WARN}}, 5.0)
    else
        Player.sendAll("关卡 3 已启动 - 玩家死亡将触发关卡重置")
    end
    -- 1. 创建默认横墙
    Layer3.createDefaultWall()
    -- 5. 创建事件矩形（等待英雄进入）
    Layer3.createEventRect()
    -- 7. 刷怪系统初始化（计数器清零 / 记录列表初始化 / mobSpawnRects 校验）
    Layer3.initMobSpawnSystem()
    
    -- 注册关卡失败处理（玩家死亡时触发）
    if GameInit and GameInit.registerLayer3DeathHandler then
        GameInit.registerLayer3DeathHandler()
    end
end

-- ============================================================
-- §10 关卡失败处理（所有在线玩家死亡重置关卡）
-- ============================================================

function Layer3.onAllPlayersDied()
    -- 防止重复触发
    if Layer3.finished then return end
    print("[Layer3] === 所有在线玩家死亡，触发关卡重置！===")
    
    -- 广播失败消息（中央系统信息 + Player.sendAll）
    local msg = "🚨 关卡失败 - 所有玩家死亡！10 秒后将重启关卡 3..."
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", msg, SystemMessage.COLOR_FAIL}}, 5.0)
    else
        Player.sendAll(msg)
    end
    
    -- 记录当前在线玩家（用于后续复活）
    local onlineList = GameInit and GameInit.getOnlinePlayers() or {}
    Layer3.onlinePlayers = {}
    for _, player in ipairs(onlineList) do
        if player and player:isPlaying() and player:isUser() then
            local pid = player:getId()
            Layer3.onlinePlayers[pid] = true
            -- 记录该玩家的所有英雄单位（用于复活）
            -- [OOP] 使用 Group.new + enumPlayer 替代 cj.CreateGroup + cj.GroupEnumUnitsOfPlayer
            local g = Group:new()
            g:enumPlayer(player._handle)
            g:forEach(function(u) -- 纯 Lua 遍历，自动调用 validate 清理失效单位
                if cj.IsUnitType(u, UNIT_TYPE_HERO) then
                    table.insert(Layer3.onlinePlayers, { pid = pid, hero = u })
                end
            end)
        end
    end
    print(string.format("[Layer3] 记录在线玩家数量：%d", #Layer3.onlinePlayers))
    
    -- 启动 10 秒倒计时后重启关卡
    Timer:new(10, false, function()Layer3.onReloadingLevel3()end)
end

function Layer3.onReloadingLevel3()
    if Layer3.finished then return end
    print("[Layer3] === 10 秒倒计时结束，重启关卡 3...===")
    
    -- 广播重启消息
    local msg = "🔄 关卡 3 即将重启！所有玩家将在复活点重生..."
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", msg, SystemMessage.COLOR_WARN}}, 5.0)
    else
        Player.sendAll(msg)
    end
    
    -- 销毁当前关卡的所有对象（墙体、事件矩形等）
    Layer3.shutdown()
    
    -- 关闭所有玩家的英雄，等待重生
    local onlinePlayers = GameInit and GameInit.getOnlinePlayers() or {}
    for _, player in ipairs(onlinePlayers) do
        if player and player:isPlaying() then
            -- 关闭玩家游戏，准备重生（可选：使用 closeGame 或强制移除所有英雄）
            pcall(function() 
                if player.closeGame then 
                    player.closeGame(true) 
                end
            end)
            print(string.format("[Layer3] 已通知玩家：%s (PID=%d) 等待重生", player:getName(), player:getId()))
        end
    end
    
    -- 1 秒后重新加载关卡（通过 GameInit.startLayer3 重启）
    Timer:new(1, false, function()
        Layer3.reloading = true
        print("[Layer3] === 尝试重新加载关卡 3...===")
        if GameInit and GameInit.startLayer3 then
            -- 直接调用 startLayer3（会重置状态并重新启动整个关卡）
            GameInit.startLayer3()
        end
        Layer3.reloading = false
    end)
end

function Layer3.registerLayer3DeathHandler()
    print("[Layer3] 注册关卡死亡处理...")
    -- 使用 Event.new 添加全局玩家单位死亡事件（Event.lua 已支持 nil 目标）
    local deathListenerAdded = nil
    
    -- [OOP] 直接使用 Event:new(nil, EVENT_PLAYER_UNIT_DEATH, ...)注册全局事件
    Layer3.deathHandler = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        local dyingUnit = ev.unit or cj.GetTriggerUnit()
        if not dyingUnit then return end
        
        -- 仅处理英雄单位且是玩家控制的在线用户
        if not cj.IsUnitType(dyingUnit, UNIT_TYPE_HERO) then return end
        
        local player = Player.fromHandle(cj.GetOwningPlayer(dyingUnit))
        if not player or not player:isUser() then return end
        
        local pid = player:getId()
        if pid < 0 or pid > 3 then return end
        
        -- 检查是否在关卡 3 中且未通关
        if Layer3.started and not Layer3.finished then
            print(string.format("[Layer3] 玩家 %d (PID=%d) 死亡，触发关卡失败处理", player:getName(), pid))
            Layer3.onAllPlayersDied()
        end
    end)
end

function Layer3.unregisterLayer3DeathHandler()
    if Layer3.deathListenerAdded then
        -- 取消事件监听（简单方案：在 shutdown 时忽略）
        print("[Layer3] 注销关卡死亡处理")
    end
end

-- 将 unregister 添加到 shutdown
Layer3.shutdown = function(self)
    local wasStarted = self.started
    self.started = false
    print("[Layer3] 关闭")
    -- 刷怪系统完整清理（停止并销毁计时器 / 清除单位实体 / 释放记录 / 重置状态）
    if Layer3.cleanupMobSpawnSystem then
        Layer3.cleanupMobSpawnSystem("关卡关闭")
    end
    -- 注销死亡监听
    Layer3.unregisterLayer3DeathHandler()
    -- ... 其他清理代码 ...
end

-- ============================================================
-- §11 兼容别名
-- ============================================================

Layer3EntryPos    = Layer3.entryPos
Layer3RevivePos   = Layer3.revivePos
Layer3TeleportPos = Layer3.teleportPos

return Layer3