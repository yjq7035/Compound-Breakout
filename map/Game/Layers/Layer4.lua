--|=============================================================
-- Layer4 — 第四关卡模块
--|
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡 3 通关后传送至此）
--|
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. §1b: 创建墙体
--   3. §1c: 矩形区域定义（A/B 刷怪区，C 通关区）
--   4. §2a: 玩法系统（玩法 1：魔法强化怪物 + 击杀检测）
--   5. §2b: 玩法 2（竖墙 1 延迟创建 + 区域触发待实现）
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
    { index = 4, x = -9596.7, y = 4296.7, wallId = "DL84", dir = "V", face = 0, name = "竖墙 1" },
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
-- §2b: 玩法 2 配置（竖墙 1 延迟创建 + 区域触发待实现）
--|=============================================================

-- 玩法 2：竖墙 1 延迟创建
--   - 墙体坐标：-9596.7,4296.7 | DL84 | face 0
--   - 触发条件：所有用户玩家英雄进入矩形 A or B（待实现）
Layer4.play2Wall1Pos = { x = -9596.7, y = 4296.7, wallId = "DL84", dir = "V", face = 0, name = "竖墙 1" }
Layer4.play2Triggered = false -- 是否已触发（防止重复创建）
Layer4.play2WallHandle = nil  -- 运行时墙体句柄
Layer4.play2EnteredPids = {}  -- 记录已进入刷怪区域A/B的用户玩家pid集合 (pid -> true)

--|=============================================================
-- §2 生命周期
--|=============================================================

Layer4.started = false
Layer4.finished = false

function Layer4.start()
    if Layer4.started then return end
    Layer4.started = true
    Layer4.finished = false
    -- §2b: 重置玩法2状态（等待所有用户玩家英雄进入A/B才创建竖墙1）
    Layer4.play2Triggered = false
    Layer4.play2EnteredPids = {}
    Layer4.play2WallHandle = nil
    print(string.format("[Layer4] 启动 入口/复活/传送 %.1f,%.1f", Layer4.entryPos.x, Layer4.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
    -- §1b: 创建墙体（竖墙1 index=4 与竖墙3 index=6 默认不创建）
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
    -- §2b: 清理竖墙 1（如果存在）
    if Layer4.play2WallHandle then
        pcall(function() cj.RemoveDestructable(Layer4.play2WallHandle) end)
        print("[Layer4] §2b: 清理竖墙 1")
        Layer4.play2WallHandle = nil
    end
    Layer4.wallMap[4] = nil
    -- 重置玩法2进入记录
    Layer4.play2EnteredPids = {}
    -- §1b: 清理所有横墙（如果存在）
    Layer4.destroyWalls()
end

--|=============================================================
-- §1b: 墙体管理
--|=============================================================

local function createOne(w)
    if not w or not w.x or not w.y then
        print(string.format("[Layer4] createOne: nil params w=%s", tostring(w)))
        return nil
    end
    local destructableId = w.id or w.wallId
    if not destructableId then
        print(string.format("[Layer4] createOne: missing id/wallId w=%s", tostring(w)))
        return nil
    end
    local face = w.face or (w.dir == "H" and 270 or 0)
    -- 确保参数类型正确：c2i 返回整数，坐标是数字
    local typeId = c2i(destructableId) or 0
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
        -- 关卡4启动时默认不创建竖墙1(index=4)和竖墙3(index=6)
        if w.index == 4 or w.index == 6 then
            print(string.format("  ⊘ %s(index=%d) 跳过创建(关卡4默认不创建)", w.name, w.index))
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
    if not Layer4.createDone then return end
    print("[Layer4] §1b: 销毁所有横墙...")
    for _, h in ipairs(Layer4.handles) do
        if h then
            pcall(function() cj.RemoveDestructable(h) end)
            print(string.format("  ✓ 移除 %s", type(h)))
        end
    end
    Layer4.handles = {}
    Layer4.wallMap = {}
    Layer4.createDone = false
end

--|=============================================================
-- §2b: 玩法 2 - 竖墙 1 延迟创建管理
--|=============================================================

function Layer4.createPlay2Wall1()
    if Layer4.play2Triggered then return end
    Layer4.play2Triggered = true
    print("[Layer4] §2b: 创建竖墙 1...")
    local pos = Layer4.play2Wall1Pos
    local h = createOne(pos)
    if h then
        Layer4.play2WallHandle = h
        -- 同步写入 wallMap[4] 与 handles，便于统一销毁与查询
        Layer4.wallMap[4] = h
        table.insert(Layer4.handles, h)
        print(string.format("  ✓ 竖墙 1 已创建：%.1f,%.1f", pos.x, pos.y))
    else
        print(string.format("  ✗ 竖墙 1 创建失败"))
    end
end

-- 获取当前所有用户玩家pid列表（0-3 且 isUser && isPlaying）
local function getActiveUserPids()
    local list = {}
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p and p:isUser() and p:isPlaying() then
            table.insert(list, pid)
        end
    end
    return list
end

-- 检查是否所有用户玩家英雄都已进入过A/B区域
local function isAllUserHeroesEntered()
    local active = getActiveUserPids()
    if #active == 0 then return false end
    for _, pid in ipairs(active) do
        if not Layer4.play2EnteredPids[pid] then
            return false
        end
    end
    return true
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
-- §2b: 玩法 2 - 区域触发系统（待实现）
--|=============================================================

--所有用户玩家英雄进入刷怪区域A或B后激活玩法2，此时竖墙1创建
local function onMobSpawnRectEnter(rectId, unit)
    if Layer4.play2Triggered then return end
    if not unit then return end
    local owner = Player.fromHandle(cj.GetOwningPlayer(unit))
    if not owner then return end
    local pid = owner:getId()
    if pid < 0 or pid > 3 then return end
    -- 记录该pid已进入过A/B区域
    if not Layer4.play2EnteredPids[pid] then
        Layer4.play2EnteredPids[pid] = true
        print(string.format("[Layer4] §2b: 玩家%d英雄进入矩形%s，已记录", pid, rectId))
    end
    -- 检查是否所有活跃用户玩家都已进入
    if isAllUserHeroesEntered() then
        print(string.format("[Layer4] §2b: 所有用户玩家英雄已进入A/B区域！矩形%s触发，激活竖墙 1", rectId))
        Layer4.createPlay2Wall1()
        -- TODO: 添加玩法 2 的其他逻辑（待用户设计）
    else
        local active = getActiveUserPids()
        local entered = 0
        for _, apid in ipairs(active) do if Layer4.play2EnteredPids[apid] then entered = entered + 1 end end
        print(string.format("[Layer4] §2b: 等待所有玩家进入A/B [%d/%d] 当前矩形%s pid=%d", entered, #active, rectId, pid))
    end
end

-- 初始化区域进入监听器（关卡启动时调用）
local function initMobSpawnRectListeners()
    for _, rectA in ipairs(Layer4.mobSpawnRectsA) do
        if not Layer4.rectListeners then Layer4.rectListeners = {} end
        local rectId = rectA.id or ""  
        local r = Rect:new(rectA.cx - rectA.width/2, rectA.cy - rectA.height/2,
                           rectA.cx + rectA.width/2, rectA.cy + rectA.height/2)
        if not r then return end
        
        print(string.format("[Layer4] §2b: 创建矩形 A[%s] 触发器：%.1f,%.1f -> %.1f,%.1f", 
            rectId, r.left, r.bottom, r.right, r.top))
        local onEnter = function(ev)
            if Layer4.finished then return end
            local unit = ev.unit or cj.GetEnteringUnit()
            if not unit then return end
            -- 仅检测用户玩家英雄（pid 0-3）
            local owner = Player.fromHandle(cj.GetOwningPlayer(unit))
            if not owner or not owner:isUser() then return end
            if not cj.IsUnitType(unit, UNIT_TYPE_HERO) then return end
        
            local pid = owner:getId()
            if pid < 0 or pid > 3 then return end
        
            onMobSpawnRectEnter(rectId, unit)
        end
        Layer4.rectListeners["A:" .. rectId] = Event:newRect(r, onEnter)
    end
    
    -- 对矩形 B 重复处理...
    for _, rectB in ipairs(Layer4.mobSpawnRectsB) do
        if not Layer4.rectListeners then Layer4.rectListeners = {} end
        local rectId = rectB.id or ""
        local r = Rect:new(rectB.cx - rectB.width/2, rectB.cy - rectB.height/2,
                           rectB.cx + rectB.width/2, rectB.cy + rectB.height/2)
        if not r then return end
        
        print(string.format("[Layer4] §2b: 创建矩形 B[%s] 触发器：%.1f,%.1f -> %.1f,%.1f", 
            rectId, r.left, r.bottom, r.right, r.top))
        local onEnter = function(ev)
            if Layer4.finished then return end
            local unit = ev.unit or cj.GetEnteringUnit()
            if not unit then return end
            -- 仅检测用户玩家英雄（pid 0-3）
            local owner = Player.fromHandle(cj.GetOwningPlayer(unit))
            if not owner or not owner:isUser() then return end
            if not cj.IsUnitType(unit, UNIT_TYPE_HERO) then return end
        
            local pid = owner:getId()
            if pid < 0 or pid > 3 then return end
        
            onMobSpawnRectEnter(rectId, unit)
        end
        Layer4.rectListeners["B:" .. rectId] = Event:newRect(r, onEnter)
    end
end

-- 调用 initMobSpawnRectListeners（在 Layer4.start() 中）
if not Layer4.rectListeners then
    print("[Layer4] §2b: 初始化矩形 A/B 进入监听器...")
    initMobSpawnRectListeners()
end

--|=============================================================
-- §3 兼容别名（保留）
--|=============================================================

Layer4EntryPos    = Layer4.entryPos
Layer4RevivePos   = Layer4.revivePos
Layer4TeleportPos = Layer4.teleportPos
Layer4PotionShopPos = Layer4.potionShopPos

return Layer4