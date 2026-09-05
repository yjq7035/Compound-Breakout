--|=============================================================
-- Layer4Play3 — 关卡 4 玩法 3 独立模块
--|=============================================================
-- 职责：
--   1. §1d: play3 矩形区域定义与监听
--   2. §2d: 区域内可破坏物死亡 → 概率召唤玩法2随机怪物（HP+500/ATK+20 后×25%）
--   3. §2d: 概率出现隐藏BOSS（HP+1万/ATK+100/攻强+500/魔强+2000/护甲+150/魔抗+150）
--   4. 击杀隐藏BOSS 时玩法 3 通关
--|=============================================================

--|=============================================================
--[§1 坐标]
--|=============================================================
Layer4Play3 = {
    __index = function(t, k)
        local v = rawget(t, k)
        if v ~= nil then return v end
        return nil
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
}

Layer4Play3.entryPos     = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4Play3.revivePos    = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4Play3.teleportPos  = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4Play3.potionShopPos= { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
--[§1d: play3 矩形区域定义]
--|=============================================================
-- 左下角：-15497.8,565.2 右上角：-12546.1,3765.5
Layer4Play3.play3NewRegion = {
    minx = -15497.8, miny = 565.2, maxx = -12546.1, maxy = 3765.5,
    name = "play3 新区域（左下角：-15497.8,565.2 右上角：-12546.1,3765.5）",
}

--|=============================================================
--[§1d: play3 新区域初始化 / 销毁]
--|=============================================================
function Layer4Play3.initPlay3NewRegion()
    if Layer4Play3.play3NewRegionRect then return end
    local cfg = Layer4Play3.play3NewRegion
    Layer4Play3.play3NewRegionRect = Rect:new(cfg.minx, cfg.miny, cfg.maxx, cfg.maxy)
    print(string.format("[Layer4Play3] §1d: play3 新区域已创建 (min: %.1f,%.1f max: %.1f,%.1f)",
          cfg.minx, cfg.miny, cfg.maxx, cfg.maxy))
end

function Layer4Play3.destroyPlay3NewRegion()
    if Layer4Play3.play3NewRegionRect then
        pcall(function() Layer4Play3.play3NewRegionRect:destroy() end)
        Layer4Play3.play3NewRegionRect = nil
    end
end

--|=============================================================
--[§2d: 玩法 3 配置]
--|=============================================================
Layer4Play3.play3Config = {
    spawnChance  = 50,   -- 可破坏物死亡召唤普通怪概率（%）
    bossChance   = 10,   -- 出现隐藏BOSS概率（%）
    bossHp       = 10000,-- 隐藏BOSS 额外生命
    bossAtk      = 100,  -- 隐藏BOSS 额外攻击
    bossAtkStr   = 500,  -- 攻击强化（每1000=+100%）
    bossMagAmp   = 2000, -- 魔法强化（每1000=+100%）
    bossArmor    = 150,  -- 护甲
    bossResMag   = 150,  -- 魔法抗性
}
Layer4Play3.finished  = false   -- 玩法 3 是否通关
Layer4Play3.bossUnit  = nil     -- 隐藏BOSS 单位

--|=============================================================
--[§2d: 召唤怪物]
-- @param x,y      死亡位置
-- @param isBoss   是否隐藏BOSS（额外属性加成）
--|=============================================================
function Layer4Play3.spawnMonster(x, y, isBoss)
    local mobId = Layer4.getRandomMobId()
    if not mobId then return end
    local p = Player:new(4)
    if not p then return end
    local u = Unit:new(p, mobId, x, y, 270)
    if not u or not u._handle then return end
    -- 生命 +500、攻击 +20 后 ×25%
    u:addState(UNIT_STATE_LIFE, 500):addState(UNIT_STATE_ATTACK_WHITE, 20)
    u:addState(UNIT_STATE_LIFE, -math.floor(u:getState(UNIT_STATE_LIFE) * 0.75))
    u:addState(UNIT_STATE_ATTACK_WHITE, -math.floor(u:getState(UNIT_STATE_ATTACK_WHITE) * 0.75))
    if isBoss then
        local cfg = Layer4Play3.play3Config
        u:addState(UNIT_STATE_LIFE, cfg.bossHp)
        u:addState(UNIT_STATE_ATTACK_WHITE, cfg.bossAtk)
        u:addState(UNIT_STATE_DEFEND_WHITE, cfg.bossArmor)
        u.state.attackStr = (u.state.attackStr or 0) + cfg.bossAtkStr
        u.state.magicAmp  = (u.state.magicAmp  or 0) + cfg.bossMagAmp
        u.state.resMag    = (u.state.resMag    or 0) + cfg.bossResMag
        Layer4Play3.bossUnit = u
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "隐藏BOSS 出现！", SystemMessage.COLOR_WARN}}, 4.0)
        else
            Player.sendAll("隐藏BOSS 出现！")
        end
    end
    print(string.format("[Layer4Play3] §2d: 召唤%s %s @%.1f,%.1f",
          isBoss and "隐藏BOSS" or "普通怪", mobId, x, y))
end

--|=============================================================
--[§2d: 监听区域内可破坏物死亡]
--|=============================================================
function Layer4Play3.initPlay3NewRegionDeathListener()
    if Layer4Play3.play3DeathTrigger then return end
    Layer4Play3.play3DeathTrigger = Destroyable.EnumDestructablesInRect(Layer4Play3.play3NewRegionRect, function(d)
        local d = Destroyable.fromHandle(cj.GetTriggerDestructable())
        local x, y = d:getX(), d:getY()
        local cfg = Layer4Play3.play3Config
        local r = math.random(1, 100)
        if r <= cfg.bossChance then
            Layer4Play3.spawnMonster(x, y, true)   -- 隐藏BOSS
        elseif r <= cfg.bossChance + cfg.spawnChance then
            Layer4Play3.spawnMonster(x, y, false)  -- 普通怪
        end
    end)
    print("[Layer4Play3] §2d-DEATH: play3 新区域死亡可破坏物监听已注册")
end

function Layer4Play3.destroyPlay3NewRegionDeathListener()
    if play3DeathTrigger then
        pcall(function() play3DeathTrigger:destroy() end)
        play3DeathTrigger = nil
    end
end

--|=============================================================
--[§2d: 监听隐藏BOSS死亡 → 通关]
--|=============================================================
function Layer4Play3.initPlay3BossDeathListener()
    if Layer4Play3.play3BossDeathEvent then return end
    Layer4Play3.play3BossDeathEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        local u = Layer4Play3.bossUnit
        if not u or not ev.unit then return end
        local ok, dead = pcall(Unit.fromHandle, ev.unit)
        if not ok or dead ~= u then return end
        Layer4Play3.bossUnit = nil
        if Layer4Play3.finished then return end
        Layer4Play3.finished = true
        print("[Layer4Play3] §2d: 隐藏BOSS 被击杀，玩法 3 通关！")
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "隐藏BOSS 已击杀，玩法 3 通关！", SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            Player.sendAll("隐藏BOSS 已击杀，玩法 3 通关！")
        end
    end)
end

function Layer4Play3.destroyPlay3BossDeathListener()
    if Layer4Play3.play3BossDeathEvent then
        pcall(function() Layer4Play3.play3BossDeathEvent:destroy() end)
        Layer4Play3.play3BossDeathEvent = nil
    end
end

--|=============================================================
--[§2d: 清理隐藏BOSS单位]
--|=============================================================
function Layer4Play3.destroyPlay3Boss()
    if Layer4Play3.bossUnit then
        pcall(function() Layer4Play3.bossUnit:destroy() end)
        Layer4Play3.bossUnit = nil
    end
end

--|=============================================================
--[§2d: 创建死亡可破坏物]
-- @param x,y      可破坏物坐标
-- @param typeId   可破坏物类型（四字符码或整数）
-- @param facing   面向角度
-- @param scale    缩放比例
--|=============================================================
function Layer4Play3.createDeadDestructable(x, y, typeId, facing, scale)
    if type(typeId) == "string" then typeId = c2i(typeId) end
    local h = cj.CreateDeadDestructable(typeId, x, y, facing or 0, scale or 1, 0)
    if not h then return nil end
    local d = Destroyable.fromHandle(h)
    if not d then return nil end
    return d
end

--|=============================================================
--[§2 生命周期]
--|=============================================================
function Layer4Play3.start()
    if Layer4Play3.started then return end
    Layer4Play3.started = true
    Layer4Play3.finished = false
    Layer4Play3.bossUnit = nil
    Layer4Play3.initPlay3NewRegion()
    Layer4Play3.initPlay3NewRegionDeathListener()
    Layer4Play3.initPlay3BossDeathListener()
    print("[Layer4Play3] 玩法 3 已启动")
end

function Layer4Play3.shutdown()
    Layer4Play3.started = false
    Layer4Play3.destroyPlay3Boss()
    Layer4Play3.destroyPlay3NewRegionDeathListener()
    Layer4Play3.destroyPlay3BossDeathListener()
    Layer4Play3.destroyPlay3NewRegion()
    print("[Layer4Play3] 关闭")
end

--|=============================================================
--[§3 兼容别名]
--|=============================================================
Layer4Play3EntryPos     = Layer4Play3.entryPos
Layer4Play3RevivePos    = Layer4Play3.revivePos
Layer4Play3TeleportPos  = Layer4Play3.teleportPos
Layer4Play3PotionShopPos= Layer4Play3.potionShopPos

return Layer4Play3
