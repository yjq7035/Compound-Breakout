--|=============================================================
-- Layer4 — 第四关卡模块（重写稳定版 2026-08-29）
--|
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡 3 通关后传送至此）
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. §1b: 创建墙体（横墙 B000 / 竖墙 DL84，index=4/6 默认不创建）
--   3. §1c: 矩形区域定义（A/B 刷怪区，C 通关区）
--   4. §2a: 玩法 1 魔法强化怪物 n89f + 击杀销毁横墙 1
--   5. §2b: 玩法 2 所有用户玩家英雄进入 A 或 B 后创建竖墙 1
--|=============================================================

-- ============================================================
-- [常量] 魔法强化换算（与 GameDamage.lua 保持一致）
-- ============================================================
-- local MAGICAMP_TO_PCT = 1000

Layer4 = {}
Layer4.__index = Layer4

--|=============================================================
-- §1 坐标
--|=============================================================
Layer4.entryPos     = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4.revivePos    = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4.teleportPos  = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4.potionShopPos= { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
-- §1c: 矩形区域定义
--|=============================================================
Layer4.mobSpawnRectsA = {
    { id = "A", cx = -13020.15, cy = 5888.8, width = 4959.9, height = 3636.2, name = "矩形 A 刷怪区域" },
}
Layer4.mobSpawnRectsB = {
    { id = "B", cx = -9302.4, cy = 6552.7, width = 2223.0, height = 2262.4, name = "矩形 B 刷怪区域" },
}
Layer4.finishAreaC = {
    { id = "C", minx = -10234.0, miny = 4894.7, maxx = -9815.9, maxy = 5127.0, name = "矩形 C 通关区域" },
}

--|=============================================================
-- §1b: 墙体定义与运行时（横墙 B000, 竖墙 DL84）
--|=============================================================
Layer4.WALL_H = "B000"
Layer4.WALL_V = "DL84"

-- index 4=竖墙 1, index 6=竖墙 3 启动时默认不创建（玩法 2 触发后才创建竖墙 1）
Layer4.walls = {
    { index = 1, x = -8543.2,  y = 3544.7, id = "B000", dir = "H", face = 270, name = "横墙 1" },
    { index = 2, x = -12897.8, y = 3844.4, id = "B000", dir = "H", face = 270, name = "横墙 2" },
    { index = 3, x = -10070.3, y = 5306.5, id = "B000", dir = "H", face = 270, name = "横墙 3" },
    { index = 4, x = -9596.7,  y = 4296.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 1" },
    { index = 5, x = -12457.2, y = 2074.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 2" },
    { index = 6, x = -11647.0, y = 2867.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 3" },
}

Layer4.handles     = {}    -- destructable handle 列表
Layer4.wallMap     = {}    -- index -> handle
Layer4.createDone  = false
Layer4.started     = false
Layer4.finished    = false
Layer4.rectListeners = nil -- "A:A" / "B:B" -> Event
Layer4.deathListener = nil

--|=============================================================
-- §2a: 玩法 1 配置
--|=============================================================
Layer4.play1Config = {
    pos     = { x = -8524.9, y = 3091.9 },
    unitId  = "n89f",
    facing  = 270,
    armor   = 50,        -- Boss 物理护甲（魔法抗性也用这个值）
    magic   = 2000,
    maxMana = 5000,
}
Layer4.play1Unit      = nil

-- 获取敌方玩家（固定为玩家 4）
local function getEnemyPlayer()
    return Player:new(4)
end
Layer4.play1Triggered = false

--|=============================================================
-- §2b: 玩法 2 配置（竖墙 1 延迟创建）
--|=============================================================
Layer4.play2Wall1Pos     = { x = -9596.7, y = 4296.7, id = "DL84", dir = "V", face = 0, name = "竖墙 1" }
Layer4.play2Triggered    = false
Layer4.play2WallHandle   = nil
Layer4.play2EnteredPids  = {} -- pid -> true
Layer4.play2MobTimer     = nil
Layer4.play2MobHandles   = {} -- 单位 handle 列表，用于死亡监听

--|=============================================================
-- §1b 墙体管理
--|=============================================================
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then
        print(string.format("[Layer4] createOne: nil params w=%s", tostring(w and w.name or w)))
        return nil
    end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local typeId = c2i(w.id) or 0
    local x, y = tonumber(w.x), tonumber(w.y)
    if not x or not y then
        print(string.format("[Layer4] createOne: bad coords id=%s", tostring(w.id)))
        return nil
    end
    local h = cj.CreateDestructable(typeId, x, y, face, 1, 0)
    if h then
        print(string.format("[Layer4] createOne: %s at %.1f,%.1f ok", w.name or w.id, x, y))
    else
        print(string.format("[Layer4] createOne FAILED: %s id=%s at %.1f,%.1f", w.name or "?", tostring(w.id), x, y))
    end
    return h
end

function Layer4.createWalls()
    if Layer4.createDone then return end
    print("[Layer4] §1b: 开始创建墙体（跳过 index 4/6）...")
    for _, w in ipairs(Layer4.walls) do
        if w.index == 4 or w.index == 6 then
            print(string.format("  ⊘ %s(index=%d) 跳过创建 (关卡 4 默认不创建)", w.name, w.index))
        else
            local h = createOne(w)
            if h then
                table.insert(Layer4.handles, h)
                Layer4.wallMap[w.index] = h
                print(string.format("  ✓ %s: %.1f,%.1f (%s)", w.name, w.x, w.y, w.dir))
            else
                print(string.format("  ✗ %s 创建失败", w.name))
            end
        end
    end
    Layer4.createDone = true
end

function Layer4.destroyWalls()
    if not Layer4.createDone and #Layer4.handles == 0 and not next(Layer4.wallMap) then return end
    print("[Layer4] §1b: 销毁所有墙体...")
    for _, h in ipairs(Layer4.handles) do
        if h then pcall(function() cj.RemoveDestructable(h) end) end
    end
    Layer4.handles = {}
    Layer4.wallMap = {}
    Layer4.createDone = false
end

--|=============================================================
-- §2b: 玩法 2 逻辑
--|=============================================================
function Layer4.createPlay2Wall1()
    if Layer4.play2Triggered then return end
    Layer4.play2Triggered = true
    print("[Layer4] §2b: 创建竖墙 1...")
    local h = createOne(Layer4.play2Wall1Pos)
    if h then
        Layer4.play2WallHandle = h
        Layer4.wallMap[4] = h
        table.insert(Layer4.handles, h)
        print(string.format("  ✓ 竖墙 1 已创建 %.1f,%.1f", Layer4.play2Wall1Pos.x, Layer4.play2Wall1Pos.y))
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "所有玩家已进入刷怪区，竖墙 1 已升起！", SystemMessage.COLOR_WARN}}, 3.0)
        end
        -- 启动刷怪计时器
        Layer4.startMobSpawnerTimer()
    else
        print("  ✗ 竖墙 1 创建失败")
    end
end

local function getActiveUserPids()
    local list = {}
    for pid = 0, 3 do
        local ok, p = pcall(Player.new, Player, pid)
        if ok and p and p.isUser and p.isPlaying and p:isUser() and p:isPlaying() then
            table.insert(list, pid)
        end
    end
    return list
end

local function isAllUserHeroesEntered()
    local active = getActiveUserPids()
    if #active == 0 then return false end
    for _, pid in ipairs(active) do
        if not Layer4.play2EnteredPids[pid] then return false end
    end
    return true
end

local function onMobSpawnRectEnter(rectId, unit)
    if Layer4.play2Triggered then return end
    if not unit then return end
    local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(unit))
    if not okOwner or not owner then return end
    local pid = owner:getId()
    if pid < 0 or pid > 3 then return end
    if not Layer4.play2EnteredPids[pid] then
        Layer4.play2EnteredPids[pid] = true
        print(string.format("[Layer4] §2b: 玩家%d 英雄进入矩形%s 已记录", pid, rectId))
    end
    if isAllUserHeroesEntered() then
        print(string.format("[Layer4] §2b: 所有用户玩家英雄已进入 A/B，矩形%s触发 创建竖墙 1", rectId))
        Layer4.createPlay2Wall1()
    else
        local active = getActiveUserPids()
        local entered = 0
        for _, apid in ipairs(active) do if Layer4.play2EnteredPids[apid] then entered = entered + 1 end end
        print(string.format("[Layer4] §2b: 等待所有玩家进入 A/B [%d/%d] rect=%s pid=%d", entered, #active, rectId, pid))
    end
end

local function initMobSpawnRectListeners()
    if Layer4.rectListeners then return end
    Layer4.rectListeners = {}
    local function makeRect(cfg)
        local ok, r = pcall(Rect.new, Rect, cfg.cx - cfg.width/2, cfg.cy - cfg.height/2, cfg.cx + cfg.width/2, cfg.cy + cfg.height/2)
        if not ok or not r then
            print(string.format("[Layer4] 矩形%s 创建失败", cfg.id or "?"))
            return nil
        end
        return r
    end
    for _, cfg in ipairs(Layer4.mobSpawnRectsA) do
        local r = makeRect(cfg)
        if r then
            print(string.format("[Layer4] §2b: 监听矩形 A[%s] %.1f,%.1f -> %.1f,%.1f", cfg.id, r:getMinX(), r:getMinY(), r:getMaxX(), r:getMaxY()))
            local rid = cfg.id
            local ev = Event:newRect(r, function(ev)
                if Layer4.finished then return end
                local u = ev.unit or cj.GetEnteringUnit()
                if not u then return end
                local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(u))
                if not okOwner or not owner or not owner.isUser or not owner:isUser() then return end
                if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end
                if owner:getId() < 0 or owner:getId() > 3 then return end
                onMobSpawnRectEnter(rid, u)
            end)
            Layer4.rectListeners["A:" .. rid] = ev
            -- 保留 Rect 句柄防止 GC（Event:newRect 内部已持有 region，但保留引用更稳）
            Layer4["__rectA_" .. rid] = r
        end
    end
    for _, cfg in ipairs(Layer4.mobSpawnRectsB) do
        local r = makeRect(cfg)
        if r then
            print(string.format("[Layer4] §2b: 监听矩形 B[%s] %.1f,%.1f -> %.1f,%.1f", cfg.id, r:getMinX(), r:getMinY(), r:getMaxX(), r:getMaxY()))
            local rid = cfg.id
            local ev = Event:newRect(r, function(ev)
                if Layer4.finished then return end
                local u = ev.unit or cj.GetEnteringUnit()
                if not u then return end
                local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(u))
                if not okOwner or not owner or not owner.isUser or not owner:isUser() then return end
                if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end
                if owner:getId() < 0 or owner:getId() > 3 then return end
                onMobSpawnRectEnter(rid, u)
            end)
            Layer4.rectListeners["B:" .. rid] = ev
            Layer4["__rectB_" .. rid] = r
        end
    end
end

local function destroyMobSpawnRectListeners()
    if not Layer4.rectListeners then return end
    for key, ev in pairs(Layer4.rectListeners) do
        -- Event:newRect 返回的是共享 obj，销毁需通过 Event:destroyRect(rectHandle)
        -- 但我们未保留原 rectHandle 到 ev._rect，直接尝试 destroy
        pcall(function() if ev and ev.destroy then ev:destroy() end end)
    end
    -- 尝试按 Rect 对象销毁 region
    for _, cfg in ipairs(Layer4.mobSpawnRectsA) do
        local r = Layer4["__rectA_" .. cfg.id]
        if r then pcall(function() Event:destroyRect(r) end) pcall(function() r:destroy() end) Layer4["__rectA_" .. cfg.id] = nil end
    end
    for _, cfg in ipairs(Layer4.mobSpawnRectsB) do
        local r = Layer4["__rectB_" .. cfg.id]
        if r then pcall(function() Event:destroyRect(r) end) pcall(function() r:destroy() end) Layer4["__rectB_" .. cfg.id] = nil end
    end
    Layer4.rectListeners = nil
end

--|=============================================================
-- §2a: 玩法 1
--|=============================================================



function Layer4.createPlay1Boss()
    if Layer4.play1Unit then print("[Layer4] §2a: 玩法 1 怪物已存在") return end

    local p = getEnemyPlayer()
    if not p then print("[Layer4] §2a: Player 4 nil") return end
    local u = Unit:new(p, Layer4.play1Config.unitId, Layer4.play1Config.pos.x, Layer4.play1Config.pos.y, Layer4.play1Config.facing)
    if not u or not u._handle then return end
    local maValue = Layer4.play1Config.magic or 2000  -- 每千点=+100% 魔伤增幅


    u.state.magicAmp = maValue                        -- [魔法强化]
    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)

    Layer4.play1Unit = u
end

function Layer4.destroyPlay1Boss()
    if not Layer4.play1Unit then return end
    pcall(function() Layer4.play1Unit:destroy() end)
    print("[Layer4] §2a: 玩法 1 怪物已销毁")
    Layer4.play1Unit = nil
end

--|=============================================================
-- §2c: 玩法 3 BOSS 创建和销毁
--|=============================================================
function Layer4.createPlay3Boss()
    if Layer4.play3Unit then print("[Layer4] §2c: 玩法 3 BOSS 已存在") return end

    local p = getEnemyPlayer()
    if not p then print("[Layer4] §2c: Player 4 nil") return end
    local u = Unit:new(p, Layer4.play3Config.unitId, Layer4.play3Config.pos.x, Layer4.play3Config.pos.y, Layer4.play3Config.facing)
    if not u or not u._handle then return end

    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)
    u.state.defendWhite = u:getState(UNIT_STATE_DEFEND_WHITE)

    Layer4.play3Unit = u
end

function Layer4.destroyPlay3Boss()
    if not Layer4.play3Unit then return end
    pcall(function() Layer4.play3Unit:destroy() end)
    print("[Layer4] §2c: 玩法 3 BOSS 已销毁")
    Layer4.play3Unit = nil
end

--|=============================================================
-- §2d: 玩法 4 BOSS 创建和销毁
--|=============================================================
function Layer4.createPlay4Boss()
    if Layer4.play4Unit then print("[Layer4] §2d: 玩法 4 BOSS 已存在") return end

    local p = getEnemyPlayer()
    if not p then print("[Layer4] §2d: Player 4 nil") return end
    local u = Unit:new(p, Layer4.play4Config.unitId, Layer4.play4Config.pos.x, Layer4.play4Config.pos.y, Layer4.play4Config.facing)
    if not u or not u._handle then return end

    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)
    u.state.defendWhite = u:getState(UNIT_STATE_DEFEND_WHITE)

    Layer4.play4Unit = u
end

function Layer4.destroyPlay4Boss()
    if not Layer4.play4Unit then return end
    pcall(function() Layer4.play4Unit:destroy() end)
    print("[Layer4] §2d: 玩法 4 BOSS 已销毁")
    Layer4.play4Unit = nil
end

function Layer4.ensureDeathListener()
    if Layer4.deathListener then return end
    print("[Layer4] §2a: 注册死亡监听...")
    Layer4.deathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then return end
        local dyingHandle = ev.unit
        if not dyingHandle then return end
        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if not okU or not dyingUnit then return end
        local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
        if not okCode or typeCode ~= Layer4.play1Config.unitId then return end
        if not Layer4.play1Unit then return end
        print(string.format("[Layer4] ✓ 玩法 1 BOSS 死亡 type=%s", tostring(typeCode)))
        if Layer4.play1Triggered then print("[Layer4] 已触发过跳过") return end
        Layer4.play1Triggered = true
        local h = Layer4.wallMap[1]
        if not h then print("[Layer4] 横墙 1 handle 缺失") return end
        local wallCfg = Layer4.walls[1]
        print(string.format("[Layer4] 销毁横墙 1 at %.1f,%.1f", wallCfg.x, wallCfg.y))
        pcall(function() cj.RemoveDestructable(h) end)
        for i, handle in ipairs(Layer4.handles) do if handle == h then table.remove(Layer4.handles, i) break end end
        Layer4.wallMap[1] = nil
        print("[Layer4] 横墙 1 已销毁")
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "玩法 1 通关！横墙 1 已摧毁！", SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            Player.sendAll("玩法 1 通关！横墙 1 已摧毁")
        end
        Layer4.deathListener:destroy()
        Layer4.deathListener = nil
    end)
end

--|=============================================================
-- §2 怪物 ID 注册（用户提供的怪物列表）
-- 注：nPo0 和 nx20 已分别作为玩法 4 和玩法 3 的 BOSS 单独注册
--|=============================================================
Layer4.registeredMobIds = {
    "n8st", "ncE7", "n8b9", "n113", "n3pi", "nv16", "nn7s", "nlok", "n0m1", "ny5m",
    "nt13", "n2ra", "nGyP", "nyrv", "no3F", "n338", "n834", "nz21", "n0v0", "n134",
    "n37t", "nD46", "nT8J", "n01r", "nb8k", "n8c8", "n048", "ng0z", "n1io",
    "n35p", "nJm3", "nQ2P", "nr19", "nx92"
}

--|=============================================================
-- §2b: 首次达到上限刷怪配置
-- 当首次达到 70 个上限时，给每个玩家额外刷一个怪
--|=============================================================
Layer4.play2BonusSpawns = {} -- 记录每个玩家是否已获得 bonus spawn
Layer4.play2HasBonus = false -- 是否已经触发过 bonus spawn 奖励

function Layer4.bonusSpawnOnCap()
    -- 防止重复触发
    if Layer4.play2HasBonus then
        print("[Layer4] §2b: 已经触发过首次上限奖励，跳过")
        return
    end
    
    print("[Layer4] §2b: 首次达到上限，触发奖励刷怪...")
    Layer4.play2HasBonus = true
    
    -- 给每个玩家刷一个怪
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            -- 为该玩家刷一个怪（使用 countAliveUnits 最少的玩家逻辑）
            local alive = Layer4.countAliveUnits(p)
            if alive < 10 then -- 如果该玩家还没满
                -- 临时跳过上限检查，专门刷这个 bonus 怪
                local originalCanSpawn = Layer4.canSpawnMob
                Layer4.canSpawnMob = function() return true end -- 临时允许
                local u = Unit:new(p, Layer4.getRandomMobId(), 0, 0, 270)
                Layer4.canSpawnMob = originalCanSpawn -- 恢复
                if u and u._handle then
                    table.insert(Layer4.play2MobHandles, u._handle)
                    print(string.format("[Layer4] §2b: 奖励刷怪：玩家%d 获得怪物 %s", pid, Layer4.getRandomMobId()))
                    -- 记录该玩家已获得 bonus
                    Layer4.play2BonusSpawns[pid] = true
                else
                    print(string.format("[Layer4] §2b: 奖励刷怪失败：玩家%d", pid))
                end
            end
        end
    end
end

--|=============================================================
-- §2c: 玩法 3 BOSS 配置（nx20）
--|=============================================================
Layer4.play3Config = {
    pos     = { x = -8524.9, y = 3200.0 },
    unitId  = "nx20",
    facing  = 270,
    armor   = 50,
    hp      = 5000,     -- 自定义 HP
    magic   = 2000,
    maxMana = 5000,
}
Layer4.play3Unit      = nil

--|=============================================================
-- §2d: 玩法 4 BOSS 配置（nPo0）
--|=============================================================
Layer4.play4Config = {
    pos     = { x = -8524.9, y = 3300.0 },
    unitId  = "nPo0",
    facing  = 270,
    armor   = 100,      -- 高护甲
    hp      = 7500,     -- 高生命
    magic   = 0,        -- 无魔法强化
    maxMana = 0,
}
Layer4.play4Unit      = nil

--|=============================================================
-- §2 生命周期
--|=============================================================
function Layer4.start()
    if Layer4.started then print("[Layer4] 已启动跳过") return end
    Layer4.started = true
    Layer4.finished = false
    Layer4.play1Triggered = false
    Layer4.play2Triggered = false
    Layer4.play2EnteredPids = {}
    Layer4.play2WallHandle = nil
    -- 重置刷怪状态
    Layer4.play2MobTimer = nil
    Layer4.play2MobHandles = {}
    -- 重置首次达到上限的状态
    Layer4.play2BonusSpawns = {}
    Layer4.play2HasBonus = false
    print(string.format("[Layer4] 启动 %.1f,%.1f", Layer4.entryPos.x, Layer4.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
    Layer4.createWalls()
    if not Layer4.play1Unit then Layer4.createPlay1Boss() end
    initMobSpawnRectListeners()
    Layer4.ensureDeathListener()
    Layer4.ensureMobDeathListener()
end

function Layer4.shutdown()
    if not Layer4.started and not Layer4.finished then
        -- 允许重复调用清理
    end
    Layer4.started = false
    print("[Layer4] 关闭")
    Layer4.destroyPlay1Boss()
    -- 停止刷怪计时器
    if Layer4.play2MobTimer then
        Layer4.play2MobTimer:stop()
        print("[Layer4] 停止刷怪计时器")
        Layer4.play2MobTimer = nil
    end
    -- 销毁所有刷怪单位
    if #Layer4.play2MobHandles > 0 then
        print(string.format("[Layer4] §2b: 销毁 %d 个刷怪单位", #Layer4.play2MobHandles))
        for _, h in ipairs(Layer4.play2MobHandles) do
            if h then pcall(function() Unit.fromHandle(h):destroy() end) end
        end
        Layer4.play2MobHandles = {}
    end
    if Layer4.play2WallHandle then
        pcall(function() cj.RemoveDestructable(Layer4.play2WallHandle) end)
        print("[Layer4] 清理竖墙 1")
        Layer4.play2WallHandle = nil
    end
    Layer4.wallMap[4] = nil
    Layer4.play2EnteredPids = {}
    Layer4.play2Triggered = false
    destroyMobSpawnRectListeners()
    Layer4.destroyWalls()
    Layer4.play1Triggered = false
end

--|=============================================================
-- §2b: 刷怪逻辑
--|=============================================================

-- 启动刷怪真计时器（间隔 1.5 秒，周期性刷怪）
function Layer4.startMobSpawnerTimer()
    if Layer4.play2MobTimer then return end
    if not Layer4.play2Triggered then
        print("[Layer4] §2b: 警告：尝试启动计时器但玩法 2 未触发")
        return
    end
    print("[Layer4] §2b: 启动刷怪真计时器...")
    Layer4.play2MobTimer = Timer:new(1.5, true, function()
        if not Layer4.play2Triggered or Layer4.finished then return end
        print("[Layer4] §2b: 计时器触发，开始刷怪...")
        Layer4.spawnOneMob()
    end)
    Layer4.play2MobTimer:start()
    print("[Layer4] 刷怪计时器已启动 (1.5 秒/次)")
end

-- 停止刷怪计时器
function Layer4.stopMobSpawnerTimer()
    if Layer4.play2MobTimer then
        Layer4.play2MobTimer:stop()
        Layer4.play2MobTimer = nil
        print("[Layer4] 刷怪计时器已停止")
    end
end

-- 随机获取一个怪物 ID
function Layer4.getRandomMobId()
    local ids = Layer4.registeredMobIds
    if #ids == 0 then return nil end
    local idx = math.random(1, #ids)
    return ids[idx]
end

-- 检查周围 800 码内是否有敌对单位
-- 使用 Group:enumRange 高效枚举 800 码内单位，再过滤敌方（玩家 4+）
function Layer4.canSpawnMob()
    local spawnPos = {}
    -- 选择随机刷怪区
    local rects = Layer4.mobSpawnRectsA
    local rect = rects[math.random(1, #rects)]
    
    -- 计算随机位置
    local minx = rect.cx - rect.width / 2
    local miny = rect.cy - rect.height / 2
    local maxx = rect.cx + rect.width / 2
    local maxy = rect.cy + rect.height / 2
    local x = minx + math.random() * (maxx - minx)
    local y = miny + math.random() * (maxy - miny)
    
    spawnPos.x = x
    spawnPos.y = y
    
    local enemyCount = 0
    
    -- 使用 Group 枚举 800 码内所有单位（底层遍历 _unitPool，范围过滤）
    local g = Group:new()
    g:enumRange(x, y, 800, nil)
    
    g:forEach(function(handle)
        local u = Unit.fromHandle(handle)
        if not u then return end
        local ux, uy = u:getX(), u:getY()
        if ux and uy then
            local dx = ux - spawnPos.x
            local dy = uy - spawnPos.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist < 800 then
                local owner = u:getOwner()
                if owner and owner:getId() >= 4 then
                    enemyCount = enemyCount + 1
                    if enemyCount <= 3 then
                        print(string.format("[Layer4] §2b: 发现第%d个敌对单位 %s 在 %.1f,%.1f，距离 %.1f 码", enemyCount, u:getName(), ux, uy, dist))
                    end
                end
            end
        end
    end)
    
    if enemyCount > 0 then
        return false
    end
    
    return true
end

-- 在刷怪区 A 或 B 的随机位置生成一个单位
function Layer4.spawnOneMob()
    -- 统计所有敌方玩家（4-11）的存活单位数
    local totalAlive = 0
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            totalAlive = totalAlive + Layer4.countAliveUnits(p)
        end
    end
    
    -- 每个玩家最多 10 个，总共 7 个玩家 = 70 个上限
    if totalAlive >= 70 then
        print(string.format("[Layer4] §2b: 达到上限 %d/70，暂停刷怪", totalAlive))
        -- 首次达到上限时，给每个玩家刷一个怪
        Layer4.bonusSpawnOnCap()
        return
    end
    
    -- 检查周围 800 码内是否有敌对单位
    if not Layer4.canSpawnMob() then
        print(string.format("[Layer4] §2b: 周围 800 码内有敌对单位，跳过刷怪"))
        return
    end
    
    -- 选择随机刷怪区
    local rects = Layer4.mobSpawnRectsA
    local rect = rects[math.random(1, #rects)]
    
    -- 计算随机位置
    local minx = rect.cx - rect.width / 2
    local miny = rect.cy - rect.height / 2
    local maxx = rect.cx + rect.width / 2
    local maxy = rect.cy + rect.height / 2
    local x = minx + math.random() * (maxx - minx)
    local y = miny + math.random() * (maxy - miny)
    
    -- 获取敌方玩家列表（4-11）
    local enemyPlayers = {}
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            table.insert(enemyPlayers, p)
        end
    end
    
    -- 找到存活数最少的敌方玩家
    local bestPlayer = nil
    local minAlive = 999999
    for _, p in ipairs(enemyPlayers) do
        local alive = Layer4.countAliveUnits(p)
        if alive < minAlive then
            minAlive = alive
            bestPlayer = p
        end
    end
    
    if not bestPlayer then
        print("[Layer4] §2b: 没有可用的敌方玩家")
        return
    end
    
    -- 创建单位
    local mobId = Layer4.getRandomMobId()
    if not mobId then
        print("[Layer4] §2b: 没有可用的怪物 ID")
        return
    end
    
    -- 检查位置高度，大于 1 不创建
    -- 使用 Terrain.lua 封装的 cdz.DzGetTerrainZ 获取地形高度
    local height = cdz.DzGetTerrainZ(x, y) or 0
    if height > 1 then
        print(string.format("[Layer4] §2b: 位置 %.1f,%.1f 高度 %.1f > 1，跳过创建", x, y, height))
        return
    end
    
    local u = Unit:new(bestPlayer, mobId, x, y, 270)
    if u and u._handle then
        -- 添加到句柄列表，用于死亡监听
        table.insert(Layer4.play2MobHandles, u._handle)
        print(string.format("[Layer4] §2b: 在 %.1f,%.1f 创建怪物 %s 给玩家%d", x, y, mobId, bestPlayer:getId()))
        print(string.format("[Layer4] §2b: 当前刷怪单位总数：%d / 上限：70", #Layer4.play2MobHandles, 70))
        
        -- 可选：设置单位属性（如 HP、护甲等）
        -- u:setLife(1000)
        -- u:setArmor(30)
    else
        print(string.format("[Layer4] §2b: 创建怪物失败 %s", mobId))
    end
end

-- 统计指定玩家的存活单位数（不包括 BOSS）
function Layer4.countAliveUnits(p)
    if not p then return 0 end
    local g = Group:new()
    g:enumPlayer(p._handle or cj.Player(p:getId()))
    local count = 0
    g:forEach(function(handle)
        local u = Unit.fromHandle(handle)
        if u and not u:isType(UNIT_TYPE_DEAD) then
            count = count + 1
        end
    end)
    return count
end

-- 死亡监听：当刷怪单位死亡时，从句柄列表中移除
function Layer4.onMobDeath(handle)
    if not Layer4.play2MobTimer then return end
    -- 从 handle 列表中移除
    for i, h in ipairs(Layer4.play2MobHandles) do
        if h == handle then
            table.remove(Layer4.play2MobHandles, i)
            break
        end
    end
    -- 检查是否有空坑位，如果有则尝试创建新单位
    local totalAlive = 0
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            totalAlive = totalAlive + Layer4.countAliveUnits(p)
        end
    end
    if totalAlive < 70 then
        -- 延迟 0.5 秒再刷，避免瞬间刷太多
        -- Timer:delayed 不存在，改用 Timer:new + 手动销毁
        local t = Timer:new(0.5, false, function(timer)
            if Layer4.play2Triggered and not Layer4.finished then
                Layer4.spawnOneMob()
            end
        end)
        -- 计时器到期后自动销毁
        t:destroy()
    end
end

-- 注册死亡监听
function Layer4.ensureMobDeathListener()
    if Layer4.mobDeathListener then return end
    print("[Layer4] §2b: 注册刷怪单位死亡监听...")
    Layer4.mobDeathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then return end
        local dyingHandle = ev.unit
        if not dyingHandle then return end
        -- 检查是否是刷怪单位
        for _, h in ipairs(Layer4.play2MobHandles) do
            if h == dyingHandle then
                Layer4.onMobDeath(h)
                return
            end
        end
        -- 如果不是刷怪单位，也尝试监听（兼容 BOSS 死亡）
        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if okU and dyingUnit then
            local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
            -- 这里可以添加更多过滤条件
        end
    end)
end

--|=============================================================
-- §3 兼容别名
--|=============================================================
Layer4EntryPos     = Layer4.entryPos
Layer4RevivePos    = Layer4.revivePos
Layer4TeleportPos  = Layer4.teleportPos
Layer4PotionShopPos= Layer4.potionShopPos

return Layer4
