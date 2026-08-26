-- ============================================================
-- Layer2 — 第二关卡模块
--
-- 职责：
--   1. 存放第二关卡坐标（入口/复活、药剂商店）
--   2. 封装关卡力量墙的创建/销毁（可破坏物 destructable）
--   3. 刷怪点系统 11 组（默认无敌且暂停，待激活后恢复）
--   4. 提供关卡生命周期：Layer2.start / Layer2.shutdown
--
-- 目录结构：
--   §1 坐标
--   §2 墙体定义与运行时
--   §3 刷怪点配置（11 组，顺序编号）
--   §4 兼容别名
--   §5 内部工具
--   §6 墙体管理
--   §7 宫格计算（calcMobSpawn*Grid）
--   §8 刷怪点行为（spawn / clear / destroy / activate）
--   §9 批量操作
--   §10 生命周期
-- ============================================================

Layer2 = {}
Layer2.__index = Layer2

-- ============================================================
-- §1 坐标
-- ============================================================

Layer2.entryPos      = { x = -11398.9, y = -7748.4, name = "关卡 2 入口/复活" }
Layer2.revivePos     = { x = -11398.9, y = -7748.4, name = "关卡 2 复活点" }
Layer2.potionShopPos = { x = -10883.1, y = -7679.4, name = "关卡 2 药剂商店" }

-- 刷怪矩形区域配置（中心点 + 宽高）
Layer2.mobSpawnRects = {
    -- 1 号：中心 -11392.1,-9468.3 宽 500 高 300
    { id = 1, cx = -11392.1, cy = -9468.3, width = 500, height = 300, name = "刷怪区域 1" },
    -- 2 号：中心 -11262.9,-9981.0 宽 500 高 300
    { id = 2, cx = -11262.9, cy = -9981.0, width = 500, height = 300, name = "刷怪区域 2" },
    -- 3 号：中心 -9730.1,-10106.9 宽 300 高 500
    { id = 3, cx = -9730.1, cy = -10106.9, width = 300, height = 500, name = "刷怪区域 3" },
    -- 4 号：中心 -9474.1,-10619.1 宽 500 高 300
    { id = 4, cx = -9474.1, cy = -10619.1, width = 500, height = 300, name = "刷怪区域 4" },
    -- 5 号：中心 -9475.6,-11001.8 宽 500 高 300
    { id = 5, cx = -9475.6, cy = -11001.8, width = 500, height = 300, name = "刷怪区域 5" },
    -- 6 号：中心 -9475.8,-11444.4 宽 500 高 300
    { id = 6, cx = -9475.8, cy = -11444.4, width = 500, height = 300, name = "刷怪区域 6" },
    -- 7 号：中心 -9473.7,-11942.2 宽 500 高 300
    { id = 7, cx = -9473.7, cy = -11942.2, width = 500, height = 300, name = "刷怪区域 7" },
    -- 8 号：中心 -9476.0,-12224.2 宽 500 高 300
    { id = 8, cx = -9476.0, cy = -12224.2, width = 500, height = 300, name = "刷怪区域 8" },
    -- 9 号：中心 -9472.0,-12627.5 宽 500 高 300
    { id = 9, cx = -9472.0, cy = -12627.5, width = 500, height = 300, name = "刷怪区域 9" },
    -- 10 号：中心 -9475.3,-13050.7 宽 500 高 300
    { id = 10, cx = -9475.3, cy = -13050.7, width = 500, height = 300, name = "刷怪区域 10" },
    -- 11 号：中心 -9474.7,-13305.1 宽 500 高 300
    { id = 11, cx = -9474.7, cy = -13305.1, width = 500, height = 300, name = "刷怪区域 11" },
}

-- 左下角触发区域（销毁竖墙 1 + 激活 1 号刷怪）
Layer2.triggerAreaBL = {
    left   = -11650.1,
    bottom = -9724.1,
    right  = -11135.7,
    top    = -9340.1,
    name   = "左下角触发区域",
}

-- ============================================================
-- §2 墙体定义与运行时
-- ============================================================
-- 竖墙 DL84 face 0，横墙 B000 face 270（同 Layer1）
-- 竖墙 10 + 横墙 2（用户提供 2026-08-25）

Layer2.WALL_H = "B000"
Layer2.WALL_V = "DL84"

Layer2.walls = {
    { x = -11775.9, y = -9896.5,  id = "DL84", dir = "V", face = 0,   name = "竖墙 1"  },
    { x = -9095,    y = -10082.8, id = "DL84", dir = "V", face = 0,   name = "竖墙 2"  },
    { x = -9095,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 3"  },
    { x = -9095,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 4"  },
    { x = -9095,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 5"  },
    { x = -9095,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 6"  },
    { x = -9865,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 7"  },
    { x = -9865,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 8"  },
    { x = -9865,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 9"  },
    { x = -9865,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 10" },
    { x = -11224.8, y = -10484.6, id = "B000", dir = "H", face = 270, name = "横墙 1"  },
    { x = -9490,    y = -13448,   id = "B000", dir = "H", face = 270, name = "横墙 2"  },
}

-- 运行时
Layer2.handles = {} -- destructable handle 列表
Layer2.wallMap = {} -- wallIndex -> handle

-- ============================================================
-- §3 刷怪点配置（11 组，顺序编号）
-- 统一字段：Pos {x,y,spacing,name} / Units {} / Invincible / Paused / facing
-- ============================================================

-- 刷怪点 1：-12200.2,-9890.9  nF22(2) + nHj3(3)  默认朝向 270
Layer2.mobSpawn1Pos        = { x = -12200.2, y = -9890.9,  spacing = 90, name = "关卡 2 刷怪点 1"  }
Layer2.mobSpawn1Units      = {}
Layer2.mobSpawn1Invincible = true
Layer2.mobSpawn1Paused     = true
Layer2.mobSpawn1Facing     = 270

-- 刷怪点 2：-11205.7,-10873.9  n91z(1) + nHj3(3)  默认朝向 270
Layer2.mobSpawn2Pos        = { x = -11205.7, y = -10873.9, spacing = 90, name = "关卡 2 刷怪点 2"  }
Layer2.mobSpawn2Units      = {}
Layer2.mobSpawn2Invincible = true
Layer2.mobSpawn2Paused     = true
Layer2.mobSpawn2Facing     = 270

-- 刷怪点 3：-8682.9,-10097.1  n485(3) + nf42(2)  默认朝向 180
Layer2.mobSpawn3Pos        = { x = -8682.9,  y = -10097.1, spacing = 90, name = "关卡 2 刷怪点 3"  }
Layer2.mobSpawn3Units      = {}
Layer2.mobSpawn3Invincible = true
Layer2.mobSpawn3Paused     = true
Layer2.mobSpawn3Facing     = 180

-- 刷怪点 4：-10264.8,-10858.6  nv64(1) + nf42(3)  默认朝向 0
Layer2.mobSpawn4Pos        = { x = -10264.8, y = -10858.6, spacing = 90, name = "关卡 2 刷怪点 4"  }
Layer2.mobSpawn4Units      = {}
Layer2.mobSpawn4Invincible = true
Layer2.mobSpawn4Paused     = true
Layer2.mobSpawn4Facing     = 0

-- 刷怪点 5：-8702.5,-10848.3  n02P(9)  默认朝向 180
Layer2.mobSpawn5Pos        = { x = -8702.5,  y = -10848.3, spacing = 90, name = "关卡 2 刷怪点 5"  }
Layer2.mobSpawn5Units      = {}
Layer2.mobSpawn5Invincible = true
Layer2.mobSpawn5Paused     = true
Layer2.mobSpawn5Facing     = 180

-- 刷怪点 6：-10317.6,-11615.1  um5F(1) + n02P(3)  默认朝向 0
Layer2.mobSpawn6Pos        = { x = -10317.6, y = -11615.1, spacing = 90, name = "关卡 2 刷怪点 6"  }
Layer2.mobSpawn6Units      = {}
Layer2.mobSpawn6Invincible = true
Layer2.mobSpawn6Paused     = true
Layer2.mobSpawn6Facing     = 0

-- 刷怪点 7：-8699.1,-11629.4  u7v9(2) + u8mo(3)  默认朝向 180
Layer2.mobSpawn7Pos        = { x = -8699.1,  y = -11629.4, spacing = 90, name = "关卡 2 刷怪点 7"  }
Layer2.mobSpawn7Units      = {}
Layer2.mobSpawn7Invincible = true
Layer2.mobSpawn7Paused     = true
Layer2.mobSpawn7Facing     = 180

-- 刷怪点 8：-10273.8,-13174.9  nM28(1)  默认朝向 0
Layer2.mobSpawn8Pos        = { x = -10273.8, y = -13174.9, spacing = 90, name = "关卡 2 刷怪点 8"  }
Layer2.mobSpawn8Units      = {}
Layer2.mobSpawn8Invincible = true
Layer2.mobSpawn8Paused     = true
Layer2.mobSpawn8Facing     = 0

-- 刷怪点 9：-10290.0,-12379.8  um5F(1) + u7v9(2) + u8mo(6)  默认朝向 0  增强属性
Layer2.mobSpawn9Pos        = { x = -10290.0, y = -12379.8, spacing = 90, name = "关卡 2 刷怪点 9"  }
Layer2.mobSpawn9Units      = {}
Layer2.mobSpawn9Invincible = true
Layer2.mobSpawn9Paused     = true
Layer2.mobSpawn9Facing     = 0

-- 刷怪点 10：-8712.0,-12396.8  n8Ti(1) + nd96(5)  默认朝向 180  增强属性
Layer2.mobSpawn10Pos        = { x = -8712.0, y = -12396.8, spacing = 90, name = "关卡 2 刷怪点 10" }
Layer2.mobSpawn10Units      = {}
Layer2.mobSpawn10Invincible = true
Layer2.mobSpawn10Paused     = true
Layer2.mobSpawn10Facing     = 180

-- 刷怪点 11：-8720.5,-13157.2  nn13(1)  默认朝向 180
Layer2.mobSpawn11Pos        = { x = -8720.5, y = -13157.2, spacing = 90, name = "关卡 2 刷怪点 11" }
Layer2.mobSpawn11Units      = {}
Layer2.mobSpawn11Invincible = true
Layer2.mobSpawn11Paused     = true
Layer2.mobSpawn11Facing     = 180

-- ============================================================
-- §4 兼容别名
-- ============================================================

Layer2EntryPos      = Layer2.entryPos
Layer2RevivePos     = Layer2.revivePos
Layer2PotionShopPos = Layer2.potionShopPos
Layer2Area          = Layer2.walls

-- ============================================================
-- §5 内部工具
-- ============================================================

local function distance(ax, ay, bx, by)
    return ((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5
end

local function getEnemyPlayer()
    return Player:new(4)
end

-- 增强属性：最大生命 +20%、当前生命设为 35% 新上限、护甲 +20%、攻击 +20%
---@param u Unit
local function applyEnhancedStats(u)
    if not u or not u.getState or not u.addState then return end
    local maxLife     = u:getState(UNIT_STATE_MAX_LIFE)
    local currentLife = u:getState(UNIT_STATE_LIFE)
    local armor       = u:getState(UNIT_STATE_DEFEND_WHITE)
    local attack      = u:getState(UNIT_STATE_ATTACK_WHITE)
    if not maxLife or not currentLife then return end

    -- 最大生命 +20%
    u:addState(UNIT_STATE_MAX_LIFE, math.floor(maxLife * 0.2))

    -- 当前生命设为 35% 新上限
    local newMaxLife = maxLife * 1.2
    local targetLife = newMaxLife * 0.35
    u:addState(UNIT_STATE_LIFE, targetLife)

    -- 护甲 +20%
    if armor then
        local newArmor = math.floor(armor * 0.2)
        u:addState(UNIT_STATE_DEFEND_WHITE, newArmor)
    end

    -- 攻击 +20%
    if attack and attack > 0 then
        local newAttack = math.floor(attack * 0.2)
        u:addState(UNIT_STATE_ATTACK_WHITE, newAttack)
    end

    if u.add then pcall(function() u:add("EnhancedUnit") end) end
end

local function setInvulnerableAndPause(u, invincible, paused)
    if not u then return end
    if invincible and u.setInvulnerable then
        pcall(function() u:setInvulnerable(true) end)
    end
    -- 兼容两种暂停接口
    if paused then
        if u.setPauseState then
            pcall(function() u:setPauseState(true) end)
        end
        if u.pause then
            pcall(function() u:pause(true) end)
        end
    end
end

local function clearUnits(unitsKey, label)
    local list = Layer2[unitsKey]
    if not list then Layer2[unitsKey] = {} return end
    for _, u in ipairs(list) do
        if u and u.destroy then u:destroy() end
    end
    local n = #list
    Layer2[unitsKey] = {}
    if n > 0 then print(string.format("[Layer2] %s已清理 count=%d", label, n)) end
end

local function activateUnits(unitsKey, label)
    local list = Layer2[unitsKey]
    if not list then return end
    
    print(string.format("[Layer2] %s 待激活 count=%d", label, #list))
    
    for _, u in ipairs(list) do
        if not u or not u._handle then 
            print(string.format("[Layer2] %s 单位不存在，跳过", label))
            goto continue_loop
        end
        
        -- 移除无敌：优先 Unit 接口，失败回退到原生（规避flag==false的旧封装bug已修复，此处双保险）
        local okInv = pcall(function() u:setInvulnerable(false) end)
        if not okInv and u._handle then pcall(function() cj.SetUnitInvulnerable(u._handle, false) end) end
        
        -- 解除暂停：PauseUnit(false) 为唯一正确路径，setPauseState 仅作兼容
        local okPause = false
        if u.pause then
            okPause = pcall(function() u:pause(false) end)
        end
        if not okPause then
            if u._handle then pcall(function() cj.PauseUnit(u._handle, false) end) end
            if u.setPauseState then pcall(function() u:setPauseState(false) end) end
        end
        -- 兜底：EXPauseUnit（框架 stun 使用）也需解开
        if u._handle and cj.IsUnitPaused and cj.IsUnitPaused(u._handle) then
            pcall(function() cdz.EXPauseUnit(u._handle, false) end)
        end
        
        ::continue_loop::
    end
    
    print(string.format("[Layer2] %s 已激活 count=%d", label, #list))
end

-- 通用刷怪：创建前自动清理旧的，统一处理无敌/暂停/增强
local function spawnGeneric(posKey, unitsKey, gridFunc, facing, label, detail, enhanced)
    local posDef = Layer2[posKey]
    local cx = posDef and posDef.x or nil
    local cy = posDef and posDef.y or nil
    -- 允许外部传入覆盖坐标（保持原接口 cx,cy 可选）
    -- 调用方已处理 cx/cy 回落，此处仅兜底
    local positions = gridFunc(cx, cy)
    local p = getEnemyPlayer()

    clearUnits(unitsKey, label)
    Layer2[unitsKey] = {}

    local invincibleKey = posKey:gsub("Pos$", "Invincible")
    local needInvincible = Layer2[invincibleKey]

    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, facing)
        if u then
            table.insert(Layer2[unitsKey], u)
            setInvulnerableAndPause(u, needInvincible, true)
            if enhanced then applyEnhancedStats(u) end
        end
    end

    local count = #Layer2[unitsKey]
    local suffix = enhanced and " (默认无敌且暂停，朝向 " .. facing .. "，增强属性)" or string.format(" (默认无敌且暂停，朝向 %d)", facing)
    -- detail 已包含单位构成说明
    print(string.format("[Layer2] %s已创建 中心%.1f,%.1f %s count=%d%s", label, cx, cy, detail, count, suffix))
    return Layer2[unitsKey]
end

-- ============================================================
-- §6 墙体管理
-- ============================================================

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then
        print(string.format("[Layer2] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else
        print(string.format("[Layer2] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y))
    end
    return h
end

function Layer2.createWalls()
    if #Layer2.handles > 0 then
        print("[Layer2] 墙体已存在，跳过 count=" .. #Layer2.handles)
        return Layer2.handles
    end
    Layer2.handles = {}
    Layer2.wallMap = {}
    for i, w in ipairs(Layer2.walls) do
        local h = createOne(w)
        if h then table.insert(Layer2.handles, h); Layer2.wallMap[i] = h end
    end
    print(string.format("[Layer2] 第二关卡墙体创建完成 count=%d/%d", #Layer2.handles, #Layer2.walls))
    return Layer2.handles
end

function Layer2.destroyWalls()
    for _, h in ipairs(Layer2.handles) do if h then cj.RemoveDestructable(h) end end
    local n = #Layer2.handles
    Layer2.handles = {}
    Layer2.wallMap = {}
    if n > 0 then print("[Layer2] 第二关卡墙体已移除 count=" .. n) end
end

function Layer2.getCount() return #Layer2.handles end
function Layer2.isCreated() return #Layer2.handles > 0 end

-- 最近墙匹配移除（供营地/Boss 击杀触发调用）
function Layer2.removeWallNear(tx, ty, reason)
    if not tx or not ty then return false end
    local bestIdx, bestDist = nil, 1e9
    for i, w in ipairs(Layer2.walls) do
        local d = distance(tx, ty, w.x, w.y)
        if d < bestDist then bestDist = d; bestIdx = i end
    end
    if not bestIdx then return false end
    local h = Layer2.wallMap[bestIdx]
    local w = Layer2.walls[bestIdx]
    if h then
        cj.RemoveDestructable(h)
        Layer2.wallMap[bestIdx] = nil
        for k, vh in ipairs(Layer2.handles) do
            if vh == h then table.remove(Layer2.handles, k) break end
        end
        print(string.format("[Layer2] 墙已移除 %s (最近 %.1f 码) tx=%.1f,%.1f -> wall %s %.1f,%.1f reason=%s",
            w.name, bestDist, tx, ty, w.name, w.x, w.y, reason or ""))
        if SystemMessage and SystemMessage.send then
            local wallMsg = string.format("力量墙已销毁 - %s - %s", reason or w.name, w.name)
            SystemMessage.send({{"STR", wallMsg, SystemMessage.COLOR_INFO}}, 3.0)
        end
        return true
    else
        print(string.format("[Layer2] 墙已不存在或已移除 %s 最近 %.1f 码", w.name, bestDist))
        return false
    end
end

-- ============================================================
-- §7 宫格计算
-- ============================================================

-- 刷怪点 1：中心 nF22(2：y±90) + x+90 上中下 nHj3(3)
function Layer2.calcMobSpawn1Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn1Pos.spacing or 90
    return {
        { x = cx,         y = cy + s, id = "nF22" },
        { x = cx,         y = cy - s, id = "nF22" },
        { x = cx + s,     y = cy + s, id = "nHj3" },
        { x = cx + s,     y = cy,     id = "nHj3" },
        { x = cx + s,     y = cy - s, id = "nHj3" },
    }
end

-- 刷怪点 2：中心 n91z(1) + y+90 水平线左中右 nHj3(3)
function Layer2.calcMobSpawn2Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn2Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "n91z" },
        { x = cx - s,     y = cy + s, id = "nHj3" },
        { x = cx,         y = cy + s, id = "nHj3" },
        { x = cx + s,     y = cy + s, id = "nHj3" },
    }
end

-- 刷怪点 3：x-90 上中下 n485(3) + 中心上下 nf42(2)  朝向 180
function Layer2.calcMobSpawn3Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn3Pos.spacing or 90
    return {
        { x = cx - s,     y = cy + s, id = "n485" },
        { x = cx - s,     y = cy,     id = "n485" },
        { x = cx - s,     y = cy - s, id = "n485" },
        { x = cx,         y = cy + s, id = "nf42" },
        { x = cx,         y = cy - s, id = "nf42" },
    }
end

-- 刷怪点 4：中心 nv64(1) + x+90 上中下 nf42(3)  朝向 0
function Layer2.calcMobSpawn4Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn4Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "nv64" },
        { x = cx + s,     y = cy + s, id = "nf42" },
        { x = cx + s,     y = cy,     id = "nf42" },
        { x = cx + s,     y = cy - s, id = "nf42" },
    }
end

-- 刷怪点 5：中心 + 四周 + 四角 共 9 个 n02P  朝向 180
function Layer2.calcMobSpawn5Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn5Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "n02P" },
        { x = cx,         y = cy + s, id = "n02P" },
        { x = cx,         y = cy - s, id = "n02P" },
        { x = cx - s,     y = cy,     id = "n02P" },
        { x = cx + s,     y = cy,     id = "n02P" },
        { x = cx - s,     y = cy + s, id = "n02P" },
        { x = cx + s,     y = cy + s, id = "n02P" },
        { x = cx - s,     y = cy - s, id = "n02P" },
        { x = cx + s,     y = cy - s, id = "n02P" },
    }
end

-- 刷怪点 6：中心 um5F(1) + x+90 上中下 n02P(3)  朝向 0
function Layer2.calcMobSpawn6Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn6Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "um5F" },
        { x = cx + s,     y = cy + s, id = "n02P" },
        { x = cx + s,     y = cy,     id = "n02P" },
        { x = cx + s,     y = cy - s, id = "n02P" },
    }
end

-- 刷怪点 7：中心上下 u7v9(2) + x-90 上中下 u8mo(3)  朝向 180
function Layer2.calcMobSpawn7Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn7Pos.spacing or 90
    return {
        { x = cx,         y = cy + s, id = "u7v9" },
        { x = cx,         y = cy - s, id = "u7v9" },
        { x = cx - s,     y = cy + s, id = "u8mo" },
        { x = cx - s,     y = cy,     id = "u8mo" },
        { x = cx - s,     y = cy - s, id = "u8mo" },
    }
end

-- 刷怪点 8：中心 nM28(1)  朝向 0
function Layer2.calcMobSpawn8Grid(cx, cy)
    if not cx or not cy then return {} end
    return {
        { x = cx,         y = cy,     id = "nM28" },
    }
end

-- 刷怪点 9：中心 um5F(1) + 上下 u7v9(2) + x±90 上中下 u8mo(6)  朝向 0  增强
function Layer2.calcMobSpawn9Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn9Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "um5F" },
        { x = cx,         y = cy + s, id = "u7v9" },
        { x = cx,         y = cy - s, id = "u7v9" },
        { x = cx - s,     y = cy + s, id = "u8mo" },
        { x = cx - s,     y = cy,     id = "u8mo" },
        { x = cx - s,     y = cy - s, id = "u8mo" },
        { x = cx + s,     y = cy + s, id = "u8mo" },
        { x = cx + s,     y = cy,     id = "u8mo" },
        { x = cx + s,     y = cy - s, id = "u8mo" },
    }
end

-- 刷怪点 10：中心 n8Ti(1) + 上下 nd96(2) + x-90 上中下 nd96(3)  朝向 180  增强
function Layer2.calcMobSpawn10Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn10Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "n8Ti" },
        { x = cx,         y = cy + s, id = "nd96" },
        { x = cx,         y = cy - s, id = "nd96" },
        { x = cx - s,     y = cy + s, id = "nd96" },
        { x = cx - s,     y = cy,     id = "nd96" },
        { x = cx - s,     y = cy - s, id = "nd96" },
    }
end

-- 刷怪点 11：中心 nn13(1)  朝向 180
function Layer2.calcMobSpawn11Grid(cx, cy)
    if not cx or not cy then return {} end
    return {
        { x = cx,         y = cy,     id = "nn13" },
    }
end

-- ============================================================
-- §8 刷怪点行为（spawn / clear / destroy / activate）
-- 保持对外接口不变，内部统一走 spawnGeneric / clearUnits / activateUnits
-- ============================================================

-- 刷怪点 1
function Layer2.spawnMobSpawn1(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn1Pos.x end
    if cy == nil then cy = Layer2.mobSpawn1Pos.y end
    -- 覆盖 Pos 供 spawnGeneric 读取
    local origX, origY = Layer2.mobSpawn1Pos.x, Layer2.mobSpawn1Pos.y
    Layer2.mobSpawn1Pos.x, Layer2.mobSpawn1Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn1Pos", "mobSpawn1Units", Layer2.calcMobSpawn1Grid, Layer2.mobSpawn1Facing,
        "刷怪点 1 ", "nF22(2 个：y+90/-90) + nHj3(3 个：x+90 上中下)", false)
    Layer2.mobSpawn1Pos.x, Layer2.mobSpawn1Pos.y = origX, origY
    -- 若传入了自定义坐标，需要修正 positions 到传入坐标（grid 已基于临时 Pos）
    -- 上述临时替换已生效，无需二次修正
    return ret
end
function Layer2.clearMobSpawn1()   clearUnits("mobSpawn1Units", "刷怪点 1") end
function Layer2.destroyMobSpawn1() Layer2.clearMobSpawn1() end
function Layer2.activateMobSpawn1() activateUnits("mobSpawn1Units", "刷怪点 1") end

-- 刷怪点 2
function Layer2.spawnMobSpawn2(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn2Pos.x end
    if cy == nil then cy = Layer2.mobSpawn2Pos.y end
    local ox, oy = Layer2.mobSpawn2Pos.x, Layer2.mobSpawn2Pos.y
    Layer2.mobSpawn2Pos.x, Layer2.mobSpawn2Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn2Pos", "mobSpawn2Units", Layer2.calcMobSpawn2Grid, Layer2.mobSpawn2Facing,
        "刷怪点 2 ", "n91z(1 个：中心) + nHj3(3 个：y+90 左中右)", false)
    Layer2.mobSpawn2Pos.x, Layer2.mobSpawn2Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn2()   clearUnits("mobSpawn2Units", "刷怪点 2") end
function Layer2.destroyMobSpawn2() Layer2.clearMobSpawn2() end
function Layer2.activateMobSpawn2() activateUnits("mobSpawn2Units", "刷怪点 2") end

-- 刷怪点 3
function Layer2.spawnMobSpawn3(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn3Pos.x end
    if cy == nil then cy = Layer2.mobSpawn3Pos.y end
    local ox, oy = Layer2.mobSpawn3Pos.x, Layer2.mobSpawn3Pos.y
    Layer2.mobSpawn3Pos.x, Layer2.mobSpawn3Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn3Pos", "mobSpawn3Units", Layer2.calcMobSpawn3Grid, Layer2.mobSpawn3Facing,
        "刷怪点 3 ", "n485(3 个：x-90 上中下) + nf42(2 个：y+90/-90)", false)
    Layer2.mobSpawn3Pos.x, Layer2.mobSpawn3Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn3()   clearUnits("mobSpawn3Units", "刷怪点 3") end
function Layer2.destroyMobSpawn3() Layer2.clearMobSpawn3() end
function Layer2.activateMobSpawn3() activateUnits("mobSpawn3Units", "刷怪点 3") end

-- 刷怪点 4
function Layer2.spawnMobSpawn4(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn4Pos.x end
    if cy == nil then cy = Layer2.mobSpawn4Pos.y end
    local ox, oy = Layer2.mobSpawn4Pos.x, Layer2.mobSpawn4Pos.y
    Layer2.mobSpawn4Pos.x, Layer2.mobSpawn4Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn4Pos", "mobSpawn4Units", Layer2.calcMobSpawn4Grid, Layer2.mobSpawn4Facing,
        "刷怪点 4 ", "nv64(1 个：中心) + nf42(3 个：x+90 上中下)", false)
    Layer2.mobSpawn4Pos.x, Layer2.mobSpawn4Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn4()   clearUnits("mobSpawn4Units", "刷怪点 4") end
function Layer2.destroyMobSpawn4() Layer2.clearMobSpawn4() end
function Layer2.activateMobSpawn4() activateUnits("mobSpawn4Units", "刷怪点 4") end

-- 刷怪点 5
function Layer2.spawnMobSpawn5(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn5Pos.x end
    if cy == nil then cy = Layer2.mobSpawn5Pos.y end
    local ox, oy = Layer2.mobSpawn5Pos.x, Layer2.mobSpawn5Pos.y
    Layer2.mobSpawn5Pos.x, Layer2.mobSpawn5Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn5Pos", "mobSpawn5Units", Layer2.calcMobSpawn5Grid, Layer2.mobSpawn5Facing,
        "刷怪点 5 ", "n02P(9 个：中心 +8 个)", false)
    Layer2.mobSpawn5Pos.x, Layer2.mobSpawn5Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn5()   clearUnits("mobSpawn5Units", "刷怪点 5") end
function Layer2.destroyMobSpawn5() Layer2.clearMobSpawn5() end
function Layer2.activateMobSpawn5() activateUnits("mobSpawn5Units", "刷怪点 5") end

-- 刷怪点 6
function Layer2.spawnMobSpawn6(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn6Pos.x end
    if cy == nil then cy = Layer2.mobSpawn6Pos.y end
    local ox, oy = Layer2.mobSpawn6Pos.x, Layer2.mobSpawn6Pos.y
    Layer2.mobSpawn6Pos.x, Layer2.mobSpawn6Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn6Pos", "mobSpawn6Units", Layer2.calcMobSpawn6Grid, Layer2.mobSpawn6Facing,
        "刷怪点 6 ", "um5F(1 个：中心) + n02P(3 个：x+90 上中下)", false)
    Layer2.mobSpawn6Pos.x, Layer2.mobSpawn6Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn6()   clearUnits("mobSpawn6Units", "刷怪点 6") end
function Layer2.destroyMobSpawn6() Layer2.clearMobSpawn6() end
function Layer2.activateMobSpawn6() activateUnits("mobSpawn6Units", "刷怪点 6") end

-- 刷怪点 7
function Layer2.spawnMobSpawn7(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn7Pos.x end
    if cy == nil then cy = Layer2.mobSpawn7Pos.y end
    local ox, oy = Layer2.mobSpawn7Pos.x, Layer2.mobSpawn7Pos.y
    Layer2.mobSpawn7Pos.x, Layer2.mobSpawn7Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn7Pos", "mobSpawn7Units", Layer2.calcMobSpawn7Grid, Layer2.mobSpawn7Facing,
        "刷怪点 7 ", "u7v9(2 个：y+90/-90) + u8mo(3 个：x-90 上中下)", false)
    Layer2.mobSpawn7Pos.x, Layer2.mobSpawn7Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn7()   clearUnits("mobSpawn7Units", "刷怪点 7") end
function Layer2.destroyMobSpawn7() Layer2.clearMobSpawn7() end
function Layer2.activateMobSpawn7() activateUnits("mobSpawn7Units", "刷怪点 7") end

-- 刷怪点 8
function Layer2.spawnMobSpawn8(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn8Pos.x end
    if cy == nil then cy = Layer2.mobSpawn8Pos.y end
    local ox, oy = Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y
    Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn8Pos", "mobSpawn8Units", Layer2.calcMobSpawn8Grid, Layer2.mobSpawn8Facing,
        "刷怪点 8 ", "nM28(1 个：中心)", false)
    Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn8()   clearUnits("mobSpawn8Units", "刷怪点 8") end
function Layer2.destroyMobSpawn8() Layer2.clearMobSpawn8() end
function Layer2.activateMobSpawn8() activateUnits("mobSpawn8Units", "刷怪点 8") end

-- 刷怪点 9（增强）
function Layer2.spawnMobSpawn9(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn9Pos.x end
    if cy == nil then cy = Layer2.mobSpawn9Pos.y end
    local ox, oy = Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y
    Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn9Pos", "mobSpawn9Units", Layer2.calcMobSpawn9Grid, Layer2.mobSpawn9Facing,
        "刷怪点 9 ", "um5F(1 个：中心) + u7v9(2 个：y+90/-90) + u8mo(6 个：x±90 上中下)", true)
    Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn9()   clearUnits("mobSpawn9Units", "刷怪点 9") end
function Layer2.destroyMobSpawn9() Layer2.clearMobSpawn9() end
function Layer2.activateMobSpawn9() activateUnits("mobSpawn9Units", "刷怪点 9") end

-- 刷怪点 10（增强）
function Layer2.spawnMobSpawn10(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn10Pos.x end
    if cy == nil then cy = Layer2.mobSpawn10Pos.y end
    local ox, oy = Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y
    Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn10Pos", "mobSpawn10Units", Layer2.calcMobSpawn10Grid, Layer2.mobSpawn10Facing,
        "刷怪点 10", "n8Ti(1 个：中心) + nd96(5 个：上下 +x-90 上中下)", true)
    Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn10()   clearUnits("mobSpawn10Units", "刷怪点 10") end
function Layer2.destroyMobSpawn10() Layer2.clearMobSpawn10() end
function Layer2.activateMobSpawn10() activateUnits("mobSpawn10Units", "刷怪点 10") end

-- 刷怪点 11
function Layer2.spawnMobSpawn11(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn11Pos.x end
    if cy == nil then cy = Layer2.mobSpawn11Pos.y end
    local ox, oy = Layer2.mobSpawn11Pos.x, Layer2.mobSpawn11Pos.y
    Layer2.mobSpawn11Pos.x, Layer2.mobSpawn11Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn11Pos", "mobSpawn11Units", Layer2.calcMobSpawn11Grid, Layer2.mobSpawn11Facing,
        "刷怪点 11", "nn13(1 个：中心)", false)
    Layer2.mobSpawn11Pos.x, Layer2.mobSpawn11Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn11()   clearUnits("mobSpawn11Units", "刷怪点 11") end
function Layer2.destroyMobSpawn11() Layer2.clearMobSpawn11() end
function Layer2.activateMobSpawn11() activateUnits("mobSpawn11Units", "刷怪点 11") end

-- ============================================================
-- §9 批量操作
-- ============================================================

function Layer2.spawnAllMobSpawns()
    Layer2.spawnMobSpawn1()
    Layer2.spawnMobSpawn2()
    Layer2.spawnMobSpawn3()
    Layer2.spawnMobSpawn4()
    Layer2.spawnMobSpawn5()
    Layer2.spawnMobSpawn6()
    Layer2.spawnMobSpawn7()
    Layer2.spawnMobSpawn8()
    Layer2.spawnMobSpawn9()
    Layer2.spawnMobSpawn10()
    Layer2.spawnMobSpawn11()
end

function Layer2.clearAllMobSpawns()
    Layer2.clearMobSpawn1()
    Layer2.clearMobSpawn2()
    Layer2.clearMobSpawn3()
    Layer2.clearMobSpawn4()
    Layer2.clearMobSpawn5()
    Layer2.clearMobSpawn6()
    Layer2.clearMobSpawn7()
    Layer2.clearMobSpawn8()
    Layer2.clearMobSpawn9()
    Layer2.clearMobSpawn10()
    Layer2.clearMobSpawn11()
end

function Layer2.destroyAllMobSpawns() Layer2.clearAllMobSpawns() end

function Layer2.activateAllMobSpawns()
    Layer2.activateMobSpawn1()
    Layer2.activateMobSpawn2()
    Layer2.activateMobSpawn3()
    Layer2.activateMobSpawn4()
    Layer2.activateMobSpawn5()
    Layer2.activateMobSpawn6()
    Layer2.activateMobSpawn7()
    Layer2.activateMobSpawn8()
    Layer2.activateMobSpawn9()
    Layer2.activateMobSpawn10()
    Layer2.activateMobSpawn11()
end

-- ============================================================
-- §10 生命周期
-- ============================================================

Layer2.started = false

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    Layer2.createWalls()
    Layer2.spawnAllMobSpawns()
    -- 创建触发区域和事件（延迟 0.5 秒，确保墙体和怪物已就绪）
    Timer:new(0.5, false, function()
        if not Layer2.started then return end
        Layer2.createTriggerAreaBL()
        Layer2.createMobSpawnRects()
    end)
    -- TODO: 关卡 2 营地、Boss 等后续扩展
end

function Layer2.shutdown()
    if not Layer2.started then return end
    Layer2.started = false
    Layer2.destroyWalls()
    Layer2.clearAllMobSpawns()
    Layer2.destroyMobSpawnRects()
    print("[Layer2] 关闭")
end

-- ============================================================
-- §11 触发区域管理（Rect.new + 触发器事件）
-- ============================================================

local triggerAreaBL = nil -- Rect 句柄
local triggerEventBL = nil -- 触发器事件句柄
local mobSpawnRects = {}   -- 刷怪矩形区域句柄列表
local mobSpawnEvents = {}  -- 刷怪矩形区域事件句柄列表

--- 创建左下角触发区域并设置单位进入事件
function Layer2.createTriggerAreaBL()
    if triggerAreaBL then return end
    
    local minX, minY = -11650.1, -9724.1
    local maxX, maxY = -11135.7, -9340.1
    
    -- 创建矩形区域
    triggerAreaBL = Rect.new(minX, minY, maxX, maxY)
    print(string.format("[Layer2] 触发区域已创建 左下角：%.1f,%.1f 右上角：%.1f,%.1f", minX, minY, maxX, maxY))
    
    -- 设置单位进入事件（回调接收 Event 对象，通过 self.unit 获取进入的单位）
    triggerEventBL = Event:newRect(triggerAreaBL, function(ev)
        local unit = ev.unit or ev._unit or cj.GetEnteringUnit()
        if not unit then return end
        
        -- 获取单位所属玩家
        local player = Player.fromHandle(cj.GetOwningPlayer(unit))
        if not player or not player:isUser() then return end
        
        local pid = player:getId()
        local playerName = player:getName() or string.format("玩家%d", pid)
        
        print(string.format("[Layer2] 单位进入触发区域 unit=%s owner=%s", Event.unitDesc(unit), playerName))
        
        -- 销毁竖墙 1（使用单位坐标）
        if Layer2.removeWallNear(cj.GetUnitX(unit), cj.GetUnitY(unit), "触发区域") then
            print("[Layer2] 竖墙 1 已销毁（触发区域）")
            
            -- 激活 1 号刷怪点
            Layer2.activateMobSpawn1()
        end
        
        -- 删除区域和事件，避免其他单位进入造成重复触发
        local rectToClean = triggerAreaBL
        triggerAreaBL = nil
        triggerEventBL = nil
        if rectToClean then
            print("[Layer2] 触发区域已销毁")
            Event:destroyRect(rectToClean)
            rectToClean:destroy()
            print("[Layer2] 触发器事件已销毁")
        end
    end)
    
    if triggerEventBL then
        print("[Layer2] 触发器事件已启动")
    end
    
    return triggerAreaBL, triggerEventBL
end

--- 删除触发区域和事件（手动调用）
function Layer2.destroyTriggerAreaBL()
    local rectToClean = triggerAreaBL
    triggerAreaBL = nil
    triggerEventBL = nil
    if rectToClean then
        Event:destroyRect(rectToClean)
        rectToClean:destroy()
    end
end

--- 创建所有刷怪矩形区域触发器（使用 Rect:newCenter + event）
function Layer2.createMobSpawnRects()
    for _, rectDef in ipairs(Layer2.mobSpawnRects) do
        local cx = rectDef.cx
        local cy = rectDef.cy
        local width = rectDef.width
        local height = rectDef.height
        
        -- 使用 Rect:newCenter 创建矩形区域（中心点 + 宽高）
        local rect = Rect:newCenter(cx, cy, width, height)
        
        -- 设置单位进入事件（使用 event 创建区域事件）
        local event = Event:newRect(rect, function(ev)
            local unit = ev.unit or ev._unit or cj.GetEnteringUnit()
            if not unit then return end
            
            -- 获取单位所属玩家
            local player = Player.fromHandle(cj.GetOwningPlayer(unit))
            if not player or not player:isUser() then return end
            
            local pid = player:getId()
            local playerName = player:getName() or string.format("玩家%d", pid)
            
            print(string.format("[Layer2] 单位进入刷怪区域 %s unit=%s owner=%s", rectDef.name, Event.unitDesc(unit), playerName))
            
            -- 激活对应编号的刷怪点
            local spawnId = rectDef.id
            Layer2.activateMobSpawn(spawnId)
        end)
        
        if event then
            print(string.format("[Layer2] 刷怪区域 %s (%.1f,%.1f) 触发器已启动", rectDef.name, cx, cy))
        else
            print(string.format("[Layer2] 刷怪区域 %s 创建失败", rectDef.name))
        end
        
        -- 存储句柄
        mobSpawnRects[rectDef.id] = rect
        mobSpawnEvents[rectDef.id] = event
    end
    
    print(string.format("[Layer2] 共创建%d个刷怪矩形区域触发器", #Layer2.mobSpawnRects))
end

--- 删除所有刷怪矩形区域触发器（先激活再删除）
function Layer2.destroyMobSpawnRects()
    for id, rect in pairs(mobSpawnRects) do
        if rect then
            -- 销毁矩形区域
            Event:destroyRect(rect)
            rect:destroy()
            print(string.format("[Layer2] 刷怪区域 %d 已销毁", id))
        end
    end
    
    -- 清空事件句柄（先激活再删除）
    for id, event in pairs(mobSpawnEvents) do
        if event then
            Event:destroy(event)
            event:destroy()
        end
    end
    
    mobSpawnRects = {}
    mobSpawnEvents = {}
    
    print(string.format("[Layer2] 共销毁%d个刷怪矩形区域触发器", #Layer2.mobSpawnRects))
end

--- 通用激活刷怪点函数（根据 ID）
function Layer2.activateMobSpawn(id)
    local spawnFuncName = "activateMobSpawn" .. id
    local func = Layer2[spawnFuncName]
    if func then
        func()
    else
        print(string.format("[Layer2] 未找到刷怪点 %d 的激活函数", id))
    end
end

return Layer2
