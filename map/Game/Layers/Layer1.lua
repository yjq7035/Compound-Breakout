-- ============================================================
-- Layer1 — 第一关卡模块
--
-- 归属：Game/Layers/  战役关卡模块目录
-- 职责：
--   1. 存放第一关卡所有坐标集合（Layer1Area）
--   2. 封装关卡力量墙的创建/销毁（可破坏物，非单位）
--   3. 提供关卡生命周期入口：Layer1.createWalls / Layer1.destroyWalls
--
-- 坐标来源（用户提供，2026-08-23）：
--   1. -11147.3, -12794.7  横墙  B000 parent Dofw FixedRot 270
--   2. -13345.1, -11943.7  竖墙  DL84 parent Dofw FixedRot 0
--   3. -11393.4, -14058.5  竖墙  DL84
--   4. -9975.7,  -14137.8  竖墙  DL84
--   5. -9350.8,  -15071.1  竖墙  DL84
-- 营地坐标（2026-08-24）：
--   1. -11578.3, -12966.9
--   2. -12011.9, -10722.1
--   3. -13559.1, -10209.1
--   4. -15028.4, -12065.9
--   5. -10819.0, -14009.4
--   6. -8626.4,  -15303.5
-- Boss坐标（2026-08-24）：
--   1号Boss -14868.4, -10349.3
--   2号Boss -10250.5, -14186.0
--   3号Boss -8835.9,  -14844.6
-- 复活/商店坐标（2026-08-24）：
--   复活点 -11787.8, -14967.1
--   药剂商店 -11388.4, -14565.7
-- Boss仆从（2026-08-24）：
--   1号 以 -14300.2,-10995.4 为中心宫格 N个 间隔35
--   2号 以boss面向前100码为起点，宫格4个：起点左右2个，推前35再2个
--   3号 以boss为中心宫格 N个 间隔35
--
-- 调用：
--   require "Game.Layers.Layer1"
--   Layer1.createWalls()   -- 创建5面力量墙
--   Layer1.destroyWalls()  -- 移除5面墙
--   Layer1.camps           -- 6个营地坐标 {x,y}
--   Layer1.bosses          -- 3个Boss坐标 {x,y}
--   Layer1.revivePos       -- 复活坐标 {x,y}
--   Layer1.potionShopPos   -- 药剂商店坐标 {x,y}
--   Layer1.bossMinions     -- Boss仆从配置 + 宫格公式
--   Layer1.calcGridPositions(cx,cy,N,35)  -- 通用宫格
--   Layer1.getBossMinionPositions(bossIndex,bossX,bossY,facing,N) -- 按Boss规则取坐标
-- ============================================================

Layer1 = {}
Layer1.__index = Layer1

-- ------------------------------------------------------------
-- 墙体定义（非单位：可破坏物 destructable）
-- B000 = 横墙，DL84 = 竖墙，见 table/destructable.ini
-- ------------------------------------------------------------
Layer1.WALL_H = "B000"
Layer1.WALL_V = "DL84"

--- 第一关卡墙体坐标表（对外暴露，供编辑器/调试使用）
--- 字段：x, y, id, dir
Layer1.walls = {
    { x = -11147.3, y = -12794.7, id = "B000", dir = "H", face = 270, name = "横墙1" },
    { x = -13345.1, y = -11943.7, id = "DL84", dir = "V", face = 0,   name = "竖墙1" },
    { x = -11393.4, y = -14058.5, id = "DL84", dir = "V", face = 0,   name = "竖墙2" },
    { x = -9975.7,  y = -14137.8, id = "DL84", dir = "V", face = 0,   name = "竖墙3" },
    { x = -9350.8,  y = -15071.1, id = "DL84", dir = "V", face = 0,   name = "竖墙4" },
}

-- 兼容旧全局：Layer1Area = 第一关卡坐标集合（供 GameCoords.lua 迁移前代码访问）
Layer1Area = Layer1.walls

-- ------------------------------------------------------------
-- 营地坐标（6个，供刷怪/任务/据点使用）
-- ------------------------------------------------------------
Layer1.camps = {
    { x = -11578.3, y = -12966.9, name = "营地1" },
    { x = -12011.9, y = -10722.1, name = "营地2" },
    { x = -13559.1, y = -10209.1, name = "营地3" },
    { x = -15028.4, y = -12065.9, name = "营地4" },
    { x = -10819.0, y = -14009.4, name = "营地5" },
    { x = -8626.4,  y = -15303.5, name = "营地6" },
}
-- 兼容全局：Layer1Camps
Layer1Camps = Layer1.camps
Layer1CampPos = Layer1.camps

-- ------------------------------------------------------------
-- Boss 坐标（3个）
-- ------------------------------------------------------------
Layer1.bosses = {
    { x = -14868.4, y = -10349.3, name = "1号Boss" },
    { x = -10250.5, y = -14186.0, name = "2号Boss" },
    { x = -8835.9,  y = -14844.6, name = "3号Boss" },
}
-- 兼容全局
Layer1BossPos = Layer1.bosses
Layer1Bosses = Layer1.bosses

-- ------------------------------------------------------------
-- 复活点 / 功能商店坐标
-- ------------------------------------------------------------
Layer1.revivePos = { x = -11787.8, y = -14967.1, name = "复活点" }
Layer1.potionShopPos = { x = -11388.4, y = -14565.7, name = "药剂商店" }
-- 兼容全局
Layer1RevivePos = Layer1.revivePos
Layer1PotionShopPos = Layer1.potionShopPos

-- ------------------------------------------------------------
-- Boss 仆从配置（N 待定，可随意调整）
-- ------------------------------------------------------------
Layer1.bossMinionSpacing = 35
Layer1.bossMinions = {
    -- 1号：以固定中心为中心宫格，N可变，间隔35
    [1] = { center = { x = -14300.2, y = -10995.4 }, spacing = 35, name = "1号仆从" },
    -- 2号：无固定中心，以boss面向前100码为起点宫格，固定4个
    [2] = { forward = 100, spacing = 35, count = 4, name = "2号仆从" },
    -- 3号：以boss为中心宫格，N可变，间隔35
    [3] = { center = "boss", spacing = 35, name = "3号仆从" },
}
-- 兼容全局
Layer1BossMinions = Layer1.bossMinions

-- ------------------------------------------------------------
-- 单位ID分配（2026-08-24）
-- ------------------------------------------------------------
Layer1.campId    = "h9Z4" -- 营地建筑
Layer1.guardId   = "hlc4" -- 营地狱卒（hlc4绑定营地，每30秒刷新）
Layer1.boss1Id   = "h31v" -- 1号Boss 狱士长
Layer1.minionId  = "hbaj" -- Boss仆从 狱士（1号Boss仆从宫格）
-- 兼容全局
Layer1CampId   = Layer1.campId
Layer1GuardId  = Layer1.guardId
Layer1Boss1Id  = Layer1.boss1Id
Layer1MinionId = Layer1.minionId

-- 运行时：营地 / Boss
Layer1.handles = {}    -- { destructable handle, ... }
Layer1.campData = {}   -- [campIndex] = { camp=Unit, guards={Unit,...}, timer=Timer, x,y }
Layer1.boss1Unit = nil -- Unit
Layer1.boss1Minions = {} -- { Unit, ... }

-- ------------------------------------------------------------
-- 内部：单面墙创建
-- ------------------------------------------------------------
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    -- cj.CreateDestructable(objectId, x, y, face, scale, variation)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then
        print(string.format("[Layer1] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else
        print(string.format("[Layer1] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y))
    end
    return h
end

--- 创建第一关卡所有力量墙（幂等：已存在则跳过）
---@return table handles
function Layer1.createWalls()
    if #Layer1.handles > 0 then
        print("[Layer1] 墙体已存在，跳过重复创建 count=" .. #Layer1.handles)
        return Layer1.handles
    end
    Layer1.handles = {}
    for _, w in ipairs(Layer1.walls) do
        local h = createOne(w)
        if h then table.insert(Layer1.handles, h) end
    end
    print("[Layer1] 第一关卡墙体创建完成 count=" .. #Layer1.handles .. "/5")
    return Layer1.handles
end

--- 移除第一关卡所有力量墙
function Layer1.destroyWalls()
    for _, h in ipairs(Layer1.handles) do
        if h then
            cj.RemoveDestructable(h)
        end
    end
    local n = #Layer1.handles
    Layer1.handles = {}
    print("[Layer1] 第一关卡墙体已移除 count=" .. n)
end

--- 获取墙体数量
---@return integer
function Layer1.getCount()
    return #Layer1.handles
end

--- 是否已创建
---@return boolean
function Layer1.isCreated()
    return #Layer1.handles > 0
end

-- ============================================================
-- Boss 仆从宫格公式
-- ============================================================

--- 通用宫格：以 (cx,cy) 为中心，N个点，间隔 spacing，行列尽量方正、居中对称
---@param cx number 中心X
---@param cy number 中心Y
---@param count integer 数量 N
---@param spacing number 间隔码，默认35
---@return table positions {{x,y},...}
function Layer1.calcGridPositions(cx, cy, count, spacing)
    if not cx or not cy or not count or count <= 0 then return {} end
    spacing = spacing or Layer1.bossMinionSpacing or 35
    -- 行列：cols=ceil(sqrt(N)), rows=ceil(N/cols)，最接近正方形
    local cols = math.ceil(math.sqrt(count))
    local rows = math.ceil(count / cols)
    -- 居中偏移：(cols-1)/2 * spacing
    local offsetX0 = (cols - 1) * spacing * 0.5
    local offsetY0 = (rows - 1) * spacing * 0.5
    local positions = {}
    for i = 0, count - 1 do
        local r = math.floor(i / cols)
        local c = i % cols
        local x = cx - offsetX0 + c * spacing
        local y = cy - offsetY0 + r * spacing
        table.insert(positions, { x = x, y = y })
    end
    return positions
end

--- 2号专用：以boss面向前100码为起点，4个宫格（起点左右2个，推前35再2个）
--- 布局（面向角 facingDeg，0度=正东）：
---   起点 = boss + facing*100
---   第一排：起点 + left/right * (spacing*0.5)  （左右各1，横向间距=spacing）
---   第二排：起点 + facing*spacing + left/right * (spacing*0.5)
---@param bossX number Boss X
---@param bossY number Boss Y
---@param facingDeg number Boss面向角度 0-360
---@param forward number 前伸距离 默认100
---@param spacing number 间隔 默认35
---@return table positions {{x,y},...} 4个
function Layer1.calcBoss2ForwardGrid(bossX, bossY, facingDeg, forward, spacing)
    if not bossX or not bossY then return {} end
    forward = forward or 100
    spacing = spacing or Layer1.bossMinionSpacing or 35
    facingDeg = facingDeg or 0
    local rad = math.rad(facingDeg)
    local cosA = math.cos(rad)
    local sinA = math.sin(rad)
    -- 前向单位向量 (cos, sin)，左向 = (-sin, cos)
    local startX = bossX + cosA * forward
    local startY = bossY + sinA * forward
    -- 半间距用于左右偏移
    local half = spacing * 0.5
    local lx, ly = -sinA * half, cosA * half  -- 左半间距
    local rx, ry = sinA * half, -cosA * half -- 右半间距（相反）
    -- 第二排前推向量
    local fx, fy = cosA * spacing, sinA * spacing
    -- 顺序：起点左、起点右、前推左、前推右（便于“左右两个后推前35再两个”）
    return {
        { x = startX + lx, y = startY + ly },
        { x = startX + rx, y = startY + ry },
        { x = startX + fx + lx, y = startY + fy + ly },
        { x = startX + fx + rx, y = startY + fy + ry },
    }
end

--- 统一入口：按Boss规则获取仆从坐标表
---@param bossIndex integer 1|2|3
---@param bossX number|nil Boss当前X（2/3号需要；1号可nil）
---@param bossY number|nil Boss当前Y
---@param facingDeg number|nil Boss面向（仅2号需要）
---@param count integer|nil 数量N（1/3号可覆盖，2号忽略固定4）
---@param spacing number|nil 间隔覆盖
---@return table positions
function Layer1.getBossMinionPositions(bossIndex, bossX, bossY, facingDeg, count, spacing)
    if bossIndex == 1 then
        -- 1号：固定中心宫格，N可调
        local cfg = Layer1.bossMinions[1]
        spacing = spacing or cfg.spacing
        count = count or cfg.count or 9  -- 默认9，可随意调整
        return Layer1.calcGridPositions(cfg.center.x, cfg.center.y, count, spacing)
    elseif bossIndex == 2 then
        -- 2号：面向前100宫格，固定4，不受count影响
        if not bossX or not bossY then
            -- 若未传boss坐标，fallback 用 Boss2 配置坐标
            bossX = Layer1.bosses[2].x
            bossY = Layer1.bosses[2].y
        end
        local cfg = Layer1.bossMinions[2]
        spacing = spacing or cfg.spacing
        local forward = cfg.forward
        return Layer1.calcBoss2ForwardGrid(bossX, bossY, facingDeg, forward, spacing)
    elseif bossIndex == 3 then
        -- 3号：boss为中心宫格，N可调
        if not bossX or not bossY then
            bossX = Layer1.bosses[3].x
            bossY = Layer1.bosses[3].y
        end
        local cfg = Layer1.bossMinions[3]
        spacing = spacing or cfg.spacing
        count = count or cfg.count or 8
        return Layer1.calcGridPositions(bossX, bossY, count, spacing)
    end
    return {}
end

-- ============================================================
-- 营地系统：h9Z4 每30秒刷新 hlc4，上限 4+在线人数，初始2个
-- ============================================================

local function isUnitAlive(u)
    if not u then return false end
    local h = u._handle or u
    if not h then return false end
    if cj.IsUnitType(h, UNIT_TYPE_DEAD) then return false end
    if cj.GetUnitState(h, UNIT_STATE_LIFE) <= 0.405 then return false end
    return true
end

local function getEnemyPlayer()
    return Player:new(12)
end

local function getCampMaxGuards()
    local n = 0
    if GameInit and GameInit.getOnlinePlayers then
        n = #GameInit.getOnlinePlayers()
    else
        for pid = 0, 3 do
            local p = Player:new(pid)
            if p:isPlaying() and p:isUser() then n = n + 1 end
        end
    end
    return 4 + n
end

local function pruneDeadGuards(camp)
    if not camp or not camp.guards then return 0 end
    local alive = {}
    for _, g in ipairs(camp.guards) do
        if isUnitAlive(g) then table.insert(alive, g) end
    end
    camp.guards = alive
    return #alive
end

local function getNextGuardPos(camp)
    local max = getCampMaxGuards()
    local alive = pruneDeadGuards(camp)
    local positions = Layer1.calcGridPositions(camp.x, camp.y, max, 35)
    local idx = (alive % #positions) + 1
    return positions[idx].x, positions[idx].y
end

local function spawnGuardForCamp(camp)
    if not camp or not camp.camp or not isUnitAlive(camp.camp) then return nil end
    local x, y = getNextGuardPos(camp)
    local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.guardId, x, y, 270)
    if u then
        table.insert(camp.guards, u)
        print(string.format("[Layer1] 营地%d 刷新狱卒 %s at %.1f,%.1f [%d/%d]", camp.idx, Layer1.guardId, x, y, #camp.guards, getCampMaxGuards()))
    end
    return u
end

--- 创建全部6个营地（幂等）+ 默认2狱卒 + 30秒刷新定时器
function Layer1.createCamps()
    if #Layer1.campData > 0 then
        print("[Layer1] 营地已创建，跳过 count=" .. #Layer1.campData)
        return Layer1.campData
    end
    local p = getEnemyPlayer()
    for i, pos in ipairs(Layer1.camps) do
        local campUnit = Unit:new(p, Layer1.campId, pos.x, pos.y, 270)
        local camp = { idx = i, x = pos.x, y = pos.y, name = pos.name, camp = campUnit, guards = {}, timer = nil }
        for _ = 1, 2 do spawnGuardForCamp(camp) end
        camp.timer = Timer:new(30, true, function()
            if not isUnitAlive(camp.camp) then return end
            pruneDeadGuards(camp)
            local max = getCampMaxGuards()
            if #camp.guards >= max then return end
            spawnGuardForCamp(camp)
        end)
        table.insert(Layer1.campData, camp)
        print(string.format("[Layer1] 营地创建 %s id=%s at %.1f,%.1f 初始狱卒2", pos.name, Layer1.campId, pos.x, pos.y))
    end
    print("[Layer1] 营地系统创建完成 count=6")
    return Layer1.campData
end

--- 销毁全部营地及定时器
function Layer1.destroyCamps()
    for _, camp in ipairs(Layer1.campData) do
        if camp.timer then camp.timer:destroy() camp.timer = nil end
        if camp.camp then camp.camp:destroy() end
        for _, g in ipairs(camp.guards or {}) do if g then g:destroy() end end
    end
    local n = #Layer1.campData
    Layer1.campData = {}
    print("[Layer1] 营地系统已销毁 count=" .. n)
end

-- ============================================================
-- 1号Boss & 仆从：h31v / hbaj（宫格 N可调，间隔35）
-- ============================================================

--- 创建1号Boss h31v 于 Boss1坐标
---@return Unit|nil
function Layer1.createBoss1()
    if Layer1.boss1Unit and isUnitAlive(Layer1.boss1Unit) then
        print("[Layer1] 1号Boss已存在")
        return Layer1.boss1Unit
    end
    local pos = Layer1.bosses[1]
    local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.boss1Id, pos.x, pos.y, 270)
    Layer1.boss1Unit = u
    if u then print(string.format("[Layer1] 1号Boss %s 已创建 at %.1f,%.1f", Layer1.boss1Id, pos.x, pos.y)) end
    return u
end

--- 在1号仆从中心 -14300.2,-10995.4 以宫格刷新 N个 hbaj（N可随意调整，默认9）
---@param count integer|nil 数量N，默认9
---@param spacing number|nil 间隔，默认35
---@return table guards Unit列表
function Layer1.spawnBoss1Minions(count, spacing)
    count = count or 9
    spacing = spacing or Layer1.bossMinionSpacing
    local positions = Layer1.getBossMinionPositions(1, nil, nil, nil, count, spacing)
    local p = getEnemyPlayer()
    Layer1.boss1Minions = {}
    for _, pos in ipairs(positions) do
        local u = Unit:new(p, Layer1.minionId, pos.x, pos.y, 270)
        if u then table.insert(Layer1.boss1Minions, u) end
    end
    print(string.format("[Layer1] 1号Boss仆从 %s 宫格已刷新 N=%d 间隔%d count=%d", Layer1.minionId, count, spacing, #Layer1.boss1Minions))
    return Layer1.boss1Minions
end

--- 清理1号Boss仆从
function Layer1.clearBoss1Minions()
    for _, u in ipairs(Layer1.boss1Minions) do if u then u:destroy() end end
    local n = #Layer1.boss1Minions
    Layer1.boss1Minions = {}
    print("[Layer1] 1号Boss仆从已清理 count=" .. n)
end

return Layer1
