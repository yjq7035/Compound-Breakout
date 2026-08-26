-- ============================================================
-- Layer2 — 第二关卡模块
--
-- 职责：
--   1. 存放第二关卡坐标（入口/复活、药剂商店）
--   2. 提供关卡生命周期：Layer2.start / Layer2.shutdown
--   3. 刷怪点系统（默认无敌且暂停，待激活后恢复）
-- ============================================================

Layer2 = {}
Layer2.__index = Layer2

-- ------------------------------------------------------------
-- 坐标
-- ------------------------------------------------------------
Layer2.entryPos      = { x = -11398.9, y = -7748.4, name = "关卡 2 入口/复活" }
Layer2.revivePos     = { x = -11398.9, y = -7748.4, name = "关卡 2 复活点" }
Layer2.potionShopPos = { x = -10883.1, y = -7679.4, name = "关卡 2 药剂商店" }

-- 兼容全局
Layer2EntryPos      = Layer2.entryPos
Layer2RevivePos     = Layer2.revivePos
Layer2PotionShopPos = Layer2.potionShopPos

-- ------------------------------------------------------------
-- 墙体定义（非单位：可破坏物 destructable）
-- 用户提供 2026-08-25：
--   竖墙 10：-11775.9,-9896.5 / -9095,-10082.8 / -9095,-10855 / -9095,-11618 / -9095,-12400 / -9095,-13165 / -9865,-10855 / -9865,-11618 / -9865,-12400 / -9865,-13165
--   横墙 2：-11224.8,-10484.6 / -9490,-13448
--   竖墙 DL84 face 0，横墙 B000 face 270（同 Layer1）
-- ------------------------------------------------------------
Layer2.WALL_H = "B000"
Layer2.WALL_V = "DL84"

Layer2.walls = {
    { x = -11775.9, y = -9896.5,  id = "DL84", dir = "V", face = 0,   name = "竖墙 1" },
    { x = -9095,    y = -10082.8, id = "DL84", dir = "V", face = 0,   name = "竖墙 2" },
    { x = -9095,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 3" },
    { x = -9095,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 4" },
    { x = -9095,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 5" },
    { x = -9095,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 6" },
    { x = -9865,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 7" },
    { x = -9865,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 8" },
    { x = -9865,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 9" },
    { x = -9865,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 10" },
    { x = -11224.8, y = -10484.6, id = "B000", dir = "H", face = 270, name = "横墙 1" },
    { x = -9490,    y = -13448,   id = "B000", dir = "H", face = 270, name = "横墙 2" },
}
Layer2Area = Layer2.walls

-- 运行时
Layer2.handles = {} -- destructable handle 列表
Layer2.wallMap = {} -- wallIndex -> handle

-- ------------------------------------------------------------
-- 刷怪点配置（关卡 2）
-- ------------------------------------------------------------
Layer2.mobSpawn1Pos = { x = -12200.2, y = -9890.9, spacing = 90, name = "关卡 2 刷怪点" }
Layer2.mobSpawn1Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn1Invincible = true
Layer2.mobSpawn1Paused = true

-- ------------------------------------------------------------
-- 新增刷怪点配置（关卡 2）
-- ------------------------------------------------------------
Layer2.mobSpawn2Pos = { x = -11205.7, y = -10873.9, spacing = 90, name = "关卡 2 新增刷怪点" }
Layer2.mobSpawn2Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn2Invincible = true
Layer2.mobSpawn2Paused = true

-- ------------------------------------------------------------
-- 新增刷怪点配置（关卡 2 - 坐标 -8682.9,-10097.1）
-- ------------------------------------------------------------
Layer2.mobSpawn3Pos = { x = -8682.9, y = -10097.1, spacing = 90, name = "关卡 2 刷怪点 2" }
Layer2.mobSpawn3Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn3Invincible = true
Layer2.mobSpawn3Paused = true
-- 默认朝向：180

-- ------------------------------------------------------------
-- 新增刷怪点 3 配置（关卡 2 - 坐标 -10264.8,-10858.6）
-- ------------------------------------------------------------
Layer2.mobSpawn4Pos = { x = -10264.8, y = -10858.6, spacing = 90, name = "关卡 2 刷怪点 3" }
Layer2.mobSpawn4Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn4Invincible = true
Layer2.mobSpawn4Paused = true
-- 默认朝向：0

-- ------------------------------------------------------------
-- 新增刷怪点 4 配置（关卡 2 - 坐标 -8302.5,-10848.3）
-- ------------------------------------------------------------
Layer2.mobSpawn5Pos = { x = -8702.5, y = -10848.3, spacing = 90, name = "关卡 2 新增刷怪点 4" }
Layer2.mobSpawn5Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn5Invincible = true
Layer2.mobSpawn5Paused = true

-- ------------------------------------------------------------
-- 新增刷怪点 5 配置（关卡 2 - 坐标 -10317.6,-11615.1）
-- ------------------------------------------------------------
Layer2.mobSpawn6Pos = { x = -10317.6, y = -11615.1, spacing = 90, name = "关卡 2 刷怪点 5" }
Layer2.mobSpawn6Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn6Invincible = true
Layer2.mobSpawn6Paused = true
-- 默认朝向：0

-- ------------------------------------------------------------
-- 新增刷怪点 6 配置（关卡 2 - 坐标 -6683.9,-11611.7）
-- ------------------------------------------------------------
Layer2.mobSpawn7Pos = { x = -8699.1, y = -11629.4, spacing = 90, name = "关卡 2 刷怪点 6" }
Layer2.mobSpawn7Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn7Invincible = true
Layer2.mobSpawn7Paused = true
-- 默认朝向：180

-- ------------------------------------------------------------
-- 新增刷怪点 7 配置（关卡 2 - 坐标 -8699.1，-11629.4,）中心 nM28，默认朝向 0
-- ------------------------------------------------------------
Layer2.mobSpawn8Pos = { x = -10273.8, y = -13174.9, spacing = 90, name = "关卡 2 新增刷怪点 7" }
Layer2.mobSpawn8Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn8Invincible = true
Layer2.mobSpawn8Paused = true
-- 默认朝向：0

-- ------------------------------------------------------------
-- 墙工具
-- ------------------------------------------------------------
local function distance(ax, ay, bx, by) return ((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5 end

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then print(string.format("[Layer2] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else print(string.format("[Layer2] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y)) end
    return h
end

function Layer2.createWalls()
    if #Layer2.handles > 0 then print("[Layer2] 墙体已存在，跳过 count=" .. #Layer2.handles) return Layer2.handles end
    Layer2.handles = {}; Layer2.wallMap = {}
    for i, w in ipairs(Layer2.walls) do
        local h = createOne(w)
        if h then table.insert(Layer2.handles, h); Layer2.wallMap[i] = h end
    end
    print("[Layer2] 第二关卡墙体创建完成 count=" .. #Layer2.handles .. "/" .. #Layer2.walls)
    return Layer2.handles
end

function Layer2.destroyWalls()
    for _, h in ipairs(Layer2.handles) do if h then cj.RemoveDestructable(h) end end
    local n = #Layer2.handles
    Layer2.handles = {}; Layer2.wallMap = {}
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
        for k, vh in ipairs(Layer2.handles) do if vh == h then table.remove(Layer2.handles, k) break end end
        print(string.format("[Layer2] 墙已移除 %s (最近 %.1f 码) tx=%.1f,%.1f -> wall %s %.1f,%.1f reason=%s", w.name, bestDist, tx, ty, w.name, w.x, w.y, reason or ""))
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

-- ------------------------------------------------------------
-- 刷怪点函数（关卡 2）
-- ------------------------------------------------------------

local function getEnemyPlayer()
    return Player:new(4)
end

-- 刷怪点布局：中心 nF22 两个（y+90/-90），x+90 上中下各一只 nHj3（间隔 90）
function Layer2.calcMobSpawn1Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn1Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心上方 y+90：nF22
    table.insert(positions, { x = cx, y = cy + spacing, id = "nF22" })
    -- 2. 中心下方 y-90：nF22
    table.insert(positions, { x = cx, y = cy - spacing, id = "nF22" })
    
    -- 3. x+90 开始，上中下各一只 nHj3（间隔 90）
    --   上方：x+90, y+90
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "nHj3" })
    --   中间：x+90, y
    table.insert(positions, { x = cx + spacing, y = cy, id = "nHj3" })
    --   下方：x+90, y-90
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "nHj3" })
    
    return positions
end

-- 新增刷怪点布局：中心 n91z，y+90 水平线左中右各一只 nHj3（间隔 90）
function Layer2.calcMobSpawn2Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn2Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：n91z
    table.insert(positions, { x = cx, y = cy, id = "n91z" })
    
    -- 2. y+90 水平线，左中右各一只 nHj3（间隔 90）
    --   左侧：x-90, y+90
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "nHj3" })
    --   中间：x, y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "nHj3" })
    --   右侧：x+90, y+90
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "nHj3" })
    
    return positions
end

-- ------------------------------------------------------------
-- 刷怪点 2 布局：中心上下 nF42，x-90 上中下 n485（间隔 90），默认朝向 180
-- ------------------------------------------------------------
function Layer2.calcMobSpawn3Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn3Pos.spacing or 90
    local positions = {}
    
    -- 1. x-90 为中心，上中下各一只 n485（间隔 90）
    --   上方：x-90, y+90
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "n485" })
    --   中间：x-90, y
    table.insert(positions, { x = cx - spacing, y = cy, id = "n485" })
    --   下方：x-90, y-90
    table.insert(positions, { x = cx - spacing, y = cy - spacing, id = "n485" })
    
    -- 2. 中心上下 nF42（间隔 90）
    --   上方：x, y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "nf42" })
    --   下方：x, y-90
    table.insert(positions, { x = cx, y = cy - spacing, id = "nf42" })
    
    return positions
end

-- ------------------------------------------------------------
-- 刷怪点 3 布局：中心 nv64，x+90 上中下 nf42（间隔 90），默认朝向 0
-- ------------------------------------------------------------
function Layer2.calcMobSpawn4Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn4Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：nv64
    table.insert(positions, { x = cx, y = cy, id = "nv64" })
    
    -- 2. x+90 为中心，上中下各一只 nf42（间隔 90）
    --   上方：x+90, y+90
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "nf42" })
    --   中间：x+90, y
    table.insert(positions, { x = cx + spacing, y = cy, id = "nf42" })
    --   下方：x+90, y-90
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "nf42" })
    
    return positions
end

-- ------------------------------------------------------------
-- 新增刷怪点 4 布局（坐标 -8502.5,-10848.3）：中心 +8 个 n02P，间隔 90 码
-- ------------------------------------------------------------
function Layer2.calcMobSpawn5Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn5Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：n02P
    table.insert(positions, { x = cx, y = cy, id = "n02P" })
    
    -- 2. 上下左右各一只 n02P（间隔 90）
    --   上方：y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "n02P" })
    --   下方：y-90
    table.insert(positions, { x = cx, y = cy - spacing, id = "n02P" })
    --   左侧：x-90
    table.insert(positions, { x = cx - spacing, y = cy, id = "n02P" })
    --   右侧：x+90
    table.insert(positions, { x = cx + spacing, y = cy, id = "n02P" })
    
    -- 3. 四个角各一只 n02P（形成正方形）
    --   左上：x-90, y+90
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "n02P" })
    --   右上：x+90, y+90
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "n02P" })
    --   左下：x-90, y-90
    table.insert(positions, { x = cx - spacing, y = cy - spacing, id = "n02P" })
    --   右下：x+90, y-90
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "n02P" })
    
    return positions
end

-- ------------------------------------------------------------
-- 刷怪点 5 布局（坐标 -10317.6,-11615.1）：中心 um5F，x+90 上中下 n02P，默认朝向 0
-- ------------------------------------------------------------
function Layer2.calcMobSpawn6Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn6Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：um5F
    table.insert(positions, { x = cx, y = cy, id = "um5F" })
    
    -- 2. x+90 为中心，上中下各一只 n02P（间隔 90）
    --   上方：x+90, y+90
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "n02P" })
    --   中间：x+90, y
    table.insert(positions, { x = cx + spacing, y = cy, id = "n02P" })
    --   下方：x+90, y-90
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "n02P" })
    
    return positions
end

-- ------------------------------------------------------------
-- 新增刷怪点 6 布局（坐标 -6683.9,-11611.7）：中心上下 u7v9，x-90 上中下 u8mo，默认朝向 180
-- ------------------------------------------------------------
function Layer2.calcMobSpawn7Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn7Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心上下各一只 u7v9（间隔 90）
    --   上方：x, y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "u7v9" })
    --   下方：x, y-90
    table.insert(positions, { x = cx, y = cy - spacing, id = "u7v9" })
    
    -- 2. x-90 为中心，上中下各一只 u8mo（间隔 90）
    --   上方：x-90, y+90
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "u8mo" })
    --   中间：x-90, y
    table.insert(positions, { x = cx - spacing, y = cy, id = "u8mo" })
    --   下方：x-90, y-90
    table.insert(positions, { x = cx - spacing, y = cy - spacing, id = "u8mo" })
    
    return positions
end

-- ------------------------------------------------------------
-- 新增刷怪点 7 布局（坐标 -10273.8,-13174.9）：中心 nM28，默认朝向 0
-- ------------------------------------------------------------
function Layer2.calcMobSpawn8Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn8Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：nM28
    table.insert(positions, { x = cx, y = cy, id = "nM28" })
    
    return positions
end

-- ------------------------------------------------------------
-- 刷怪点创建函数（关卡 2）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn1(cx, cy)
    cx = cx or Layer2.mobSpawn1Pos.x
    cy = cy or Layer2.mobSpawn1Pos.y
    local positions = Layer2.calcMobSpawn1Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn1()
    Layer2.mobSpawn1Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.mobSpawn1Units, u)
            u:setInvulnerable(true)
            u:pause(true)
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn1Invincible and u.addImmortal then
                pcall(function() u:addImmortal() end)
            end
            if u.setPauseState then
                pcall(function() u:setPauseState(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn1Units
    print(string.format("[Layer2] 刷怪点已创建 中心%.1f,%.1f nF22(2 个：y+90/-90) + nHj3(3 个：x+90 上中下) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawn1Units
end

function Layer2.spawnMobSpawn1(cx, cy)
    cx = cx or Layer2.mobSpawn1Pos.x
    cy = cy or Layer2.mobSpawn1Pos.y
    local positions = Layer2.calcMobSpawn1Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn1()
    Layer2.mobSpawn1Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.mobSpawn1Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn1Invincible and u.addImmortal then
                pcall(function() u:addImmortal() end)
            end
            if u.setPauseState then
                pcall(function() u:setPauseState(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn1Units
    print(string.format("[Layer2] 刷怪点已创建 中心%.1f,%.1f nF22(2 个：y+90/-90) + nHj3(3 个：x+90 上中下) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawn1Units
end

function Layer2.clearMobSpawn1()
    if not Layer2.mobSpawn1Units then Layer2.mobSpawn1Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn1Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn1Units
    Layer2.mobSpawn1Units = {}
    if n > 0 then print("[Layer2] 刷怪点已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn1()
    Layer2.clearMobSpawn1()
end

-- 激活刷怪点（移除无敌和暂停）
function Layer2.activateMobSpawn1()
    if not Layer2.mobSpawn1Units then return end
    for _, u in ipairs(Layer2.mobSpawn1Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 刷怪点已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点创建函数（关卡 2）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn2(cx, cy)
    cx = cx or Layer2.mobSpawn2Pos.x
    cy = cy or Layer2.mobSpawn2Pos.y
    local positions = Layer2.calcMobSpawn2Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn2()
    Layer2.mobSpawn2Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.mobSpawn2Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn2Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn2Units
    print(string.format("[Layer2] 新增刷怪点已创建 中心%.1f,%.1f n91z(1 个：中心) + nHj3(3 个：y+90 左中右) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawn2Units
end

function Layer2.clearMobSpawn2()
    if not Layer2.mobSpawn2Units then Layer2.mobSpawn2Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn2Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn2Units
    Layer2.mobSpawn2Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn2()
    Layer2.clearMobSpawn2()
end

-- 激活新增刷怪点（移除无敌和暂停）
function Layer2.activateMobSpawn2()
    if not Layer2.mobSpawn2Units then return end
    for _, u in ipairs(Layer2.mobSpawn2Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 新增刷怪点已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 刷怪点 2 创建函数（默认朝向 180）
-- ------------------------------------------------------------
function Layer2.spawnMobSpawn3(cx, cy)
    cx = cx or Layer2.mobSpawn3Pos.x
    cy = cy or Layer2.mobSpawn3Pos.y
    local positions = Layer2.calcMobSpawn3Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn3()
    Layer2.mobSpawn3Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180)
        if u then 
            table.insert(Layer2.mobSpawn3Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn3Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn3Units
    print(string.format("[Layer2] 刷怪点 2 已创建 中心%.1f,%.1f n485(3 个：x-90 上中下) + nf42(2 个：y+90/-90) count=%d (默认无敌且暂停，朝向 180)", cx, cy, count))
    return Layer2.mobSpawn3Units
end

function Layer2.clearMobSpawn3()
    if not Layer2.mobSpawn3Units then Layer2.mobSpawn3Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn3Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn3Units
    Layer2.mobSpawn3Units = {}
    if n > 0 then print("[Layer2] 刷怪点 2 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn3()
    Layer2.clearMobSpawn3()
end

-- 激活刷怪点 2（移除无敌和暂停）
function Layer2.activateMobSpawn3()
    if not Layer2.mobSpawn3Units then return end
    for _, u in ipairs(Layer2.mobSpawn3Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 刷怪点 2 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 刷怪点 3 创建函数（默认朝向 0）
-- ------------------------------------------------------------
function Layer2.spawnMobSpawn4(cx, cy)
    cx = cx or Layer2.mobSpawn4Pos.x
    cy = cy or Layer2.mobSpawn4Pos.y
    local positions = Layer2.calcMobSpawn4Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn4()
    Layer2.mobSpawn4Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 0)
        if u then 
            table.insert(Layer2.mobSpawn4Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn4Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn4Units
    print(string.format("[Layer2] 刷怪点 3 已创建 中心%.1f,%.1f nv64(1 个：中心) + nf42(3 个：x+90 上中下) count=%d (默认无敌且暂停，朝向 0)", cx, cy, count))
    return Layer2.mobSpawn4Units
end

function Layer2.clearMobSpawn4()
    if not Layer2.mobSpawn4Units then Layer2.mobSpawn4Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn4Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn4Units
    Layer2.mobSpawn4Units = {}
    if n > 0 then print("[Layer2] 刷怪点 3 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn4()
    Layer2.clearMobSpawn4()
end

-- 激活刷怪点 3（移除无敌和暂停）
function Layer2.activateMobSpawn4()
    if not Layer2.mobSpawn4Units then return end
    for _, u in ipairs(Layer2.mobSpawn4Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 刷怪点 3 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 4 创建函数（坐标 -8502.5,-10848.3，9 个 n02P）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn5(cx, cy)
    cx = cx or Layer2.mobSpawn5Pos.x
    cy = cy or Layer2.mobSpawn5Pos.y
    local positions = Layer2.calcMobSpawn5Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn5()
    Layer2.mobSpawn5Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180)
        if u then 
            table.insert(Layer2.mobSpawn5Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn5Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn5Units
    print(string.format("[Layer2] 新增刷怪点 4 已创建 中心%.1f,%.1f n02P(9 个：中心 +8 个) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawn5Units
end

function Layer2.clearMobSpawn5()
    if not Layer2.mobSpawn5Units then Layer2.mobSpawn5Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn5Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn5Units
    Layer2.mobSpawn5Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点 4 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn5()
    Layer2.clearMobSpawn5()
end

-- 激活新增刷怪点 4（移除无敌和暂停）
function Layer2.activateMobSpawn5()
    if not Layer2.mobSpawn5Units then return end
    for _, u in ipairs(Layer2.mobSpawn5Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 新增刷怪点 4 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 刷怪点 5 创建函数（坐标 -10317.6,-11615.1，中心 um5F + n02P(3 个)）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn6(cx, cy)
    cx = cx or Layer2.mobSpawn6Pos.x
    cy = cy or Layer2.mobSpawn6Pos.y
    local positions = Layer2.calcMobSpawn6Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn6()
    Layer2.mobSpawn6Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 0)
        if u then 
            table.insert(Layer2.mobSpawn6Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn6Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn6Units
    print(string.format("[Layer2] 刷怪点 5 已创建 中心%.1f,%.1f um5F(1 个：中心) + n02P(3 个：x+90 上中下) count=%d (默认无敌且暂停，朝向 0)", cx, cy, count))
    return Layer2.mobSpawn6Units
end

function Layer2.clearMobSpawn6()
    if not Layer2.mobSpawn6Units then Layer2.mobSpawn6Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn6Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn6Units
    Layer2.mobSpawn6Units = {}
    if n > 0 then print("[Layer2] 刷怪点 5 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn6()
    Layer2.clearMobSpawn6()
end

-- 激活刷怪点 5（移除无敌和暂停）
function Layer2.activateMobSpawn6()
    if not Layer2.mobSpawn6Units then return end
    for _, u in ipairs(Layer2.mobSpawn6Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 刷怪点 5 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 6 创建函数（坐标 -6683.9,-11611.7，中心上下 u7v9 + x-90 上中下 u8mo）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn7(cx, cy)
    cx = cx or Layer2.mobSpawn7Pos.x
    cy = cy or Layer2.mobSpawn7Pos.y
    local positions = Layer2.calcMobSpawn7Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn7()
    Layer2.mobSpawn7Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180)
        if u then 
            table.insert(Layer2.mobSpawn7Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn7Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn7Units
    print(string.format("[Layer2] 刷怪点 6 已创建 中心%.1f,%.1f u7v9(2 个：y+90/-90) + u8mo(3 个：x-90 上中下) count=%d (默认无敌且暂停，朝向 180)", cx, cy, count))
    return Layer2.mobSpawn7Units
end

function Layer2.clearMobSpawn7()
    if not Layer2.mobSpawn7Units then Layer2.mobSpawn7Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn7Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn7Units
    Layer2.mobSpawn7Units = {}
    if n > 0 then print("[Layer2] 刷怪点 6 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn7()
    Layer2.clearMobSpawn7()
end

-- 激活刷怪点 6（移除无敌和暂停）
function Layer2.activateMobSpawn7()
    if not Layer2.mobSpawn7Units then return end
    for _, u in ipairs(Layer2.mobSpawn7Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 刷怪点 6 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 7 创建函数（坐标 -10273.8,-13174.9，中心 nM28，默认朝向 0）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn8(cx, cy)
    cx = cx or Layer2.mobSpawn8Pos.x
    cy = cy or Layer2.mobSpawn8Pos.y
    local positions = Layer2.calcMobSpawn8Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn8()
    Layer2.mobSpawn8Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 0) -- 默认朝向 0
        if u then 
            table.insert(Layer2.mobSpawn8Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn8Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn8Units
    print(string.format("[Layer2] 新增刷怪点 7 已创建 中心%.1f,%.1f nM28(1 个：中心) count=%d (默认无敌且暂停，朝向 0)", cx, cy, count))
    return Layer2.mobSpawn8Units
end

function Layer2.clearMobSpawn8()
    if not Layer2.mobSpawn8Units then Layer2.mobSpawn8Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn8Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn8Units
    Layer2.mobSpawn8Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点 7 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn8()
    Layer2.clearMobSpawn8()
end

-- 激活新增刷怪点 7（移除无敌和暂停）
function Layer2.activateMobSpawn8()
    if not Layer2.mobSpawn8Units then return end
    for _, u in ipairs(Layer2.mobSpawn8Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 新增刷怪点 7 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 7 布局（坐标 -10290.0,-12379.8，中心 um5F + 上下 u7v9 + 左右 x±90 上中下 u8mo）
-- ------------------------------------------------------------
Layer2.mobSpawn9Pos = { x = -10290.0, y = -12379.8, spacing = 90, name = "关卡 2 新增刷怪点 7" }
Layer2.mobSpawn9Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn9Invincible = true
Layer2.mobSpawn9Paused = true

-- ------------------------------------------------------------
-- 新增刷怪点 8 布局（坐标 -8712.0,-12396.8，中心 n8Ti + 上下 nd96 + x-90 上中下 nd96）
-- ------------------------------------------------------------
Layer2.mobSpawn10Pos = { x = -8712.0, y = -12396.8, spacing = 90, name = "关卡 2 新增刷怪点 8" }
Layer2.mobSpawn10Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn10Invincible = true
Layer2.mobSpawn10Paused = true
-- 默认朝向：180

function Layer2.calcMobSpawn10Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn10Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：n8Ti
    table.insert(positions, { x = cx, y = cy, id = "n8Ti" })
    
    -- 2. 上下各一只 nd96（间隔 90）
    --   上方：x, y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "nd96" })
    --   下方：x, y-90
    table.insert(positions, { x = cx, y = cy - spacing, id = "nd96" })
    
    -- 3. x-90 为中心，上中下各一只 nd96（间隔 90）
    --   左侧 x-90：上方
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "nd96" })
    --   左侧 x-90：中间
    table.insert(positions, { x = cx - spacing, y = cy, id = "nd96" })
    --   左侧 x-90：下方
    table.insert(positions, { x = cx - spacing, y = cy - spacing, id = "nd96" })
    
    return positions
end

function Layer2.spawnMobSpawn10(cx, cy)
    cx = cx or Layer2.mobSpawn10Pos.x
    cy = cy or Layer2.mobSpawn10Pos.y
    local positions = Layer2.calcMobSpawn10Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn10()
    Layer2.mobSpawn10Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180) -- 默认朝向 180
        if u then 
            table.insert(Layer2.mobSpawn10Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn10Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
            
            -- 添加增强属性：最大生命 +20%，物理抗性 +20，攻击力 +20，生命值设为 35%
            -- 先获取当前最大值
            local maxLife = u:getState(UNIT_STATE_MAX_LIFE)  -- UNIT_MAX_LIFE
            local currentLife = u:getState(UNIT_STATE_LIFE)  -- UNIT_STATE_LIFE
            local armor = u:getState(UNIT_STATE_DEFEND_WHITE)  -- UNIT_STATE_DEFEND_WHITE (护甲)
            local attack = u:getState(UNIT_STATE_ATTACK_WHITE)  -- UNIT_STATE_ATTACK_WHITE (攻击力)
            
            -- 设置最大生命 +20%
            if u.addState then
                u:addState(UNIT_STATE_MAX_LIFE, math.floor(maxLife * 0.2))
            end
            
            -- 设置当前生命为 35% 的最大生命
            local newMaxLife = maxLife * 1.2
            local targetCurrentLife = newMaxLife * 0.35
            if u.addState then
                u:addState(UNIT_STATE_LIFE, math.floor(targetCurrentLife - currentLife))
            end
            
            -- 设置物理抗性 +20%（护甲）
            if armor >= 0 then
                local newArmor = math.floor(armor * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_DEFEND_WHITE, newArmor - armor)
                end
            else
                -- 负护甲情况
                local newArmor = math.floor(armor * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_DEFEND_WHITE, newArmor - armor)
                end
            end
            
            -- 设置攻击力 +20%
            if attack > 0 then
                local newAttack = math.floor(attack * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_ATTACK_WHITE, newAttack - attack)
                end
            end
            
            -- add 属性标记（用于识别增强单位）
            if u.add then
                u:add("EnhancedUnit")
            end
        end
    end
    
    local count = #Layer2.mobSpawn10Units
    print(string.format("[Layer2] 新增刷怪点 8 已创建 中心%.1f,%.1f n8Ti(1 个：中心) + nd96(5 个：上下 +x-90 上中下) count=%d (默认无敌且暂停，朝向 180，增强属性)", cx, cy, count))
    return Layer2.mobSpawn10Units
end

function Layer2.clearMobSpawn10()
    if not Layer2.mobSpawn10Units then Layer2.mobSpawn10Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn10Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn10Units
    Layer2.mobSpawn10Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点 8 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn10()
    Layer2.clearMobSpawn10()
end

-- 激活刷怪点 8（移除无敌和暂停）
function Layer2.activateMobSpawn10()
    if not Layer2.mobSpawn10Units then return end
    for _, u in ipairs(Layer2.mobSpawn10Units) do 
        if u and u.setInvulnerable then pcall(function() u:setInvulnerable(false) end) end
        if u.pause then pcall(function() u:pause(false) end) end
    end
    print("[Layer2] 新增刷怪点 8 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 7 布局（坐标 -10290.0,-12379.8，中心 um5F + 上下 u7v9 + 左右 x±90 上中下 u8mo）
-- ------------------------------------------------------------

function Layer2.calcMobSpawn9Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn9Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：um5F
    table.insert(positions, { x = cx, y = cy, id = "um5F" })
    
    -- 2. 上下各一只 u7v9（间隔 90）
    --   上方：x, y+90
    table.insert(positions, { x = cx, y = cy + spacing, id = "u7v9" })
    --   下方：x, y-90
    table.insert(positions, { x = cx, y = cy - spacing, id = "u7v9" })
    
    -- 3. x±90 为中心，上中下各一只 u8mo（间隔 90）
    --   左侧 x-90：上中下
    table.insert(positions, { x = cx - spacing, y = cy + spacing, id = "u8mo" })
    table.insert(positions, { x = cx - spacing, y = cy, id = "u8mo" })
    table.insert(positions, { x = cx - spacing, y = cy - spacing, id = "u8mo" })
    
    --   右侧 x+90：上中下
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "u8mo" })
    table.insert(positions, { x = cx + spacing, y = cy, id = "u8mo" })
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "u8mo" })
    
    return positions
end

function Layer2.spawnMobSpawn9(cx, cy)
    cx = cx or Layer2.mobSpawn9Pos.x
    cy = cy or Layer2.mobSpawn9Pos.y
    local positions = Layer2.calcMobSpawn9Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn9()
    Layer2.mobSpawn9Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 0) -- 默认朝向 0
        if u then 
            table.insert(Layer2.mobSpawn9Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn9Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
            
            -- 添加增强属性：最大生命 +20%，物理抗性 +20，攻击力 +20，生命值设为 35%
            -- 先获取当前最大值
            local maxLife = u:getState(UNIT_STATE_MAX_LIFE)  -- UNIT_MAX_LIFE
            local currentLife = u:getState(UNIT_STATE_LIFE)  -- UNIT_STATE_LIFE
            local armor = u:getState(UNIT_STATE_DEFEND_WHITE)  -- UNIT_STATE_DEFEND_WHITE (护甲)
            local attack = u:getState(UNIT_STATE_ATTACK_WHITE)  -- UNIT_STATE_ATTACK_WHITE (攻击力)
            
            -- 设置最大生命 +20%
            if u.addState then
                u:addState(UNIT_STATE_MAX_LIFE, math.floor(maxLife * 0.2))
            end
            
            -- 设置当前生命为 35% 的最大生命
            local newMaxLife = maxLife * 1.2
            local targetCurrentLife = newMaxLife * 0.35
            if u.addState then
                u:addState(UNIT_STATE_LIFE, math.floor(targetCurrentLife - currentLife))
            end
            
            -- 设置物理抗性 +20%（护甲）
            if armor >= 0 then
                local newArmor = math.floor(armor * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_DEFEND_WHITE, newArmor - armor)
                end
            else
                -- 负护甲情况
                local newArmor = math.floor(armor * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_DEFEND_WHITE, newArmor - armor)
                end
            end
            
            -- 设置攻击力 +20%
            if attack > 0 then
                local newAttack = math.floor(attack * 1.2)
                if u.addState then
                    u:addState(UNIT_STATE_ATTACK_WHITE, newAttack - attack)
                end
            end
            
            -- add 属性标记（用于识别增强单位）
            if u.add then
                u:add("EnhancedUnit")
            end
        end
    end
    
    local count = #Layer2.mobSpawn9Units
    print(string.format("[Layer2] 新增刷怪点 7 已创建 中心%.1f,%.1f um5F(1 个：中心) + u7v9(2 个：y+90/-90) + u8mo(6 个：x±90 上中下) count=%d (默认无敌且暂停，朝向 0，增强属性)", cx, cy, count))
    return Layer2.mobSpawn9Units
end

function Layer2.clearMobSpawn9()
    if not Layer2.mobSpawn9Units then Layer2.mobSpawn9Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn9Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn9Units
    Layer2.mobSpawn9Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点 7 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn9()
    Layer2.clearMobSpawn9()
end

-- 激活新增刷怪点 7（移除无敌和暂停）
function Layer2.activateMobSpawn9()
    if not Layer2.mobSpawn9Units then return end
    for _, u in ipairs(Layer2.mobSpawn9Units) do
        if u and u.setInvulnerable then
            pcall(function() u:setInvulnerable(false) end)
        end
        if u.pause then
            pcall(function() u:pause(false) end)
        end
    end
    print("[Layer2] 新增刷怪点 7 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 新增刷怪点 9 配置（关卡 2 - 坐标 -8720.5,-13157.2，中心 nn13，默认朝向 180）
-- ------------------------------------------------------------
Layer2.mobSpawn11Pos = { x = -8720.5, y = -13157.2, spacing = 90, name = "关卡 2 新增刷怪点 9" }
Layer2.mobSpawn11Units = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawn11Invincible = true
Layer2.mobSpawn11Paused = true
-- 默认朝向：180

function Layer2.calcMobSpawn11Grid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawn11Pos.spacing or 90
    local positions = {}
    
    -- 1. 中心位置：nn13
    table.insert(positions, { x = cx, y = cy, id = "nn13" })
    
    return positions
end

function Layer2.spawnMobSpawn11(cx, cy)
    cx = cx or Layer2.mobSpawn11Pos.x
    cy = cy or Layer2.mobSpawn11Pos.y
    local positions = Layer2.calcMobSpawn11Grid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn11()
    Layer2.mobSpawn11Units = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180) -- 默认朝向 180
        if u then 
            table.insert(Layer2.mobSpawn11Units, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawn11Invincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawn11Units
    print(string.format("[Layer2] 新增刷怪点 9 已创建 中心%.1f,%.1f nn13(1 个：中心) count=%d (默认无敌且暂停，朝向 180)", cx, cy, count))
    return Layer2.mobSpawn11Units
end

function Layer2.clearMobSpawn11()
    if not Layer2.mobSpawn11Units then Layer2.mobSpawn11Units = {} return end
    for _, u in ipairs(Layer2.mobSpawn11Units) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawn11Units
    Layer2.mobSpawn11Units = {}
    if n > 0 then print("[Layer2] 新增刷怪点 9 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn11()
    Layer2.clearMobSpawn11()
end

-- 激活新增刷怪点 9（移除无敌和暂停）
function Layer2.activateMobSpawn11()
    if not Layer2.mobSpawn11Units then return end
    for _, u in ipairs(Layer2.mobSpawn11Units) do 
        if u and u.setInvulnerable then pcall(function() u:setInvulnerable(false) end) end
        if u.pause then pcall(function() u:pause(false) end) end
    end
    print("[Layer2] 新增刷怪点 9 已激活（移除无敌和暂停）")
end

-- ------------------------------------------------------------
-- 生命周期
-- ------------------------------------------------------------
Layer2.started = false

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    Layer2.createWalls()
    
    -- 初始化刷怪点（默认无敌且暂停）
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
    
    -- TODO: 关卡 2 营地、Boss 等后续扩展
end

function Layer2.shutdown()
    if not Layer2.started then return end
    Layer2.started = false
    Layer2.destroyWalls()
    print("[Layer2] 关闭")
end

return Layer2
