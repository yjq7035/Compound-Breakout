--|=============================================================
-- Layer4Play3 — 关卡 4 玩法 3 独立模块
--|=============================================================
-- 职责：
--   1. §2d: 玩法 3 BOSS 创建和销毁
--   2. play3 新区域定义
--   3. play3 新区域死亡事件监听
--|=============================================================

--|=============================================================
--[常量] 魔法强化换算（与 GameDamage.lua 保持一致）
--|=============================================================
local MAGICAMP_TO_PCT = 1000

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

--|=============================================================
--[§1 坐标]
--|=============================================================
Layer4Play3.entryPos     = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4Play3.revivePos    = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4Play3.teleportPos  = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4Play3.potionShopPos= { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
--[§1d: play3 新区域定义]
--|=============================================================
-- 左下角：-15497.8,565.2 右上角：-12546.1,3765.5
--|=============================================================
Layer4Play3.play3NewRegion = {
    minx = -15497.8, miny = 565.2, maxx = -12546.1, maxy = 3765.5,
    name = "play3 新区域（左下角：-15497.8,565.2 右上角：-12546.1,3765.5）",
}

--|=============================================================
--[§1d: play3 新区域初始化]
--|=============================================================
-- 创建 Rect 对象和触发器
--|=============================================================
function Layer4Play3.initPlay3NewRegion()
    if Layer4Play3.play3NewRegionRect then return end
    print("[Layer4Play3] §1d: 创建 play3 新区域 Rect 和触发器...")
    
    Layer4Play3.play3NewRegionRect = Rect:new(Layer4Play3.play3NewRegion.minx, Layer4Play3.play3NewRegion.miny, 
                                         Layer4Play3.play3NewRegion.maxx, Layer4Play3.play3NewRegion.maxy)
    
    local rid = "play3NewRegion"
    local ev = Event:newRect(Layer4Play3.play3NewRegionRect, function(ev)
        if Layer4Play3.finished then return end
        local u = ev.unit or cj.GetEnteringUnit()
        if not u then return end
        local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(u))
        if not okOwner or not owner or not owner.isUser or not owner:isUser() then return end
        if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end
        if owner:getId() < 0 or owner:getId() > 3 then return end
        
        print(string.format("[Layer4Play3] §1d: 玩家%d 英雄进入 play3 新区域", owner:getId()))
    end)
    Layer4Play3.play3NewRegionEvent = ev
    
    print(string.format("[Layer4Play3] §1d: play3 新区域监听已注册 (min: %.1f,%.1f max: %.1f,%.1f)", 
                      Layer4Play3.play3NewRegion.minx, Layer4Play3.play3NewRegion.miny, 
                      Layer4Play3.play3NewRegion.maxx, Layer4Play3.play3NewRegion.maxy))
end

function Layer4Play3.destroyPlay3NewRegion()
    if Layer4Play3.play3NewRegionRect then
        pcall(function() Layer4Play3.play3NewRegionRect:destroy() end)
        Layer4Play3.play3NewRegionRect = nil
    end
    if Layer4Play3.play3NewRegionEvent then
        pcall(function() Layer4Play3.play3NewRegionEvent:destroy() end)
        Layer4Play3.play3NewRegionEvent = nil
    end
end

--|=============================================================
-- 监听区域内可破坏物死亡事件，输出死亡信息
--|=============================================================
function Layer4Play3.initPlay3NewRegionDeathListener()
    if Layer4Play3.play3NewRegionDeathEvent then return end
    print("[Layer4Play3] §1d-DEATH: 注册 play3 新区域死亡监听...")
    
    Layer4Play3.play3NewRegionDeathEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4Play3.finished then return end
        
        local handle = ev.unit
        if not handle then return end
        
        -- 检查死亡单位是否属于可破坏物类型
        local typeId = cj.GetDestructableTypeId(handle)
        if typeId == 0 then return end -- 非可破坏物
        
        -- 检查是否在 play3 新区域内
        local dx, dy = cj.GetUnitX(handle), cj.GetUnitY(handle)
        if not dx or not dy then return end
        
        local x, y = tonumber(dx), tonumber(dy)
        local minX, minY, maxX, maxY = Layer4Play3.play3NewRegion.minx, Layer4Play3.play3NewRegion.miny, 
                                      Layer4Play3.play3NewRegion.maxx, Layer4Play3.play3NewRegion.maxy
        
        if x >= minX and x <= maxX and y >= minY and y <= maxY then
            -- 获取可破坏物 ID
            local destructableId = cj.GetDestructableId(handle)
            local destructableName = cj.GetDestructableTypeString(destructableId) or cj.GetDestructableTypeIdString(handle)
            
            print(string.format("[Layer4Play3] §1d-DEATH: play3 新区域内可破坏物死亡 - ID: %s, Name: %s, Type: %d, Pos: %.1f,%.1f", 
                              destructableId, destructableName or "未知", typeId, x, y))
            
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", string.format("play3 新区域：%s 死亡！ID:%s", destructableName or "可破坏物", destructableId), SystemMessage.COLOR_WARN}}, 3.0)
            else
                Player.sendAll(string.format("play3 新区域：%s 死亡！ID:%s", destructableName or "可破坏物", destructableId))
            end
            
            -- 尝试刷新 BOSS（在死亡时调用）
            Layer4Play3.createPlay3Boss()
        end
    end)
    
    Layer4Play3.play3NewRegionRect = Rect:new(Layer4Play3.play3NewRegion.minx, Layer4Play3.play3NewRegion.miny, 
                                         Layer4Play3.play3NewRegion.maxx, Layer4Play3.play3NewRegion.maxy)
    print(string.format("[Layer4Play3] §1d-DEATH: play3 新区域监听已注册 (min: %.1f,%.1f max: %.1f,%.1f)", 
                      Layer4Play3.play3NewRegion.minx, Layer4Play3.play3NewRegion.miny, 
                      Layer4Play3.play3NewRegion.maxx, Layer4Play3.play3NewRegion.maxy))
end

function Layer4Play3.destroyPlay3NewRegionDeathListener()
    if Layer4Play3.play3NewRegionDeathEvent then
        pcall(function() Layer4Play3.play3NewRegionDeathEvent:destroy() end)
        Layer4Play3.play3NewRegionDeathEvent = nil
    end
    if Layer4Play3.play3NewRegionRect then
        pcall(function() Layer4Play3.play3NewRegionRect:destroy() end)
        Layer4Play3.play3NewRegionRect = nil
    end
end

--|=============================================================
--[§2d: 玩法 3 BOSS 配置（nPo0）]
--|=============================================================
Layer4Play3.play3Config = {
    pos     = { x = -8524.9, y = 3300.0 },
    unitId  = "nPo0",
    facing  = 270,
    armor   = 100,      -- 高护甲
    hp      = 7500,     -- 高生命
    magic   = 0,        -- 无魔法强化
    maxMana = 0,
}
Layer4Play3.play3Unit      = nil
Layer4Play3.play3BossSpawnCount = 0     -- BOSS 刷新次数
Layer4Play3.play3BossMaxSpawn = 1        -- 最大刷新次数（只刷新一次）
Layer4Play3.play3Finished = false       -- 玩法 3 是否通关

--|=============================================================
--[§2d: 玩法 3 BOSS 创建]
--|=============================================================
function Layer4Play3.createPlay3Boss()
    if Layer4Play3.play3Unit then print("[Layer4Play3] §2d: 玩法 3 BOSS 已存在") return end
    
    -- 检查是否已经通关，不再刷新 BOSS
    if Layer4Play3.play3Finished then return end
    
    -- 检查是否已经达到最大刷新次数
    if Layer4Play3.play3BossSpawnCount >= Layer4Play3.play3BossMaxSpawn then
        print("[Layer4Play3] §2d: 已达到最大 BOSS 刷新次数，不再刷新")
        return
    end
    
    -- 概率刷新（这里设置为 100% 概率刷新，可以在这里改为概率值）
    local shouldSpawn = true -- 直接设置为 true，或者改为 math.random(1, 100) >= 50 等概率判断
    if not shouldSpawn then
        print("[Layer4Play3] §2d: 概率未触发，不刷新 BOSS")
        return
    end
    
    print(string.format("[Layer4Play3] §2d: 刷新 BOSS 第 %d/%d 次", Layer4Play3.play3BossSpawnCount + 1, Layer4Play3.play3BossMaxSpawn))
    
    local p = Player:new(4) -- 固定为玩家 4
    if not p then print("[Layer4Play3] §2d: Player 4 nil") return end
    
    local u = Unit:new(p, Layer4Play3.play3Config.unitId, Layer4Play3.play3Config.pos.x, 
                       Layer4Play3.play3Config.pos.y, Layer4Play3.play3Config.facing)
    if not u or not u._handle then return end
    
    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)
    u.state.defendWhite = u:getState(UNIT_STATE_DEFEND_WHITE)
    
    Layer4Play3.play3Unit = u
    Layer4Play3.play3BossSpawnCount = Layer4Play3.play3BossSpawnCount + 1
end

--|=============================================================
--[§2d: 玩法 3 BOSS 销毁]
--|=============================================================
function Layer4Play3.destroyPlay3Boss()
    if not Layer4Play3.play3Unit then return end
    
    -- 检查是否已经通关，避免重复触发
    if Layer4Play3.play3Finished then
        print("[Layer4Play3] §2d: 玩法 3 已经通关，跳过通关逻辑")
        return
    end
    
    -- 销毁 BOSS
    pcall(function() Layer4Play3.play3Unit:destroy() end)
    
    -- 通关逻辑
    Layer4Play3.play3Finished = true
    print("[Layer4Play3] §2d: 玩法 3 通关！")
    
    -- 发送通关消息
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "play3 通关！击杀 BOSS 完成所有挑战！", SystemMessage.COLOR_SUCCESS}}, 5.0)
    else
        Player.sendAll("play3 通关！击杀 BOSS 完成所有挑战！")
    end
    
    -- 重置 BOSS 单位，允许下次刷新（如果需要）
    Layer4Play3.play3Unit = nil
end

--|=============================================================
--[§2 生命周期]
--|=============================================================
function Layer4Play3.start()
    if Layer4Play3.started then print("[Layer4Play3] 已启动跳过") return end
    
    Layer4Play3.started = true
    Layer4Play3.finished = false
    
    -- 创建 play3 新区域
    Layer4Play3.initPlay3NewRegion()
    Layer4Play3.initPlay3NewRegionDeathListener()
    
    -- 创建 BOSS
    Layer4Play3.createPlay3Boss()
    
    print("[Layer4Play3] 玩法 3 已启动")
end

function Layer4Play3.shutdown()
    if not Layer4Play3.started and not Layer4Play3.finished then
        -- 允许重复调用清理
    end
    Layer4Play3.started = false
    
    -- 销毁 BOSS
    Layer4Play3.destroyPlay3Boss()
    
    -- 清理死亡监听
    Layer4Play3.destroyPlay3NewRegionDeathListener()
    
    print("[Layer4Play3] 关闭")
end

--|=============================================================
--[§3 兼容别名]
--|=============================================================
Layer4Play3EntryPos     = Layer4Play3.entryPos
Layer4Play3RevivePos    = Layer4Play3.revivePos
Layer4Play3TeleportPos  = Layer4Play3.teleportPos
Layer4Play3PotionShopPos= Layer4Play3.potionShopPos

--|=============================================================
--[返回模块]
--|=============================================================
return Layer4Play3
