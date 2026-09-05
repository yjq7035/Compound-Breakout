--|=============================================================
-- Layer4 — 第四关卡模块（重写稳定版 2026-08-29）
--|=============================================================
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡 3 通关后传送至此）
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. §1b: 创建墙体（横墙 B000 / 竖墙 DL84，index=4/6 默认不创建）
--   3. §2a: 玩法 1 魔法强化怪物 n89f + 击杀销毁横墙 1
--   4. §2b: 玩法 2 已分离至 Layer4Play2.lua（独立管理）
--   5. §2d: 玩法 4 BOSS 创建和销毁
--|=============================================================

-- ============================================================
-- [常量] 魔法强化换算（与 GameDamage.lua 保持一致）
-- ============================================================
local MAGICAMP_TO_PCT = 1000

Layer4 = {}
Layer4.__index = Layer4

-- 初始化空表（防止 nil 错误）
-- 注意：mobSpawnRects 的初始化移到 start() 中，避免模块加载时依赖未加载的 Layer3
Layer4.mobSpawnRectsA = {}
Layer4.mobSpawnRectsB = {}

--|=============================================================
-- §1 坐标
--|=============================================================
Layer4.entryPos     = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4.revivePos    = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4.teleportPos  = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4.potionShopPos= { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
--[§1c: 矩形区域定义]
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
-- 玩法 2 已分离至 Layer4Play2，此处不再保留 play2 相关字段

--|=============================================================
-- §1b 墙体管理
--|=============================================================
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then
        return nil
    end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local typeId = c2i(w.id) or 0
    local x, y = tonumber(w.x), tonumber(w.y)
    if not x or not y then
        return nil
    end
    local h = cj.CreateDestructable(typeId, x, y, face, 1, 0)
    return h
end

function Layer4.createWalls()
    if Layer4.createDone then return end
    for _, w in ipairs(Layer4.walls) do
        if w.index ~= 4 and w.index ~= 6 then
            local h = createOne(w)
            if h then
                table.insert(Layer4.handles, h)
                Layer4.wallMap[w.index] = h
            end
        end
    end
    Layer4.createDone = true
end

function Layer4.destroyWalls()
    if not Layer4.createDone and #Layer4.handles == 0 and not next(Layer4.wallMap) then return end
    for _, h in ipairs(Layer4.handles) do
        if h then pcall(function() cj.RemoveDestructable(h) end) end
    end
    Layer4.handles = {}
    Layer4.wallMap = {}
    Layer4.createDone = false
end

--|=============================================================\
--[§2a: 玩法 1 配置]
--|=============================================================\
Layer4.play1Config = {
    pos     = { x = -8524.9, y = 3091.9 },
    unitId  = "n89f",
    facing  = 270,
    armor   = 50,
    magic   = 2000,
    maxMana = 5000,
}

--|=============================================================\
--[§2a: 玩法 1]
--|=============================================================\

function Layer4.createPlay1Boss()
    if Layer4.play1Unit then return end

    local p = Player:new(4)
    if not p then return end
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
    Layer4.play1Unit = nil
end

Layer4.play1Triggered = false

--|=============================================================\
--[§2a: 玩法 1 Boss 死亡监听]
--|=============================================================
function Layer4.ensureDeathListener()
    if Layer4.deathListener then return end
    Layer4.deathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then return end
        local dyingHandle = ev.unit
        if not dyingHandle then return end
        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if not okU or not dyingUnit then return end
        local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
        if not okCode or typeCode ~= Layer4.play1Config.unitId then return end
        if not Layer4.play1Unit then return end
        if Layer4.play1Triggered then return end
        Layer4.play1Triggered = true
        local h = Layer4.wallMap[1]
        if not h then 
            -- 不销毁监听器，保持存活以便后续可能重新创建横墙
            return 
        end
        local wallCfg = Layer4.walls[1]
        pcall(function() cj.RemoveDestructable(h) end)
        for i, handle in ipairs(Layer4.handles) do if handle == h then table.remove(Layer4.handles, i) break end end
        Layer4.wallMap[1] = nil
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "玩法 1 通关！横墙 1 已摧毁！", SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            Player.sendAll("玩法 1 通关！横墙 1 已摧毁")
        end
        -- 不销毁监听器，保持存活（已在函数开头检查已存在则返回）
        -- 如果需要在热重载时清理，调用 Layer4.destroyDeathListeners()
    end)
end

--|=============================================================
--[§2 怪物 ID 注册（用户提供的怪物列表）]
-- 注：nPo0 已作为玩法 4 的 BOSS 单独注册
--|=============================================================
Layer4.registeredMobIds = {
    "n8st", "ncE7", "n8b9", "n113", "n3pi", "nv16", "nn7s", "nlok", "n0m1", "ny5m",
    "nt13", "n2ra", "nGyP", "nyrv", "no3F", "n338", "n834", "nz21", "n0v0", "n134",
    "n37t", "nD46", "nT8J", "n01r", "nb8k", "n8c8", "n048", "ng0z", "n1io",
    "n35p", "nJm3", "nQ2P", "nr19", "nx92"
}

--|=============================================================
--[§2d: 玩法 4 BOSS 配置（nPo0）]
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
--[§2d: 玩法 4 BOSS 创建/销毁]
--|=============================================================
function Layer4.createPlay4Boss()
    if Layer4.play4Unit then return end

    local p = Player:new(4)
    if not p then return end
    local u = Unit:new(p, Layer4.play4Config.unitId, Layer4.play4Config.pos.x, Layer4.play4Config.pos.y, Layer4.play4Config.facing)
    if not u or not u._handle then return end

    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)
    u.state.defendWhite = u:getState(UNIT_STATE_DEFEND_WHITE)

    Layer4.play4Unit = u
end

function Layer4.destroyPlay4Boss()
    if not Layer4.play4Unit then return end
    pcall(function() Layer4.play4Unit:destroy() end)
    Layer4.play4Unit = nil
end

--|=============================================================
--[§2c: 玩法 3 已分离至 Layer4Play3.lua]
-- 用法：require("Layers.Layer4Play3")
--|=============================================================

--|=============================================================
--[§2d: 玩法 4 已分离至 Layer4Play4.lua]
-- 用法：require("Layers.Layer4Play4")
--|=============================================================

--|=============================================================
--[§2e: 玩法 4 Boss 死亡监听（在 Layer4Play4 中处理）
-- 用法：require("Layers.Layer4Play4")
--|=============================================================

--|=============================================================
--[§2 生命周期]
--|=============================================================
function Layer4.start()
    if Layer4.started then return end
    Layer4.started = true
    Layer4.finished = false
    Layer4.play1Triggered = false
    -- 玩法 2 已分离，此处不再初始化 play2 状态
    Layer4.destroyPlay2KeyListeners() -- 兜底清理旧监听（热重载）
    -- 初始化 mobSpawnRectsA（从 Layer3 复制，避免 nil 错误）
    if Layer3 and Layer3.mobSpawnRects then
        Layer4.mobSpawnRectsA = Layer3.mobSpawnRects
    end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
    Layer4.createWalls()
    if not Layer4.play1Unit then Layer4.createPlay1Boss() end
    -- 初始化玩法 2 监听器（玩家进入 A/B 区域触发）
    if Layer4Play2 then
        Layer4Play2.start()
    end
    -- Layer4Play2.initMobSpawnRectListeners(Layer4.mobSpawnRectsA, Layer4.mobSpawnRectsB)
    Layer4.ensureDeathListener()
    Layer4.ensureMobDeathListener()
    Layer4.ensurePlay2KeyListeners() -- 兼容调用，实际在 Layer4Play2 中实现
    -- 玩法 3 由玩法 2 开门后激活（见 Layer4Play2.onPlay2DoorOpen）
end

function Layer4.shutdown()
    if not Layer4.started and not Layer4.finished then
        -- 允许重复调用清理
    end
    Layer4.started = false
    Layer4.destroyPlay1Boss()
    -- 停止刷怪计时器（已在 Layer4Play2.shutdown 中处理）
    -- if Layer4.play2MobTimer then
    --     Layer4.play2MobTimer:stop()
    --     print("[Layer4] 停止刷怪计时器")
    --     Layer4.play2MobTimer = nil
    -- end
    -- -- 销毁所有刷怪单位（已在 Layer4Play2.shutdown 中处理）
    -- if #Layer4.play2MobHandles > 0 then
    --     print(string.format("[Layer4] §2b: 销毁 %d 个刷怪单位", #Layer4.play2MobHandles))
    --     for _, h in ipairs(Layer4.play2MobHandles) do
    --         if h then pcall(function() Unit.fromHandle(h):destroy() end) end
    --     end
    --     Layer4.play2MobHandles = {}
    -- end
    -- if Layer4.play2WallHandle then
    --     pcall(function() cj.RemoveDestructable(Layer4.play2WallHandle) end)
    --     print("[Layer4] 清理竖墙 1")
    --     Layer4.play2WallHandle = nil
    -- end
    -- Layer4.wallMap[4] = nil
    -- Layer4.play2EnteredPids = {}
    -- Layer4.play2Triggered = false
    -- Layer4Play2.destroyMobSpawnRectListeners()  -- 已在 Layer4Play2.shutdown() 中处理
    Layer4.destroyWalls()
    Layer4.play1Triggered = false
    -- 清理钥匙玩法监听/门区域（已在 Layer4Play2.shutdown 中处理）
    -- Layer4.destroyPlay2KeyListeners()
    -- -- 清理 play3（完整 shutdown，包括 BOSS 清理与监听）
    if Layer4Play3 then
        Layer4Play3.shutdown()
    end
    -- -- 清理玩法 2（已在 Layer4Play2.shutdown 中处理）
    if Layer4Play2 then
        Layer4Play2.shutdown()
    end
    -- -- 死亡监听不随关卡销毁（复用时 ensure 会重建），但此处清理 deathListener 便于热重载
    if Layer4.deathListener then pcall(function() Layer4.deathListener:destroy() end) Layer4.deathListener=nil end
end

--|=============================================================
--[销毁刷怪区监听器工具函数（供 Layer4Play2 使用）]
--|=============================================================
local function destroyMobSpawnRectListeners()
    if not Layer4.rectListeners then return end
    for key, ev in pairs(Layer4.rectListeners) do
        pcall(function() if ev and ev.destroy then ev:destroy() end end)
    end
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
--[§2b: 刷怪逻辑工具函数（供 Layer4Play2 使用）]
--|=============================================================

-- 启动刷怪计时器（间隔 1.5 秒，周期性刷怪）
function Layer4.startMobSpawnerTimer()
    -- 此函数已移至 Layer4Play2.startMobSpawnerTimer
end

-- 停止刷怪计时器
function Layer4.stopMobSpawnerTimer()
    -- 此函数已移至 Layer4Play2.stopMobSpawnerTimer
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
    -- 此函数已移至 Layer4Play2.spawnOneMob
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
    -- 此函数已移至 Layer4Play2.onMobDeath
end

-- 注册死亡监听
function Layer4.ensureMobDeathListener()
    if Layer4.mobDeathListener then return end
    Layer4.mobDeathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then return end
        local handle = ev.unit
        if not handle then return end
        -- 只处理本玩法刷出的怪（玩家英雄 / 各 BOSS 死亡交给各自的监听处理）
        -- play2MobHandles 已移至 Layer4Play2，此处不处理
        -- 保留此监听器以便兼容调用
        -- print("[Layer4] §2b: 刷怪死亡监听已注册（实际处理在 Layer4Play2 中）")
    end)
end

--|=============================================================
--[§2b-KEY: 钥匙掉落 / 持有检测 / 开门通关]
--|=============================================================
function Layer4.hasUnitKey(uHandle)
    if not uHandle then return false, nil end
    -- 使用 Layer4Play2 的 play2KeyConfig
    local keyId = c2i(Layer4Play2.play2KeyConfig.itemId)
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
    -- 此函数已移至 Layer4Play2.tryDropKeyAt
end

function Layer4.onPlay2DoorOpen(heroHandle, itemHandle)
    -- 此函数已移至 Layer4Play2.onPlay2DoorOpen
end

function Layer4.createPlay2KeyDoor()
    -- 此函数已移至 Layer4Play2.createPlay2KeyDoor
end

function Layer4.destroyPlay2KeyDoor()
    -- 此函数已移至 Layer4Play2.destroyPlay2KeyDoor
end

local function onKeyPickup(ev)
    local it = ev.item
    if not it then return end
    if cj.GetItemTypeId(it) ~= c2i(Layer4Play2.play2KeyConfig.itemId) then return end
    local hero = ev.unit
    if not hero then return end
    local owner = Player.fromHandle(cj.GetOwningPlayer(hero))
    local pname = owner and owner:getName() or "未知"
    if not pname or pname == "" then pname = string.format("玩家%d", owner and owner:getId() or 0) end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("%s 获得了钥匙！前往横墙 2 (-1289,3844) 开门通关！", pname), SystemMessage.COLOR_SUCCESS}}, 5.0)
    end
end

function Layer4.ensurePlay2KeyListeners()
    if Layer4.play2KeyPickupEvent then return end
    Layer4.createPlay2KeyDoor()
    local keyId = c2i(Layer4Play2.play2KeyConfig.itemId)
    if not keyId or keyId == 0 then return end
    Layer4.play2KeyPickupEvent = Event:new(nil, EVENT_PLAYER_UNIT_PICKUP_ITEM, onKeyPickup)
end

function Layer4.destroyPlay2KeyListeners()
    if Layer4.play2KeyPickupEvent then
        pcall(function() Layer4.play2KeyPickupEvent:destroy() end)
        Layer4.play2KeyPickupEvent = nil
    end
    Layer4.destroyPlay2KeyDoor()
end

--|=============================================================
--[§3 兼容别名]
--|=============================================================
Layer4EntryPos     = Layer4.entryPos
Layer4RevivePos    = Layer4.revivePos
Layer4TeleportPos  = Layer4.teleportPos
Layer4PotionShopPos= Layer4.potionShopPos

--|=============================================================
--[返回模块]
--|=============================================================
return Layer4
