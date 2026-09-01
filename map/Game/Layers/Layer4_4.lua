--|=============================================================
-- 4_4 — 玩法 4 专属模块（独立文件）
--|
-- 职责：
--   1. 存放玩法 4 刷怪点配置
--   2. 提供玩法 4 刷怪逻辑
--|=============================================================

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
function Layer4_4.spawnMobAtPoint(mobId, pointId)
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
    
    -- 创建单位
    local u = Unit:new(nil, mobId, point.x, point.y, 270)
    if u and u._handle then
        -- 添加到句柄列表
        table.insert(Layer4_4.mobHandles, u._handle)
        print(string.format("[4_4] 在刷怪点%d (%.1f,%.1f) 创建怪物 %s", 
            pointId, point.x, point.y, mobId))
        
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
