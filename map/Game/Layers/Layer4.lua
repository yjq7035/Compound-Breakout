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
Layer4.play2MobHandles   = {} -- 单位 handle 列表

--|=============================================================
-- §2b-KEY: 玩法 2 钥匙玩法（ao8y 通行旗子）
--  1) 关卡4创建的单位死亡概率掉落 ao8y
--  2) 横墙2(index=2) 为通关门，携带钥匙靠近即开门通关
--|=============================================================
Layer4.play2KeyConfig = {
    itemId      = "ao8y",
    dropChance  = 0.01,  -- 单只死亡掉落概率 1%，可在测试时临时调高
    doorWallIndex = 2,   -- 横墙 2 为通关门
    doorSize    = { w = 700, h = 700 },
    finished    = false,
}
Layer4.play2DoorRect        = nil
Layer4.play2DoorEvent       = nil
Layer4.play2KeyPickupEvent  = nil

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
                local spawnPos = Layer4.generateRandomSpawnPos()
                if not spawnPos then
                    print(string.format("[Layer4] §2b: 奖励刷怪位置生成失败，跳过"))
                    Layer4.canSpawnMob = originalCanSpawn
                    return
                end
                local u = Unit:new(p, Layer4.getRandomMobId(), spawnPos.x, spawnPos.y, 270)
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
    -- 重置钥匙玩法状态
    Layer4.play2KeyConfig.finished = false
    Layer4.destroyPlay2KeyListeners() -- 兜底清理旧监听（热重载）
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
    Layer4.ensurePlay2KeyListeners()
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
    -- 清理钥匙玩法监听/门区域
    Layer4.destroyPlay2KeyListeners()
    -- 死亡监听不随关卡销毁（复用时 ensure 会重建），但此处清理 deathListener 便于热重载
    if Layer4.deathListener then pcall(function() Layer4.deathListener:destroy() end) Layer4.deathListener=nil end
    if Layer4.mobDeathListener then pcall(function() Layer4.mobDeathListener:destroy() end) Layer4.mobDeathListener=nil end
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
        pcall(function() Layer4.play2MobTimer:stop() end)
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

-- 生成一个随机刷怪位置（A 或 B 区域）
function Layer4.generateRandomSpawnPos()
    local allRects = {}
    for i = 1, #Layer4.mobSpawnRectsA do allRects[#allRects + 1] = Layer4.mobSpawnRectsA[i] end
    for i = 1, #Layer4.mobSpawnRectsB do allRects[#allRects + 1] = Layer4.mobSpawnRectsB[i] end
    if #allRects == 0 then return nil end
    local rect = allRects[math.random(1, #allRects)]
    local minx = rect.cx - rect.width / 2
    local miny = rect.cy - rect.height / 2
    local maxx = rect.cx + rect.width / 2
    local maxy = rect.cy + rect.height / 2
    local x = minx + math.random() * (maxx - minx)
    local y = miny + math.random() * (maxy - miny)
    return { x = x, y = y, rect = rect }
end

-- 在刷怪区 A 或 B 的随机位置生成一个单位
function Layer4.spawnOneMob()
    -- 获取敌方玩家列表（4-11）
    local enemyPlayers = {}
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            table.insert(enemyPlayers, p)
        end
    end
    
    -- 找到存活数最少的敌方玩家作为目标
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
    
    local totalAlive = 0
    local maxAttempts = 20
    for pid = 4, 11 do
        local p = Player:new(pid)
        totalAlive = totalAlive + Layer4.countAliveUnits(p)
    end
    
    -- 每个玩家最多 10 个，总共 7 个玩家 = 70 个上限
    if totalAlive >= 70 then
        print(string.format("[Layer4] §2b: 达到上限 %d/70，暂停刷怪", totalAlive))
        -- 首次达到上限时，给每个玩家刷一个怪
        Layer4.bonusSpawnOnCap()
        return
    end
    
    -- 在目标玩家周围寻找安全位置
    for attempt = 1, maxAttempts do
        local spawnPos = Layer4.generateRandomSpawnPos()
        x = spawnPos.x
        y = spawnPos.y
        local enemyCount = 0
        
        -- 检查周围 800 码内是否有与目标玩家敌对的单位
        Group:new():enumRange(x, y, 800, function(handle)
            local u = Unit.fromHandle(handle)
            if not u then return end
            local ux, uy = u:getX(), u:getY()
            if ux and uy then
                local dx = ux - x
                local dy = uy - y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 800 then
                    local owner = u:getOwner()
                    -- 判断单位所属玩家是否与目标玩家敌对
                    if owner and owner:isEnemy(bestPlayer) then
                        enemyCount = enemyCount + 1
                    end
                end
            end
        end)
        
        if enemyCount == 0 then
            -- 找到安全位置，break 跳出循环
            break
        end
        
        -- 尝试次数过多，打印警告
        if attempt == maxAttempts then
            print(string.format("[Layer4] §2b: 尝试 %d 次后仍未找到安全的刷怪位置，跳过刷怪", maxAttempts))
            return
        end
    end
    
    -- 获取可用的怪物 ID
    local mobId = Layer4.getRandomMobId()
    if not mobId then
        print("[Layer4] §2b: 没有可用的怪物 ID")
        return
    end
    
    -- 检查位置高度，大于 1 不创建
    local height = cdz.DzGetTerrainZ(x, y) or 0
    if height > 1 then
        print(string.format("[Layer4] §2b: 位置 %.1f,%.1f 高度 %.1f > 1，跳过创建", x, y, height))
        return
    end
    
    -- 创建单位
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
    -- 钥匙掉落（在移除前触发，确保位置有效）
    do
        local okX, x = pcall(cj.GetUnitX, handle)
        local okY, y = pcall(cj.GetUnitY, handle)
        if okX and okY and x and y then
            Layer4.tryDropKeyAt(x, y)
        end
    end
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
        -- if p and p:isEnemy() then
            totalAlive = totalAlive + Layer4.countAliveUnits(p)
        -- end
    end
    if totalAlive < 70 then
        -- 延迟 0.5 秒再刷，避免瞬间刷太多
        local t = Timer:new(0.5, false, function()
            if Layer4.play2Triggered and not Layer4.finished then
                Layer4.spawnOneMob()
            end
        end)
        t:start()
    end
end

-- 注册死亡监听
function Layer4.ensureMobDeathListener()
    if Layer4.mobDeathListener then return end
    print("[Layer4] §2b: 注册刷怪死亡监听...")
    Layer4.mobDeathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then return end
        local handle = ev.unit
        if not handle then return end
        -- 只处理本玩法刷出的怪（玩家英雄 / 各 BOSS 死亡交给各自的监听处理）
        local isMob = false
        for _, h in ipairs(Layer4.play2MobHandles) do
            if h == handle then isMob = true break end
        end
        if not isMob then return end
        Layer4.onMobDeath(handle)
    end)
end


--|=============================================================
-- §2b-KEY: 钥匙掉落 / 持有检测 / 开门通关
--|=============================================================
function Layer4.hasUnitKey(uHandle)
    if not uHandle then return false, nil end
    local keyId = c2i(Layer4.play2KeyConfig.itemId)
    if not keyId or keyId == 0 then return false, nil end
    for slot = 0, 5 do
        local it = cj.UnitItemInSlot(uHandle, slot)
        if it and cj.GetItemTypeId(it) == keyId then
            return true, it
        end
    end
    return false, nil
end

function Layer4.tryDropKeyAt(x, y)
    -- 注：当前代码只有钥匙掉落（1% 概率），无旗子掉落逻辑
    -- 如需添加旗子掉落，请在 tryDropKeyAt 中额外添加 tryDropFlagAt 函数调用
    if Layer4.play2KeyConfig.finished then return end
    if not x or not y then return end
    local chance = Layer4.play2KeyConfig.dropChance or 0.01 -- 1% 掉落概率
    if cj.I2R(math.random(1, 100)) / 100 >= chance then return end
    local itemIdStr = Layer4.play2KeyConfig.itemId
    local ok, it = pcall(function() return Item:new(itemIdStr, x, y) end)
    if not ok or not it or not it._handle then
        -- 兜底直接用原生创建
        local iid = c2i(itemIdStr)
        if iid and iid ~= 0 then
            local h = cj.CreateItem(iid, x, y)
            if h then print(string.format("[Layer4] §2b-KEY: 钥匙掉落(原生) %s at %.1f,%.1f", itemIdStr, x, y)) end
        end
        return
    end
    print(string.format("[Layer4] §2b-KEY: 钥匙掉落 %s at %.1f,%.1f", itemIdStr, x, y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "钥匙已掉落！拾取后前往横墙2开门通关！", SystemMessage.COLOR_WARN}}, 3.0)
    end
end

function Layer4.onPlay2DoorOpen(heroHandle, itemHandle)
    if Layer4.play2KeyConfig.finished then return end
    Layer4.play2KeyConfig.finished = true
    -- 消耗钥匙
    if heroHandle and itemHandle then
        pcall(function()
            cj.UnitRemoveItem(heroHandle, itemHandle)
            cj.RemoveItem(itemHandle)
        end)
    else
        local has, it = Layer4.hasUnitKey(heroHandle)
        if has and it then pcall(function() cj.UnitRemoveItem(heroHandle, it); cj.RemoveItem(it) end) end
    end
    -- 销毁横墙2（通关门）
    local wallIdx = Layer4.play2KeyConfig.doorWallIndex
    local h = Layer4.wallMap[wallIdx]
    local wallCfg = nil
    for _, w in ipairs(Layer4.walls) do if w.index == wallIdx then wallCfg = w break end end
    if h then
        pcall(cj.RemoveDestructable, h)
        Layer4.wallMap[wallIdx] = nil
        for i, handle in ipairs(Layer4.handles) do if handle == h then table.remove(Layer4.handles, i) break end end
        print("[Layer4] §2b-KEY: 横墙2 已开启销毁 (钥匙开门)")
    elseif wallCfg then
        local rect = cj.Rect(wallCfg.x - 96, wallCfg.y - 96, wallCfg.x + 96, wallCfg.y + 96)
        if rect then
            pcall(function()
                cj.EnumDestructablesInRect(rect, nil, function()
                    local d = cj.GetEnumDestructable()
                    if d and cj.GetDestructableTypeId(d) == c2i(wallCfg.id) then
                        local dx, dy = cj.GetDestructableX(d), cj.GetDestructableY(d)
                        if ((dx - wallCfg.x)^2 + (dy - wallCfg.y)^2)^0.5 < 96 then
                            pcall(cj.RemoveDestructable, d)
                        end
                    end
                end)
            end)
            cj.RemoveRect(rect)
            print("[Layer4] §2b-KEY: 横墙2 兜底枚举销毁")
        end
    end
    if SystemMessage and SystemMessage.send then
        local icon = SystemMessage.getUnitIcon and SystemMessage.getUnitIcon(heroHandle) or ""
        local owner = Player.fromHandle(cj.GetOwningPlayer(heroHandle))
        local pname = owner and owner:getName() or "英雄"
        if not pname or pname == "" then pname = string.format("玩家%d", owner and owner:getId() or 0) end
        local msg = string.format("%s 使用钥匙开启了横墙2，玩法2通关！", pname)
        if icon and icon ~= "" then
            SystemMessage.send({{"art", icon}, {"STR", msg, SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            SystemMessage.send({{"STR", msg, SystemMessage.COLOR_SUCCESS}}, 5.0)
        end
    else
        Player.sendAll("玩法2通关！横墙2已开启")
    end
    Layer4.destroyPlay2KeyDoor()
    -- 玩法 2 通关：停止刷怪计时器、清理剩余单位（刷怪单位属于玩法 2 内容）
    Layer4.stopMobSpawnerTimer()
    if #Layer4.play2MobHandles > 0 then
        print(string.format("[Layer4] §2b: 玩法 2 通关，销毁 %d 个剩余刷怪单位", #Layer4.play2MobHandles))
        for _, h in ipairs(Layer4.play2MobHandles) do
            if h then pcall(function() Unit.fromHandle(h):destroy() end) end
        end
        Layer4.play2MobHandles = {}
    end
    -- 清理刷怪区监听
    destroyMobSpawnRectListeners()
    print("[Layer4] §2b-KEY: 玩法 2 通关完成（已清理刷怪内容）")
end

function Layer4.createPlay2KeyDoor()
    if Layer4.play2DoorRect then return end
    local wall = nil
    for _, w in ipairs(Layer4.walls) do if w.index == Layer4.play2KeyConfig.doorWallIndex then wall = w break end end
    if not wall then print("[Layer4] §2b-KEY: 横墙2 配置缺失") return end
    local w, h = Layer4.play2KeyConfig.doorSize.w, Layer4.play2KeyConfig.doorSize.h
    local r = Rect:newCenter(wall.x, wall.y, w, h)
    if not r or not r._handle then print("[Layer4] §2b-KEY: 门区域创建失败") return end
    Layer4.play2DoorRect = r
    print(string.format("[Layer4] §2b-KEY: 通关门检测区域已创建 横墙2 %.1f,%.1f 范围 %.0fx%.0f", wall.x, wall.y, w, h))
    Layer4.play2DoorEvent = Event:newRect(r, function(ev)
        if Layer4.finished or Layer4.play2KeyConfig.finished then return end
        local u = ev.unit or ev._unit or cj.GetEnteringUnit()
        if not u then return end
        if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(u))
        if not owner or not owner:isUser() then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        local has = Layer4.hasUnitKey(u)
        if not has then return end
        print(string.format("[Layer4] §2b-KEY: 玩家%d 携带钥匙靠近横墙2，开门", pid))
        Layer4.onPlay2DoorOpen(u, select(2, Layer4.hasUnitKey(u)))
    end)
end

function Layer4.destroyPlay2KeyDoor()
    -- Event:newRect 共享 region，destroyRect 会清掉整个 region；用 pcall 保护
    if Layer4.play2DoorRect then
        pcall(function() Event:destroyRect(Layer4.play2DoorRect) end)
        pcall(function() Layer4.play2DoorRect:destroy() end)
        Layer4.play2DoorRect = nil
    end
    Layer4.play2DoorEvent = nil
end

local function onKeyPickup(ev)
    local it = ev.item
    if not it then return end
    if cj.GetItemTypeId(it) ~= c2i(Layer4.play2KeyConfig.itemId) then return end
    local hero = ev.unit
    if not hero then return end
    local owner = Player.fromHandle(cj.GetOwningPlayer(hero))
    local pname = owner and owner:getName() or "未知"
    if not pname or pname == "" then pname = string.format("玩家%d", owner and owner:getId() or 0) end
    print(string.format("[Layer4] §2b-KEY: %s 拾取钥匙 %s", pname, Layer4.play2KeyConfig.itemId))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("%s 获得了钥匙！前往横墙 2 (-12897,3844) 开门通关！", pname), SystemMessage.COLOR_SUCCESS}}, 5.0)
    end
end

function Layer4.ensurePlay2KeyListeners()
    if Layer4.play2KeyPickupEvent then return end
    Layer4.createPlay2KeyDoor()
    local keyId = c2i(Layer4.play2KeyConfig.itemId)
    if not keyId or keyId == 0 then print("[Layer4] §2b-KEY: ao8y 的 c2i 转换失败") return end
    Layer4.play2KeyPickupEvent = Event:new(nil, EVENT_PLAYER_UNIT_PICKUP_ITEM, onKeyPickup)
    print("[Layer4] §2b-KEY: 钥匙拾取监听已注册 ao8y 横墙 2 为通关门")
end

function Layer4.destroyPlay2KeyListeners()
    if Layer4.play2KeyPickupEvent then
        pcall(function() Layer4.play2KeyPickupEvent:destroy() end)
        Layer4.play2KeyPickupEvent = nil
    end
    Layer4.destroyPlay2KeyDoor()
end

--|=============================================================
-- §3 兼容别名
--|=============================================================
Layer4EntryPos     = Layer4.entryPos
Layer4RevivePos    = Layer4.revivePos
Layer4TeleportPos  = Layer4.teleportPos
Layer4PotionShopPos= Layer4.potionShopPos

return Layer4
