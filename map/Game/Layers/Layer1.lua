-- ============================================================
-- Layer1 — 第一关卡模块
--
-- 归属：Game/Layers/  战役关卡模块目录
-- 职责：
--   1. 存放第一关卡所有坐标集合（Layer1Area）
--   2. 封装关卡力量墙的创建/销毁（可破坏物，非单位）
--   3. 提供关卡生命周期：Layer1.start / Layer1.shutdown
--   4. 营地系统 h9Z4->hlc4 30s刷新 上限4+在线 初始2
--   5. Boss系统 h31v(1号)/hqR6(2号)/h01e(3号) + hbaj 仆从宫格（分阶段创建防隔墙偷打）
--   6. 关卡触发：营地摧毁/Boss击杀 移除对应墙，3号后350区域全员进入通关
--   7. 分阶段流程：start仅创建1号内容；1号击杀后创建2号内容；2号击杀后创建3号内容（墙体5个坐标保持不变）
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
-- Boss仆从（2026-08-24 fix 2026-08-24）：
--   1号 以 -14300.2,-10995.4 为中心 3x3=9个 间隔200
--        中间行以中心为基准 左右各200；上行y+200/下行y-200 同样3个
--   2号 以boss面向前100码为起点，宫格5个（3个h11q+2个hA11）：起点3个（左中右），推前35再2个（左右）
--   3号 以boss为中心宫格 N个 间隔35
-- 刷怪点（2026-08-25 新增 2026-08-25调整）：
--   刷怪点1 中心 -12880.6,-11384.0 6单位 间隔90（非满9宫格）
--     上行 y+90 3个 h11q；中行 y 两边 hA11（2个）；下行 y-90 1个 h00p（居中）
--   刷怪点2 中心 -11990.7,-12169.0 6单位 间隔90
--     中心1个 nl3r；x+90 1个 n611 + x+90 y+90 1个 n611 + x+90 y-90 1个 n611；y-90 1个 n642 + y+90 1个 n642
--   刷怪点3 中心 -12171.7,-13688.3 2单位 间隔90 两边各1个 hlc4
--   刷怪点4 中心 -11148.1,-12564.9 2单位 间隔90 左右各1个 h11q
-- 触发墙（用户给出大概坐标，自动最近匹配）：
--   营地1 -11582.7,-12989 -> 横墙 -11162.2,-12736.6 (最近 横墙1)
--   营地2 -11962.0,-10687.5 -> 竖墙 -13307.5,-11940.9 (最近 竖墙1)
--   1号Boss击杀 -> 竖墙 -11384.7,-14049.5 (最近 竖墙2)
--   2号Boss击杀 -> 竖墙 -9939.2,-14109.1 (最近 竖墙3)
--   3号Boss击杀 -> 竖墙 -9283.2,-15104.3 (最近 竖墙4)
-- 通关区域：-9629.7,-15068.3 为中心 350x350
--
-- 调用：
--   require "Game.Layers.Layer1"
--   Layer1.start()             -- 关卡1启动（墙/营地/Boss/事件）
--   Layer1.shutdown()          -- 关卡1关闭清理
-- ============================================================

Layer1 = {}
Layer1.__index = Layer1

-- ------------------------------------------------------------
-- 墙体定义（非单位：可破坏物 destructable）
-- ------------------------------------------------------------
Layer1.WALL_H = "B000"
Layer1.WALL_V = "DL84"

Layer1.walls = {
    { x = -11147.3, y = -12794.7, id = "B000", dir = "H", face = 270, name = "横墙1" },
    { x = -13345.1, y = -11943.7, id = "DL84", dir = "V", face = 0,   name = "竖墙1" },
    { x = -11393.4, y = -14058.5, id = "DL84", dir = "V", face = 0,   name = "竖墙2" },
    { x = -9975.7,  y = -14137.8, id = "DL84", dir = "V", face = 0,   name = "竖墙3" },
    { x = -9350.8,  y = -15071.1, id = "DL84", dir = "V", face = 0,   name = "竖墙4" },
}
Layer1Area = Layer1.walls

-- ------------------------------------------------------------
-- 营地 / Boss / 复活
-- ------------------------------------------------------------
Layer1.camps = {
    { x = -11578.3, y = -12966.9, name = "营地1" },
    { x = -12011.9, y = -10722.1, name = "营地2" },
    { x = -13559.1, y = -10209.1, name = "营地3" },
    { x = -15028.4, y = -12065.9, name = "营地4" },
    { x = -10819.0, y = -14009.4, name = "营地5" },
    { x = -8626.4,  y = -15303.5, name = "营地6" },
}
Layer1Camps = Layer1.camps
Layer1CampPos = Layer1.camps

Layer1.bosses = {
    { x = -14868.4, y = -10349.3, name = "1号Boss" },
    { x = -10250.5, y = -14186.0, name = "2号Boss" },
    { x = -8835.9,  y = -14844.6, name = "3号Boss" },
}
Layer1BossPos = Layer1.bosses
Layer1Bosses = Layer1.bosses

Layer1.revivePos = { x = -11787.8, y = -14967.1, name = "复活点" }
Layer1.potionShopPos = { x = -11388.4, y = -14565.7, name = "药剂商店" }
Layer1RevivePos = Layer1.revivePos
Layer1PotionShopPos = Layer1.potionShopPos

Layer1.bossMinionSpacing = 35
Layer1.bossMinions = {
    [1] = { center = { x = -14300.2, y = -10995.4 }, spacing = 200, count = 9, name = "1号仆从" },
    [2] = { forward = 100, spacing = 35, count = 5, name = "2号仆从", ids = { "h11q", "h11q", "h11q", "hA11", "hA11" } },
    [3] = { center = "boss", spacing = 35, name = "3号仆从" },
}
Layer1BossMinions = Layer1.bossMinions

-- 新增刷怪点（2026-08-25）
Layer1.mobSpawnPos = { x = -12880.6, y = -11384.0, spacing = 90, name = "刷怪点1" }
Layer1.mobSpawnUnits = {} -- 运行时句柄列表
Layer1MobSpawnPos = Layer1.mobSpawnPos
-- 刷怪点2（2026-08-25 新增）
Layer1.mobSpawnPos2 = { x = -11990.7, y = -12169.0, spacing = 90, name = "刷怪点2" }
Layer1.mobSpawnUnits2 = {}
Layer1MobSpawnPos2 = Layer1.mobSpawnPos2
-- 刷怪点3（2026-08-25 新增）
Layer1.mobSpawnPos3 = { x = -12171.7, y = -13688.3, spacing = 90, name = "刷怪点3" }
Layer1.mobSpawnUnits3 = {}
Layer1MobSpawnPos3 = Layer1.mobSpawnPos3
-- 刷怪点4（2026-08-25 新增）
Layer1.mobSpawnPos4 = { x = -11148.1, y = -12564.9, spacing = 90, name = "刷怪点4" }
Layer1.mobSpawnUnits4 = {}
Layer1MobSpawnPos4 = Layer1.mobSpawnPos4

Layer1.campId    = "h9Z4"
Layer1.guardId   = "hlc4"
Layer1.boss1Id   = "h31v"
Layer1.boss2Id   = "hqR6"
Layer1.boss3Id   = "h01e"
Layer1.minionId  = "hbaj"
Layer1CampId   = Layer1.campId
Layer1GuardId  = Layer1.guardId
Layer1Boss1Id  = Layer1.boss1Id
Layer1Boss2Id  = Layer1.boss2Id
Layer1Boss3Id  = Layer1.boss3Id
Layer1MinionId = Layer1.minionId

-- 运行时
Layer1.handles = {}
Layer1.campData = {}
Layer1.campTimer = nil -- 唯一true计时器驱动所有营地（每30s检查）
Layer1.boss1Unit = nil
Layer1.boss1Minions = {}
Layer1.boss2Minions = {}
Layer1.boss3Minions = {}
Layer1.bossUnits = {} -- [1..3] = Unit
Layer1.bossStage = 1 -- 1=仅1号已创建 2=2号已创建 3=3号已创建
Layer1.boss1ChaseTimer = nil -- 1号Boss死后仆从追击计时器
Layer1.mobSpawnCenter = Layer1.mobSpawnPos -- 别名兼容
Layer1.mobSpawnCenter2 = Layer1.mobSpawnPos2
Layer1.mobSpawnCenter3 = Layer1.mobSpawnPos3
Layer1.mobSpawnCenter4 = Layer1.mobSpawnPos4
-- 关卡流程状态
Layer1.started = false
Layer1.finished = false
Layer1.events = {} -- {Event,...}
Layer1.wallMap = {} -- wallIndex -> destructable handle
Layer1.exitRect = nil
Layer1.exitRegionCallback = nil
Layer1.enteredPlayers = {} -- pid -> true 已进入通关区域的玩家
-- 触发墙映射（用户给的大概坐标 -> 最近真实墙）
Layer1.triggerWalls = {
    camp1 = { tx = -11162.2, ty = -12736.6, desc = "营地1摧毁->横墙" },
    camp2 = { tx = -13307.5, ty = -11940.9, desc = "营地2摧毁->竖墙1" },
    boss1 = { tx = -11384.7, ty = -14049.5, desc = "1号Boss击杀->竖墙2" },
    boss2 = { tx = -9939.2,  ty = -14109.1, desc = "2号Boss击杀->竖墙3" },
    boss3 = { tx = -9283.2,  ty = -15104.3, desc = "3号Boss击杀->竖墙4" },
}
-- 通关区域
Layer1.exitCenter = { x = -9629.7, y = -15068.3, w = 350, h = 350 }

-- ------------------------------------------------------------
-- 工具
-- ------------------------------------------------------------
local function isUnitAlive(u)
    if not u then return false end
    local h
    if type(u) == "table" then
        h = u._handle
        if not h then return false end
    else
        h = u -- userdata handle 直接传入
    end
    -- handle 已被引擎移除（GetUnitTypeId==0）视为死亡
    if cj.GetUnitTypeId(h) == 0 then return false end
    if cj.IsUnitType(h, UNIT_TYPE_DEAD) then return false end
    -- GetUnitState 对死亡单位仍可调用，life<=0.405视为死亡
    local ok, life = pcall(cj.GetUnitState, h, UNIT_STATE_LIFE)
    if ok and life <= 0.405 then return false end
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
        for pid = 0, 3 do local p = Player:new(pid) if p:isPlaying() and p:isUser() then n = n+1 end end
    end
    return 4 + n
end

local function pruneDeadGuards(camp)
    if not camp or not camp.guards then return 0 end
    local alive = {}
    for _, g in ipairs(camp.guards) do if isUnitAlive(g) then table.insert(alive, g) end end
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
    if not camp or not camp.camp or not isUnitAlive(camp.camp) then
        print(string.format("[Layer1] 营地%d 跳过刷新(营地已死亡)", camp.idx or -1))
        return nil
    end
    local x, y = getNextGuardPos(camp)
    local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.guardId, x, y, 270)
    -- 创建失败时尝试偏移（规避地形阻塞）
    if not u or not u._handle then
        for _, off in ipairs({{32,0},{-32,0},{0,32},{0,-32},{64,0},{-64,0}}) do
            u = Unit:new(p, Layer1.guardId, x+off[1], y+off[2], 270)
            if u and u._handle then
                print(string.format("[Layer1] 营地%d 獄卒创建重试偏移 %d,%d 成功", camp.idx, off[1], off[2]))
                x, y = x+off[1], y+off[2]
                break
            end
        end
    end
    if u and u._handle then
        table.insert(camp.guards, u)
        print(string.format("[Layer1] 营地%d 刷新獄卒 %s at %.1f,%.1f [%d/%d]", camp.idx, Layer1.guardId, x, y, #camp.guards, getCampMaxGuards()))
    else
        print(string.format("[Layer1] 营地%d 獄卒创建失败 at %.1f,%.1f", camp.idx, x, y))
    end
    return u
end

local function distance(ax,ay,bx,by) return ((ax-bx)^2 + (ay-by)^2) ^ 0.5 end

-- 最近墙匹配：按坐标找 walls 中最近的一项，移除其 destructable
function Layer1.removeWallNear(tx, ty, reason)
    if not tx or not ty then return false end
    local bestIdx, bestDist = nil, 1e9
    for i, w in ipairs(Layer1.walls) do
        local d = distance(tx, ty, w.x, w.y)
        if d < bestDist then bestDist = d; bestIdx = i end
    end
    if not bestIdx then return false end
    local h = Layer1.wallMap[bestIdx]
    local w = Layer1.walls[bestIdx]
    if h then
        cj.RemoveDestructable(h)
        Layer1.wallMap[bestIdx] = nil
        -- 同步从 handles 移除
        for k, vh in ipairs(Layer1.handles) do if vh == h then table.remove(Layer1.handles, k) break end end
        print(string.format("[Layer1] 墙已移除 %s (最近 %.1f码) tx=%.1f,%.1f -> wall %s %.1f,%.1f reason=%s", w.name, bestDist, tx, ty, w.name, w.x, w.y, reason or ""))
        -- 中央系统信息：力量墙销毁
        if SystemMessage and SystemMessage.send then
            local wallMsg = string.format("力量墙已销毁 - %s - %s", reason or w.name, w.name)
            SystemMessage.send({{"STR", wallMsg, SystemMessage.COLOR_INFO}}, 3.0)
        end
        return true
    else
        print(string.format("[Layer1] 墙已不存在或已移除 %s 最近 %.1f码", w.name, bestDist))
        return false
    end
end

-- ------------------------------------------------------------
-- 墙创建
-- ------------------------------------------------------------
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then print(string.format("[Layer1] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else print(string.format("[Layer1] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y)) end
    return h
end

function Layer1.createWalls()
    if #Layer1.handles > 0 then print("[Layer1] 墙体已存在，跳过 count=" .. #Layer1.handles) return Layer1.handles end
    Layer1.handles = {}; Layer1.wallMap = {}
    for i, w in ipairs(Layer1.walls) do
        local h = createOne(w)
        if h then table.insert(Layer1.handles, h); Layer1.wallMap[i] = h end
    end
    print("[Layer1] 第一关卡墙体创建完成 count=" .. #Layer1.handles .. "/5")
    return Layer1.handles
end

function Layer1.destroyWalls()
    for _, h in ipairs(Layer1.handles) do if h then cj.RemoveDestructable(h) end end
    local n = #Layer1.handles
    Layer1.handles = {}; Layer1.wallMap = {}
    print("[Layer1] 第一关卡墙体已移除 count=" .. n)
end

function Layer1.getCount() return #Layer1.handles end
function Layer1.isCreated() return #Layer1.handles > 0 end

-- ============================================================
-- Boss 仆从宫格公式
-- ============================================================
-- 1号Boss专用：以中心为中间行，中心左右200，上行y+200/下行y-200 各3个，共9个
function Layer1.calcBoss1Grid(cx, cy, spacing)
    if not cx or not cy then return {} end
    spacing = spacing or 200
    local positions = {}
    -- 上行 y+spacing
    for _, dx in ipairs({ -spacing, 0, spacing }) do
        table.insert(positions, { x = cx + dx, y = cy + spacing })
    end
    -- 中间行 y
    for _, dx in ipairs({ -spacing, 0, spacing }) do
        table.insert(positions, { x = cx + dx, y = cy })
    end
    -- 下行 y-spacing
    for _, dx in ipairs({ -spacing, 0, spacing }) do
        table.insert(positions, { x = cx + dx, y = cy - spacing })
    end
    return positions
end

function Layer1.calcGridPositions(cx, cy, count, spacing)
    if not cx or not cy or not count or count <= 0 then return {} end
    spacing = spacing or Layer1.bossMinionSpacing or 35
    local cols = math.ceil(math.sqrt(count))
    local rows = math.ceil(count / cols)
    local offsetX0 = (cols - 1) * spacing * 0.5
    local offsetY0 = (rows - 1) * spacing * 0.5
    local positions = {}
    for i = 0, count - 1 do
        local r = math.floor(i / cols); local c = i % cols
        local x = cx - offsetX0 + c * spacing
        local y = cy - offsetY0 + r * spacing
        table.insert(positions, { x = x, y = y })
    end
    return positions
end

function Layer1.calcBoss2ForwardGrid(bossX, bossY, facingDeg, forward, spacing)
    if not bossX or not bossY then return {} end
    forward = forward or 100; spacing = spacing or Layer1.bossMinionSpacing or 35; facingDeg = facingDeg or 0
    local rad = math.rad(facingDeg); local cosA = math.cos(rad); local sinA = math.sin(rad)
    local startX = bossX + cosA * forward; local startY = bossY + sinA * forward
    local half = spacing * 0.5
    local lx, ly = -sinA * half, cosA * half
    local rx, ry = sinA * half, -cosA * half
    local fx, fy = cosA * spacing, sinA * spacing
    -- 5个：起点行3个（左/中/右），前推一行2个（左右） -> 3个h11q + 2个hA11
    return {
        { x = startX + lx, y = startY + ly },           -- 起点左 h11q
        { x = startX, y = startY },                      -- 起点中 h11q
        { x = startX + rx, y = startY + ry },           -- 起点右 h11q
        { x = startX + fx + lx, y = startY + fy + ly }, -- 前推左 hA11
        { x = startX + fx + rx, y = startY + fy + ry }, -- 前推右 hA11
    }
end

-- 刷怪点 6单位（2026-08-25调整）：上行3/中行2/下行1
function Layer1.calcMobSpawnGrid(cx, cy, spacing)
    if not cx or not cy then return {} end
    spacing = spacing or (Layer1.mobSpawnPos and Layer1.mobSpawnPos.spacing) or 90
    local positions = {}
    -- 上行 y+spacing 3个 h11q
    for _, dx in ipairs({ -spacing, 0, spacing }) do
        table.insert(positions, { x = cx + dx, y = cy + spacing, id = "h11q" })
    end
    -- 中行 y 两边 hA11（左右各90，中间空缺）
    for _, dx in ipairs({ -spacing, spacing }) do
        table.insert(positions, { x = cx + dx, y = cy, id = "hA11" })
    end
    -- 下行 y-spacing 居中 1个 h00p
    table.insert(positions, { x = cx, y = cy - spacing, id = "h00p" })
    return positions
end

function Layer1.getMobSpawnPositions(cx, cy, spacing)
    cx = cx or (Layer1.mobSpawnPos and Layer1.mobSpawnPos.x) or -12880.6
    cy = cy or (Layer1.mobSpawnPos and Layer1.mobSpawnPos.y) or -11384.0
    spacing = spacing or (Layer1.mobSpawnPos and Layer1.mobSpawnPos.spacing) or 90
    return Layer1.calcMobSpawnGrid(cx, cy, spacing)
end

-- 刷怪点2 6单位（2026-08-25新增）：中心nl3r + 东侧3个n611 + 南北2个n642
function Layer1.calcMobSpawnGrid2(cx, cy, spacing)
    if not cx or not cy then return {} end
    spacing = spacing or (Layer1.mobSpawnPos2 and Layer1.mobSpawnPos2.spacing) or 90
    local positions = {}
    -- 1. 中心 1个 nl3r
    table.insert(positions, { x = cx, y = cy, id = "nl3r" })
    -- 2. x+90 1个 n611，x+90 y+90 1个 n611，x+90 y-90 1个 n611
    table.insert(positions, { x = cx + spacing, y = cy, id = "n611" })
    table.insert(positions, { x = cx + spacing, y = cy + spacing, id = "n611" })
    table.insert(positions, { x = cx + spacing, y = cy - spacing, id = "n611" })
    -- 3. y-90 1个 n642，y+90 1个 n642（中心垂线）
    table.insert(positions, { x = cx, y = cy - spacing, id = "n642" })
    table.insert(positions, { x = cx, y = cy + spacing, id = "n642" })
    return positions
end

function Layer1.getMobSpawnPositions2(cx, cy, spacing)
    cx = cx or (Layer1.mobSpawnPos2 and Layer1.mobSpawnPos2.x) or -11990.7
    cy = cy or (Layer1.mobSpawnPos2 and Layer1.mobSpawnPos2.y) or -12169.0
    spacing = spacing or (Layer1.mobSpawnPos2 and Layer1.mobSpawnPos2.spacing) or 90
    return Layer1.calcMobSpawnGrid2(cx, cy, spacing)
end

-- 刷怪点3 2单位（2026-08-25新增）：中心两边各1个 hlc4
function Layer1.calcMobSpawnGrid3(cx, cy, spacing)
    if not cx or not cy then return {} end
    spacing = spacing or (Layer1.mobSpawnPos3 and Layer1.mobSpawnPos3.spacing) or 90
    local positions = {}
    -- 两边各1个 hlc4：x-90 与 x+90，y 保持中心
    table.insert(positions, { x = cx - spacing, y = cy, id = "hlc4" })
    table.insert(positions, { x = cx + spacing, y = cy, id = "hlc4" })
    return positions
end

function Layer1.getMobSpawnPositions3(cx, cy, spacing)
    cx = cx or (Layer1.mobSpawnPos3 and Layer1.mobSpawnPos3.x) or -12171.7
    cy = cy or (Layer1.mobSpawnPos3 and Layer1.mobSpawnPos3.y) or -13688.3
    spacing = spacing or (Layer1.mobSpawnPos3 and Layer1.mobSpawnPos3.spacing) or 90
    return Layer1.calcMobSpawnGrid3(cx, cy, spacing)
end

-- 刷怪点4 2单位：左右各1个 h11q
function Layer1.calcMobSpawnGrid4(cx, cy, spacing)
    if not cx or not cy then return {} end
    spacing = spacing or (Layer1.mobSpawnPos4 and Layer1.mobSpawnPos4.spacing) or 90
    local positions = {}
    table.insert(positions, { x = cx - spacing, y = cy, id = "h11q" })
    table.insert(positions, { x = cx + spacing, y = cy, id = "h11q" })
    return positions
end

function Layer1.getMobSpawnPositions4(cx, cy, spacing)
    cx = cx or (Layer1.mobSpawnPos4 and Layer1.mobSpawnPos4.x) or -11148.1
    cy = cy or (Layer1.mobSpawnPos4 and Layer1.mobSpawnPos4.y) or -12564.9
    spacing = spacing or (Layer1.mobSpawnPos4 and Layer1.mobSpawnPos4.spacing) or 90
    return Layer1.calcMobSpawnGrid4(cx, cy, spacing)
end

function Layer1.getBossMinionPositions(bossIndex, bossX, bossY, facingDeg, count, spacing)
    if bossIndex == 1 then
        local cfg = Layer1.bossMinions[1]; spacing = spacing or cfg.spacing or 200; count = count or cfg.count or 9
        -- 固定 9个 3x3 间隔200，以配置中心为中间行中心
        if count == 9 and spacing == 200 then
            return Layer1.calcBoss1Grid(cfg.center.x, cfg.center.y, spacing)
        end
        return Layer1.calcGridPositions(cfg.center.x, cfg.center.y, count, spacing)
    elseif bossIndex == 2 then
        if not bossX or not bossY then bossX = Layer1.bosses[2].x; bossY = Layer1.bosses[2].y end
        local cfg = Layer1.bossMinions[2]; spacing = spacing or cfg.spacing; local forward = cfg.forward
        return Layer1.calcBoss2ForwardGrid(bossX, bossY, facingDeg, forward, spacing)
    elseif bossIndex == 3 then
        if not bossX or not bossY then bossX = Layer1.bosses[3].x; bossY = Layer1.bosses[3].y end
        local cfg = Layer1.bossMinions[3]; spacing = spacing or cfg.spacing; count = count or cfg.count or 8
        return Layer1.calcGridPositions(bossX, bossY, count, spacing)
    end
    return {}
end

-- ============================================================
-- 营地系统
-- ============================================================
function Layer1.createCamps()
    if #Layer1.campData > 0 then print("[Layer1] 营地已创建，跳过 count=" .. #Layer1.campData) return Layer1.campData end
    local p = getEnemyPlayer()
    for i, pos in ipairs(Layer1.camps) do
        local campUnit = Unit:new(p, Layer1.campId, pos.x, pos.y, 270)
        local camp = { idx = i, x = pos.x, y = pos.y, name = pos.name, camp = campUnit, guards = {}, timer = nil }
        for _ = 1, 2 do spawnGuardForCamp(camp) end
        table.insert(Layer1.campData, camp)
        print(string.format("[Layer1] 营地创建 %s id=%s at %.1f,%.1f 初始狱卒2", pos.name, Layer1.campId, pos.x, pos.y))
    end
    -- 唯一计时器驱动所有营地：每30s检查各营地绑定数量，未达上限则在营地位置创建狱卒（走单核内核，保证同步）
    if Layer1.campTimer then Layer1.campTimer:destroy() end
    Layer1.campTimer = Timer:new(30, true, function()
        print(string.format("[Layer1][CampTimer] tick 检查 %d个营地 上限=%d", #Layer1.campData, getCampMaxGuards()))
        for _, camp in ipairs(Layer1.campData) do
            if not isUnitAlive(camp.camp) then
                print(string.format("[Layer1][CampTimer] 营地%d 已死亡 跳过", camp.idx))
            else
                local before = #camp.guards
                pruneDeadGuards(camp)
                local afterPrune = #camp.guards
                if before ~= afterPrune then
                    print(string.format("[Layer1][CampTimer] 营地%d 清理死亡獄卒 %d->%d", camp.idx, before, afterPrune))
                end
                local max = getCampMaxGuards()
                print(string.format("[Layer1][CampTimer] 营地%d 状态 %d/%d", camp.idx, #camp.guards, max))
                if #camp.guards < max then
                    spawnGuardForCamp(camp)
                else
                    print(string.format("[Layer1][CampTimer] 营地%d 已满 不刷新", camp.idx))
                end
            end
        end
    end, true)
    print("[Layer1] 营地系统创建完成 count=6 已启动唯一刷新计时器 30s")
    return Layer1.campData
end

function Layer1.destroyCamps()
    if Layer1.campTimer then Layer1.campTimer:destroy(); Layer1.campTimer = nil end
    for _, camp in ipairs(Layer1.campData) do
        if camp.timer then camp.timer:destroy() camp.timer = nil end
        if camp.camp then camp.camp:destroy() end
        for _, g in ipairs(camp.guards or {}) do if g then g:destroy() end end
    end
    local n = #Layer1.campData; Layer1.campData = {}
    print("[Layer1] 营地系统已销毁 count=" .. n)
end

-- ============================================================
-- Boss
-- ============================================================
function Layer1.createBoss1()
    if Layer1.boss1Unit and isUnitAlive(Layer1.boss1Unit) then print("[Layer1] 1号Boss已存在") return Layer1.boss1Unit end
    local pos = Layer1.bosses[1]; local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.boss1Id, pos.x, pos.y, 270)
    Layer1.boss1Unit = u; Layer1.bossUnits[1] = u
    Layer1.bossStage = math.max(Layer1.bossStage, 1)
    if u then print(string.format("[Layer1] 1号Boss %s 已创建 at %.1f,%.1f", Layer1.boss1Id, pos.x, pos.y)) end
    return u
end

function Layer1.spawnBoss1Minions(count, spacing)
    local cfg = Layer1.bossMinions[1]
    count = count or cfg.count or 9; spacing = spacing or cfg.spacing or 200
    local positions = Layer1.getBossMinionPositions(1, nil, nil, nil, count, spacing)
    local p = getEnemyPlayer(); Layer1.boss1Minions = {}
    for _, pos in ipairs(positions) do local u = Unit:new(p, Layer1.minionId, pos.x, pos.y, 270) if u then table.insert(Layer1.boss1Minions, u) end end
    print(string.format("[Layer1] 1号Boss仆从 %s 宫格已刷新 N=%d 间隔%d count=%d", Layer1.minionId, count, spacing, #Layer1.boss1Minions))
    return Layer1.boss1Minions
end

function Layer1.clearBoss1Minions()
    if Layer1.boss1ChaseTimer then Layer1.boss1ChaseTimer:destroy(); Layer1.boss1ChaseTimer = nil end
    for _, u in ipairs(Layer1.boss1Minions) do if u then u:destroy() end end
    local n = #Layer1.boss1Minions; Layer1.boss1Minions = {}
    print("[Layer1] 1号Boss仆从已清理 count=" .. n)
end

-- 1号Boss死亡时：存活仆从转为追击玩家（扩大索敌 + 攻击最近英雄），不再直接删除
function Layer1.activateBoss1MinionsChase()
    -- 清理已死亡的句柄，统计存活
    local alive = {}
    for _, u in ipairs(Layer1.boss1Minions) do
        if isUnitAlive(u) then table.insert(alive, u) end
    end
    if #alive == 0 then
        print("[Layer1] 1号Boss仆从无存活，无需追击")
        Layer1.boss1Minions = {}
        return 0
    end

    local function findNearestHero(x, y)
        local best, bestDist = nil, 1e9
        for pid = 0, 3 do
            local p = Player:new(pid)
            if p:isPlaying() and p:isUser() then
                local g = cj.CreateGroup()
                cj.GroupEnumUnitsOfPlayer(g, p._handle, nil)
                local u = cj.FirstOfGroup(g)
                while u ~= nil do
                    if cj.IsUnitType(u, UNIT_TYPE_HERO) and not cj.IsUnitType(u, UNIT_TYPE_DEAD) then
                        local ok, life = pcall(cj.GetUnitState, u, UNIT_STATE_LIFE)
                        if ok and life > 0.405 then
                            local d = ((cj.GetUnitX(u) - x) ^ 2 + (cj.GetUnitY(u) - y) ^ 2) ^ 0.5
                            if d < bestDist then bestDist = d; best = u end
                        elseif not ok then
                            local d = ((cj.GetUnitX(u) - x) ^ 2 + (cj.GetUnitY(u) - y) ^ 2) ^ 0.5
                            if d < bestDist then bestDist = d; best = u end
                        end
                    end
                    cj.GroupRemoveUnit(g, u)
                    u = cj.FirstOfGroup(g)
                end
                cj.DestroyGroup(g)
            end
        end
        return best
    end

    local function issueChase()
        local ordered = 0
        local stillAlive = 0
        for _, u in ipairs(Layer1.boss1Minions) do
            if isUnitAlive(u) then
                stillAlive = stillAlive + 1
                local h = u._handle
                if h then
                    -- 扩大主动攻击范围
                    pcall(cj.SetUnitAcquireRange, h, 2500)
                    if u.setAcquireRange then pcall(function() u:setAcquireRange(2500) end) end
                    pcall(cj.PauseUnit, h, false)
                    local hx, hy = cj.GetUnitX(h), cj.GetUnitY(h)
                    local target = findNearestHero(hx, hy)
                    if target then
                        cj.IssueTargetOrder(h, "attack", target)
                    else
                        local rev = Layer1.revivePos or { x = -11787.8, y = -14967.1 }
                        cj.IssuePointOrder(h, "attack", rev.x, rev.y)
                    end
                    ordered = ordered + 1
                end
            end
        end
        return ordered, stillAlive
    end

    local ordered = issueChase()
    print(string.format("[Layer1] 1号Boss仆从追击已激活 存活%d/%d 已下达追击指令%d (索敌2500)", #alive, #Layer1.boss1Minions, ordered))

    -- 周期性重新索敌（每3秒），防止丢失目标后发呆；无存活时自动停止
    if Layer1.boss1ChaseTimer then Layer1.boss1ChaseTimer:destroy() end
    Layer1.boss1ChaseTimer = Timer:new(3, true, function()
        local _, stillAlive = issueChase()
        if stillAlive == 0 then
            if Layer1.boss1ChaseTimer then Layer1.boss1ChaseTimer:destroy(); Layer1.boss1ChaseTimer = nil end
            print("[Layer1] 1号Boss追击仆从已全部死亡，停止追击计时器")
        end
    end, true)

    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("1号Boss仆从 %d个 进入追击状态！", #alive), SystemMessage.COLOR_WARN}}, 3.0)
    end
    return #alive
end

-- 2号Boss：仅在1号击杀后创建，避免隔墙被远程命中
function Layer1.createBoss2()
    if Layer1.bossUnits[2] and isUnitAlive(Layer1.bossUnits[2]) then print("[Layer1] 2号Boss已存在") return Layer1.bossUnits[2] end
    local pos = Layer1.bosses[2]; local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.boss2Id, pos.x, pos.y, 270)
    Layer1.bossUnits[2] = u
    Layer1.bossStage = math.max(Layer1.bossStage, 2)
    if u then print(string.format("[Layer1] 2号Boss %s 已创建 at %.1f,%.1f (阶段2)", Layer1.boss2Id, pos.x, pos.y)) end
    return u
end

function Layer1.spawnBoss2Minions(facingDeg)
    -- 2号仆从：以boss面向前100码为起点，宫格5个 3*h11q+2*hA11
    local pos = Layer1.bosses[2]
    local positions = Layer1.getBossMinionPositions(2, pos.x, pos.y, facingDeg or 270, nil, nil)
    local p = getEnemyPlayer(); Layer1.boss2Minions = {}
    local ids = (Layer1.bossMinions[2] and Layer1.bossMinions[2].ids) or { "h11q","h11q","h11q","hA11","hA11" }
    for i, mpos in ipairs(positions) do
        local uid = ids[i] or Layer1.minionId
        local u = Unit:new(p, uid, mpos.x, mpos.y, facingDeg or 270)
        if u then table.insert(Layer1.boss2Minions, u) end
    end
    print(string.format("[Layer1] 2号Boss仆从 前向宫格已刷新 count=%d (3*h11q+2*hA11) 实际=%d", #positions, #Layer1.boss2Minions))
    return Layer1.boss2Minions
end

function Layer1.clearBoss2Minions()
    for _, u in ipairs(Layer1.boss2Minions) do if u then u:destroy() end end
    local n = #Layer1.boss2Minions; Layer1.boss2Minions = {}
    print("[Layer1] 2号Boss仆从已清理 count=" .. n)
end

-- 3号Boss：仅在2号击杀后创建
function Layer1.createBoss3()
    if Layer1.bossUnits[3] and isUnitAlive(Layer1.bossUnits[3]) then print("[Layer1] 3号Boss已存在") return Layer1.bossUnits[3] end
    local pos = Layer1.bosses[3]; local p = getEnemyPlayer()
    local u = Unit:new(p, Layer1.boss3Id, pos.x, pos.y, 270)
    Layer1.bossUnits[3] = u
    Layer1.bossStage = math.max(Layer1.bossStage, 3)
    if u then print(string.format("[Layer1] 3号Boss %s 已创建 at %.1f,%.1f (阶段3)", Layer1.boss3Id, pos.x, pos.y)) end
    return u
end

function Layer1.spawnBoss3Minions(count, spacing)
    count = count or 8; spacing = spacing or Layer1.bossMinionSpacing
    local pos = Layer1.bosses[3]
    local positions = Layer1.getBossMinionPositions(3, pos.x, pos.y, nil, count, spacing)
    local p = getEnemyPlayer(); Layer1.boss3Minions = {}
    for _, mpos in ipairs(positions) do local u = Unit:new(p, Layer1.minionId, mpos.x, mpos.y, 270) if u then table.insert(Layer1.boss3Minions, u) end end
    print(string.format("[Layer1] 3号Boss仆从 %s 宫格已刷新 N=%d count=%d", Layer1.minionId, count, #Layer1.boss3Minions))
    return Layer1.boss3Minions
end

function Layer1.clearBoss3Minions()
    for _, u in ipairs(Layer1.boss3Minions) do if u then u:destroy() end end
    local n = #Layer1.boss3Minions; Layer1.boss3Minions = {}
    print("[Layer1] 3号Boss仆从已清理 count=" .. n)
end

-- ============================================================
-- 刷怪点（2026-08-25 调整后）
-- 中心 -12880.6,-11384.0 6单位：上行3 h11q / 中行2 hA11 / 下行1 h00p
-- ============================================================
function Layer1.spawnMobSpawn(cx, cy, spacing)
    cx = cx or Layer1.mobSpawnPos.x; cy = cy or Layer1.mobSpawnPos.y; spacing = spacing or Layer1.mobSpawnPos.spacing or 90
    local positions = Layer1.calcMobSpawnGrid(cx, cy, spacing)
    local p = getEnemyPlayer()
    -- 清理旧的
    Layer1.clearMobSpawn()
    Layer1.mobSpawnUnits = {}
    for _, pos in ipairs(positions) do
        local uid = pos.id or "h11q"
        local u = Unit:new(p, uid, pos.x, pos.y, 270)
        if u then table.insert(Layer1.mobSpawnUnits, u) end
    end
    print(string.format("[Layer1] 刷怪点 已创建 中心%.1f,%.1f 间隔%d 上行3*h11q(y+90) 中行2*hA11(y) 下行1*h00p(y-90) count=%d", cx, cy, spacing, #Layer1.mobSpawnUnits))
    return Layer1.mobSpawnUnits
end

function Layer1.clearMobSpawn()
    if not Layer1.mobSpawnUnits then Layer1.mobSpawnUnits = {} return end
    for _, u in ipairs(Layer1.mobSpawnUnits) do if u then u:destroy() end end
    local n = #Layer1.mobSpawnUnits
    Layer1.mobSpawnUnits = {}
    if n > 0 then print("[Layer1] 刷怪点1已清理 count=" .. n) end
end

function Layer1.createMobSpawn()
    return Layer1.spawnMobSpawn()
end

function Layer1.destroyMobSpawn()
    Layer1.clearMobSpawn()
end

-- 刷怪点2
function Layer1.spawnMobSpawn2(cx, cy, spacing)
    cx = cx or Layer1.mobSpawnPos2.x; cy = cy or Layer1.mobSpawnPos2.y; spacing = spacing or Layer1.mobSpawnPos2.spacing or 90
    local positions = Layer1.calcMobSpawnGrid2(cx, cy, spacing)
    local p = getEnemyPlayer()
    Layer1.clearMobSpawn2()
    Layer1.mobSpawnUnits2 = {}
    for _, pos in ipairs(positions) do
        local uid = pos.id or "nl3r"
        local u = Unit:new(p, uid, pos.x, pos.y, 270)
        if u then table.insert(Layer1.mobSpawnUnits2, u) end
    end
    print(string.format("[Layer1] 刷怪点2 已创建 中心%.1f,%.1f 间隔%d 中心nl3r 东侧3*n611 南北2*n642 count=%d", cx, cy, spacing, #Layer1.mobSpawnUnits2))
    return Layer1.mobSpawnUnits2
end

function Layer1.clearMobSpawn2()
    if not Layer1.mobSpawnUnits2 then Layer1.mobSpawnUnits2 = {} return end
    for _, u in ipairs(Layer1.mobSpawnUnits2) do if u then u:destroy() end end
    local n = #Layer1.mobSpawnUnits2
    Layer1.mobSpawnUnits2 = {}
    if n > 0 then print("[Layer1] 刷怪点2已清理 count=" .. n) end
end

function Layer1.createMobSpawn2()
    return Layer1.spawnMobSpawn2()
end

function Layer1.destroyMobSpawn2()
    Layer1.clearMobSpawn2()
end

-- 刷怪点3
function Layer1.spawnMobSpawn3(cx, cy, spacing)
    cx = cx or Layer1.mobSpawnPos3.x; cy = cy or Layer1.mobSpawnPos3.y; spacing = spacing or Layer1.mobSpawnPos3.spacing or 90
    local positions = Layer1.calcMobSpawnGrid3(cx, cy, spacing)
    local p = getEnemyPlayer()
    Layer1.clearMobSpawn3()
    Layer1.mobSpawnUnits3 = {}
    for _, pos in ipairs(positions) do
        local uid = pos.id or "hlc4"
        local u = Unit:new(p, uid, pos.x, pos.y, 270)
        if u then table.insert(Layer1.mobSpawnUnits3, u) end
    end
    print(string.format("[Layer1] 刷怪点3 已创建 中心%.1f,%.1f 间隔%d 两边2*hlc4 count=%d", cx, cy, spacing, #Layer1.mobSpawnUnits3))
    return Layer1.mobSpawnUnits3
end

function Layer1.clearMobSpawn3()
    if not Layer1.mobSpawnUnits3 then Layer1.mobSpawnUnits3 = {} return end
    for _, u in ipairs(Layer1.mobSpawnUnits3) do if u then u:destroy() end end
    local n = #Layer1.mobSpawnUnits3
    Layer1.mobSpawnUnits3 = {}
    if n > 0 then print("[Layer1] 刷怪点3已清理 count=" .. n) end
end

function Layer1.createMobSpawn3()
    return Layer1.spawnMobSpawn3()
end

function Layer1.destroyMobSpawn3()
    Layer1.clearMobSpawn3()
end

-- 刷怪点4
function Layer1.spawnMobSpawn4(cx, cy, spacing)
    cx = cx or Layer1.mobSpawnPos4.x; cy = cy or Layer1.mobSpawnPos4.y; spacing = spacing or Layer1.mobSpawnPos4.spacing or 90
    local positions = Layer1.calcMobSpawnGrid4(cx, cy, spacing)
    local p = getEnemyPlayer()
    Layer1.clearMobSpawn4()
    Layer1.mobSpawnUnits4 = {}
    for _, pos in ipairs(positions) do
        local uid = pos.id or "h11q"
        local u = Unit:new(p, uid, pos.x, pos.y, 270)
        if u then table.insert(Layer1.mobSpawnUnits4, u) end
    end
    print(string.format("[Layer1] 刷怪点4 已创建 中心%.1f,%.1f 间隔%d 左右2*h11q count=%d", cx, cy, spacing, #Layer1.mobSpawnUnits4))
    return Layer1.mobSpawnUnits4
end

function Layer1.clearMobSpawn4()
    if not Layer1.mobSpawnUnits4 then Layer1.mobSpawnUnits4 = {} return end
    for _, u in ipairs(Layer1.mobSpawnUnits4) do if u then u:destroy() end end
    local n = #Layer1.mobSpawnUnits4
    Layer1.mobSpawnUnits4 = {}
    if n > 0 then print("[Layer1] 刷怪点4已清理 count=" .. n) end
end

function Layer1.createMobSpawn4()
    return Layer1.spawnMobSpawn4()
end

function Layer1.destroyMobSpawn4()
    Layer1.clearMobSpawn4()
end

function Layer1.spawnAllMobSpawns()
    Layer1.spawnMobSpawn()
    Layer1.spawnMobSpawn2()
    Layer1.spawnMobSpawn3()
    Layer1.spawnMobSpawn4()
end

function Layer1.clearAllMobSpawns()
    Layer1.clearMobSpawn()
    Layer1.clearMobSpawn2()
    Layer1.clearMobSpawn3()
    Layer1.clearMobSpawn4()
end

function Layer1.destroyAllMobSpawns()
    Layer1.destroyMobSpawn()
    Layer1.destroyMobSpawn2()
    Layer1.destroyMobSpawn3()
    Layer1.destroyMobSpawn4()
end

-- 兼容旧接口：仅创建1号（分阶段后2/3号不再随start创建）
function Layer1.createBosses()
    Layer1.createBoss1()
    print("[Layer1] createBosses 已改为分阶段，仅创建1号Boss；2/3号将在击杀后依次创建")
end

function Layer1.destroyBosses()
    for i, u in pairs(Layer1.bossUnits) do if u then u:destroy() end end
    Layer1.bossUnits = {}; Layer1.boss1Unit = nil
    Layer1.bossStage = 1
    Layer1.clearBoss1Minions()
    Layer1.clearBoss2Minions()
    Layer1.clearBoss3Minions()
    print("[Layer1] Boss已销毁")
end

-- ============================================================
-- 关卡流程：触发与通关
-- ============================================================
local function registerLayerEvents()
    -- 清理旧事件
    for _, e in ipairs(Layer1.events) do if e then e:destroy() end end
    Layer1.events = {}

    -- 监听任意单位死亡：营地 / 獄卒解绑 / Boss
    local deathEv = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer1.finished then return end
        local dying = ev.unit
        if not dying then return end
        local dx, dy = cj.GetUnitX(dying), cj.GetUnitY(dying)
        local tid = cj.GetUnitTypeId(dying)
        local tidStr = i2c(tid)

        -- 獄卒 hlc4 死亡 -> 立即解除所属营地的绑定
        if tidStr == Layer1.guardId then
            for _, camp in ipairs(Layer1.campData) do
                for k, g in ipairs(camp.guards) do
                    if g and g._handle == dying then
                        table.remove(camp.guards, k)
                        print(string.format("[Layer1] 营地%d 獄卒死亡已解绑 剩余%d/%d", camp.idx, #camp.guards, getCampMaxGuards()))
                        break
                    end
                end
            end
            return
        end

        -- 营地 h9Z4 死亡 -> 移除对应墙（最近匹配）
        if tidStr == Layer1.campId then
            -- 找到最近的营地（距离<300）
            local hitCamp = nil
            for _, camp in ipairs(Layer1.campData) do
                if distance(dx, dy, camp.x, camp.y) < 300 then hitCamp = camp; break end
            end
            if hitCamp then
                if hitCamp.idx == 1 then
                    Layer1.removeWallNear(Layer1.triggerWalls.camp1.tx, Layer1.triggerWalls.camp1.ty, "营地1摧毁")
                    print("[Layer1] 营地1被摧毁，横墙已移除")
                    if SystemMessage and SystemMessage.send then SystemMessage.send({{"STR", "营地1已摧毁", SystemMessage.COLOR_SUCCESS}}, 3.0) end
                elseif hitCamp.idx == 2 then
                    Layer1.removeWallNear(Layer1.triggerWalls.camp2.tx, Layer1.triggerWalls.camp2.ty, "营地2摧毁")
                    print("[Layer1] 营地2被摧毁，竖墙1已移除")
                    if SystemMessage and SystemMessage.send then SystemMessage.send({{"STR", "营地2已摧毁", SystemMessage.COLOR_SUCCESS}}, 3.0) end
                else
                    print(string.format("[Layer1] 营地%d被摧毁", hitCamp.idx))
                    if SystemMessage and SystemMessage.send then SystemMessage.send({{"STR", string.format("营地%d已摧毁", hitCamp.idx), SystemMessage.COLOR_SUCCESS}}, 3.0) end
                end
                -- 清理该营地残留獄卒绑定（死亡时已解绑，此处兜底）
                hitCamp.guards = {}
            else
                -- fallback 按原触发点距离
                local cx, cy = -11582.7, -12989
                if distance(dx, dy, cx, cy) < 300 then
                    Layer1.removeWallNear(Layer1.triggerWalls.camp1.tx, Layer1.triggerWalls.camp1.ty, "营地1摧毁")
                end
                local cx2, cy2 = -11962.0, -10687.5
                if distance(dx, dy, cx2, cy2) < 300 then
                    Layer1.removeWallNear(Layer1.triggerWalls.camp2.tx, Layer1.triggerWalls.camp2.ty, "营地2摧毁")
                end
            end
            return
        end

        -- Boss击杀：按Boss坐标距离判定是几号
        local killerBossIdx = nil
        for i, bpos in ipairs(Layer1.bosses) do
            if distance(dx, dy, bpos.x, bpos.y) < 500 then killerBossIdx = i; break end
        end
        -- fallback：按Boss Unit句柄匹配
        if not killerBossIdx then
            for i, bu in pairs(Layer1.bossUnits) do
                if bu and bu._handle == dying then killerBossIdx = i; break end
            end
            if not killerBossIdx and Layer1.boss1Unit and Layer1.boss1Unit._handle == dying then killerBossIdx = 1 end
        end

        if killerBossIdx == 1 then
            Layer1.removeWallNear(Layer1.triggerWalls.boss1.tx, Layer1.triggerWalls.boss1.ty, "1号Boss击杀")
            print("[Layer1] 1号Boss已击杀，竖墙2已移除")
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "1号Boss已击杀", SystemMessage.COLOR_SUCCESS}}, 3.0)
            end
            Layer1.activateBoss1MinionsChase()
            -- 分阶段：1号击杀后才创建2号Boss及其仆从，避免隔墙被远程命中
            if not Layer1.bossUnits[2] or not isUnitAlive(Layer1.bossUnits[2]) then
                Layer1.createBoss2()
                Layer1.spawnBoss2Minions(270)
                print("[Layer1] 阶段推进：2号Boss hqR6 内容已创建")
                if SystemMessage and SystemMessage.send then
                    SystemMessage.send({{"STR", "2号Boss已出现！", SystemMessage.COLOR_WARN}}, 3.0)
                else
                    Player.sendAll("2号Boss已出现！")
                end
            end
        elseif killerBossIdx == 2 then
            Layer1.removeWallNear(Layer1.triggerWalls.boss2.tx, Layer1.triggerWalls.boss2.ty, "2号Boss击杀")
            print("[Layer1] 2号Boss已击杀，竖墙3已移除")
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "2号Boss已击杀", SystemMessage.COLOR_SUCCESS}}, 3.0)
            end
            Layer1.clearBoss2Minions()
            -- 分阶段：2号击杀后才创建3号Boss及其仆从
            if not Layer1.bossUnits[3] or not isUnitAlive(Layer1.bossUnits[3]) then
                Layer1.createBoss3()
                Layer1.spawnBoss3Minions(8)
                print("[Layer1] 阶段推进：3号Boss h01e 内容已创建")
                if SystemMessage and SystemMessage.send then
                    SystemMessage.send({{"STR", "3号Boss已出现！", SystemMessage.COLOR_WARN}}, 3.0)
                else
                    Player.sendAll("3号Boss已出现！")
                end
            end
        elseif killerBossIdx == 3 then
            Layer1.removeWallNear(Layer1.triggerWalls.boss3.tx, Layer1.triggerWalls.boss3.ty, "3号Boss击杀")
            print("[Layer1] 3号Boss已击杀，竖墙4已移除")
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "3号Boss已击杀", SystemMessage.COLOR_SUCCESS}}, 3.0)
            end
            Layer1.clearBoss3Minions()
            -- 创建通关区域
            Layer1.createExitRegion()
        end
    end)
    table.insert(Layer1.events, deathEv)
end

function Layer1.createExitRegion()
    if Layer1.exitRect then return end
    local cx, cy, w, h = Layer1.exitCenter.x, Layer1.exitCenter.y, Layer1.exitCenter.w, Layer1.exitCenter.h
    Layer1.exitRect = Rect:newCenter(cx, cy, w, h)
    Layer1.enteredPlayers = {}
    print(string.format("[Layer1] 通关区域已创建 中心 %.1f,%.1f 尺寸 %dx%d", cx, cy, w, h))

    local function onEnter(ev)
        if Layer1.finished then return end
        local entering = ev._unit or cj.GetEnteringUnit()
        if not entering then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(entering))
        if not owner or not owner:isUser() then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        -- 标记该玩家已进入
        if not Layer1.enteredPlayers[pid] then
            Layer1.enteredPlayers[pid] = true
            print(string.format("[Layer1] 玩家%d 进入通关区域 [%d/%d]", pid, Layer1.getEnteredCount(), Layer1.getOnlineCount()))
        end
        -- 判断是否所有在线玩家都已进入（同时或累计）
        local need = Layer1.getOnlineCount()
        local have = Layer1.getEnteredCount()
        if have >= need and need > 0 then
            Layer1.onAllPlayersEntered()
        end
    end

    local ev = Event:newRect(Layer1.exitRect._handle, onEnter)
    Layer1.exitRegionCallback = onEnter
    table.insert(Layer1.events, ev)
end

function Layer1.getOnlineCount()
    if GameInit and GameInit.getOnlinePlayers then return #GameInit.getOnlinePlayers() end
    local n=0; for pid=0,3 do local p=Player:new(pid) if p:isPlaying() and p:isUser() then n=n+1 end end; return n
end

function Layer1.getEnteredCount()
    local n=0; for _ in pairs(Layer1.enteredPlayers) do n=n+1 end; return n
end

function Layer1.onAllPlayersEntered()
    if Layer1.finished then return end
    Layer1.finished = true
    print("[Layer1] 所有玩家已进入通关区域，关卡1通关！")
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡1通关！", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡1通关！")
    end
    -- 移动所有玩家英雄到关卡2入口
    local entry = Layer2 and Layer2.entryPos or { x = -11398.9, y = -7748.4 }
    local ex, ey = entry.x, entry.y
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p:isPlaying() and p:isUser() then
            -- 移动该玩家所有英雄到入口
            local g = cj.CreateGroup()
            cj.GroupEnumUnitsOfPlayer(g, p._handle, nil)
            local u = cj.FirstOfGroup(g)
            while u ~= nil do
                if cj.IsUnitType(u, UNIT_TYPE_HERO) then
                    cj.SetUnitPosition(u, ex, ey)
                    if cj.GetLocalPlayer() == p._handle then Camera.panTo(ex, ey) end
                end
                cj.GroupRemoveUnit(g, u)
                u = cj.FirstOfGroup(g)
            end
            cj.DestroyGroup(g)
        end
    end
    -- 切换关卡
    if GameInit then GameInit.currentLayer = 2 end
    -- 关闭移除关卡1所有功能（不再复用）
    Layer1.shutdown()
    -- 启动关卡2
    local ok, L2 = pcall(require, "Game.Layers.Layer2")
    if ok and L2 and L2.start then L2.start() end
end

-- 启动 / 关闭（分阶段：初始仅创建1号Boss内容，2/3号击杀后依次创建，墙体5个保持不变）
function Layer1.start()
    if Layer1.started then print("[Layer1] 已启动，跳过") return end
    Layer1.started = true; Layer1.finished = false
    Layer1.bossStage = 1
    print("[Layer1] 启动关卡1（分阶段）")
    Layer1.createWalls() -- 5墙保持不变
    Layer1.createCamps()
    -- 初始阶段仅1号Boss，避免远程隔墙打2/3号
    Layer1.createBoss1()
    Layer1.spawnBoss1Minions(9)
    -- 刷怪点1 -12880.6,-11384.0 上行y+90 3*h11q 中行y 两边hA11 下行y-90 1*h00p
    Layer1.spawnMobSpawn()
    -- 刷怪点2 -11990.7,-12169.0 中心nl3r 东侧3*n611 南北2*n642
    Layer1.spawnMobSpawn2()
    -- 刷怪点3 -12171.7,-13688.3 两边各1个 hlc4
    Layer1.spawnMobSpawn3()
    -- 刷怪点4 -11148.1,-12564.9 左右各1个 h11q
    Layer1.spawnMobSpawn4()
    registerLayerEvents()
    print("[Layer1] 初始阶段完成：仅1号Boss h31v +仆从已创建 +刷怪点1/2各6单位+刷怪点3 2*hlc4+刷怪点4 2*h11q，2号hqR6/3号h01e待击杀后创建")
end

function Layer1.shutdown()
    if not Layer1.started and not Layer1.finished then end
    Layer1.started = false
    -- 销毁事件
    for _, e in ipairs(Layer1.events) do if e and e.destroy then pcall(function() e:destroy() end) end end
    Layer1.events = {}
    -- 销毁区域
    if Layer1.exitRect and Layer1.exitRegionCallback then
        pcall(function() Event:destroyRect(Layer1.exitRect._handle) end)
    end
    if Layer1.exitRect then Layer1.exitRect:destroy(); Layer1.exitRect = nil end
    Layer1.exitRegionCallback = nil
    Layer1.enteredPlayers = {}
    -- 停止唯一营地刷新计时器
    if Layer1.campTimer then Layer1.campTimer:destroy(); Layer1.campTimer = nil end
    if Layer1.boss1ChaseTimer then Layer1.boss1ChaseTimer:destroy(); Layer1.boss1ChaseTimer = nil end
    Layer1.destroyCamps()
    Layer1.destroyBosses()
    Layer1.destroyAllMobSpawns()
    Layer1.destroyWalls()
    print("[Layer1] 已关闭移除，关卡1不再复用")
end

return Layer1
