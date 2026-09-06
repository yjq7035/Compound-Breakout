--|=============================================================
-- 4_4 — 玩法 4 专属模块（独立文件）
--|
-- 职责：
--   1. 存放玩法 4 刷怪点配置
--   2. 提供玩法 4 刷怪逻辑
--|=============================================================

-- ============================================================
-- §0: 玩法 4 Boss 区域配置
-- ============================================================
-- Boss 战斗区域：左下角 -11107.3, 1447.1 右上角 -10208.0, 2483.8
Layer4Play4 = {}
Layer4Play4.bossArea = {
    { id = "4_boss", minx = -11107.3, miny = 1447.1, maxx = -10208.0, maxy = 2483.8, name = "玩法 4 Boss 战斗区域" }
}

-- ============================================================
-- §1: 刷怪点坐标配置
-- ============================================================
-- -1 号刷怪坐标：-12226.5, 596.6
-- -2 号刷怪坐标：-10609.0, 728.3
-- -3 号刷怪坐标：-9229.6, 663.2
-- -4 号刷怪坐标：-9361.2, 2051.5
-- -5 号刷怪坐标：-9263, 3564.5
-- -6 号刷怪坐标：-10751.2, 3482.7
-- -7 号刷怪坐标：-11984.2, 3393.0

Layer4Play4.__index = Layer4Play4

-- 刷怪点列表
Layer4Play4.spawnPoints = {
    { id = 1,  x = -12226.5, y = 596.6 },
    { id = 2,  x = -10609.0, y = 728.3 },
    { id = 3,  x = -9229.6,  y = 663.2 },
    { id = 4,  x = -9361.2,  y = 2051.5 },
    { id = 5,  x = -9263.0,  y = 3564.5 },
    { id = 6,  x = -10751.2, y = 3482.7 },
    { id = 7,  x = -11984.2, y = 3393.0 },
}

-- 当前激活的刷怪点索引（1-7）
Layer4Play4.activeSpawnIndex = 1

-- 已使用的刷怪点集合（记录已触发过的刷怪点）
Layer4Play4.usedSpawnPoints = {}

-- 当前在刷怪的单位列表
Layer4Play4.mobHandles = {}

-- 是否已初始化
Layer4Play4.initialized = false

-- ============================================================
-- §0b: 玩法 4 Boss 战斗配置
-- ============================================================
Layer4Play4.bossConfig = {
    unitId    = "na6m",      -- Boss 单位类型（最终Boss）
    pos       = { x = -10657.7, y = 1965.5 },  -- Boss 初始坐标（区域中心）
    facing    = 270,
    hp        = 50000,       -- Boss 生命值
    magic     = 20000,       -- Boss 魔法值
    atk       = 350,         -- Boss 基础攻击
    armor     = 125,         -- Boss 基础防御
    resMag    = 125,         -- Boss 魔法抗性
    atkStr    = 350,         -- Boss 攻击强化
    magAmp    = 1500,        -- Boss 魔法强化
    lifeRegen = 5,           -- Boss 生命恢复
    finished  = false        -- 玩法 4 是否通关
}

Layer4Play4.bossUnit     = nil       -- Boss 单位
Layer4Play4.bossEvent    = nil       -- Boss 死亡监听器
Layer4Play4.bossAreaRect = nil       -- Boss 区域矩形
Layer4Play4.bossActivated = false    -- Boss 战是否已激活

-- ============================================================
-- §2: 刷怪点管理函数
-- ============================================================

-- 获取当前激活的刷怪点坐标
function Layer4Play4.getCurrentSpawnPos()
    if not Layer4Play4.initialized then return nil end
    local idx = Layer4Play4.activeSpawnIndex
    if idx > #Layer4Play4.spawnPoints then idx = 1 end
    return Layer4Play4.spawnPoints[idx]
end

-- 切换到下一个刷怪点
function Layer4Play4.nextSpawnPoint()
    if not Layer4Play4.initialized then return end
    Layer4Play4.activeSpawnIndex = Layer4Play4.activeSpawnIndex + 1
    if Layer4Play4.activeSpawnIndex > #Layer4Play4.spawnPoints then
        Layer4Play4.activeSpawnIndex = 1
    end
    print(string.format("[4_4] 切换到刷怪点 %d: %.1f,%.1f", 
        Layer4Play4.activeSpawnIndex, 
        Layer4Play4.spawnPoints[Layer4Play4.activeSpawnIndex].x, 
        Layer4Play4.spawnPoints[Layer4Play4.activeSpawnIndex].y))
end

-- 标记刷怪点为已使用
function Layer4Play4.markSpawnPointUsed(pointId)
    Layer4Play4.usedSpawnPoints[pointId] = true
end

-- 检查刷怪点是否已使用
function Layer4Play4.isSpawnPointUsed(pointId)
    return Layer4Play4.usedSpawnPoints[pointId] or false
end

-- 获取下一个可用的刷怪点
function Layer4Play4.getNextAvailableSpawnPoint()
    if not Layer4Play4.initialized then return nil end
    
    -- 优先返回未使用过的刷怪点
    for _, point in ipairs(Layer4Play4.spawnPoints) do
        if not Layer4Play4.usedSpawnPoints[point.id] then
            return point
        end
    end
    
    -- 所有刷怪点都已使用，按顺序循环
    local idx = Layer4Play4.activeSpawnIndex
    if idx > #Layer4Play4.spawnPoints then idx = 1 end
    return Layer4Play4.spawnPoints[idx]
end

-- 重置刷怪点状态
function Layer4Play4.resetSpawnPoints()
    Layer4Play4.activeSpawnIndex = 1
    Layer4Play4.usedSpawnPoints = {}
    print("[4_4] 刷怪点状态已重置")
end

-- ============================================================
-- §3: 刷怪管理函数
-- ============================================================

-- 在指定刷怪点创建怪物
function Layer4Play4.spawnMobAtPoint(mobId, pointId, mobLevel)
    if not Layer4Play4.initialized then
        print("[4_4] 警告：玩法 4 未初始化，无法刷怪")
        return nil
    end

    local point = Layer4Play4.spawnPoints[pointId]
    if not point then
        print(string.format("[4_4] 刷怪点 %d 不存在", pointId))
        return nil
    end

    -- 检查位置高度，大于 1 不创建
    local height = cdz.DzGetTerrainZ(point.x, point.y) or 0
    if height > 1 then
        print(string.format("[4_4] 位置 %.1f,%.1f 高度 %.1f > 1，跳过创建", point.x, point.y, height))
        return nil
    end

    -- 计算属性：500*等级 生命值、5*等级 攻击力、15*等级 护甲和魔法抗性
    if not mobLevel or mobLevel < 1 then mobLevel = 1 end
    local bonusLife = 500 * mobLevel
    local bonusAtk = 5 * mobLevel
    local bonusArmor = 15 * mobLevel
    local bonusResMag = 15 * mobLevel

    -- 创建单位
    local u = Unit:new(nil, mobId, point.x, point.y, 270)
    if u and u._handle then
        -- 添加基础状态
        u:addState(UNIT_STATE_LIFE, bonusLife)
        u:addState(UNIT_STATE_ATTACK_WHITE, bonusAtk)
        u:addState(UNIT_STATE_DEFEND_WHITE, bonusArmor)
        u:addState(UNIT_STATE_DEFEND_WHITE, bonusResMag)

        -- 添加到句柄列表
        table.insert(Layer4Play4.mobHandles, u._handle)
        print(string.format("[4_4] 在刷怪点%d (%.1f,%.1f) 创建怪物 %s [等级=%d, 生命+=%d, 攻击+=%d, 护甲+=%d, 魔抗+=%d]",
            pointId, point.x, point.y, mobId, mobLevel, bonusLife, bonusAtk, bonusArmor, bonusResMag))

        -- 标记该刷怪点为已使用
        Layer4Play4.markSpawnPointUsed(pointId)

        return u
    else
        print(string.format("[4_4] 创建怪物失败 %s", mobId))
        return nil
    end
end

-- 在下一个可用刷怪点创建怪物
function Layer4Play4.spawnNextMob(mobId)
    local point = Layer4Play4.getNextAvailableSpawnPoint()
    if not point then
        print("[4_4] 没有可用的刷怪点")
        return nil
    end

    return Layer4Play4.spawnMobAtPoint(mobId, point.id)
end

-- 从玩法2怪物列表随机抽取6-9个单位，并在所有刷怪点批量创建
function Layer4Play4.batchSpawnAtAllPoints()
    if not Layer4Play4.initialized then
        print("[4_4] 警告：玩法 4 未初始化，无法刷怪")
        return
    end

    -- 从 Layer4.registeredMobIds 随机抽取6-9个单位
    local mobList = Layer4.registeredMobIds
    if not mobList or #mobList == 0 then
        print("[4_4] 警告：没有可用的怪物列表")
        return
    end

    -- 随机抽取数量 6-9
    local count = math.random(6, 9)
    local selectedMobs = {}

    -- 洗牌算法：Fisher-Yates shuffle
    local shuffled = {}
    for i = 1, #mobList do
        shuffled[i] = mobList[i]
    end
    for i = #shuffled, 2, -1 do
        local j = math.random(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    -- 取前 count 个
    for i = 1, math.min(count, #shuffled) do
        table.insert(selectedMobs, shuffled[i])
    end

    print(string.format("[4_4] 从玩法2列表随机抽取 %d 个怪物：", #selectedMobs))
    for i, mobId in ipairs(selectedMobs) do
        print(string.format("  [%d] %s", i, mobId))
    end

    -- 在所有刷怪点批量创建（每个刷怪点6-9个单位）
    local unitsPerPoint = math.random(6, 9)
    local spawnedCount = 0

    for i, point in ipairs(Layer4Play4.spawnPoints) do
        -- 从 selectedMobs 循环取值
        local mobId = selectedMobs[(i - 1) % #selectedMobs + 1]
        local level = i % 3 + 1 -- 等级 1-3，每3个刷怪点循环一次

        for j = 1, unitsPerPoint do
            local u = Layer4Play4.spawnMobAtPoint(mobId, point.id, level)
            if u then
                spawnedCount = spawnedCount + 1
            end
        end
    end

    print(string.format("[4_4] 批量刷怪完成，共创建 %d 个单位", spawnedCount))
end

-- 获取当前刷怪点数量
function Layer4Play4.getSpawnPointCount()
    return #Layer4Play4.spawnPoints
end

-- 获取已激活的刷怪点数量
function Layer4Play4.getActiveSpawnPointCount()
    local count = 0
    for _, point in ipairs(Layer4Play4.spawnPoints) do
        if Layer4Play4.usedSpawnPoints[point.id] then
            count = count + 1
        end
    end
    return count
end

-- 销毁所有刷怪单位
function Layer4Play4.destroyAllMobs()
    if #Layer4Play4.mobHandles == 0 then return end
    
    print(string.format("[4_4] 销毁 %d 个刷怪单位", #Layer4Play4.mobHandles))
    
    for _, h in ipairs(Layer4Play4.mobHandles) do
        if h then
            pcall(function()
                local u = Unit.fromHandle(h)
                if u then u:destroy() end
            end)
        end
    end
    
    Layer4Play4.mobHandles = {}
end

-- 从刷怪列表中移除指定单位
function Layer4Play4.removeMobFromList(handle)
    for i, h in ipairs(Layer4Play4.mobHandles) do
        if h == handle then
            table.remove(Layer4Play4.mobHandles, i)
            break
        end
    end
end

-- 检查是否有空刷怪点
function Layer4Play4.hasEmptySpawnPoint()
    if not Layer4Play4.initialized then return false end
    
    for _, point in ipairs(Layer4Play4.spawnPoints) do
        if not Layer4Play4.usedSpawnPoints[point.id] then
            return true
        end
    end
    
    return false
end

-- 初始化玩法 4
function Layer4Play4.init()
    if Layer4Play4.initialized then
        print("[4_4] 玩法 4 已初始化，跳过")
        return
    end

    Layer4Play4.initialized = true
    print("[4_4] 玩法 4 初始化完成")
    print(string.format("[4_4] 共 %d 个刷怪点:", #Layer4Play4.spawnPoints))
    for _, point in ipairs(Layer4Play4.spawnPoints) do
        print(string.format("  - 刷怪点 %d: (%.1f, %.1f)",
            point.id, point.x, point.y))
    end
end

-- ============================================================
-- §0c: Boss 战斗逻辑函数
-- ============================================================

-- 创建 Boss
function Layer4Play4.createBoss()
    if Layer4Play4.bossUnit then
        print("[4_4] Boss 已存在，跳过创建")
        return
    end

    local p = Player:new(4)
    local cfg = Layer4Play4.bossConfig

    local u = Unit:new(p, cfg.unitId, cfg.pos.x, cfg.pos.y, cfg.facing)
    if not u or not u._handle then
        print("[4_4] Boss 创建失败")
        return
    end

    -- 设置 Boss 属性
    u:addState(UNIT_STATE_LIFE, cfg.hp)
    u:addState(UNIT_STATE_ATTACK_WHITE, cfg.atk)
    u:addState(UNIT_STATE_DEFEND_WHITE, cfg.armor)
    u:addState(UNIT_STATE_DEFEND_WHITE, cfg.resMag)
    u:addState(UNIT_STATE_MANA, cfg.magic)
    u.state.attackStr = (u.state.attackStr or 0) + cfg.atkStr
    u.state.magicAmp  = (u.state.magicAmp  or 0) + cfg.magAmp
    u.state.lifeRegen = (u.state.lifeRegen or 0) + cfg.lifeRegen

    Layer4Play4.bossUnit = u
    print(string.format("[4_4] ✓ Boss 创建：type=%s hp=%d mana=%d armor=%d resMag=%d atk=%d atkStr=%d magAmp=%d regen=%d",
                        u:getType(), u:getLife(), u:getMana() or 0, u:getArmor(),
                        u.state.resMag or 0, u:getAttack(), u.state.attackStr, u.state.magicAmp, u.state.lifeRegen or 0))
end

-- 销毁 Boss
function Layer4Play4.destroyBoss()
    if not Layer4Play4.bossUnit then
        print("[4_4] Boss 不存在，跳过销毁")
        return
    end
    pcall(function() Layer4Play4.bossUnit:destroy() end)
    print("[4_4] Boss 已销毁")
    Layer4Play4.bossUnit = nil
end

-- 初始化 Boss 区域矩形
function Layer4Play4.initBossArea()
    if Layer4Play4.bossAreaRect then
        print("[4_4] Boss 区域已创建，跳过")
        return
    end

    local cfg = Layer4Play4.bossArea[1]
    Layer4Play4.bossAreaRect = Rect:new(cfg.minx, cfg.miny, cfg.maxx, cfg.maxy)
    print(string.format("[4_4] Boss 区域已创建：(min: %.1f,%.1f max: %.1f,%.1f)",
          cfg.minx, cfg.miny, cfg.maxx, cfg.maxy))
end

-- 检测所有玩家是否已进入 Boss 区域，如果是则激活 Boss 战
function Layer4Play4.checkAndActivateBoss()
    if Layer4Play4.bossActivated then return end

    local activePlayers = {}
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p and p:isUser() and p:isPlaying() then
            table.insert(activePlayers, p)
        end
    end

    if #activePlayers == 0 then return end

    -- 检查所有玩家英雄是否在 Boss 区域内
    local cfg = Layer4Play4.bossArea[1]
    local allEntered = true

    for _, p in ipairs(activePlayers) do
        local entered = false
        local g = Group:new()
        g:enumPlayer(p._handle)
        g:forEach(function(handle)
            local u = Unit.fromHandle(handle)
            if u then
                local ux, uy = u:getX(), u:getY()
                if ux and uy then
                    if ux >= cfg.minx and ux <= cfg.maxx and uy >= cfg.miny and uy <= cfg.maxy then
                        entered = true
                    end
                end
            end
        end)
        if not entered then
            allEntered = false
        end
    end

    -- 所有玩家进入 Boss 区域，激活 Boss 战
    if allEntered then
        print("[4_4] 所有玩家已进入 Boss 区域，激活 Boss 战！")
        Layer4Play4.bossActivated = true

        -- 创建 Boss
        Layer4Play4.createBoss()

        -- 激活 Boss 战：创建竖墙 3（index=6）作为关门
        local wall6 = Layer4.wallMap[6]
        if wall6 then
            -- 竖墙3已存在（从map中获取handle），激活显示
            print("[4_4] ✓ 竖墙 3 已激活")
        else
            -- 竖墙3不存在，创建它
            local wallTypeId = c2i("DL84") or 0
            if wallTypeId > 0 then
                local wallPos = { index = 6, x = -11647.0, y = 2867.7, id = "DL84", dir = "V", face = 0 }
                local h = cj.CreateDestructable(wallTypeId, wallPos.x, wallPos.y, wallPos.face, 1, 0)
                if h then
                    Layer4.wallMap[6] = h
                    table.insert(Layer4.handles, h)
                    print(string.format("[4_4] ✓ 竖墙 3 已创建 @ %.1f,%.1f", wallPos.x, wallPos.y))
                else
                    print(string.format("[4_4] ✗ 竖墙 3 创建失败 @ %.1f,%.1f", wallPos.x, wallPos.y))
                end
            else
                print("[4_4] 竖墙类型 DL84 无效")
            end
        end

        -- 发送系统消息
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "⚠️ Boss 战激活！所有玩家已进入战斗区域！", SystemMessage.COLOR_WARN}}, 5.0)
        else
            Player.sendAll("⚠️ Boss 战激活！所有玩家已进入战斗区域！")
        end
    end
end

-- 监听玩家进入 Boss 区域
function Layer4Play4.initBossEnterListener()
    if Layer4Play4.bossEnterEvent then
        print("[4_4] Boss 进入监听已存在，跳过")
        return
    end

    Layer4Play4.initBossArea()

    Layer4Play4.bossEnterEvent = Event:newRect(Layer4Play4.bossAreaRect, function(ev)
        if Layer4Play4.bossActivated then return end

        local u = ev._unit or ev.unit or cj.GetEnteringUnit()
        if not u then return end
        if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end

        local owner = Player.fromHandle(cj.GetOwningPlayer(u))
        if not owner or not owner:isUser() then return end

        Layer4Play4.checkAndActivateBoss()
    end)

    print("[4_4] Boss 进入监听已注册")
end

-- 销毁 Boss 进入监听
function Layer4Play4.destroyBossEnterListener()
    if Layer4Play4.bossEnterEvent then
        pcall(function() Layer4Play4.bossEnterEvent:destroy() end)
        Layer4Play4.bossEnterEvent = nil
    end
end

-- 销毁 Boss 区域矩形
function Layer4Play4.destroyBossArea()
    if Layer4Play4.bossAreaRect then
        pcall(function() Layer4Play4.bossAreaRect:destroy() end)
        Layer4Play4.bossAreaRect = nil
        print("[4_4] Boss 区域已销毁")
    end
end

-- 初始化 Boss 死亡监听
function Layer4Play4.initBossDeathListener()
    if Layer4Play4.bossEvent then
        print("[4_4] Boss 死亡监听已存在，跳过")
        return
    end

    print("[4_4] 注册 Boss 死亡监听...")
    Layer4Play4.bossEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4Play4.bossConfig.finished then return end

        local dyingHandle = ev.unit
        if not dyingHandle then return end

        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if not okU or not dyingUnit then return end

        local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
        if not okCode or typeCode ~= Layer4Play4.bossConfig.unitId then
            return
        end

        if not Layer4Play4.bossUnit then return end

        if not Layer4Play4.bossConfig.finished then
            Layer4Play4.bossConfig.finished = true
            print(string.format("[4_4] ✓ Boss 死亡 type=%s", tostring(typeCode)))

            -- 玩法 4 通关：销毁 Boss，销毁竖墙 3，发送消息，清理资源
            Layer4Play4.destroyBoss()

            -- 销毁竖墙 3（index=6）
            local wall6 = Layer4.wallMap[6]
            if wall6 then
                pcall(cj.RemoveDestructable, wall6)
                Layer4.wallMap[6] = nil
                for i, handle in ipairs(Layer4.handles) do 
                    if handle == wall6 then 
                        table.remove(Layer4.handles, i) 
                        break 
                    end 
                end
                print("[4_4] 竖墙 3 已销毁")
            end

            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "Boss 已击杀！门已开启，关卡 4 通关！请尽快到门口集合！", SystemMessage.COLOR_SUCCESS}}, 5.0)
            else
                Player.sendAll("Boss 已击杀！门已开启，关卡 4 通关！请尽快到门口集合")
            end

            Layer4Play4.destroyBossEvent()
        end
    end)

    -- 注册英雄死亡监听，检测团灭
    Layer4Play4.initHeroDeathListener()
end

-- 监听英雄死亡，检测团灭
function Layer4Play4.initHeroDeathListener()
    if Layer4Play4.heroDeathListener then return end

    Layer4Play4.heroDeathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if not Layer4Play4.bossActivated then return end
        if Layer4Play4.bossConfig.finished then return end

        local dyingHandle = ev.unit
        if not dyingHandle then return end
        if not cj.IsUnitType(dyingHandle, UNIT_TYPE_HERO) then return end

        local owner = Player.fromHandle(cj.GetOwningPlayer(dyingHandle))
        if not owner or not owner:isUser() then return end

        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end

        -- 记录玩家英雄死亡
        if not Layer4Play4.deadHeroes then
            Layer4Play4.deadHeroes = {}
        end
        Layer4Play4.deadHeroes[pid] = true

        -- 检查是否所有玩家英雄都已死亡
        local activePlayers = {}
        for pid2 = 0, 3 do
            local p = Player:new(pid2)
            if p and p:isUser() and p:isPlaying() then
                table.insert(activePlayers, pid2)
            end
        end

        local allDead = true
        for _, pid2 in ipairs(activePlayers) do
            if not Layer4Play4.deadHeroes[pid2] then
                allDead = false
                break
            end
        end

        -- 团灭：所有玩家英雄死亡
        if allDead and #activePlayers > 0 then
            print("[4_4] 所有玩家英雄死亡，团灭！")
            Layer4Play4.onAllPlayersDied()
        end
    end)
end

-- 团灭处理
function Layer4Play4.onAllPlayersDied()
    if Layer4Play4.bossConfig.finished then return end

    -- 广播团灭消息
    local msg = "💀 团灭！所有玩家英雄死亡，Boss 战失败！"
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", msg, SystemMessage.COLOR_FAIL}}, 5.0)
    else
        Player.sendAll(msg)
    end

    -- 销毁 Boss 和竖墙 3
    Layer4Play4.destroyBoss()
    local wall6 = Layer4.wallMap[6]
    if wall6 then
        pcall(cj.RemoveDestructable, wall6)
        Layer4.wallMap[6] = nil
        for i, handle in ipairs(Layer4.handles) do 
            if handle == wall6 then 
                table.remove(Layer4.handles, i) 
                break 
            end 
        end
        print("[4_4] 团灭：竖墙 3 已销毁")
    end

    -- 重置 Boss 战状态
    Layer4Play4.bossActivated = false
    Layer4Play4.bossUnit = nil
    Layer4Play4.bossConfig.finished = false
    Layer4Play4.deadHeroes = {}

    -- 关闭所有玩家英雄，然后在关卡4复活点复活
    local onlinePlayers = GameInit and GameInit.getOnlinePlayers() or {}
    for _, player in ipairs(onlinePlayers) do
        if player and player:isPlaying() then
            pcall(function() 
                if player.closeGame then 
                    player.closeGame(true) 
                end
            end)
        end
    end

    -- 等待1秒后重新加载关卡4（在关卡4复活点复活）
    Timer:new(1, false, function()
        if GameInit and GameInit.currentLayer == 4 then
            -- 关闭所有玩家的英雄，等待重生
            local onlinePlayers2 = GameInit and GameInit.getOnlinePlayers() or {}
            for _, player in ipairs(onlinePlayers2) do
                if player and player:isPlaying() then
                    pcall(function() 
                        if player.closeGame then 
                            player.closeGame(true) 
                        end
                    end)
                end
            end
            
            -- 重新加载关卡 4（会重置所有状态并在复活点复活）
            Timer:new(1, false, function()
                if GameInit and GameInit.startLayer4 then
                    GameInit.startLayer4()
                end
            end)
        end
    end)

    -- 销毁英雄死亡监听
    Layer4Play4.destroyHeroDeathListener()
end

-- 销毁英雄死亡监听
function Layer4Play4.destroyHeroDeathListener()
    if Layer4Play4.heroDeathListener then
        pcall(function() Layer4Play4.heroDeathListener:destroy() end)
        Layer4Play4.heroDeathListener = nil
    end
end

-- 销毁 Boss 死亡监听
function Layer4Play4.destroyBossEvent()
    if Layer4Play4.bossEvent then
        pcall(function() Layer4Play4.bossEvent:destroy() end)
        Layer4Play4.bossEvent = nil
    end
end

-- 初始化 Boss 战斗系统
function Layer4Play4.initBossSystem()
    Layer4Play4.initBossArea()
    Layer4Play4.initBossEnterListener()
    Layer4Play4.initBossDeathListener()
    print("[4_4] Boss 战斗系统初始化完成")
end

-- 清理 Boss 战斗系统
function Layer4Play4.cleanupBossSystem()
    Layer4Play4.bossConfig.finished = false
    Layer4Play4.bossActivated = false
    Layer4Play4.destroyBossEnterListener()
    Layer4Play4.destroyBossEvent()
    Layer4Play4.destroyHeroDeathListener()
    Layer4Play4.destroyBoss()
    -- 销毁竖墙 3（index=6）
    local wall6 = Layer4.wallMap[6]
    if wall6 then
        pcall(cj.RemoveDestructable, wall6)
        Layer4.wallMap[6] = nil
        for i, handle in ipairs(Layer4.handles) do 
            if handle == wall6 then 
                table.remove(Layer4.handles, i) 
                break 
            end 
        end
    end
    Layer4Play4.destroyBossArea()
    Layer4Play4.deadHeroes = {}
    print("[4_4] Boss 战斗系统清理完成")
end

-- 清理玩法 4
function Layer4Play4.cleanup()
    Layer4Play4.initialized = false
    Layer4Play4.destroyAllMobs()
    Layer4Play4.resetSpawnPoints()
    -- 销毁 Boss 战竖墙 3（如果存在）
    if Layer4Play4.bossActivated then
        local wall6 = Layer4.wallMap[6]
        if wall6 then
            pcall(cj.RemoveDestructable, wall6)
            Layer4.wallMap[6] = nil
            for i, handle in ipairs(Layer4.handles) do 
                if handle == wall6 then 
                    table.remove(Layer4.handles, i) 
                    break 
                end 
            end
        end
        Layer4Play4.bossActivated = false
    end
    print("[4_4] 玩法 4 清理完成")
end

-- 获取刷怪点配置（供外部调用）
function Layer4Play4.getSpawnPointConfig()
    return Layer4Play4.spawnPoints
end

-- 获取当前激活刷怪点
function Layer4Play4.getActiveSpawnConfig()
    return Layer4Play4.getCurrentSpawnPos()
end

return Layer4Play4
