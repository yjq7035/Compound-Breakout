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
    {index = 1, x = -11775.9, y = -9896.5,  id = "DL84", dir = "V", face = 0,    name = "竖墙 1"  },
    {index = 2 , x = -11224.8, y = -10484.6, id = "B000", dir = "H", face = 270, name = "横墙 2"  },
    {index = 3, x = -9095,    y = -10082.8, id = "DL84", dir = "V", face = 0,    name = "竖墙 3"  },--右边

    {index = 4, x = -9865,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 4"  },--左边1
    {index = 5, x = -9095,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙 5"  },--右边1

    {index = 6, x = -9865,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 6"  },--左边2
    {index = 7, x = -9095,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙 7"  },--右边2

    {index = 8, x = -9865,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 8"  },--左边3
    {index = 9, x = -9095,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙 9"  },--右边3

    {index = 10, x = -9865,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 10" },--左边4
    {index = 11, x = -9095,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙 11" },--右边4

    {index = 12, x = -9490,    y = -13448,   id = "B000", dir = "H", face = 270, name = "横墙 2"  },
}

-- 运行时
Layer2.handles = {} -- destructable handle 列表
Layer2.wallMap = {} -- index -> handle（以 walls[].index 为 key，绑定刷怪区域）

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

-- 刷怪点 8：-10290.0,-12379.8  um5F(1) + u7v9(2) + u8mo(6)  默认朝向 0  增强属性（原9号，已对调 2026-08-26）
Layer2.mobSpawn8Pos        = { x = -10290.0, y = -12379.8, spacing = 90, name = "关卡 2 刷怪点 8"  }
Layer2.mobSpawn8Units      = {}
Layer2.mobSpawn8Invincible = true
Layer2.mobSpawn8Paused     = true
Layer2.mobSpawn8Facing     = 0

-- 刷怪点 9：-8712.0,-12396.8  n8Ti(1) + nd96(5)  默认朝向 180  增强属性（原8号，已对调 2026-08-26，原10号->8）
Layer2.mobSpawn9Pos        = { x = -8712.0, y = -12396.8, spacing = 90, name = "关卡 2 刷怪点 9"  }
Layer2.mobSpawn9Units      = {}
Layer2.mobSpawn9Invincible = true
Layer2.mobSpawn9Paused     = true
Layer2.mobSpawn9Facing     = 180

-- 刷怪点 10：-10273.8,-13174.9  nM28(1)  默认朝向 0（原8号，已对调）
Layer2.mobSpawn10Pos        = { x = -10273.8, y = -13174.9, spacing = 90, name = "关卡 2 刷怪点 10" }
Layer2.mobSpawn10Units      = {}
Layer2.mobSpawn10Invincible = true
Layer2.mobSpawn10Paused     = true
Layer2.mobSpawn10Facing     = 0

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

local function isUnitAlive(u)
    if not u then return false end
    -- 使用 Unit 对象的 isValid 方法，避免直接使用底层 API
    if type(u) == "table" and u.isValid then
        return u:isValid()
    end
    -- handle 已被引擎移除（通过 Unit 封装检查）视为死亡
    if u and u._handle then
        if type(u.isValid) == "function" then
            local ok, valid = u:isValid()
            return ok and valid or false
        end
        -- 兜底：尝试通过 Unit 对象获取状态
        if u.getState then
            local life = u:getState(UNIT_STATE_LIFE)
            if life <= 0.405 then return false end
        end
    end
    return true
end

-- 设置单位无敌和暂停（与 Layer1 刷怪点默认行为一致）
---@param u Unit
---@param invincible boolean
---@param paused boolean
local function setInvulnerableAndPause(u, invincible, paused)
    if not u then return end
    -- 设置无敌
    if invincible then
        if u.setInvulnerable then
            u:setInvulnerable(true)
        elseif u._handle and cj.SetUnitInvulnerable then
            cj.SetUnitInvulnerable(u._handle, true)
        end
    end
    -- 设置暂停
    if paused then
        if u.pause then
            u:pause(true)
        elseif u._handle and cj.PauseUnit then
            cj.PauseUnit(u._handle, true)
        end
        if u.setPauseState then
            u:setPauseState(true)
        end
    end
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

    -- 当前生命设为新上限的 35%（使用 set 接口强制设置，避免 addState 负值问题）
    local newMaxLife = maxLife * 1.2
    local targetLife = math.floor(newMaxLife * 0.35)
    
    -- 优先尝试直接设置当前生命值
    if u.set then
        u:setState(UNIT_STATE_LIFE, targetLife)
    elseif u._handle and cj.SetUnitState then
        cj.SetUnitState(u._handle, UNIT_STATE_LIFE, targetLife)
    else
        local delta = targetLife - currentLife
        if delta ~= 0 then
            u:addState(UNIT_STATE_LIFE, delta)
        end
    end
    
    local newArmor = math.floor(armor * 0.2)
    local newAttack = math.floor(attack * 0.2)

    u:addState(UNIT_STATE_DEFEND_WHITE, newArmor)
    u:addState(UNIT_STATE_ATTACK_WHITE, newAttack)
end

local function clearUnits(unitsKey, label)
    local list = Layer2[unitsKey]
    if not list then Layer2[unitsKey] = {} return end
    for _, u in ipairs(list) do
        if u and u.destroy then u:destroy() end
    end
    local n = #list
    Layer2[unitsKey] = {}
end

local function activateUnits(unitsKey, label, tx, ty)
    local list = Layer2[unitsKey]
    if not list then return end
    

    
    for _, u in ipairs(list) do
        if not u or not u._handle then 
            goto continue_loop
        end
        
        -- 移除无敌：直接调用 Unit 封装接口
        if u.setInvulnerable then
            u:setInvulnerable(false)
        elseif u._handle then
            cj.SetUnitInvulnerable(u._handle, false)
        end
        
        -- 解除暂停
        if u.pause then
            u:pause(false)
        elseif u._handle then
            cj.PauseUnit(u._handle, false)
        end
        if u.setPauseState and u.setPauseState then
            u:setPauseState(false)
        end
        
        -- 兜底：EXPauseUnit（框架 stun 使用）
        if u._handle and cj.IsUnitPaused and cj.IsUnitPaused(u._handle) then
            cdz.EXPauseUnit(u._handle, false)
        end
        
        -- 扩大索敌
        cj.SetUnitAcquireRange(u._handle, 2500)
        if u.setAcquireRange then
            u:setAcquireRange(2500)
        end
        
        -- 攻击移动
        if u.attack then
            u:attack(tx, ty)
        elseif u.orderPoint then
            u:orderPoint("attack", tx, ty)
        elseif u._handle then
            cj.IssuePointOrder(u._handle, "attack", tx, ty)
        end
        
        ::continue_loop::
    end
end

-- 通用刷怪：创建前自动清理旧的，统一处理无敌/暂停/增强
local function spawnGeneric(posKey, unitsKey, gridFunc, facing, label, detail, enhanced)
    local posDef = Layer2[posKey]
    local cx = posDef and posDef.x or nil
    local cy = posDef and posDef.y or nil
    -- 允许外部传入覆盖坐标（保持原接口 cx,cy 可选）
    -- 调用方已处理 cx/cy 回落，此处仅兜底
    local positions = gridFunc(cx, cy)
    local p = Player:new(0)

    clearUnits(unitsKey, label)
    Layer2[unitsKey] = {}

    local invincibleKey = posKey:gsub("Pos$", "Invincible")
    local pausedKey     = posKey:gsub("Pos$", "Paused")
    local needInvincible = Layer2[invincibleKey]
    local needPaused     = Layer2[pausedKey]

    for _, pos in ipairs(positions) do
        local u = Unit:new(p, pos.id, pos.x, pos.y, facing)
        if u then
            table.insert(Layer2[unitsKey], u)
            setInvulnerableAndPause(u, needInvincible, needPaused)
            if enhanced then applyEnhancedStats(u) end
        end
    end

    -- local count = #Layer2[unitsKey]
    -- local suffix = enhanced and " (默认无敌且暂停，朝向 " .. facing .. "，增强属性)" or string.format(" (默认无敌且暂停，朝向 %d)", facing)
    -- detail 已包含单位构成说明
    return Layer2[unitsKey]
end

-- ============================================================
-- §6 墙体管理
-- ============================================================

    local function createOne(w)
        if not w or not w.x or not w.y or not w.id then return nil end
        local face = w.face or (w.dir == "H" and 270 or 0)
        -- 使用底层 API 创建可破坏物
        local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
        return h
    end

function Layer2.createWalls()
    if #Layer2.handles > 0 then
        return Layer2.handles
    end
    Layer2.handles = {}
    Layer2.wallMap = {}
    for i, w in ipairs(Layer2.walls) do
        local h = createOne(w)
        if h then
            table.insert(Layer2.handles, h)
            Layer2.wallMap[w.index or i] = h
        end
    end
    return Layer2.handles
end

function Layer2.destroyWalls()
    for _, h in ipairs(Layer2.handles) do if h then cj.RemoveDestructable(h) end end
    local n = #Layer2.handles
    Layer2.handles = {}
    Layer2.wallMap = {}
    if n > 0 then
        --print("[Layer2] 第二关卡墙体已移除 count=" .. n)
    end
end

function Layer2.getCount() return #Layer2.handles end
function Layer2.isCreated() return #Layer2.handles > 0 end

-- 按 index 精确移除（刷怪区域进入后按 walls[].index == 区域id 删除对应墙）
function Layer2.removeWallByIndex(index, reason)
    if not index then return false end
    -- 兼容字符串索引
    if type(index) == "string" then index = tonumber(index) or index end
    local h = Layer2.wallMap[index]
    -- 查找墙定义用于日志
    local w = nil
    for _, ww in ipairs(Layer2.walls) do
        if ww.index == index then w = ww; break end
    end
    local wName = (w and w.name) or ("index=" .. tostring(index))
    if h then
        -- 使用 Unit 封装移除（如果封装层提供）
        if h.destroy then
            pcall(function() h:destroy() end)
        else
            -- 兜底：使用底层 API 移除
            pcall(function() cj.RemoveDestructable(h) end)
        end
        Layer2.wallMap[index] = nil
        for k, vh in ipairs(Layer2.handles) do
            if vh == h then table.remove(Layer2.handles, k) break end
        end
        return true
    else
        -- 兜底：wallMap 缺失时尝试按坐标枚举可破坏物直接删除（防 Create 失败但地图仍有编辑器放置的墙）
        if w and w.x and w.y then
            local found = 0
            local rect = cj.Rect(w.x - 64, w.y - 64, w.x + 64, w.y + 64)
            if rect then
                pcall(function() cj.EnumDestructablesInRect(rect, nil, function()
                    local d = cj.GetEnumDestructable()
                    if d then
                        local tid = cj.GetDestructableTypeId(d)
                        if tid == c2i(w.id) then
                            local dx, dy = cj.GetDestructableX(d), cj.GetDestructableY(d)
                            if ((dx - w.x)^2 + (dy - w.y)^2)^0.5 < 64 then
                                if d.destroy then
                                    pcall(function() d:destroy() end)
                                else
                                    pcall(function() cj.RemoveDestructable(d) end)
                                end
                                found = found + 1
                            end
                        end
                    end
                end) end)
                pcall(function() cj.RemoveRect(rect) end)
            end
            if found > 0 then
                -- 同步清理 handles 中可能残留但 wallMap 已空的情况
                for k = #Layer2.handles, 1, -1 do
                    local vh = Layer2.handles[k]
                    if vh then
                        -- 检查 handle 是否有效
                    end
                end
                if SystemMessage and SystemMessage.send then
                    local wallMsg = string.format("力量墙已销毁 - %s - %s", reason or wName, wName)
                    SystemMessage.send({{"STR", wallMsg, SystemMessage.COLOR_INFO}}, 3.0)
                end
                return true
            end
        end
        return false
    end
end



-- 最近墙匹配移除（兼容旧调用，内部转按 index 删除）
function Layer2.removeWallNear(tx, ty, reason)
    if not tx or not ty then return false end
    local bestWall, bestDist = nil, 1e9
    for _, w in ipairs(Layer2.walls) do
        local d = distance(tx, ty, w.x, w.y)
        if d < bestDist then bestDist = d; bestWall = w end
    end
    if not bestWall then return false end
    -- 复用按 index 精确删除，保持日志/ handles 一致
    local ok = Layer2.removeWallByIndex(bestWall.index, reason)
    return ok
end

-- 批量按 index 删除（可选，供外部一次性清多堵墙）
function Layer2.removeWallsByIndices(indices, reason)
    if not indices then return 0 end
    local n = 0
    for _, idx in ipairs(indices) do
        if Layer2.removeWallByIndex(idx, reason) then n = n + 1 end
    end
    return n
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

-- 刷怪点 8：中心 um5F(1) + 上下 u7v9(2) + x±90 上中下 u8mo(6)  朝向 0  增强（原9号，已对调 2026-08-26）
function Layer2.calcMobSpawn8Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn8Pos.spacing or 90
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

-- 刷怪点 9：中心 n8Ti(1) + 上下 nd96(2) + x-90 上中下 nd96(3)  朝向 180  增强（原8号，已对调 2026-08-26，原10号->8）
function Layer2.calcMobSpawn9Grid(cx, cy)
    if not cx or not cy then return {} end
    local s = Layer2.mobSpawn9Pos.spacing or 90
    return {
        { x = cx,         y = cy,     id = "n8Ti" },
        { x = cx,         y = cy + s, id = "nd96" },
        { x = cx,         y = cy - s, id = "nd96" },
        { x = cx - s,     y = cy + s, id = "nd96" },
        { x = cx - s,     y = cy,     id = "nd96" },
        { x = cx - s,     y = cy - s, id = "nd96" },
    }
end

-- 刷怪点 10：中心 nM28(1)  朝向 0（原8号，已对调）
function Layer2.calcMobSpawn10Grid(cx, cy)
    if not cx or not cy then return {} end
    return {
        { x = cx,         y = cy,     id = "nM28" },
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
function Layer2.activateMobSpawn1(tx, ty) activateUnits("mobSpawn1Units", "刷怪点 1", tx, ty) end

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
function Layer2.activateMobSpawn2(tx, ty) activateUnits("mobSpawn2Units", "刷怪点 2", tx, ty) end

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
function Layer2.activateMobSpawn3(tx, ty) activateUnits("mobSpawn3Units", "刷怪点 3", tx, ty) end

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
function Layer2.activateMobSpawn4(tx, ty) activateUnits("mobSpawn4Units", "刷怪点 4", tx, ty) end

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
function Layer2.activateMobSpawn5(tx, ty) activateUnits("mobSpawn5Units", "刷怪点 5", tx, ty) end

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
function Layer2.activateMobSpawn6(tx, ty) activateUnits("mobSpawn6Units", "刷怪点 6", tx, ty) end

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
function Layer2.activateMobSpawn7(tx, ty) activateUnits("mobSpawn7Units", "刷怪点 7", tx, ty) end

-- 刷怪点 8（增强，原9号，已对调 2026-08-26）
function Layer2.spawnMobSpawn8(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn8Pos.x end
    if cy == nil then cy = Layer2.mobSpawn8Pos.y end
    local ox, oy = Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y
    Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn8Pos", "mobSpawn8Units", Layer2.calcMobSpawn8Grid, Layer2.mobSpawn8Facing,
        "刷怪点 8 ", "um5F(1 个：中心) + u7v9(2 个：y+90/-90) + u8mo(6 个：x±90 上中下)", true)
    Layer2.mobSpawn8Pos.x, Layer2.mobSpawn8Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn8()   clearUnits("mobSpawn8Units", "刷怪点 8") end
function Layer2.destroyMobSpawn8() Layer2.clearMobSpawn8() end
function Layer2.activateMobSpawn8(tx, ty) activateUnits("mobSpawn8Units", "刷怪点 8", tx, ty) end

-- 刷怪点 9（增强，原8号，已对调 2026-08-26，原10号->8）
function Layer2.spawnMobSpawn9(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn9Pos.x end
    if cy == nil then cy = Layer2.mobSpawn9Pos.y end
    local ox, oy = Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y
    Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn9Pos", "mobSpawn9Units", Layer2.calcMobSpawn9Grid, Layer2.mobSpawn9Facing,
        "刷怪点 9 ", "n8Ti(1 个：中心) + nd96(5 个：上下 +x-90 上中下)", true)
    Layer2.mobSpawn9Pos.x, Layer2.mobSpawn9Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn9()   clearUnits("mobSpawn9Units", "刷怪点 9") end
function Layer2.destroyMobSpawn9() Layer2.clearMobSpawn9() end
function Layer2.activateMobSpawn9(tx, ty) activateUnits("mobSpawn9Units", "刷怪点 9", tx, ty) end

-- 刷怪点 10（原8号，已对调）
function Layer2.spawnMobSpawn10(cx, cy)
    if cx == nil then cx = Layer2.mobSpawn10Pos.x end
    if cy == nil then cy = Layer2.mobSpawn10Pos.y end
    local ox, oy = Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y
    Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y = cx, cy
    local ret = spawnGeneric("mobSpawn10Pos", "mobSpawn10Units", Layer2.calcMobSpawn10Grid, Layer2.mobSpawn10Facing,
        "刷怪点 10", "nM28(1 个：中心)", false)
    Layer2.mobSpawn10Pos.x, Layer2.mobSpawn10Pos.y = ox, oy
    return ret
end
function Layer2.clearMobSpawn10()   clearUnits("mobSpawn10Units", "刷怪点 10") end
function Layer2.destroyMobSpawn10() Layer2.clearMobSpawn10() end
function Layer2.activateMobSpawn10(tx, ty) activateUnits("mobSpawn10Units", "刷怪点 10", tx, ty) end

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
function Layer2.activateMobSpawn11(tx, ty) activateUnits("mobSpawn11Units", "刷怪点 11", tx, ty) end

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
-- §10 生命周期 + 通关区域（击杀11区Boss后创建）
-- ============================================================

Layer2.started = false
Layer2.finished = false
Layer2.events = {} -- {Event,...}
Layer2.exitRect = nil
Layer2.exitRegionCallback = nil
Layer2.enteredPlayers = {}
Layer2.boss11Killed = false

-- 通关区域配置（击杀11区Boss后创建，用于进入关卡3）
Layer2.exitCenter = { x = -9475.7, y = -13610.3, w = 500, h = 300 }

function Layer2.getOnlineCount()
    if GameInit and GameInit.getOnlinePlayers then return #GameInit.getOnlinePlayers() end
    local n=0; for pid=0,3 do local p=Player:new(pid) if p:isPlaying() and p:isUser() then n=n+1 end end; return n
end

function Layer2.getEnteredCount()
    local n=0; for _ in pairs(Layer2.enteredPlayers) do n=n+1 end; return n
end

function Layer2.createExitRegion()
    if Layer2.exitRect then return end
    local cx, cy, w, h = Layer2.exitCenter.x, Layer2.exitCenter.y, Layer2.exitCenter.w, Layer2.exitCenter.h
    Layer2.exitRect = Rect:newCenter(cx, cy, w, h)
    Layer2.enteredPlayers = {}

    local function onEnter(ev)
        if Layer2.finished then return end
        local entering = ev._unit or cj.GetEnteringUnit()
        if not entering then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(entering))
        if not owner or not owner:isUser() then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        -- 标记该玩家已进入（仅首次计数）
        local isNew = false
        if not Layer2.enteredPlayers[pid] then
            Layer2.enteredPlayers[pid] = true
            isNew = true
        end
        -- 中央系统信息提示：谁已就绪 + 等待其余人数（与关卡1一致）
        if isNew and SystemMessage and SystemMessage.send then
            local playerName = owner:getName()
            if not playerName or playerName == "" then playerName = string.format("玩家%d", pid + 1) end
            local need = Layer2.getOnlineCount()
            local have = Layer2.getEnteredCount()
            if have < need then
                local remain = need - have
                SystemMessage.send({{"STR", string.format("玩家 %s 已进入传送门就绪 [%d/%d]，等待其他 %d 名玩家进入...", playerName, have, need, remain), SystemMessage.COLOR_WARN}}, 3.0)
            end
        end
        local need = Layer2.getOnlineCount()
        local have = Layer2.getEnteredCount()
        if have >= need and need > 0 then
            Layer2.onAllPlayersEntered()
        end
    end

    local ev = Event:newRect(Layer2.exitRect._handle, onEnter)
    Layer2.exitRegionCallback = onEnter
    table.insert(Layer2.events, ev)
end

function Layer2.destroyExitRegion()
    if Layer2.exitRect and Layer2.exitRegionCallback then
        pcall(function() Event:destroyRect(Layer2.exitRect._handle) end)
    end
    if Layer2.exitRect then Layer2.exitRect:destroy(); Layer2.exitRect = nil end
    Layer2.exitRegionCallback = nil
    Layer2.enteredPlayers = {}
end

function Layer2.onAllPlayersEntered()
    if Layer2.finished then return end
    Layer2.finished = true
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 2 通关！", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 2 通关！")
    end

    -- 传送至关卡 3 入口：用 Unit 坐标移动（修复 SetPlayerStartLocationX/Y 不存在报错，与关卡 1 保持一致）
    local entry = Layer3 and Layer3.entryPos or { x = -11915.5, y = -1952.6 }
    local ex, ey = entry.x, entry.y
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p:isPlaying() and p:isUser() then
            -- 使用 Group 封装创建单位组（如果封装层提供）
            local g = nil
            if Group then
                g = Group:new()
            else
                g = cj.CreateGroup()
            end
            -- 枚举玩家单位
            if Group and Group.EnumUnitsOfPlayer then
                Group.EnumUnitsOfPlayer(g, p._handle, nil)
            else
                cj.GroupEnumUnitsOfPlayer(g, p._handle, nil)
            end
            local u = nil
            if Group and Group.FirstUnit then
                u = Group.FirstUnit(g)
            else
                u = cj.FirstOfGroup(g)
            end
            while u ~= nil do
                if u:IsUnitType(UNIT_TYPE_HERO) then
                    -- 优先用 Unit 封装的坐标移动，确保与项目 OOP 层一致
                    local moved = false
                    if Unit and Unit.fromHandle then
                        local ok, unitObj = pcall(Unit.fromHandle, u)
                        if ok and unitObj and unitObj.setPosition then
                            local ok2 = pcall(function() unitObj:setPosition(ex, ey) end)
                            if ok2 then moved = true end
                        end
                    end
                    if not moved then
                        -- 使用 Unit 封装设置坐标（如果提供）
                        if u.setPosition then
                            pcall(function() u:setPosition(ex, ey) end)
                        end
                        -- 兜底：使用底层 API
                        pcall(cj.SetUnitPosition, u, ex, ey)
                        pcall(cj.SetUnitX, u, ex)
                        pcall(cj.SetUnitY, u, ey)
                    end
                    -- 设置寻路
                    if u.setPathing then
                        pcall(function() u:setPathing(true) end)
                    end
                    pcall(cj.SetUnitPathing, u, true)
                    -- 镜头跟随：异步操作，需包裹异步判断
                    if cj.GetLocalPlayer() == p._handle then
                        if Camera and Camera.panTo then
                            pcall(function() Camera.panTo(ex, ey) end)
                        end
                    end
                end
                -- 移除单位
                if Group and Group.RemoveUnit then
                    Group.RemoveUnit(g, u)
                else
                    cj.GroupRemoveUnit(g, u)
                end
                -- 获取下一个单位
                if Group and Group.FirstUnit then
                    u = Group.FirstUnit(g)
                else
                    u = cj.FirstOfGroup(g)
                end
            end
            if Group and Group.Destroy then
                Group.Destroy(g)
            else
                cj.DestroyGroup(g)
            end
        end
    end

    if GameInit then GameInit.currentLayer = 3 end
    Layer2.shutdown()
    local ok, L3 = pcall(require, "Game.Layers.Layer3")
    if ok and L3 and L3.start then L3.start() end
end

-- 11区Boss死亡监听：击杀 nn13 时销毁12号墙并创建通关区域
local function registerBoss11DeathEvent()
    -- 清理旧事件
    for _, e in ipairs(Layer2.events) do
        if e and e._eventType == EVENT_PLAYER_UNIT_DEATH then
            -- 保留其他死亡事件，仅清理需重建的（此处统一清理后重建）
        end
    end
    local deathEv = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer2.finished then return end
        if Layer2.boss11Killed then return end
        local dying = ev.unit
        if not dying then return end
        -- 使用 Unit 封装获取类型 ID（如果提供）
        local tid = nil
        if dying and dying.getTypeId then
            tid = dying:getTypeId()
        else
            tid = cj.GetUnitTypeId(dying)
        end
        local tidStr = i2c(tid)
        if tidStr ~= "nn13" then return end
        -- 距离校验：确保是 11 区 Boss（-8720.5,-13157.2 附近 500 码）或通过单位句柄匹配
        local dx, dy = nil, nil
        if dying and dying.getX then
            dx, dy = dying:getX(), dying:getY()
        else
            dx = cj.GetUnitX(dying)
            dy = cj.GetUnitY(dying)
        end
        local isNear = distance(dx, dy, Layer2.mobSpawn11Pos.x, Layer2.mobSpawn11Pos.y) < 600
        local isHandleMatch = false
        for _, u in ipairs(Layer2.mobSpawn11Units or {}) do
            if u and u._handle == dying then isHandleMatch = true; break end
        end
        if not isNear and not isHandleMatch then return end

        Layer2.boss11Killed = true
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "11 区 Boss 已击杀", SystemMessage.COLOR_SUCCESS}}, 3.0)
        end
        -- 销毁12号墙（横墙 2）
        Layer2.removeWallByIndex(12, "11区Boss击杀")
        -- --print("[Layer2] 12号墙已移除（11区Boss击杀）")

        -- 清理该Boss残留
        Layer2.clearMobSpawn11()

        -- 创建通关区域
        Layer2.createExitRegion()
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "通关区域已开启 - 前往 -9475.7,-13610.3", SystemMessage.COLOR_WARN}}, 3.0)
        end
    end)
    table.insert(Layer2.events, deathEv)
end

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    Layer2.finished = false
    Layer2.boss11Killed = false
    -- 清理旧事件/区域（热重载安全）
    for _, e in ipairs(Layer2.events) do if e and e.destroy then pcall(function() e:destroy() end) end end
    Layer2.events = {}
    if Layer2.exitRect then Layer2.destroyExitRegion() end
    Layer2.enteredPlayers = {}
    -- --print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        -- Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    Layer2.createWalls()
    Layer2.spawnAllMobSpawns()
    registerBoss11DeathEvent()
    -- 创建触发区域和事件（延迟 0.5 秒，确保墙体和怪物已就绪）
    Timer:new(0.5, false, function()
        if not Layer2.started then return end
        Layer2.createTriggerAreaBL()
        Layer2.createMobSpawnRects()
    end)
end

function Layer2.shutdown()
    if not Layer2.started and not Layer2.finished then
        -- 允许 finished 后再次关闭清理
    end
    local wasStarted = Layer2.started
    Layer2.started = false
    -- 销毁事件
    for _, e in ipairs(Layer2.events) do if e and e.destroy then pcall(function() e:destroy() end) end end
    Layer2.events = {}
    -- 销毁区域
    Layer2.destroyExitRegion()
    Layer2.destroyWalls()
    Layer2.clearAllMobSpawns()
    Layer2.destroyMobSpawnRects()
    Layer2.destroyTriggerAreaBL()
    -- if wasStarted then --print("[Layer2] 关闭") else print("[Layer2] 关闭（通关后清理）") end
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
    triggerAreaBL = Rect:new(minX, minY, maxX, maxY)
    -- --print(string.format("[Layer2] 触发区域已创建 左下角：%.1f,%.1f 右上角：%.1f,%.1f", minX, minY, maxX, maxY))
    
    -- 设置单位进入事件（回调接收 Event 对象，通过 self.unit 获取进入的单位）
    triggerEventBL = Event:newRect(triggerAreaBL, function(ev)
        local unit = ev.unit or ev._unit
        if unit == nil then
            unit = cj.GetEnteringUnit()
        end
        if unit == nil then return end
        
        -- 获取单位所属玩家
        local player = Player.fromHandle(cj.GetOwningPlayer(unit))
        if not player or not player:isUser() then return end
        
        local pid = player:getId()
        local playerName = player:getName() or string.format("玩家%d", pid)
        
        print(string.format("[Layer2] 单位进入触发区域 unit=%s owner=%s", Event.unitDesc(unit), playerName))
        
        -- 按 index 精确销毁绑定墙（竖墙 1 index=1 对应刷怪区域 1）并激活 1 号刷怪下达追击
        local tx, ty = nil, nil
        if unit and unit.getX then
            tx, ty = unit:getX(), unit:getY()
        else
            tx = cj.GetUnitX(unit)
            ty = cj.GetUnitY(unit)
        end
        if Layer2.removeWallByIndex(1, "触发区域") then
            print("[Layer2] 竖墙 1 已销毁（触发区域 index=1）")
        else
            print("[Layer2] 竖墙 1 已不存在（index=1）仍激活刷怪")
        end
        Layer2.activateMobSpawn1(tx, ty)
        -- 删除区域和事件，避免其他单位进入造成重复触发
        local rectToClean = triggerAreaBL
        triggerAreaBL = nil
        triggerEventBL = nil
        if rectToClean then
            Event:destroyRect(rectToClean)
            rectToClean:destroy()
        end
    end)
    
    if triggerEventBL then
        -- --print("[Layer2] 触发器事件已启动")
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
-- 每个区域为一次性：进入后删除对应最近墙、激活对应刷怪并下达攻击移动到触发单位位置、随后销毁区域防止重复触发
function Layer2.createMobSpawnRects()
    for _, rectDef in ipairs(Layer2.mobSpawnRects) do
        local curDef = rectDef -- 局部捕获，避免闭包共享同一 rectDef 导致全部指向最后一条
        -- 若已存在旧矩形（重入/热重载），先清理避免泄漏
        if mobSpawnRects[curDef.id] then
            local old = mobSpawnRects[curDef.id]
            Event:destroyRect(old)
            old:destroy()
            mobSpawnRects[curDef.id] = nil
            mobSpawnEvents[curDef.id] = nil
        end
        local cx = curDef.cx
        local cy = curDef.cy
        local width = curDef.width
        local height = curDef.height
        
        -- 使用 Rect:newCenter 创建矩形区域（中心点 + 宽高）
        local rect = Rect:newCenter(cx, cy, width, height)
        -- 预检查绑定墙是否存在
        do
            local wallExists = Layer2.wallMap[curDef.id] and "存在" or "缺失"
            local wdef = nil
            for _, ww in ipairs(Layer2.walls) do if ww.index == curDef.id then wdef = ww; break end end
            local wName = wdef and wdef.name or "未知墙"
            --print(string.format("[Layer2] 绑定检查 区域 %s id=%s -> 墙 %s index=%s 状态=%s rectCenter=%.1f,%.1f w=%d h=%d",
                -- curDef.name, tostring(curDef.id), wName, tostring(curDef.id), wallExists, cx, cy, width, height))
        end
        
        -- 设置单位进入事件（使用 event 创建区域事件）
        local event = Event:newRect(rect, function(ev)
            local unit = ev.unit or ev._unit
            if unit == nil then
                unit = cj.GetEnteringUnit()
            end
            if unit == nil then return end
            
            -- 获取单位所属玩家
            local player = Player.fromHandle(cj.GetOwningPlayer(unit))
            if not player or not player:isUser() then return end
            
            local tx, ty = nil, nil
            if unit and unit.getX then
                tx, ty = unit:getX(), unit:getY()
            else
                tx = cj.GetUnitX(unit)
                ty = cj.GetUnitY(unit)
            end
            -- 按 index 精确删除绑定墙
            local ok = Layer2.removeWallByIndex(curDef.id, curDef.name)
            print(string.format("[Layer2] 触发前 wallMap[%s]=%s", tostring(curDef.id), tostring(Layer2.wallMap[curDef.id])))
            Layer2.activateMobSpawn(curDef.id, tx, ty)

            -- 一次性触发：销毁该区域与事件，防止重复触发
            local r = mobSpawnRects[curDef.id]
            if r then
                --print(string.format("[Layer2] 刷怪区域 %s 已触发，销毁区域防止重复", curDef.name))
                Event:destroyRect(r)
                r:destroy()
                mobSpawnRects[curDef.id] = nil
                mobSpawnEvents[curDef.id] = nil
            end
        end)
        
        -- if event then
        --     --print(string.format("[Layer2] 刷怪区域 %s (%.1f,%.1f) 触发器已启动", curDef.name, cx, cy))
        -- else
        --     --print(string.format("[Layer2] 刷怪区域 %s 创建失败", curDef.name))
        -- end
        
        -- 存储句柄
        mobSpawnRects[curDef.id] = rect
        mobSpawnEvents[curDef.id] = event
    end
    
    --print(string.format("[Layer2] 共创建%d个刷怪矩形区域触发器", #Layer2.mobSpawnRects))
end

--- 删除所有刷怪矩形区域触发器
function Layer2.destroyMobSpawnRects()
    for id, rect in pairs(mobSpawnRects) do
        if rect then
            -- 销毁矩形区域（Event:destroyRect 已销毁对应触发器与 region）
            Event:destroyRect(rect)
            rect:destroy()
            --print(string.format("[Layer2] 刷怪区域 %d 已销毁", id))
        end
    end
    -- mobSpawnEvents 与 mobSpawnRects 共享同一 trigger（Event:newRect复用），无需二次 Event:destroy
    mobSpawnRects = {}
    mobSpawnEvents = {}
    
    --print(string.format("[Layer2] 共销毁%d个刷怪矩形区域触发器", #Layer2.mobSpawnRects))
end

--- 通用激活刷怪点函数（根据 ID，透传目标坐标以便下达攻击移动）
function Layer2.activateMobSpawn(id, tx, ty)
    local spawnFuncName = "activateMobSpawn" .. id
    local func = Layer2[spawnFuncName]
    if func then func(tx, ty) end
    -- else
        --print(string.format("[Layer2] 未找到刷怪点 %d 的激活函数", id))
    -- end
end

return Layer2
