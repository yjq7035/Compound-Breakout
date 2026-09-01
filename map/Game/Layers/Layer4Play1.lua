-- Layer4Play1.lua: 玩法 1 独立模块
-- 击杀 BOSS 后触发横墙 1 摧毁和通关事件
-- 用法：require("Layers.Layer4Play1")

local Play1 = {}

-- 配置
Play1.config = {
    unitId  = "n89f",
    pos     = { x = -8524.9, y = 3300.0 },
    facing  = 270,
    armor   = 100,
    hp      = 5000,
    magic   = 2000,  -- 魔法抗性 = 护甲值
    maxMana = 0,
}

-- 全局状态
Play1.unit       = nil
Play1.triggered  = false
Play1.deathListener = nil

-- 创建 BOSS
function Play1.createBoss()
    if Play1.unit then 
        print("[Layer4Play1] BOSS 已存在", Play1.unit:getTypeName())
        return 
    end

    local p = Player:new(4)
    
    local u = Unit:new(p, Play1.config.unitId, Play1.config.pos.x, Play1.config.pos.y, Play1.config.facing)
    if not u or not u._handle then 
        print("[Layer4Play1] Unit creation failed")
        return 
    end

    -- 设置属性：魔法抗性 = 护甲值
    u.state.magicAmp = Play1.config.magic or 2000
    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)

    Play1.unit = u
    print(string.format("[Layer4Play1] ✓ BOSS 创建：type=%s hp=%d armor=%d magic=%d", 
                        u:getType(), u:getLife(), u:getArmor(), u.state.magicAmp))
end

-- 销毁 BOSS
function Play1.destroyBoss()
    if not Play1.unit then 
        print("[Layer4Play1] BOSS 不存在，跳过销毁")
        return 
    end
    pcall(function() Play1.unit:destroy() end)
    print("[Layer4Play1] BOSS 已销毁")
    Play1.unit = nil
end

-- 确保死亡监听器存在
function Play1.ensureDeathListener()
    if Play1.deathListener then 
        print("[Layer4Play1] 死亡监听已存在，跳过注册")
        return 
    end

    print("[Layer4Play1] 注册死亡监听...")
    Play1.deathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if not Play1.triggered then
            print("[Layer4Play1] 死亡事件触发")
        end
        
        local dyingHandle = ev.unit
        if not dyingHandle then return end
        
        local okU, dyingUnit = pcall(Unit.fromHandle, dyingHandle)
        if not okU or not dyingUnit then 
            print("[Layer4Play1] 死亡监听：Unit.fromHandle 失败")
            return 
        end
        
        local okCode, typeCode = pcall(dyingUnit.getTypeCode, dyingUnit)
        if not okCode or typeCode ~= Play1.config.unitId then 
            print(string.format("[Layer4Play1] 死亡监听：跳过非 BOSS 类型=%s", tostring(typeCode)))
            return 
        end
        
        if not Play1.unit then 
            print("[Layer4Play1] 死亡监听：Play1.unit 不存在")
            return 
        end
        
        -- 第一次触发
        if not Play1.triggered then
            Play1.triggered = true
            print(string.format("[Layer4Play1] ✓ BOSS 死亡 type=%s", tostring(typeCode)))
            
            -- 销毁横墙 1
            local h = cj.GetDestructableFromId(1) -- 或者使用 Layer4.wallMap[1]
            if not h then 
                print("[Layer4Play1] 横墙 1 handle 缺失")
                return 
            end
            
            local wallCfg = { x = -8520.0, y = 3300.0 } -- 横墙 1 位置
            print(string.format("[Layer4Play1] 销毁横墙 1 at %.1f,%.1f", wallCfg.x, wallCfg.y))
            
            pcall(function() cj.RemoveDestructable(h) end)
            print("[Layer4Play1] 横墙 1 已销毁")
            
            -- 发送消息
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "玩法 1 通关！横墙 1 已摧毁！", SystemMessage.COLOR_SUCCESS}}, 5.0)
            else
                Player.sendAll("玩法 1 通关！横墙 1 已摧毁")
            end
            
            -- 销毁监听器（可选，如果需要）
            -- Play1.deathListener:destroy()
            -- Play1.deathListener = nil
        else
            print("[Layer4Play1] 死亡监听：已触发过，跳过处理")
        end
    end)
end

-- 销毁死亡监听器
function Play1.destroyDeathListener()
    if Play1.deathListener then
        print("[Layer4Play1] 销毁死亡监听器")
        Play1.deathListener:destroy()
        Play1.deathListener = nil
    end
end

-- 初始化
function Play1.start()
    Play1.createBoss()
    Play1.ensureDeathListener()
    print("[Layer4Play1] 玩法 1 初始化完成")
end

-- 重置
function Play1.reset()
    Play1.triggered = false
    Play1.destroyDeathListener()
    Play1.destroyBoss()
    print("[Layer4Play1] 玩法 1 已重置")
end

return Play1
