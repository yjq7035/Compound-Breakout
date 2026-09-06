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
-- 已死亡的可破坏物 handle -> bool（用于统计数量实现动态概率）
Layer4Play3.destroyedDestructables = {}
-- 所有已注册的触发器 handle 列表（用于清理）
Layer4Play3.__registeredTrigs = {}

-- 为单个可破坏物注册死亡事件（一次性，触发后需重新注册）
local function registerOneDestructable(d)
    if not d or not d._handle then return end
    local trig = cj.CreateTrigger()
    table.insert(Layer4Play3.__registeredTrigs, trig)
    d:registerDeathEvent(trig)
    cj.TriggerAddAction(trig, function()
        -- 标记为已死亡
        Layer4Play3.destroyedDestructables[d] = true
        local x, y = d:getX(), d:getY()
        
        -- 统计已死亡数量
        local totalDestructables = 0
        for _ in pairs(Layer4Play3.destroyedDestructables) do
            totalDestructables = totalDestructables + 1
        end
        
        -- 计算动态概率：随着已死亡数量增加，隐藏BOSS概率逐渐提升
        local cfg = Layer4Play3.play3Config
        local maxDeaths = cfg.maxDestructables or 20  -- 默认最大可破坏物数量
        local lastChance = cfg.lastBossChance or 100  -- 最后一个保底概率
        
        local bossChance
        if totalDestructables >= maxDeaths then
            -- 最后一个，必定出隐藏BOSS
            bossChance = lastChance
        elseif totalDestructables >= maxDeaths - 3 then
            -- 最后几个，轻微提升概率
            bossChance = cfg.bossChance + 20 + (totalDestructables - (maxDeaths - 3)) * 10
        else
            -- 前期低概率
            bossChance = math.max(cfg.bossChance, 3)
        end
        
        local roll = math.random(1, 100)
        if roll <= bossChance then
            Layer4Play3.spawnMonster(x, y, true)   -- 隐藏BOSS
        elseif roll <= bossChance + cfg.spawnChance then
            Layer4Play3.spawnMonster(x, y, false)  -- 普通怪
        end
        
        -- 重新注册该可破坏物的死亡事件
        registerOneDestructable(d)
    end)
end

function Layer4Play3.initPlay3NewRegion()
    if Layer4Play3.play3NewRegionRect then return end
    local cfg = Layer4Play3.play3NewRegion
    Layer4Play3.play3NewRegionRect = Rect:new(cfg.minx, cfg.miny, cfg.maxx, cfg.maxy)
    
    -- 重置已死亡可破坏物记录
    Layer4Play3.destroyedDestructables = {}

    print("[Layer4Play3] §2d: 监听区域内可破坏物死亡")
    local destructables = Destroyable.EnumDestructablesInRect(Layer4Play3.play3NewRegionRect, function(rect, d) return true end)
    
    -- 统计总数用于动态概率
    local count = #destructables
    if count > 0 then
        Layer4Play3.play3Config.maxDestructables = count
    end
    
    -- 为每个可破坏物单独注册死亡事件
    for _, d in ipairs(destructables) do
        registerOneDestructable(d)
    end

end

function Layer4Play3.destroyPlay3NewRegion()
    -- 清理所有已注册的事件
    if Layer4Play3.__registeredTrigs then
        for _, trig in ipairs(Layer4Play3.__registeredTrigs) do
            pcall(function() cj.DestroyTrigger(trig) end)
        end
        Layer4Play3.__registeredTrigs = {}
    end
    if Layer4Play3.play3NewRegionRect then
        pcall(function() Layer4Play3.play3NewRegionRect:destroy() end)
        Layer4Play3.play3NewRegionRect = nil
    end
    Layer4Play3.destroyedDestructables = {}
end

--|=============================================================
--[§2d: 玩法 3 配置]
--|=============================================================
Layer4Play3.play3Config = {
    spawnChance      = 50,   -- 可破坏物死亡召唤普通怪概率（%）
    bossChance       = 5,    -- 出现隐藏BOSS基础概率（%）— 前期低概率
    lastBossChance   = 100,  -- 最后一个可破坏物死亡时隐藏BOSS概率（%）— 保底必出
    maxDestructables = 20,   -- 最大可破坏物数量（用于计算动态概率）
    bossHp           = 10000,-- 隐藏BOSS 额外生命
    bossAtk          = 100,  -- 隐藏BOSS 额外攻击
    bossAtkStr       = 500,  -- 攻击强化（每1000=+100%）
    bossMagAmp       = 2000, -- 魔法强化（每1000=+100%）
    bossArmor        = 150,  -- 护甲
    bossResMag       = 150,  -- 魔法抗性
}
Layer4Play3.finished  = false   -- 玩法 3 是否通关
Layer4Play3.bossUnit  = nil     -- 隐藏BOSS 单位

--|=============================================================
--[§2d: 召唤怪物]
-- @param x,y      死亡位置
-- @param isBoss   是否隐藏BOSS（额外属性加成）
--|=============================================================
function Layer4Play3.spawnMonster(x, y, isBoss)
    -- 通关后不再召唤怪物
    if Layer4Play3.finished then return end
    
    local mobId = Layer4.getRandomMobId()
    if not mobId then return end
    local p = Player:new(4)
    if not p then return end
    local u = Unit:new(p, mobId, x, y, 270)
    if not u or not u._handle then return end
    
    -- 生命 +500、攻击 +20（先调整最大生命，再调整当前生命）
    u:addState(UNIT_STATE_MAX_LIFE, 500 * u:getLevel())
    u:addState(UNIT_STATE_LIFE, 500 * u:getLevel())
    u:addState(UNIT_STATE_ATTACK_WHITE, 20 * u:getLevel())
    -- 当前生命也要加上500（与最大生命保持一致）
    
    
    if isBoss then
        local cfg = Layer4Play3.play3Config
        u:addState(UNIT_STATE_MAX_LIFE, cfg.bossHp)
        u:addState(UNIT_STATE_LIFE, cfg.bossHp)
        u:addState(UNIT_STATE_ATTACK_WHITE, cfg.bossAtk)
        u:addState(UNIT_STATE_DEFEND_WHITE, cfg.bossArmor)
        u.state.attackStr = (u.state.attackStr or 0) + cfg.bossAtkStr
        u.state.magicAmp  = (u.state.magicAmp  or 0) + cfg.bossMagAmp
        u.state.resMag    = (u.state.resMag    or 0) + cfg.bossResMag
        u.state.penPhys   = (u.state.penPhys   or 0) + 100  -- 物理穿透 +100
        u.state.penMag    = (u.state.penMag    or 0) + 100  -- 魔法穿透 +100
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

function Layer4Play3.destroyPlay3NewRegionDeathListener()
    if Layer4Play3.play3DeathListener then
        -- 批量取消死亡事件注册
        local listener = Layer4Play3.play3DeathListener
        if listener.events then
            local destructibles = {}
            local trigs = {}
            for d, ev in pairs(listener.events) do
                table.insert(destructibles, d)
                table.insert(trigs, listener.trigger)
            end
            Destroyable.batchUnregisterDeathEvent(destructibles, trigs)
        end
        -- 销毁触发器
        pcall(function() cj.DestroyTrigger(listener.trigger) end)
        Layer4Play3.play3DeathListener = nil
    end
end

--|=============================================================
--[§2d: 监听隐藏BOSS死亡 → 通关]
--|=============================================================
function Layer4Play3.initPlay3BossDeathListener()
    if Layer4Play3.play3BossDeathEvent then return end
    Layer4Play3.play3BossDeathEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if not ev.unit then return end
        -- 改用 handle 比较，避免 Unit 对象引用不同导致比较失败
        if ev.unit ~= (Layer4Play3.bossUnit and Layer4Play3.bossUnit._handle) then return end
        if Layer4Play3.finished then return end
        Layer4Play3.finished = true
        Layer4Play3.bossUnit = nil
        print("[Layer4Play3] §2d: 隐藏BOSS 被击杀，玩法 3 通关！")
        
        -- 销毁竖墙3（index=6）
        if Layer4 and Layer4.destroyVerticalWallForPlay3 then
            Layer4.destroyVerticalWallForPlay3()
        end
        
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "隐藏BOSS 已击杀，玩法 3 通关！竖墙已销毁！", SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            Player.sendAll("隐藏BOSS 已击杀，玩法 3 通关！竖墙已销毁！")
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
    -- 创建竖墙3（index=6），与玩法3绑定
    if Layer4 and Layer4.createVerticalWallForPlay3 then
        Layer4.createVerticalWallForPlay3()
    end
    Layer4Play3.initPlay3NewRegion()
    -- Layer4Play3.initPlay3NewRegionDeathListener()
    Layer4Play3.initPlay3BossDeathListener()
    print("[Layer4Play3] 玩法 3 已启动")
end

function Layer4Play3.shutdown()
    Layer4Play3.started = false
    Layer4Play3.destroyPlay3Boss()
    -- 销毁竖墙3（index=6），与玩法3绑定
    if Layer4 and Layer4.destroyVerticalWallForPlay3 then
        Layer4.destroyVerticalWallForPlay3()
    end
    -- Layer4Play3.destroyPlay3NewRegionDeathListener()
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
