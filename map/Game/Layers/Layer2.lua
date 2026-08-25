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
Layer2.mobSpawnPos = { x = -12200.2, y = -9890.9, spacing = 90, name = "关卡 2 刷怪点" }
Layer2.mobSpawnUnits = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawnInvincible = true
Layer2.mobSpawnPaused = true

-- ------------------------------------------------------------
-- 新增刷怪点配置（关卡 2）
-- ------------------------------------------------------------
Layer2.newMobSpawnPos = { x = -11205.7, y = -10873.9, spacing = 90, name = "关卡 2 新增刷怪点" }
Layer2.newMobSpawnUnits = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.newMobSpawnInvincible = true
Layer2.newMobSpawnPaused = true

-- ------------------------------------------------------------
-- 新增刷怪点配置（关卡 2 - 坐标 -8682.9,-10097.1）
-- ------------------------------------------------------------
Layer2.mobSpawnPos2 = { x = -8682.9, y = -10097.1, spacing = 90, name = "关卡 2 刷怪点 2" }
Layer2.mobSpawnUnits2 = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawnInvincible2 = true
Layer2.mobSpawnPaused2 = true
-- 默认朝向：180

-- ------------------------------------------------------------
-- 新增刷怪点 3 配置（关卡 2 - 坐标 -10264.8,-10858.6）
-- ------------------------------------------------------------
Layer2.mobSpawnPos3 = { x = -10264.8, y = -10858.6, spacing = 90, name = "关卡 2 刷怪点 3" }
Layer2.mobSpawnUnits3 = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.mobSpawnInvincible3 = true
Layer2.mobSpawnPaused3 = true
-- 默认朝向：0

-- ------------------------------------------------------------
-- 新增刷怪点 4 配置（关卡 2 - 坐标 -8502.5,-10848.3）
-- ------------------------------------------------------------
Layer2.newMobSpawnPos4 = { x = -8502.5, y = -10848.3, spacing = 90, name = "关卡 2 新增刷怪点 4" }
Layer2.newMobSpawnUnits4 = {} -- 运行时句柄列表

-- 默认无敌且暂停，待激活后恢复
Layer2.newMobSpawnInvincible4 = true
Layer2.newMobSpawnPaused4 = true

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
function Layer2.calcMobSpawnGrid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawnPos.spacing or 90
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
function Layer2.calcNewMobSpawnGrid(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.newMobSpawnPos.spacing or 90
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
function Layer2.calcMobSpawnGrid2(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawnPos2.spacing or 90
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
function Layer2.calcMobSpawnGrid3(cx, cy)
    if not cx or not cy then return {} end
    local spacing = Layer2.mobSpawnPos3.spacing or 90
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
function Layer2.calcNewMobSpawnGrid4(cx, cy)
    if not cx or not cy then return {} end
    local spacing = 90
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
-- 刷怪点创建函数（关卡 2）
-- ------------------------------------------------------------

function Layer2.spawnMobSpawn(cx, cy)
    cx = cx or Layer2.mobSpawnPos.x
    cy = cy or Layer2.mobSpawnPos.y
    local positions = Layer2.calcMobSpawnGrid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn()
    Layer2.mobSpawnUnits = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.mobSpawnUnits, u)
            u:setInvulnerable(true)
            u:pause(true)
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawnInvincible and u.addImmortal then
                pcall(function() u:addImmortal() end)
            end
            if u.setPauseState then
                pcall(function() u:setPauseState(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawnUnits
    print(string.format("[Layer2] 刷怪点已创建 中心%.1f,%.1f nF22(2 个：y+90/-90) + nHj3(3 个：x+90 上中下) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawnUnits
end

function Layer2.spawnMobSpawn(cx, cy)
    cx = cx or Layer2.mobSpawnPos.x
    cy = cy or Layer2.mobSpawnPos.y
    local positions = Layer2.calcMobSpawnGrid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn()
    Layer2.mobSpawnUnits = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.mobSpawnUnits, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawnInvincible and u.addImmortal then
                pcall(function() u:addImmortal() end)
            end
            if u.setPauseState then
                pcall(function() u:setPauseState(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawnUnits
    print(string.format("[Layer2] 刷怪点已创建 中心%.1f,%.1f nF22(2 个：y+90/-90) + nHj3(3 个：x+90 上中下) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.mobSpawnUnits
end

function Layer2.clearMobSpawn()
    if not Layer2.mobSpawnUnits then Layer2.mobSpawnUnits = {} return end
    for _, u in ipairs(Layer2.mobSpawnUnits) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawnUnits
    Layer2.mobSpawnUnits = {}
    if n > 0 then print("[Layer2] 刷怪点已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn()
    Layer2.clearMobSpawn()
end

-- 激活刷怪点（移除无敌和暂停）
function Layer2.activateMobSpawn()
    if not Layer2.mobSpawnUnits then return end
    for _, u in ipairs(Layer2.mobSpawnUnits) do
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

function Layer2.spawnNewMobSpawn(cx, cy)
    cx = cx or Layer2.newMobSpawnPos.x
    cy = cy or Layer2.newMobSpawnPos.y
    local positions = Layer2.calcNewMobSpawnGrid(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearNewMobSpawn()
    Layer2.newMobSpawnUnits = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.newMobSpawnUnits, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.newMobSpawnInvincible and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.newMobSpawnUnits
    print(string.format("[Layer2] 新增刷怪点已创建 中心%.1f,%.1f n91z(1 个：中心) + nHj3(3 个：y+90 左中右) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.newMobSpawnUnits
end

function Layer2.clearNewMobSpawn()
    if not Layer2.newMobSpawnUnits then Layer2.newMobSpawnUnits = {} return end
    for _, u in ipairs(Layer2.newMobSpawnUnits) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.newMobSpawnUnits
    Layer2.newMobSpawnUnits = {}
    if n > 0 then print("[Layer2] 新增刷怪点已清理 count=" .. n) end
end

function Layer2.destroyNewMobSpawn()
    Layer2.clearNewMobSpawn()
end

-- 激活新增刷怪点（移除无敌和暂停）
function Layer2.activateNewMobSpawn()
    if not Layer2.newMobSpawnUnits then return end
    for _, u in ipairs(Layer2.newMobSpawnUnits) do
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
function Layer2.spawnMobSpawn2(cx, cy)
    cx = cx or Layer2.mobSpawnPos2.x
    cy = cy or Layer2.mobSpawnPos2.y
    local positions = Layer2.calcMobSpawnGrid2(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn2()
    Layer2.mobSpawnUnits2 = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 180)
        if u then 
            table.insert(Layer2.mobSpawnUnits2, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawnInvincible2 and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawnUnits2
    print(string.format("[Layer2] 刷怪点 2 已创建 中心%.1f,%.1f n485(3 个：x-90 上中下) + nf42(2 个：y+90/-90) count=%d (默认无敌且暂停，朝向 180)", cx, cy, count))
    return Layer2.mobSpawnUnits2
end

function Layer2.clearMobSpawn2()
    if not Layer2.mobSpawnUnits2 then Layer2.mobSpawnUnits2 = {} return end
    for _, u in ipairs(Layer2.mobSpawnUnits2) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawnUnits2
    Layer2.mobSpawnUnits2 = {}
    if n > 0 then print("[Layer2] 刷怪点 2 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn2()
    Layer2.clearMobSpawn2()
end

-- 激活刷怪点 2（移除无敌和暂停）
function Layer2.activateMobSpawn2()
    if not Layer2.mobSpawnUnits2 then return end
    for _, u in ipairs(Layer2.mobSpawnUnits2) do
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
function Layer2.spawnMobSpawn3(cx, cy)
    cx = cx or Layer2.mobSpawnPos3.x
    cy = cy or Layer2.mobSpawnPos3.y
    local positions = Layer2.calcMobSpawnGrid3(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearMobSpawn3()
    Layer2.mobSpawnUnits3 = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 0)
        if u then 
            table.insert(Layer2.mobSpawnUnits3, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.mobSpawnInvincible3 and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.mobSpawnUnits3
    print(string.format("[Layer2] 刷怪点 3 已创建 中心%.1f,%.1f nv64(1 个：中心) + nf42(3 个：x+90 上中下) count=%d (默认无敌且暂停，朝向 0)", cx, cy, count))
    return Layer2.mobSpawnUnits3
end

function Layer2.clearMobSpawn3()
    if not Layer2.mobSpawnUnits3 then Layer2.mobSpawnUnits3 = {} return end
    for _, u in ipairs(Layer2.mobSpawnUnits3) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.mobSpawnUnits3
    Layer2.mobSpawnUnits3 = {}
    if n > 0 then print("[Layer2] 刷怪点 3 已清理 count=" .. n) end
end

function Layer2.destroyMobSpawn3()
    Layer2.clearMobSpawn3()
end

-- 激活刷怪点 3（移除无敌和暂停）
function Layer2.activateMobSpawn3()
    if not Layer2.mobSpawnUnits3 then return end
    for _, u in ipairs(Layer2.mobSpawnUnits3) do
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

function Layer2.spawnNewMobSpawn4(cx, cy)
    cx = cx or Layer2.newMobSpawnPos4.x
    cy = cy or Layer2.newMobSpawnPos4.y
    local positions = Layer2.calcNewMobSpawnGrid4(cx, cy)
    local p = getEnemyPlayer()
    
    -- 清理旧的
    Layer2.clearNewMobSpawn4()
    Layer2.newMobSpawnUnits4 = {}
    
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, 270)
        if u then 
            table.insert(Layer2.newMobSpawnUnits4, u)
            
            -- 默认无敌且暂停（待激活后恢复）
            if Layer2.newMobSpawnInvincible4 and u.setInvulnerable then
                pcall(function() u:setInvulnerable(true) end)
            end
            if u.pause then
                pcall(function() u:pause(true) end)
            end
        end
    end
    
    local count = #Layer2.newMobSpawnUnits4
    print(string.format("[Layer2] 新增刷怪点 4 已创建 中心%.1f,%.1f n02P(9 个：中心 +8 个) count=%d (默认无敌且暂停)", cx, cy, count))
    return Layer2.newMobSpawnUnits4
end

function Layer2.clearNewMobSpawn4()
    if not Layer2.newMobSpawnUnits4 then Layer2.newMobSpawnUnits4 = {} return end
    for _, u in ipairs(Layer2.newMobSpawnUnits4) do 
        if u and u.destroy then u:destroy() end 
    end
    local n = #Layer2.newMobSpawnUnits4
    Layer2.newMobSpawnUnits4 = {}
    if n > 0 then print("[Layer2] 新增刷怪点 4 已清理 count=" .. n) end
end

function Layer2.destroyNewMobSpawn4()
    Layer2.clearNewMobSpawn4()
end

-- 激活新增刷怪点 4（移除无敌和暂停）
function Layer2.activateNewMobSpawn4()
    if not Layer2.newMobSpawnUnits4 then return end
    for _, u in ipairs(Layer2.newMobSpawnUnits4) do
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
-- 生命周期
-- ------------------------------------------------------------
Layer2.started = false

-- 关卡 2 默认技能配置（示例：可根据需要调整）
-- Hmkg (剑圣) 默认技能：AHab (旋风斩), AHju (醉酒猛击)
-- Hfrc (山丘之王) 默认技能：AABi (巨人之握), AAGj (跳刀)
Layer2.heroDefaultSkills = {
    -- 英雄 ID -> 默认技能列表（技能 ID）
    ["Hmkg"] = {"AHab", "AHju"},  -- 剑圣：旋风斩 + 醉酒猛击
    ["Hfrc"] = {"AABi", "AAGj"},  -- 山丘之王：巨人之握 + 跳刀
    ["Hcrs"] = {"AAEi", "AAMj"},  -- 水晶射手：闪电链 + 静默（示例）
    ["Hwarp"] = {},               -- 变形虫：无默认技能
}

-- 关卡 2 默认属性加成（可选，根据需求调整）
Layer2.heroDefaultAttrs = {
    Hmkg = { str = 0, agi = 5, int = 0 },   -- 剑圣：敏捷 +5
    Hfrc = { str = 3, agi = 0, int = 0 },   -- 山丘之王：力量 +3
    Hcrs = { str = 2, agi = 2, int = 2 },   -- 水晶射手：三项各 +2
    Hwarp = { str = 0, agi = 0, int = 0 },  -- 变形虫：无加成
}

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    Layer2.createWalls()
    
    -- 初始化刷怪点（默认无敌且暂停）
    Layer2.spawnMobSpawn()
    Layer2.spawnNewMobSpawn()
    Layer2.spawnMobSpawn2()
    Layer2.spawnMobSpawn3()
    Layer2.spawnNewMobSpawn4()
    
    -- 【问题 3 修复】重置所有玩家英雄的技能为关卡 2 默认配置
    Layer2.resetHeroSkills()
    
    -- TODO: 关卡 2 营地、Boss 等后续扩展
end

-- 重置所有玩家英雄的技能（供关卡切换时调用）- 简化版，避免卡死
function Layer2.resetHeroSkills()
    print("[Layer2] 开始重置英雄技能...")
    
    -- 简单处理：只遍历所有玩家的英雄并学习默认技能
    for pid = 0, 3 do
        local player = Player:new(pid)
        if not player:isPlaying() then goto continue end
        
        -- 获取该玩家的所有英雄
        local g = cj.CreateGroup()
        cj.GroupEnumUnitsOfPlayer(g, player._handle, nil)
        
        local u = cj.FirstOfGroup(g)
        while u ~= nil do
            if cj.IsUnitType(u, UNIT_TYPE_HERO) then
                -- 创建 Hero 对象
                local hero = Hero.fromUnit(u)
                if not hero or not hero._handle then
                    cj.GroupRemoveUnit(g, u)
                    u = cj.FirstOfGroup(g)
                    goto continue
                end
                
                local heroIdStr = i2c(cj.GetUnitTypeId(hero._handle))
                
                -- 学习关卡 2 的默认技能（如果有的话）
                local defaultSkills = Layer2.heroDefaultSkills[heroIdStr] or {}
                for _, skillId in ipairs(defaultSkills) do
                    if cj.IsAbilityId(skillId) then
                        hero:learn(skillId)
                    end
                end
                
                -- 应用默认属性加成（如果有的话）
                local defaultAttrs = Layer2.heroDefaultAttrs[heroIdStr] or {}
                if defaultAttrs.str ~= nil and hero.setStr then
                    hero:setStr(defaultAttrs.str)
                end
                if defaultAttrs.agi ~= nil and hero.setAgi then
                    hero:setAgi(defaultAttrs.agi)
                end
                if defaultAttrs.int ~= nil and hero.setInt then
                    hero:setInt(defaultAttrs.int)
                end
            end
            
            cj.GroupRemoveUnit(g, u)
            u = cj.FirstOfGroup(g)
        end
        
        cj.DestroyGroup(g)
        ::continue::
    end
    
    print("[Layer2] 英雄技能重置完成")
end

function Layer2.shutdown()
    if not Layer2.started then return end
    Layer2.started = false
    Layer2.destroyWalls()
    print("[Layer2] 关闭")
end

return Layer2
