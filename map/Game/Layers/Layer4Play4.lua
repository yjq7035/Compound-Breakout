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
Layer4_4.bossArea = {
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

Layer4_4 = {}
Layer4_4.__index = Layer4_4

-- 刷怪点列表
Layer4_4.spawnPoints = {
    { id = 1,  x = -12226.5, y = 596.6 },
    { id = 2,  x = -10609.0, y = 728.3 },
    { id = 3,  x = -9229.6,  y = 663.2 },
    { id = 4,  x = -9361.2,  y = 2051.5 },
    { id = 5,  x = -9263.0,  y = 3564.5 },
    { id = 6,  x = -10751.2, y = 3482.7 },
    { id = 7,  x = -11984.2, y = 3393.0 },
}

-- 当前激活的刷怪点索引（1-7）
Layer4_4.activeSpawnIndex = 1

-- 已使用的刷怪点集合（记录已触发过的刷怪点）
Layer4_4.usedSpawnPoints = {}

-- 当前在刷怪的单位列表
Layer4_4.mobHandles = {}

-- 是否已初始化
Layer4_4.initialized = false

-- ============================================================
-- §0b: 玩法 4 Boss 战斗配置
-- ============================================================
Layer4_4.bossConfig = {
    unitId    = "n89f",      -- Boss 单位类型
    pos       = { x = -10657.7, y = 1965.5 },  -- Boss 初始坐标（区域中心）
    facing    = 270,
    armor     = 150,         -- Boss 护甲
    hp        = 20000,       -- Boss 生命值
    magic     = 5000,        -- Boss 魔抗
    atk       = 500,         -- Boss 基础攻击
    atkStr    = 2000,        -- Boss 攻强
    magAmp    = 1000,        -- Boss 魔强
    finished  = false        -- 玩法 4 是否通关
}

Layer4_4.bossUnit     = nil       -- Boss 单位
Layer4_4.bossEvent    = nil       -- Boss 死亡监听器
Layer4_4.bossAreaRect = nil       -- Boss 区域矩形

-- ============================================================
-- §2: 刷怪点管理函数
-- ============================================================

-- 获取当前激活的刷怪点坐标
function Layer4_4.getCurrentSpawnPos()
    if not Layer4_4.initialized then return nil end
    local idx = Layer4_4.activeSpawnIndex
    if idx > #Layer4_4.spawnPoints then idx = 1 end
    return Layer4_4.spawnPoints[idx]
end

-- 切换到下一个刷怪点
function Layer4_4.nextSpawnPoint()
    if not Layer4_4.initialized then return end
    Layer4_4.activeSpawnIndex = Layer4_4.activeSpawnIndex + 1
    if Layer4_4.activeSpawnIndex > #Layer4_4.spawnPoints then
        Layer4_4.activeSpawnIndex = 1
    end
    print(string.format("[4_4] 切换到刷怪点 %d: %.1f,%.1f", 
        Layer4_4.activeSpawnIndex, 
        Layer4_4.spawnPoints[Layer4_4.activeSpawnIndex].x, 
        Layer4_4.spawnPoints[Layer4_4.activeSpawnIndex].y))
end

-- 标记刷怪点为已使用
function Layer4_4.markSpawnPointUsed(pointId)
    Layer4_4.usedSpawnPoints[pointId] = true
end

-- 检查刷怪点是否已使用
function Layer4_4.isSpawnPointUsed(pointId)
    return Layer4_4.usedSpawnPoints[pointId] or false
end

-- 获取下一个可用的刷怪点
function Layer4_4.getNextAvailableSpawnPoint()
    if not Layer4_4.initialized then return nil end
    
    -- 优先返回未使用过的刷怪点
    for _, point in ipairs(Layer4_4.spawnPoints) do
        if not Layer4_4.usedSpawnPoints[point.id] then
            return point
        end
    end
    
    -- 所有刷怪点都已使用，按顺序循环
    local idx = Layer4_4.activeSpawnIndex
    if idx > #Layer4_4.spawnPoints then idx = 1 end
    return Layer4_4.spawnPoints[idx]
end

-- 重置刷怪点状态
function Layer4_4.resetSpawnPoints()
    Layer4_4.activeSpawnIndex = 1
    Layer4_4.usedSpawnPoints = {}
    print("[4_4] 刷怪点状态已重置")
end

-- ============================================================
-- §3: 刷怪管理函数
-- ============================================================

-- 在指定刷怪点创建怪物
function Layer4_4.spawnMobAtPoint(mobId, pointId, mobLevel)
    if not Layer4_4.initialized then
        print("[4_4] 警告：玩法 4 未初始化，无法刷怪")
        return nil
    end

    local point = Layer4_4.spawnPoints[pointId]
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
        table.insert(Layer4_4.mobHandles, u._handle)
        print(string.format("[4_4] 在刷怪点%d (%.1f,%.1f) 创建怪物 %s [等级=%d, 生命+=%d, 攻击+=%d, 护甲+=%d, 魔抗+=%d]",
            pointId, point.x, point.y, mobId, mobLevel, bonusLife, bonusAtk, bonusArmor, bonusResMag))

        -- 标记该刷怪点为已使用
        Layer4_4.markSpawnPointUsed(pointId)

        return u
    else
        print(string.format("[4_4] 创建怪物失败 %s", mobId))
        return nil
    end
end

-- 在下一个可用刷怪点创建怪物
function Layer4_4.spawnNextMob(mobId)
    local point = Layer4_4.getNextAvailableSpawnPoint()
    if not point then
        print("[4_4] 没有可用的刷怪点")
        return nil
    end

    return Layer4_4.spawnMobAtPoint(mobId, point.id)
end

-- 从玩法2怪物列表随机抽取6-9个单位，并在所有刷怪点批量创建
function Layer4_4.batchSpawnAtAllPoints()
    if not Layer4_4.initialized then
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

    for i, point in ipairs(Layer4_4.spawnPoints) do
        -- 从 selectedMobs 循环取值
        local mobId = selectedMobs[(i - 1) % #selectedMobs + 1]
        local level = i % 3 + 1 -- 等级 1-3，每3个刷怪点循环一次

        for j = 1, unitsPerPoint do
            local u = Layer4_4.spawnMobAtPoint(mobId, point.id, level)
            if u then
                spawnedCount = spawnedCount + 1
            end
        end
    end

    print(string.format("[4_4] 批量刷怪完成，共创建 %d 个单位", spawnedCount))
end

-- 获取当前刷怪点数量
function Layer4_4.getSpawnPointCount()
    return #Layer4_4.spawnPoints
end

-- 获取已激活的刷怪点数量
function Layer4_4.getActiveSpawnPointCount()
    local count = 0
    for _, point in ipairs(Layer4_4.spawnPoints) do
        if Layer4_4.usedSpawnPoints[point.id] then
            count = count + 1
        end
    end
    return count
end

-- 销毁所有刷怪单位
function Layer4_4.destroyAllMobs()
    if #Layer4_4.mobHandles == 0 then return end
    
    print(string.format("[4_4] 销毁 %d 个刷怪单位", #Layer4_4.mobHandles))
    
    for _, h in ipairs(Layer4_4.mobHandles) do
        if h then
            pcall(function()
                local u = Unit.fromHandle(h)
                if u then u:destroy() end
            end)
        end
    end
    
    Layer4_4.mobHandles = {}
end

-- 从刷怪列表中移除指定单位
function Layer4_4.removeMobFromList(handle)
    for i, h in ipairs(Layer4_4.mobHandles) do
        if h == handle then
            table.remove(Layer4_4.mobHandles, i)
            break
        end
    end
end

-- 检查是否有空刷怪点
function Layer4_4.hasEmptySpawnPoint()
    if not Layer4_4.initialized then return false end
    
    for _, point in ipairs(Layer4_4.spawnPoints) do
        if not Layer4_4.usedSpawnPoints[point.id] then
            return true
        end
    end
    
    return false
end

-- 初始化玩法 4
function Layer4_4.init()
    if Layer4_4.initialized then
        print("[4_4] 玩法 4 已初始化，跳过")
        return
    end

    Layer4_4.initialized = true
    print("[4_4] 玩法 4 初始化完成")
    print(string.format("[4_4] 共 %d 个刷怪点:", #Layer4_4.spawnPoints))
    for _, point in ipairs(Layer4_4.spawnPoints) do
        print(string.format("  - 刷怪点 %d: (%.1f, %.1f)",
            point.id, point.x, point.y))
    end
end

-- ============================================================
-- §0c: Boss 战斗逻辑函数
-- ============================================================

-- 创建 Boss
function Layer4_4.createBoss()
    if Layer4_4.bossUnit then
        print("[4_4] Boss 已存在，跳过创建")
        return
    end

    local p = Player:new(4)
    local cfg = Layer4_4.bossConfig

    local u = Unit:new(p, cfg.unitId, cfg.pos.x, cfg.pos.y, cfg.facing)
    if not u or not u._handle then
        print("[4_4] Boss 创建失败")
        return
    end

    -- 设置 Boss 属性
    u:addState(UNIT_STATE_LIFE, cfg.hp)
    u:addState(UNIT_STATE_ATTACK_WHITE, cfg.atk)
    u:addState(UNIT_STATE_DEFEND_WHITE, cfg.armor)
    u:addState(UNIT_STATE_DEFEND_WHITE, cfg.magic)
    u.state.attackStr = (u.state.attackStr or 0) + cfg.atkStr
    u.state.magicAmp  = (u.state.magicAmp  or 0) + cfg.magAmp

    Layer4_4.bossUnit = u
    print(string.format("[4_4] ✓ Boss 创建：type=%s hp=%d armor=%d atk=%d atkStr=%d magAmp=%d",
                        u:getType(), u:getLife(), u:getArmor(),
                        u:getAttack(), u.state.attackStr, u.state.magicAmp))
end

-- 销毁 Boss
function Layer4_4.destroyBoss()
    if not Layer4_4.bossUnit then
        print("[4_4] Boss 不存在，跳过销毁")
        return
    end
    pcall(function() Layer4_4.bossUnit:destroy() end)
    print("[4_4] Boss 已销毁")
    Layer4_4.bossUnit = nil
end

-- 初始化 Boss 区域矩形
function Layer4_4.initBossArea()
    if Layer4_4.bossAreaRect then
        print("[4_4] Boss 区域已创建，跳过")
        return
    end

    local cfg = Layer4_4.bossArea[1]
    Layer4_4.bossAreaRect = Rect:new(cfg.minx, cfg.miny, cfg.maxx, cfg.maxy)
    print(string.format("[4_4] Boss 区域已创建：(min: %.1f,%.1f max: %.1f,%.1f)",
          cfg.minx, cfg.miny, cfg.maxx, cfg.maxy))
end

-- 销毁 Boss 区域矩形
function Layer4_4.destroyBossArea()
    if Layer4_4.bossAreaRect then
        pcall(function() Layer4_4.bossAreaRect:destroy() end)
        Layer4_4.bossAreaRect = nil
        print("[4_4] Boss 区域已销毁")
    end
end

-- 初始化 Boss 死亡监听
function Layer4_4.initBossDeathListener()
    if Layer4_4.bossEvent then
        print("[4_4] Boss 死亡监听已存在，跳过")
        return
    end

    print("[4_4] 注册 Boss 死亡监听...")
    Layer4_4.bossEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4_4.bossConfig.finished then return end

        local dyingHandle = ev.unit
        if not dyingHandle then return end

        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if not okU or not dyingUnit then return end

        local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
        if not okCode or typeCode ~= Layer4_4.bossConfig.unitId then
            return
        end

        if not Layer4_4.bossUnit then return end

        if not Layer4_4.bossConfig.finished then
            Layer4_4.bossConfig.finished = true
            print(string.format("[4_4] ✓ Boss 死亡 type=%s", tostring(typeCode)))

            -- 玩法 4 通关：销毁 Boss，移除横墙 3，发送消息，清理资源
            Layer4_4.destroyBoss()

            -- 移除横墙 3（玩法 4 通关门）
            local wallIdx = 3
            local h = Layer4.wallMap[wallIdx]
            if h then
                pcall(cj.RemoveDestructable, h)
                Layer4.wallMap[wallIdx] = nil
                for i, handle in ipairs(Layer4.handles) do if handle == h then table.remove(Layer4.handles, i) break end end
                print(string.format("[4_4] 横墙 3 已移除"))
            end

            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "Boss 已击杀！门已开启，关卡 4 通关！请尽快到门口集合！", SystemMessage.COLOR_SUCCESS}}, 5.0)
            else
                Player.sendAll("Boss 已击杀！门已开启，关卡 4 通关！请尽快到门口集合")
            end

            Layer4_4.destroyBossEvent()
        end
    end)
end

-- 销毁 Boss 死亡监听
function Layer4_4.destroyBossEvent()
    if Layer4_4.bossEvent then
        pcall(function() Layer4_4.bossEvent:destroy() end)
        Layer4_4.bossEvent = nil
    end
end

-- 初始化 Boss 战斗系统
function Layer4_4.initBossSystem()
    Layer4_4.createBoss()
    Layer4_4.initBossArea()
    Layer4_4.initBossDeathListener()
    print("[4_4] Boss 战斗系统初始化完成")
end

-- 清理 Boss 战斗系统
function Layer4_4.cleanupBossSystem()
    Layer4_4.bossConfig.finished = false
    Layer4_4.destroyBossEvent()
    Layer4_4.destroyBoss()
    Layer4_4.destroyBossArea()
    print("[4_4] Boss 战斗系统清理完成")
end

-- 清理玩法 4
function Layer4_4.cleanup()
    Layer4_4.initialized = false
    Layer4_4.destroyAllMobs()
    Layer4_4.resetSpawnPoints()
    print("[4_4] 玩法 4 清理完成")
end

-- 获取刷怪点配置（供外部调用）
function Layer4_4.getSpawnPointConfig()
    return Layer4_4.spawnPoints
end

-- 获取当前激活刷怪点
function Layer4_4.getActiveSpawnConfig()
    return Layer4_4.getCurrentSpawnPos()
end

return Layer4_4
