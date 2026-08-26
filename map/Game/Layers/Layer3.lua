-- ============================================================
-- Layer3 — 第三关卡模块
--
-- 坐标：-11915.5,-1952.6 同时作为入口/复活/传送点（由 Layer2 通关后统一设置）
--
-- 扩展（关卡3设定 2026-08-26）：
--   1. 默认横墙 -11919.8,-5694.8  关卡启动时创建（B000 face 270）
--   2. 活动横墙 -11919.4,-3450.2  默认不创建，事件触发后创建
--   5. 事件矩形 左下 -12826.7,-5514.3 右上 -11014.0,-3705.4
--   6. 英雄进入事件矩形 -> 创建活动横墙 + 真计时器(剩余时间：5分钟)
--      到期后移除两堵墙，创建通关传送区域 -11925.0,-6154.3 500x300
--      全员进入后传送至关卡4 -8518.2,747.9
--
-- 职责：
--   1. 存放第三关卡坐标（入口/复活、传送）
--   2. 墙体创建/销毁（可破坏物）
--   3. 事件矩形与生存计时器
--   4. 通关传送区域与关卡切换
--   5. 提供关卡生命周期：Layer3.start / Layer3.shutdown
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

-- 墙体坐标（关卡3设定）
Layer3.defaultWallPos = { x = -11919.8, y = -5694.8, name = "默认横墙" }
Layer3.activeWallPos  = { x = -11919.4, y = -3450.2, name = "活动横墙" }

-- 事件矩形坐标（关卡3设定5）
Layer3.eventRectCoords = { left = -12826.7, bottom = -5514.3, right = -11014.0, top = -3705.4 }

-- 通关传送区域（关卡3设定6）
Layer3.exitCenter = { x = -11925.0, y = -6154.3, w = 500, h = 300, name = "关卡3通关传送区域" }

-- 关卡4 入口（关卡3设定6）
Layer3.layer4EntryPos = { x = -8518.2, y = 747.9, name = "关卡 4 入口" }

-- ============================================================
-- §2 矩形区域定义（Rect.new + 触发器事件）保留原6个占位
-- ============================================================
-- 区域 1：左下 (-13445.5,-3497.3) -> 右上 (-12303.5,-3081.7)，中心 (-12874.5, -3289.5)
-- 区域 2：左下 (-13432.5,-6231.9) -> 右上 (-13036.5,-3549.6)，中心 (-13234.5, -4890.75)
-- 区域 3：左下 (-13427.5,-6155.4) -> 右上 (-12340.4,-5656.7)，中心 (-12883.95, -5906.05)
-- 区域 4：左下 (-11476.8,-6131.7) -> 右上 (-10396.5,-5730.1)，中心 (-10936.65, -5930.9)
-- 区域 5：左下 (-10864.5,-5644.4) -> 右上 (-10387.7,-3075.3)，中心 (-10626.1, -4359.85)
-- 区域 6：左下 (-11491.3,-3535.7) -> 右上 (-10826.9,-3064.2)，中心 (-11159.1, -3299.95)

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
Layer3.survivalDuration = 300 -- 5分钟

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
    -- 启动5分钟计时器
    Layer3.startSurvivalTimer()
    -- 事件矩形为一次性，触发后销毁避免重复创建墙/计时器
    Layer3.destroyEventRect("事件已触发")
end

function Layer3.onSurvivalTimeout()
    if Layer3.finished then return end
    Layer3.finished = true
    print("[Layer3] 生存时间到期，关卡通关！")
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
            local g = cj.CreateGroup()
            cj.GroupEnumUnitsOfPlayer(g, p._handle, nil)
            local u = cj.FirstOfGroup(g)
            while u ~= nil do
                if cj.IsUnitType(u, UNIT_TYPE_HERO) then
                    local moved = false
                    if Unit and Unit.fromHandle then
                        local ok, unitObj = pcall(Unit.fromHandle, u)
                        if ok and unitObj and unitObj.setPosition then
                            local ok2 = pcall(function() unitObj:setPosition(ex, ey) end)
                            if ok2 then moved = true end
                        end
                    end
                    if not moved then
                        pcall(cj.SetUnitPosition, u, ex, ey)
                        pcall(cj.SetUnitX, u, ex)
                        pcall(cj.SetUnitY, u, ey)
                    end
                    if cj.GetLocalPlayer() == p._handle and Camera and Camera.panTo then
                        pcall(function() Camera.panTo(ex, ey) end)
                    end
                end
                cj.GroupRemoveUnit(g, u)
                u = cj.FirstOfGroup(g)
            end
            cj.DestroyGroup(g)
            print(string.format("[Layer3] 玩家%d 英雄已传送至关卡 4 入口 %.1f,%.1f", pid, ex, ey))
        end
    end
    if GameInit then GameInit.currentLayer = 4 end
    Layer3.shutdown()
    local ok, L4 = pcall(require, "Game.Layers.Layer4")
    if ok and L4 and L4.start then L4.start() end
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
    -- 清理旧 mob 占位
    for id, rect in pairs(Layer3.rectHandles) do
        if rect then pcall(function() Event:destroyRect(rect) end) pcall(function() rect:destroy() end) end
    end
    Layer3.rectHandles = {}
    Layer3.eventHandles = {}

    print(string.format("[Layer3] 启动 入口/复活/传送 %.1f,%.1f", Layer3.entryPos.x, Layer3.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 3 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 3 已启动")
    end
    -- 1. 创建默认横墙
    Layer3.createDefaultWall()
    -- 5. 创建事件矩形（等待英雄进入）
    Layer3.createEventRect()
end

function Layer3.shutdown()
    local wasStarted = Layer3.started
    Layer3.started = false
    print("[Layer3] 关闭")
    -- 销毁计时器
    if Layer3.survivalTimer then Layer3.cancelSurvivalTimer() end
    -- 销毁事件矩形
    if Layer3.eventRect then Layer3.destroyEventRect("shutdown") end
    -- 销毁通关区域
    if Layer3.exitRect then Layer3.destroyExitRegion() end
    -- 销毁墙体（兜底：若未通过 onSurvivalTimeout 移除，则此处统一移除）
    if next(Layer3.wallMap) then Layer3.destroyWalls() end
    -- 销毁额外事件
    for _, e in ipairs(Layer3.events) do if e and e.destroy then pcall(function() e:destroy() end) end end
    Layer3.events = {}
    -- 销毁占位矩形
    for id, rect in pairs(Layer3.rectHandles) do
        if rect then pcall(function() Event:destroyRect(rect) end) pcall(function() rect:destroy() end) end
        Layer3.eventHandles[id] = nil
    end
    Layer3.rectHandles = {}
    Layer3.triggered = false
    Layer3._teleporting = false
    if not wasStarted and Layer3.finished then print("[Layer3] 关闭（通关后清理）") end
end

-- 创建所有矩形区域触发器（使用 Rect:new + event）保留兼容
function Layer3.createMobSpawnRects()
    for _, rectDef in ipairs(Layer3.mobSpawnRects) do
        local curDef = rectDef
        if Layer3.rectHandles[curDef.id] then
            local oldRect = Layer3.rectHandles[curDef.id]
            pcall(function() Event:destroyRect(oldRect) end)
            pcall(function() oldRect:destroy() end)
            Layer3.eventHandles[curDef.id] = nil
            print(string.format("[Layer3] 清理旧矩形区域 %s", curDef.name))
        end
        local rect = Rect:new(curDef.cx - curDef.width/2, curDef.cy - curDef.height/2, 
                              curDef.cx + curDef.width/2, curDef.cy + curDef.height/2)
        if not rect then
            print(string.format("[Layer3] 创建矩形区域失败 %s", curDef.name))
        else
            Layer3.rectHandles[curDef.id] = rect
            local onEnter = function(ev)
                local unit = ev.unit or ev._unit or cj.GetEnteringUnit()
                if not unit then return end
                local player = Player.fromHandle(cj.GetOwningPlayer(unit))
                if not player or not player:isUser() then return end
                local pid = player:getId()
                local playerName = player:getName() or string.format("玩家%d", pid)
                print(string.format("[Layer3] 单位进入矩形区域 %s unit=%s owner=%s", curDef.name, Event.unitDesc(unit), playerName))
            end
            local event = Event:newRect(rect, onEnter)
            if event then
                Layer3.eventHandles[curDef.id] = event
                print(string.format("[Layer3] 创建矩形区域触发器 %s -> %.1f,%.1f w=%d h=%d", 
                                   curDef.name, rect.x, rect.y, rect.width, rect.height))
            else
                print(string.format("[Layer3] 绑定事件失败 区域 %s id=%s", curDef.name, curDef.id))
            end
        end
    end
    if Layer3.eventHandles then
        local count = 0; for _ in pairs(Layer3.eventHandles) do count = count + 1 end
        print(string.format("[Layer3] 矩形区域触发器已启动，共 %d 个", count))
    end
end

function Layer3.destroyMobSpawnRects()
    for id, rect in pairs(Layer3.rectHandles) do
        if rect then pcall(function() Event:destroyRect(rect) end) pcall(function() rect:destroy() end) Layer3.eventHandles[id] = nil end
    end
    Layer3.rectHandles = {}
end

function Layer3.destroyMobSpawnRectById(id, reason)
    local rect = Layer3.rectHandles[id]
    if rect then pcall(function() Event:destroyRect(rect) end) pcall(function() rect:destroy() end) Layer3.eventHandles[id] = nil Layer3.rectHandles[id] = nil print(string.format("[Layer3] 销毁矩形区域 id=%s %s", id, reason or "")) end
end

function Layer3.destroyMobSpawnEventById(id)
    local event = Layer3.eventHandles[id]
    if event then pcall(function() Event:destroyRect(event) end) Layer3.eventHandles[id] = nil print(string.format("[Layer3] 销毁矩形区域事件 id=%s", id)) end
end

function Layer3.cleanupMobSpawnRects()
    if Layer3.destroyMobSpawnRects then Layer3.destroyMobSpawnRects() end
end

-- ============================================================
-- §10 兼容别名
-- ============================================================

Layer3EntryPos    = Layer3.entryPos
Layer3RevivePos   = Layer3.revivePos
Layer3TeleportPos = Layer3.teleportPos

return Layer3
