--|=============================================================
-- Layer4 — 第四关卡模块
--|
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡 3 通关后传送至此）
--
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. §1b: 创建墙体
--   3. §1c: 矩形区域定义（A/B 刷怪区，C 通关区）
--   4. §2a: 玩法系统（玩法 1：魔法强化怪物 + 击杀检测）
--|=============================================================

Layer4 = {}
Layer4.__index = Layer4

--|=============================================================
-- §1 坐标
--|=============================================================

Layer4.entryPos    = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4.revivePos   = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4.teleportPos = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4.potionShopPos = { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
-- §1c: 矩形区域定义
-- A、B：刷怪矩形区域配置（中心点 + 宽高），C：通关区域（边角坐标）
Layer4.mobSpawnRectsA = {
    { id = "A", cx = -13020.15, cy = 5888.8, width = 4959.9, height = 3636.2, name = "矩形 A 刷怪区域" },
}
Layer4.mobSpawnRectsB = {
    { id = "B", cx = -9302.4, cy = 6552.7, width = 2223.0, height = 2262.4, name = "矩形 B 刷怪区域" },
}
Layer4.finishAreaC   = {
    { id = "C", minx = -10234.0, miny = 4894.7, maxx = -9815.9, maxy = 5127.0, name = "矩形 C 通关区域" },
}

--|=============================================================
-- §1b: 墙体定义与运行时（横墙 B000, 竖墙 DL84）
--|=============================================================

Layer4.WALL_H = "B000"
Layer4.WALL_V = "DL84"

Layer4.walls = {
    { index = 1, x = -8543.2, y = 3544.7, id = "B000", dir = "H", face = 270, name = "横墙 1" },
    { index = 2, x = -12897.8, y = 3844.4, id = "B000", dir = "H", face = 270, name = "横墙 2" },
    { index = 3, x = -10070.3, y = 5306.5, id = "B000", dir = "H", face = 270, name = "横墙 3" },
    { index = 4, x = -9596.7, y = 4296.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 1" },
    { index = 5, x = -12457.2, y = 2074.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 2" },
    { index = 6, x = -11647.0, y = 2867.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 3" },
}

Layer4.handles    = {}  -- destructable handle 列表
Layer4.wallMap    = {}  -- index -> handle
Layer4.createDone = false  -- §1b: 墙体是否已创建

--|=============================================================
-- §2a: 玩法系统配置（后续扩展）
--|=============================================================

-- 玩法 1：魔法强化怪物 + 击杀检测
--   - 位置：-8524.9,3091.9 | n89f | 朝向 270
--   - 属性：魔法+2000，最大魔法+5000
--   - 绑定：死亡时通过->销毁横墙 1
Layer4.play1Config = {
    pos     = { x = -8524.9, y = 3091.9 },
    unitId  = "n89f",
    facing  = 270,
    magic   = 2000,      -- 魔法强化 +2000
    maxMana = 5000,      -- 最大魔法 +5000
}
Layer4.play1Unit     = nil     -- 运行时怪物句柄
Layer4.play1Triggered = false -- 是否已触发（防止重复）

--|=============================================================
-- §2 生命周期
--|=============================================================

Layer4.started = false
Layer4.finished = false

function Layer4.start()
    if Layer4.started then return end
    Layer4.started = true
    Layer4.finished = false
    print(string.format("[Layer4] 启动 入口/复活/传送 %.1f,%.1f", Layer4.entryPos.x, Layer4.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
    -- §1b: 创建所有墙体
    Layer4.createWalls()
    -- §2a: 初始化玩法系统（玩法 1：创建魔法怪物）
    if not Layer4.play1Unit then
        print("[Layer4] §2a: 启动玩法 1 - 创建魔法强化怪物...")
        Layer4.createPlay1Boss()
    end
end

function Layer4.shutdown()
    if not Layer4.started then return end
    Layer4.started = false
    print("[Layer4] 关闭")
    -- §2a: 清理玩法系统（销毁怪物）
    Layer4.destroyPlay1Boss()
    -- §2b: 清理所有墙体（如果存在）
    Layer4.destroyWalls()
end

--|=============================================================
-- §1b: 墙体管理
--|=============================================================

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then
        print(string.format("[Layer4] createOne: nil params w=%s", tostring(w)))
        return nil
    end
    local face = w.face or (w.dir == "H" and 270 or 0)
    -- 确保参数类型正确：c2i 返回整数，坐标是数字
    local typeId = c2i(w.id) or 0
    local x, y = tonumber(w.x), tonumber(w.y)
    if not x or not y then
        print(string.format("[Layer4] createOne: bad coords id=%s x=%.1f y=%.1f", w.id, w.x, w.y))
        return nil
    end
    -- 打印调试信息（创建墙体时）
    print(string.format("[Layer4] ✓ createOne: %s at %.1f,%.1f typeId=%d face=%d", 
        w.name or "unknown", x, y, typeId, face))
    local h = cj.CreateDestructable(typeId, x, y, face, 1, 0)
    if not h then
        print(string.format("[Layer4] ✗ createOne FAILED: %s (id=%d pos=%.1f,%.1f)", w.name or "unknown", typeId, x, y))
    end
    return h
end

function Layer4.createWalls()
    if Layer4.createDone then return end
    print("[Layer4] §1b: 开始创建墙体...")
    for _, w in ipairs(Layer4.walls) do
        local h = createOne(w)
        if h then
            table.insert(Layer4.handles, h)
            Layer4.wallMap[w.index] = h
            print(string.format("  ✓ %s: %.1f,%.1f (%s)", w.name, w.x, w.y, w.dir))
        else
            print(string.format("  ✗ %s 创建失败", w.name))
        end
    end
    Layer4.createDone = true
end

function Layer4.destroyWalls()
    if not Layer4.createDone then return end
    print("[Layer4] §1b: 销毁所有墙体...")
    for _, h in ipairs(Layer4.handles) do
        if h then
            pcall(function() cj.RemoveDestructable(h) end)
            print(string.format("  ✓ 移除 %s", type(h)))
        end
    end
    Layer4.handles = {}
    Layer4.wallMap = {}
end

--|=============================================================
-- §2a: 玩法系统（玩法 1）
--|=============================================================

local function getEnemyPlayer()
    return Player:new(4)
end

--- 创建魔法强化怪物 n89f（关卡启动时自动调用）
function Layer4.createPlay1Boss()
    if Layer4.play1Unit then print("[Layer4] §2a: 玩法 1 怪物已存在，跳过") return end
    local p = getEnemyPlayer()
    if not p then
        print("[Layer4] §2a: Player.new 返回 nil")
        return nil
    end
    
    -- 创建单位
    local u = Unit:new(p, Layer4.play1Config.unitId, Layer4.play1Config.pos.x, Layer4.play1Config.pos.y, Layer4.play1Config.facing)
    if not u or not u._handle then
        print("[Layer4] §2a: 创建 n89f 失败（坐标", Layer4.play1Config.pos.x, ",", Layer4.play1Config.pos.y, ")")
        return
    end
    
    -- 设置魔法强化：最大生命 + 状态值方式，直接修改 UNIT_STATE_MAX_LIFE、UNIT_STATE_DEFEND_WHITE 等
    local maxLife = u:getState(UNIT_STATE_MAX_MANA)
    if maxLife then
        u:addState(UNIT_STATE_MAX_MANA, Layer4.play1Config.maxMana) -- +5000 最大魔法
        u:addState(UNIT_STATE_MANA, Layer4.play1Config.magic)       -- +2000 当前魔法
    end
    
    print(string.format("[Layer4] §2a: ✓ 玩法 1 怪物 n89f 已创建，坐标 %.1f,%.1f", Layer4.play1Config.pos.x, Layer4.play1Config.pos.y))
    
    -- 记录句柄
    Layer4.play1Unit = u
end

--- 销毁魔法强化怪物（关卡关闭时调用）
function Layer4.destroyPlay1Boss()
    if not Layer4.play1Unit then print("[Layer4] §2a: 玩法 1 怪物不存在，跳过") return end
    local u = Layer4.play1Unit
    pcall(function() u:destroy() end)
    print("[Layer4] §2a: ✓ 玩法 1 怪物已销毁")
    Layer4.play1Unit = nil
end

-- 死亡事件监听：绑定到引擎全局 EVENT_PLAYER_UNIT_DEATH，检查单位是否为玩法 1 怪物
if not Layer4.deathListener then
    print("[Layer4] §2a: 注册死亡事件监听器...")
    -- 使用 Event.new 注册全局死亡事件（参数 nil = 对所有玩家/单位生效）
    Layer4.deathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4.finished then
            print("[Layer4] §2a: 跳过（关卡已结束）")
            return
        end

        -- Event.unit 返回裸 userdata handle，需用 Unit.fromHandle 包装成 Unit 对象
        local dyingHandle = ev.unit
        if not dyingHandle then
            print("[Layer4] §2a: 没有死亡单位")
            return
        end
        local dyingUnit = Unit.fromHandle(dyingHandle)
        if not dyingUnit then
            print("[Layer4] §2a: Unit.fromHandle 返回 nil")
            return
        end

        -- 通过 OOP 方法获取四字符码类型，匹配玩法 1 怪物 n89f
        local unitTypeCode = dyingUnit:getTypeCode()
        if unitTypeCode ~= Layer4.play1Config.unitId then
            return
        end

        -- 检查怪物是否还存在（防止尸体被检测）
        if not Layer4.play1Unit then
            print("[Layer4] §2a: play1Unit is nil，跳过")
            return
        end

        print(string.format("[Layer4] ✓ 玩法 1 BOSS 死亡！type=%s handle=%s", unitTypeCode or "unknown", tostring(dyingHandle)))

        -- 去重：防止同一怪物死亡事件被多次触发
        if Layer4.play1Triggered then
            print("[Layer4] §2a: 已触发过，跳过销毁")
            return
        end
        Layer4.play1Triggered = true

        -- 销毁横墙 1（index=1）
        local h = Layer4.wallMap[1]
        if not h then
            print("[Layer4] §2a: ✗ 警告 - 横墙 1 handle 缺失！wallMap[1]=nil")
            return
        end

        -- 从 wall 配置表取坐标（destructable handle 没有 .x/.y 字段）
        local wallCfg = Layer4.walls[1]
        print(string.format("[Layer4] §2a: ✓ 开始销毁横墙 1 at %.1f,%.1f", wallCfg.x, wallCfg.y))
        pcall(function() cj.RemoveDestructable(h) end)
        -- 从 handles 和 wallMap 中移除已销毁的墙体
        for i, handle in ipairs(Layer4.handles) do
            if handle == h then
                table.remove(Layer4.handles, i)
                break
            end
        end
        Layer4.wallMap[1] = nil
        print("[Layer4] §2a: ✓ 横墙 1 已销毁，玩家可通过")

        -- 发送系统消息提示玩家
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "玩法 1 通关！横墙 1 已摧毁，继续前进！", SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            Player.sendAll("玩法 1 通关！横墙 1 已摧毁")
        end
    end)
end

--|=============================================================
-- §3 兼容别名（保留）
--|=============================================================

Layer4EntryPos    = Layer4.entryPos
Layer4RevivePos   = Layer4.revivePos
Layer4TeleportPos = Layer4.teleportPos
Layer4PotionShopPos = Layer4.potionShopPos

return Layer4
