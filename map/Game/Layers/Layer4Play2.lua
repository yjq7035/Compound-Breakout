--|=============================================================
-- Layer4Play2 — 关卡 4 玩法 2 独立模块
--|=============================================================
-- 职责：
--   1. §2b: 玩法 2 所有用户玩家英雄进入 A 或 B 后创建竖墙 1
--   2. §2b: 刷怪逻辑（刷怪区监听、刷怪、死亡处理）
--   3. §2b-KEY: 钥匙掉落/持有检测/开门通关
--   4. 独立启动和关闭（由 Layer4 调用）
--|=============================================================

Layer4Play2 = {}
Layer4Play2.__index = Layer4Play2

--|=============================================================
--[§1 坐标]
--|=============================================================
Layer4Play2.entryPos     = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4Play2.revivePos    = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4Play2.teleportPos  = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4Play2.potionShopPos= { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
--[§2b: 玩法 2 配置（竖墙 1 延迟创建）]
--|=============================================================
Layer4Play2.play2Wall1Pos     = { x = -9596.7, y = 4296.7, id = "DL84", dir = "V", face = 0, name = "竖墙 1" }
Layer4Play2.play2Triggered    = false
Layer4Play2.play2WallHandle   = nil
Layer4Play2.play2EnteredPids  = {} -- pid -> true
Layer4Play2.play2MobTimer     = nil
Layer4Play2.play2MobHandles   = {} -- 单位 handle 列表

--|=============================================================
--[§2b-KEY: 玩法 2 钥匙玩法（ao8y 通行旗子）]
--  1) 关卡 4 创建的单位死亡概率掉落 ao8y
--  2) 横墙 2(index=2) 为通关门，携带钥匙靠近即开门通关
--|=============================================================
Layer4Play2.play2KeyConfig = {
    itemId      = "ao8y",
    dropChance  = 0.01,  -- 单只死亡掉落概率 1%，可在测试时临时调高
    doorWallIndex = 2,   -- 横墙 2 为通关门
    doorSize    = { w = 700, h = 700 },
    finished    = false,
}
Layer4Play2.play2DoorRect        = nil
Layer4Play2.play2DoorEvent       = nil
Layer4Play2.play2KeyPickupEvent  = nil

--|=============================================================
--[§2b: 文件头部预先创建矩形配置（供 generateRandomSpawnPos 直接使用）]
--|=============================================================
-- 注意：play2RectsA/B 会在 initMobSpawnRectListeners 中被初始化
-- 这里预留空数组作为默认值（全局变量，供 generateRandomSpawnPos 访问）
Layer4Play2.play2RectsA = {}
Layer4Play2.play2RectsB = {}

-- 预创建矩形函数，供 generateRandomSpawnPos 使用
local function makeRectFromConfig(cfg)
    local ok, r = pcall(Rect.new, Rect, cfg.cx - cfg.width/2, cfg.cy - cfg.height/2, cfg.cx + cfg.width/2, cfg.cy + cfg.height/2)
    if not ok or not r then
        print(string.format("[Layer4Play2] 矩形%s 创建失败：ok=%s r=%s", cfg.id or "?", tostring(ok), tostring(r)))
        return nil
    end
    -- 保存原始宽度和高度到 rect 对象，供 generateRandomSpawnPos 使用
    r.width = cfg.width
    r.height = cfg.height
    print(string.format("[Layer4Play2] 矩形%s 创建成功：%.1f,%.1f -> %.1f,%.1f", cfg.id or "?", r:getMinX(), r:getMinY(), r:getMaxX(), r:getMaxY()))
    return r
end

--|=============================================================
--[§2b: 首次达到上限刷怪配置]
-- 当首次达到 70 个上限时，给每个玩家额外刷一个怪
--|=============================================================
Layer4Play2.play2BonusSpawns = {} -- 记录每个玩家是否已获得 bonus spawn
Layer4Play2.play2HasBonus = false -- 是否已经触发过 bonus spawn 奖励

--|=============================================================
--[§1b 墙体管理工具函数]
--|=============================================================
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then
        print(string.format("[Layer4Play2] createOne: nil params w=%s", tostring(w and w.name or w)))
        return nil
    end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local typeId = c2i(w.id) or 0
    local x, y = tonumber(w.x), tonumber(w.y)
    if not x or not y then
        print(string.format("[Layer4Play2] createOne: bad coords id=%s", tostring(w.id)))
        return nil
    end
    local h = cj.CreateDestructable(typeId, x, y, face, 1, 0)
    if h then
        print(string.format("[Layer4Play2] createOne: %s at %.1f,%.1f ok", w.name or w.id, x, y))
    else
        print(string.format("[Layer4Play2] createOne FAILED: %s id=%s at %.1f,%.1f", w.name or "?", tostring(w.id), x, y))
    end
    return h
end

function Layer4Play2.createPlay2Wall1()
    if Layer4Play2.play2Triggered then return end
    Layer4Play2.play2Triggered = true
    print("[Layer4Play2] §2b: 创建竖墙 1...")
    local h = createOne(Layer4Play2.play2Wall1Pos)
    if h then
        Layer4Play2.play2WallHandle = h
        -- 注意：wallMap 在 Layer4 中管理，这里不添加
        print(string.format("  ✓ 竖墙 1 已创建 %.1f,%.1f", Layer4Play2.play2Wall1Pos.x, Layer4Play2.play2Wall1Pos.y))
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "所有玩家已进入刷怪区，竖墙 1 已升起！", SystemMessage.COLOR_WARN}}, 3.0)
        end
        -- 启动刷怪计时器
        Layer4Play2.startMobSpawnerTimer()
    else
        print("  ✗ 竖墙 1 创建失败")
    end
end

local function getActiveUserPids()
    local list = {}
    for pid = 0, 3 do
        local ok, p = pcall(Player.new, Player, pid)
        if ok and p and p.isUser and p.isPlaying and p:isUser() and p:isPlaying() then
            table.insert(list, pid)
        end
    end
    return list
end

local function isAllUserHeroesEntered()
    local active = getActiveUserPids()
    if #active == 0 then return false end
    for _, pid in ipairs(active) do
        if not Layer4Play2.play2EnteredPids[pid] then return false end
    end
    return true
end

--|=============================================================
--[§2b: 激活区域监听器初始化（修复触发 bug）]
--|=============================================================
-- 修复说明：
-- 1. 确保 Rect 对象正确创建并保留引用
-- 2. 确保 Event 回调正确获取进入单位
-- 3. 确保事件触发条件正确（单位类型、玩家类型检查）
--|=============================================================
function Layer4Play2.initMobSpawnRectListeners(rectsA, rectsB)
    -- 修复：只有当 rectListeners 存在且非空时才跳过，避免重复初始化
    if Layer4Play2.rectListeners and #Layer4Play2.rectListeners > 0 then
        print("[Layer4Play2] initMobSpawnRectListeners 已初始化，跳过")
        return
    end
    print("[Layer4Play2] initMobSpawnRectListeners 开始初始化...")
    Layer4Play2.rectListeners = {}
    Layer4Play2.mobSpawnRectsA = rectsA or {}
    Layer4Play2.mobSpawnRectsB = rectsB or {}
    
    -- 保存原始配置到模块变量，供 generateRandomSpawnPos 使用
    Layer4Play2._rawRectsA = rectsA or {}
    Layer4Play2._rawRectsB = rectsB or {}
    print(string.format("[Layer4Play2] 保存原始配置：_rawRectsA=%d 个，_rawRectsB=%d 个", #Layer4Play2._rawRectsA, #Layer4Play2._rawRectsB))
    
    local function makeRect(cfg)
        local ok, r = pcall(Rect.new, Rect, cfg.cx - cfg.width/2, cfg.cy - cfg.height/2, cfg.cx + cfg.width/2, cfg.cy + cfg.height/2)
        if not ok or not r then
            print(string.format("[Layer4Play2] 矩形%s 创建失败：ok=%s r=%s", cfg.id or "?", tostring(ok), tostring(r)))
            return nil
        end
        print(string.format("[Layer4Play2] 矩形%s 创建成功：%.1f,%.1f -> %.1f,%.1f", cfg.id or "?", r:getMinX(), r:getMaxY(), r:getMaxX(), r:getMaxY()))
        -- 修复：保存原始配置字段到 rect 对象，供 generateRandomSpawnPos 使用
        r.id = cfg.id
        r.cx = cfg.cx
        r.cy = cfg.cy
        r.width = cfg.width
        r.height = cfg.height
        return r
    end
    
    -- 处理 A 区域矩形
    for _, cfg in ipairs(Layer4Play2.mobSpawnRectsA) do
        local r = makeRect(cfg)
        if r then
            print(string.format("[Layer4Play2] §2b: 监听矩形 A[%s] %.1f,%.1f -> %.1f,%.1f", cfg.id, r:getMinX(), r:getMinY(), r:getMaxX(), r:getMaxY()))
            local rid = cfg.id
            -- 保存原始宽度和高度到 rect 对象，供 generateRandomSpawnPos 使用
            r.width = cfg.width
            r.height = cfg.height
            -- 修复：确保 Event:newRect 的回调能正确获取进入单位
            local ev = Event:newRect(r, function(ev)
                if Layer4Play2.finished then return end
                
                -- 修复：优先从 Event 对象获取单位，Event:newRect 回调中 ev._unit 已经设置
                local u = ev._unit or cj.GetEnteringUnit()
                if not u then 
                    print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 触发但无单位", rid))
                    return 
                end
                
                -- 获取单位所有者
                local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(u))
                if not okOwner or not owner then 
                    print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 单位所有者获取失败", rid))
                    return 
                end
                
                -- 检查是否是英雄单位
                if not cj.IsUnitType(u, UNIT_TYPE_HERO) then 
                    print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 单位不是英雄", rid))
                    return 
                end
                
                -- 检查是否是用户玩家
                if not owner.isUser or not owner:isUser() then 
                    print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 玩家不是用户玩家", rid))
                    return 
                end
                
                -- 检查玩家 ID 范围
                local pid = owner:getId()
                if pid < 0 or pid > 3 then 
                    print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 玩家 ID 超出范围", rid))
                    return 
                end
                
                -- 记录玩家进入状态
                if not Layer4Play2.play2EnteredPids[pid] then
                    Layer4Play2.play2EnteredPids[pid] = true
                    print(string.format("[Layer4Play2] §2b: 玩家%d 英雄进入矩形%s 已记录", pid, rid))
                end
                
                -- 检查是否所有玩家都已进入
                if isAllUserHeroesEntered() then
                    print(string.format("[Layer4Play2] §2b: 所有用户玩家英雄已进入 A/B，矩形%s触发 创建竖墙 1", rid))
                    Layer4Play2.createPlay2Wall1()
                else
                    local active = getActiveUserPids()
                    local entered = 0
                    for _, apid in ipairs(active) do 
                        if Layer4Play2.play2EnteredPids[apid] then entered = entered + 1 end 
                    end
                    print(string.format("[Layer4Play2] §2b: 等待所有玩家进入 A/B [%d/%d] rect=%s pid=%d", entered, #active, rid, pid))
                end
            end)
            if not ev then
                print(string.format("[Layer4Play2] §2b: 矩形 A[%s] Event 创建失败", rid))
            else
                Layer4Play2.rectListeners["A:" .. rid] = ev
                -- 保留 Rect 和 Event 句柄防止 GC
                Layer4Play2["__rectA_" .. rid] = r
                Layer4Play2["__evA_" .. rid] = ev
            end
        else
            print(string.format("[Layer4Play2] §2b: 矩形 A[%s] 创建失败，跳过监听", cfg.id or "?"))
        end
    end
    
    -- 处理 B 区域矩形
    for _, cfg in ipairs(Layer4Play2.mobSpawnRectsB) do
        local r = makeRect(cfg)
        if r then
            print(string.format("[Layer4Play2] §2b: 监听矩形 B[%s] %.1f,%.1f -> %.1f,%.1f", cfg.id, r:getMinX(), r:getMinY(), r:getMaxX(), r:getMaxY()))
            local rid = cfg.id
            -- 保存原始宽度和高度到 rect 对象，供 generateRandomSpawnPos 使用
            r.width = cfg.width
            r.height = cfg.height
            local ev = Event:newRect(r, function(ev)
                if Layer4Play2.finished then return end
                
                -- 修复：优先从 Event 对象获取单位，Event:newRect 回调中 ev._unit 已经设置
                local u = ev._unit or cj.GetEnteringUnit()
                if not u then 
                    print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 触发但无单位", rid))
                    return 
                end
                
                -- 获取单位所有者
                local okOwner, owner = pcall(Player.fromHandle, cj.GetOwningPlayer(u))
                if not okOwner or not owner then 
                    print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 单位所有者获取失败", rid))
                    return 
                end
                
                -- 检查是否是英雄单位
                if not cj.IsUnitType(u, UNIT_TYPE_HERO) then 
                    print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 单位不是英雄", rid))
                    return 
                end
                
                -- 检查是否是用户玩家
                if not owner.isUser or not owner:isUser() then 
                    print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 玩家不是用户玩家", rid))
                    return 
                end
                
                -- 检查玩家 ID 范围
                local pid = owner:getId()
                if pid < 0 or pid > 3 then 
                    print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 玩家 ID 超出范围", rid))
                    return 
                end
                
                -- 记录玩家进入状态
                if not Layer4Play2.play2EnteredPids[pid] then
                    Layer4Play2.play2EnteredPids[pid] = true
                    print(string.format("[Layer4Play2] §2b: 玩家%d 英雄进入矩形%s 已记录", pid, rid))
                end
                
                -- 检查是否所有玩家都已进入
                if isAllUserHeroesEntered() then
                    print(string.format("[Layer4Play2] §2b: 所有用户玩家英雄已进入 A/B，矩形%s触发 创建竖墙 1", rid))
                    Layer4Play2.createPlay2Wall1()
                else
                    local active = getActiveUserPids()
                    local entered = 0
                    for _, apid in ipairs(active) do 
                        if Layer4Play2.play2EnteredPids[apid] then entered = entered + 1 end 
                    end
                    print(string.format("[Layer4Play2] §2b: 等待所有玩家进入 A/B [%d/%d] rect=%s pid=%d", entered, #active, rid, pid))
                end
            end)
            if not ev then
                print(string.format("[Layer4Play2] §2b: 矩形 B[%s] Event 创建失败", rid))
            else
                Layer4Play2.rectListeners["B:" .. rid] = ev
                Layer4Play2["__rectB_" .. rid] = r
                Layer4Play2["__evB_" .. rid] = ev
            end
        else
            print(string.format("[Layer4Play2] §2b: 矩形 B[%s] 创建失败，跳过监听", cfg.id or "?"))
        end
    end
    
    print(string.format("[Layer4Play2] initMobSpawnRectListeners 完成。注册了%d个监听器", #Layer4Play2.rectListeners))
end

--|=============================================================
--[§2b: 刷新矩形配置（给 generateRandomSpawnPos 使用）]
--|=============================================================
function Layer4Play2.refreshRects()
    print("[Layer4Play2] refreshRects: 开始刷新矩形配置...")
    
    -- 从已创建的矩形监听器中收集矩形
    local newRectsA = {}
    local newRectsB = {}
    
    for key, ev in pairs(Layer4Play2.rectListeners or {}) do
        if ev then
            -- 提取矩形 ID（格式为 "A:id" 或 "B:id"）
            local area, rid = key:match("(%a):(.+)")
            if rid then
                -- 从模块变量中获取对应的 Rect 对象
                local rect = Layer4Play2["__rect" .. area .. "_" .. rid]
                if rect then
                    if area == "A" then
                        table.insert(newRectsA, rect)
                    else
                        table.insert(newRectsB, rect)
                    end
                    print(string.format("[Layer4Play2] refreshRects: 收集到矩形 %s[%s]", area, rid))
                end
            end
        end
    end
    
    -- 修复：给全局变量赋值（不加 local）
    Layer4Play2.play2RectsA = newRectsA or {}
    Layer4Play2.play2RectsB = newRectsB or {}
    
    print(string.format("[Layer4Play2] refreshRects 完成：play2RectsA=%d 个，play2RectsB=%d 个", #Layer4Play2.play2RectsA, #Layer4Play2.play2RectsB))
end

--|=============================================================
--[销毁刷怪区监听器]
--|=============================================================
function Layer4Play2.destroyMobSpawnRectListeners()
    if not Layer4Play2.rectListeners then return end
    for key, ev in pairs(Layer4Play2.rectListeners) do
        pcall(function() if ev and ev.destroy then ev:destroy() end end)
    end
    -- 清理 Rect 对象
    for _, cfg in ipairs(Layer4Play2.mobSpawnRectsA) do
        local r = Layer4Play2["__rectA_" .. cfg.id]
        if r then pcall(function() Event:destroyRect(r) end) pcall(function() r:destroy() end) Layer4Play2["__rectA_" .. cfg.id] = nil end
    end
    for _, cfg in ipairs(Layer4Play2.mobSpawnRectsB) do
        local r = Layer4Play2["__rectB_" .. cfg.id]
        if r then pcall(function() Event:destroyRect(r) end) pcall(function() r:destroy() end) Layer4Play2["__rectB_" .. cfg.id] = nil end
    end
    Layer4Play2.rectListeners = nil
    Layer4Play2.mobSpawnRectsA = nil
    Layer4Play2.mobSpawnRectsB = nil
end

--|=============================================================
--[§2b: 玩法 1 配置（供参考）]
--|=============================================================
-- 注意：这是 Layer4 中的玩法 1，不是玩法 2
Layer4Play2.play1Config = {
    pos     = { x = -8524.9, y = 3091.9 },
    unitId  = "n89f",
    facing  = 270,
    armor   = 50,
    magic   = 2000,
    maxMana = 5000,
}

--|=============================================================
--[§2a: 玩法 1 Boss 创建/销毁（兼容 Layer4）]
--|=============================================================
function Layer4Play2.createPlay1Boss()
    if Layer4Play2.play1Unit then print("[Layer4Play2] §2a: 玩法 1 怪物已存在") return end
    
    local p = Player:new(4)
    if not p then print("[Layer4Play2] §2a: Player 4 nil") return end
    local u = Unit:new(p, Layer4Play2.play1Config.unitId, Layer4Play2.play1Config.pos.x, Layer4Play2.play1Config.pos.y, Layer4Play2.play1Config.facing)
    if not u or not u._handle then return end
    local maValue = Layer4Play2.play1Config.magic or 2000
    
    u.state.magicAmp = maValue
    u.state.resMag = u:getState(UNIT_STATE_DEFEND_WHITE)
    
    Layer4Play2.play1Unit = u
end

function Layer4Play2.destroyPlay1Boss()
    if not Layer4Play2.play1Unit then return end
    pcall(function() Layer4Play2.play1Unit:destroy() end)
    print("[Layer4Play2] §2a: 玩法 1 怪物已销毁")
    Layer4Play2.play1Unit = nil
end

--|=============================================================
--[§2b: 刷怪逻辑]
--|=============================================================

-- 启动刷怪计时器（间隔 1.5 秒，周期性刷怪）
function Layer4Play2.startMobSpawnerTimer()
    if Layer4Play2.play2MobTimer then return end
    if not Layer4Play2.play2Triggered then
        print("[Layer4Play2] §2b: 警告：尝试启动计时器但玩法 2 未触发")
        return
    end
    print("[Layer4Play2] §2b: 启动刷怪计时器...")
    Layer4Play2.play2MobTimer = Timer:new(1.5, true, function()
        if not Layer4Play2.play2Triggered or Layer4Play2.finished then return end
        print("[Layer4Play2] §2b: 计时器触发，开始刷怪...")
        Layer4Play2.spawnOneMob()
    end)
    Layer4Play2.play2MobTimer:start()
    print("[Layer4Play2] 刷怪计时器已启动 (1.5 秒/次)")
end

-- 停止刷怪计时器
function Layer4Play2.stopMobSpawnerTimer()
    if Layer4Play2.play2MobTimer then
        pcall(function() Layer4Play2.play2MobTimer:stop() end)
        Layer4Play2.play2MobTimer = nil
        print("[Layer4Play2] 刷怪计时器已停止")
    end
end

-- 随机获取一个怪物 ID
function Layer4Play2.getRandomMobId()
    local ids = Layer4.registeredMobIds
    if #ids == 0 then return nil end
    local idx = math.random(1, #ids)
    return ids[idx]
end

-- 生成一个随机刷怪位置（A 或 B 区域）
function Layer4Play2.generateRandomSpawnPos()
    -- 使用文件头部预创建的矩形对象
    local allRects = {}
    for i = 1, #Layer4Play2.play2RectsA do allRects[#allRects + 1] = Layer4Play2.play2RectsA[i] end
    for i = 1, #Layer4Play2.play2RectsB do allRects[#allRects + 1] = Layer4Play2.play2RectsB[i] end
    if #allRects == 0 then 
        print("[Layer4Play2] §2b: generateRandomSpawnPos 警告：没有可用的矩形配置")
        return nil 
    end
    local rect = allRects[math.random(1, #allRects)]
    -- 调试：打印 rect 对象的字段
    print(string.format("[Layer4Play2] §2b: generateRandomSpawnPos 选择的矩形：id=%s cx=%s cy=%s width=%s height=%s", rect.id, rect.cx, rect.cy, rect.width, rect.height))
    
    -- 调试：打印计算过程
    local halfWidth = rect.width / 2
    local halfHeight = rect.height / 2
    print(string.format("[Layer4Play2] §2b: halfWidth=%s halfHeight=%s", halfWidth, halfHeight))
    
    local minx = rect.cx - halfWidth
    local miny = rect.cy - halfHeight
    local maxx = rect.cx + halfWidth
    local maxy = rect.cy + halfHeight
    print(string.format("[Layer4Play2] §2b: minx=%s miny=%s maxx=%s maxy=%s", minx, miny, maxx, maxy))
    
    local r1 = math.random(1, 100)
    local r2 = math.random(1, 100)
    print(string.format("[Layer4Play2] §2b: math.random() 测试：r1=%s r2=%s", r1, r2))
    
    local x = minx + r1 * (maxx - minx) / 100.0
    local y = miny + r2 * (maxy - miny) / 100.0
    print(string.format("[Layer4Play2] §2b: 计算坐标：x=%s y=%s", x, y))
    
    return { x = x, y = y, rect = rect }
end

-- 在刷怪区 A 或 B 的随机位置生成一个单位
function Layer4Play2.spawnOneMob()
    -- 获取敌方玩家列表（4-11）
    local enemyPlayers = {}
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            table.insert(enemyPlayers, p)
        end
    end
    
    -- 找到存活数最少的敌方玩家作为目标
    local bestPlayer = nil
    local minAlive = 999999
    for _, p in ipairs(enemyPlayers) do
        local alive = Layer4Play2.countAliveUnits(p)
        if alive < minAlive then
            minAlive = alive
            bestPlayer = p
        end
    end
    
    if not bestPlayer then
        print("[Layer4Play2] §2b: 没有可用的敌方玩家")
        return
    end
    
    local totalAlive = 0
    local maxAttempts = 20
    for pid = 4, 11 do
        local p = Player:new(pid)
        totalAlive = totalAlive + Layer4Play2.countAliveUnits(p)
    end
    
    -- 每个玩家最多 10 个，总共 7 个玩家 = 70 个上限
    if totalAlive >= 70 then
        print(string.format("[Layer4Play2] §2b: 达到上限 %d/70，暂停刷怪", totalAlive))
        -- 首次达到上限时，给每个玩家刷一个怪
        Layer4Play2.bonusSpawnOnCap()
        return
    end
    
    -- 在目标玩家周围寻找安全位置
    local x, y = 0, 0
    for attempt = 1, maxAttempts do
        local spawnPos = Layer4Play2.generateRandomSpawnPos()
        if not spawnPos then
            print(string.format("[Layer4Play2] §2b: 第 %d 次尝试生成刷怪位置失败，跳过", attempt))
            -- 如果所有尝试都失败，直接返回
            if attempt == maxAttempts then
                return
            end
            goto continue_loop
        end
        x = spawnPos.x
        y = spawnPos.y
        local enemyCount = 0
        
        -- 检查周围 800 码内是否有与目标玩家敌对的单位
        Group:new():enumRange(x, y, 800, function(handle)
            local u = Unit.fromHandle(handle)
            if not u then return end
            local ux, uy = u:getX(), u:getY()
            if ux and uy then
                local dx = ux - x
                local dy = uy - y
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist < 800 then
                    local owner = u:getOwner()
                    -- 判断单位所属玩家是否与目标玩家敌对
                    if owner and owner:isEnemy(bestPlayer) then
                        enemyCount = enemyCount + 1
                    end
                end
            end
        end)
        
        if enemyCount == 0 then
            -- 找到安全位置，break 跳出循环
            break
        end
        
        -- 尝试次数过多，打印警告
        if attempt == maxAttempts then
            print(string.format("[Layer4Play2] §2b: 尝试 %d 次后仍未找到安全的刷怪位置，跳过刷怪", maxAttempts))
            return
        end
        ::continue_loop::
    end
    
    -- 获取可用的怪物 ID
    local mobId = Layer4Play2.getRandomMobId()
    if not mobId then
        print("[Layer4Play2] §2b: 没有可用的怪物 ID")
        return
    end
    
    -- 检查位置高度，大于 1 不创建
    local height = cdz.DzGetTerrainZ(x, y) or 0
    if height > 1 then
        print(string.format("[Layer4Play2] §2b: 位置 %.1f,%.1f 高度 %.1f > 1，跳过创建", x, y, height))
        return
    end
    
    -- 创建单位
    local u = Unit:new(bestPlayer, mobId, x, y, 270)
    if u and u._handle then
        -- 添加到句柄列表，用于死亡监听
        table.insert(Layer4Play2.play2MobHandles, u._handle)
        print(string.format("[Layer4Play2] §2b: 在 %.1f,%.1f 创建怪物 %s 给玩家%d", x, y, mobId, bestPlayer:getId()))
        print(string.format("[Layer4Play2] §2b: 当前刷怪单位总数：%d / 上限：70", #Layer4Play2.play2MobHandles, 70))
        
        -- 可选：设置单位属性（如 HP、护甲等）
        -- u:setLife(1000)
        -- u:setArmor(30)
    else
        print(string.format("[Layer4Play2] §2b: 创建怪物失败 %s", mobId))
    end
end

-- 统计指定玩家的存活单位数（不包括 BOSS）
function Layer4Play2.countAliveUnits(p)
    if not p then return 0 end
    local g = Group:new()
    g:enumPlayer(p._handle or cj.Player(p:getId()))
    local count = 0
    g:forEach(function(handle)
        local u = Unit.fromHandle(handle)
        if u and not u:isType(UNIT_TYPE_DEAD) then
            count = count + 1
        end
    end)
    return count
end

-- 首次达到上限刷怪配置
function Layer4Play2.bonusSpawnOnCap()
    -- 防止重复触发
    if Layer4Play2.play2HasBonus then
        print("[Layer4Play2] §2b: 已经触发过首次上限奖励，跳过")
        return
    end
    
    print("[Layer4Play2] §2b: 首次达到上限，触发奖励刷怪...")
    Layer4Play2.play2HasBonus = true
    
    -- 给每个玩家刷一个怪
    for pid = 4, 11 do
        local p = Player:new(pid)
        if p and p:isEnemy() then
            -- 为该玩家刷一个怪（使用 countAliveUnits 最少的玩家逻辑）
            local alive = Layer4Play2.countAliveUnits(p)
            if alive < 10 then -- 如果该玩家还没满
                -- 临时跳过上限检查，专门刷这个 bonus 怪
                local originalCanSpawn = Layer4.canSpawnMob
                Layer4.canSpawnMob = function() return true end -- 临时允许
                local spawnPos = Layer4Play2.generateRandomSpawnPos()
                if not spawnPos then
                    print(string.format("[Layer4Play2] §2b: 奖励刷怪位置生成失败，跳过"))
                    Layer4.canSpawnMob = originalCanSpawn
                    return
                end
                local u = Unit:new(p, Layer4Play2.getRandomMobId(), spawnPos.x, spawnPos.y, 270)
                Layer4.canSpawnMob = originalCanSpawn -- 恢复
                if u and u._handle then
                    table.insert(Layer4Play2.play2MobHandles, u._handle)
                    print(string.format("[Layer4Play2] §2b: 奖励刷怪：玩家%d 获得怪物 %s", pid, Layer4Play2.getRandomMobId()))
                    -- 记录该玩家已获得 bonus
                    Layer4Play2.play2BonusSpawns[pid] = true
                else
                    print(string.format("[Layer4Play2] §2b: 奖励刷怪失败：玩家%d", pid))
                end
            end
        end
    end
end

--|=============================================================
--[§2b: 死亡监听：当刷怪单位死亡时，从句柄列表中移除]
--|=============================================================
function Layer4Play2.onMobDeath(handle)
    if not Layer4Play2.play2MobTimer then return end
    -- 钥匙掉落（在移除前触发，确保位置有效）
    do
        local okX, x = pcall(cj.GetUnitX, handle)
        local okY, y = pcall(cj.GetUnitY, handle)
        if okX and okY and x and y then
            Layer4Play2.tryDropKeyAt(x, y)
        end
    end
    -- 从 handle 列表中移除
    for i, h in ipairs(Layer4Play2.play2MobHandles) do
        if h == handle then
            table.remove(Layer4Play2.play2MobHandles, i)
            break
        end
    end
    -- 检查是否有空坑位，如果有则尝试创建新单位
    local totalAlive = 0
    for pid = 4, 11 do
        local p = Player:new(pid)
        -- if p and p:isEnemy() then
            totalAlive = totalAlive + Layer4Play2.countAliveUnits(p)
        -- end
    end
    if totalAlive < 70 then
        -- 延迟 0.5 秒再刷，避免瞬间刷太多
        local t = Timer:new(0.5, false, function()
            if Layer4Play2.play2Triggered and not Layer4Play2.finished then
                Layer4Play2.spawnOneMob()
            end
        end)
        t:start()
    end
end

-- 注册死亡监听
function Layer4Play2.ensureMobDeathListener()
    if Layer4Play2.mobDeathListener then return end
    print("[Layer4Play2] §2b: 注册刷怪死亡监听...")
    Layer4Play2.mobDeathListener = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        if Layer4Play2.finished then return end
        local handle = ev.unit
        if not handle then return end
        -- 只处理本玩法刷出的怪（玩家英雄 / 各 BOSS 死亡交给各自的监听处理）
        local isMob = false
        for _, h in ipairs(Layer4Play2.play2MobHandles) do
            if h == handle then isMob = true break end
        end
        if not isMob then return end
        Layer4Play2.onMobDeath(handle)
    end)
end

--|=============================================================
--[§2b-KEY: 钥匙掉落 / 持有检测 / 开门通关]
--|=============================================================
function Layer4Play2.hasUnitKey(uHandle)
    if not uHandle then return false, nil end
    local keyId = c2i(Layer4Play2.play2KeyConfig.itemId)
    if not keyId or keyId == 0 then return false, nil end
    for slot = 0, 5 do
        local it = cj.UnitItemInSlot(uHandle, slot)
        if it and cj.GetItemTypeId(it) == keyId then
            return true, it
        end
    end
    return false, nil
end

function Layer4Play2.tryDropKeyAt(x, y)
    -- 注：当前代码只有钥匙掉落（1% 概率），无旗子掉落逻辑
    -- 如需添加旗子掉落，请在 tryDropKeyAt 中额外添加 tryDropFlagAt 函数调用
    if Layer4Play2.play2KeyConfig.finished then return end
    if not x or not y then return end
    local chance = Layer4Play2.play2KeyConfig.dropChance or 0.01 -- 1% 掉落概率
    if cj.I2R(math.random(1, 100)) / 100 >= chance then return end
    local itemIdStr = Layer4Play2.play2KeyConfig.itemId
    local ok, it = pcall(function() return Item:new(itemIdStr, x, y) end)
    if not ok or not it or not it._handle then
        -- 兜底直接用原生创建
        local iid = c2i(itemIdStr)
        if iid and iid ~= 0 then
            local h = cj.CreateItem(iid, x, y)
            if h then print(string.format("[Layer4Play2] §2b-KEY: 钥匙掉落 (原生) %s at %.1f,%.1f", itemIdStr, x, y)) end
        end
        return
    end
    print(string.format("[Layer4Play2] §2b-KEY: 钥匙掉落 %s at %.1f,%.1f", itemIdStr, x, y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "钥匙已掉落！拾取后前往横墙 2 开门通关！", SystemMessage.COLOR_WARN}}, 3.0)
    end
end

function Layer4Play2.onPlay2DoorOpen(heroHandle, itemHandle)
    if Layer4Play2.play2KeyConfig.finished then return end
    Layer4Play2.play2KeyConfig.finished = true
    -- 消耗钥匙
    if heroHandle and itemHandle then
        pcall(function()
            cj.UnitRemoveItem(heroHandle, itemHandle)
            cj.RemoveItem(itemHandle)
        end)
    else
        local has, it = Layer4Play2.hasUnitKey(heroHandle)
        if has and it then pcall(function() cj.UnitRemoveItem(heroHandle, it); cj.RemoveItem(it) end) end
    end
    -- 销毁横墙 2（通关门）
    local wallIdx = Layer4Play2.play2KeyConfig.doorWallIndex
    local h = Layer4.wallMap[wallIdx]
    local wallCfg = nil
    for _, w in ipairs(Layer4.walls) do if w.index == wallIdx then wallCfg = w break end end
    if h then
        pcall(cj.RemoveDestructable, h)
        Layer4.wallMap[wallIdx] = nil
        for i, handle in ipairs(Layer4.handles) do if handle == h then table.remove(Layer4.handles, i) break end end
        print("[Layer4Play2] §2b-KEY: 横墙 2 已开启销毁 (钥匙开门)")
    elseif wallCfg then
        local rect = cj.Rect(wallCfg.x - 96, wallCfg.y - 96, wallCfg.x + 96, wallCfg.y + 96)
        if rect then
            pcall(function()
                cj.EnumDestructablesInRect(rect, nil, function()
                    local d = cj.GetEnumDestructable()
                    if d and cj.GetDestructableTypeId(d) == c2i(wallCfg.id) then
                        local dx, dy = cj.GetDestructableX(d), cj.GetDestructableY(d)
                        if ((dx - wallCfg.x)^2 + (dy - wallCfg.y)^2)^0.5 < 96 then
                            pcall(cj.RemoveDestructable, d)
                        end
                    end
                end)
            end)
            cj.RemoveRect(rect)
            print("[Layer4Play2] §2b-KEY: 横墙 2 兜底枚举销毁")
        end
    end
    if SystemMessage and SystemMessage.send then
        local icon = SystemMessage.getUnitIcon and SystemMessage.getUnitIcon(heroHandle) or ""
        local owner = Player.fromHandle(cj.GetOwningPlayer(heroHandle))
        local pname = owner and owner:getName() or "英雄"
        if not pname or pname == "" then pname = string.format("玩家%d", owner and owner:getId() or 0) end
        local msg = string.format("%s 使用钥匙开启了横墙 2，玩法 2 通关！", pname)
        if icon and icon ~= "" then
            SystemMessage.send({{"art", icon}, {"STR", msg, SystemMessage.COLOR_SUCCESS}}, 5.0)
        else
            SystemMessage.send({{"STR", msg, SystemMessage.COLOR_SUCCESS}}, 5.0)
        end
    else
        Player.sendAll("玩法 2 通关！横墙 2 已开启")
    end
    Layer4Play2.destroyPlay2KeyDoor()
    -- 玩法 2 通关：停止刷怪计时器、清理剩余单位（刷怪单位属于玩法 2 内容）
    Layer4Play2.stopMobSpawnerTimer()
    if #Layer4Play2.play2MobHandles > 0 then
        print(string.format("[Layer4Play2] §2b: 玩法 2 通关，销毁 %d 个剩余刷怪单位", #Layer4Play2.play2MobHandles))
        for _, h in ipairs(Layer4Play2.play2MobHandles) do
            if h then pcall(function() Unit.fromHandle(h):destroy() end) end
        end
        Layer4Play2.play2MobHandles = {}
    end
    -- 清理刷怪区监听
    Layer4Play2.destroyMobSpawnRectListeners()
    print("[Layer4Play2] §2b-KEY: 玩法 2 通关完成（已清理刷怪内容）")
end

function Layer4Play2.createPlay2KeyDoor()
    -- print("[Layer4Play2] §2b-KEY: 开始创建通关门检测区域...")
    
    if Layer4Play2.play2DoorRect then return end
    -- print(string.format("[Layer4Play2] §2b-KEY: 通关门检测区域配置 %s", Layer4Play2.play2KeyConfig.doorWallIndex))
    
    local wall = nil
    for _, w in ipairs(Layer4.walls) do if w.index == Layer4Play2.play2KeyConfig.doorWallIndex then wall = w break end end
    if not wall then print("[Layer4Play2] §2b-KEY: 横墙 2 配置缺失") return end
    local w, h = Layer4Play2.play2KeyConfig.doorSize.w, Layer4Play2.play2KeyConfig.doorSize.h
    local r = Rect:newCenter(wall.x, wall.y, w, h)
    if not r or not r._handle then print("[Layer4Play2] §2b-KEY: 门区域创建失败") return end
    Layer4Play2.play2DoorRect = r
    print(string.format("[Layer4Play2] §2b-KEY: 通关门检测区域已创建 横墙 2 %.1f,%.1f 范围 %.0fx%.0f", wall.x, wall.y, w, h))
    Layer4Play2.play2DoorEvent = Event:newRect(r, function(ev)
        print(string.format("[Layer4Play2] §2b-KEY: 通关门检测区域触发事件 %s", ev.type))
        if Layer4Play2.finished or Layer4Play2.play2KeyConfig.finished then return end
        local u = ev.unit or ev._unit or cj.GetEnteringUnit()
        if not u then return end
        if not cj.IsUnitType(u, UNIT_TYPE_HERO) then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(u))
        if not owner or not owner:isUser() then return end
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        local has = Layer4Play2.hasUnitKey(u)
        if not has then return end
        print(string.format("[Layer4Play2] §2b-KEY: 玩家%d 携带钥匙靠近横墙 2，开门", pid))
        Layer4Play2.onPlay2DoorOpen(u, select(2, Layer4Play2.hasUnitKey(u)))
    end)
end

function Layer4Play2.destroyPlay2KeyDoor()
    -- Event:newRect 共享 region，destroyRect 会清掉整个 region；用 pcall 保护
    if Layer4Play2.play2DoorRect then
        pcall(function() Event:destroyRect(Layer4Play2.play2DoorRect) end)
        pcall(function() Layer4Play2.play2DoorRect:destroy() end)
        Layer4Play2.play2DoorRect = nil
    end
    Layer4Play2.play2DoorEvent = nil
end

local function onKeyPickup(ev)
    local it = ev.item
    if not it then return end
    if cj.GetItemTypeId(it) ~= c2i(Layer4Play2.play2KeyConfig.itemId) then return end
    local hero = ev.unit
    if not hero then return end
    local owner = Player.fromHandle(cj.GetOwningPlayer(hero))
    local pname = owner and owner:getName() or "未知"
    if not pname or pname == "" then pname = string.format("玩家%d", owner and owner:getId() or 0) end
    print(string.format("[Layer4Play2] §2b-KEY: %s 拾取钥匙 %s", pname, Layer4Play2.play2KeyConfig.itemId))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", string.format("%s 获得了钥匙！前往横墙 2 (-1289,3844) 开门通关！", pname), SystemMessage.COLOR_SUCCESS}}, 5.0)
    end
end

function Layer4Play2.ensurePlay2KeyListeners()
    if Layer4Play2.play2KeyPickupEvent then return end
    Layer4Play2.createPlay2KeyDoor()
    local keyId = c2i(Layer4Play2.play2KeyConfig.itemId)
    if not keyId or keyId == 0 then print("[Layer4Play2] §2b-KEY: ao8y 的 c2i 转换失败") return end
    Layer4Play2.play2KeyPickupEvent = Event:new(nil, EVENT_PLAYER_UNIT_PICKUP_ITEM, onKeyPickup)
    print("[Layer4Play2] §2b-KEY: 钥匙拾取监听已注册 ao8y 横墙 2 为通关门")
end

function Layer4Play2.destroyPlay2KeyListeners()
    if Layer4Play2.play2KeyPickupEvent then
        pcall(function() Layer4Play2.play2KeyPickupEvent:destroy() end)
        Layer4Play2.play2KeyPickupEvent = nil
    end
    Layer4Play2.destroyPlay2KeyDoor()
end

--|=============================================================
--[§2 生命周期]
--|=============================================================
function Layer4Play2.start()
    if Layer4Play2.started then print("[Layer4Play2] 已启动跳过") return end
    Layer4Play2.started = true
    Layer4Play2.finished = false
    Layer4Play2.play2Triggered = false
    Layer4Play2.play2EnteredPids = {}
    Layer4Play2.play2WallHandle = nil
    Layer4Play2.play2MobTimer = nil
    Layer4Play2.play2MobHandles = {}
    Layer4Play2.play2BonusSpawns = {}
    Layer4Play2.play2HasBonus = false
    Layer4Play2.play2KeyConfig.finished = false
    
    print("[Layer4Play2] start() 开始初始化...")


    -- 更新后的配置：
    -- 区域 A: 左下角 -15520.2, 4106.6, 右上角 -10520.0, 7668.6
    -- 区域 B: 左下角 -10407.4, 5389.9, 右上角 -8299.1, 7591.7
    
    local rectsA = {
        { id = "A", cx = -13010.4, cy = 5887.6, width = 4999.8, height = 6594, name = "A 区（触发区）" },
    }
    
    local rectsB = {
        { id = "B", cx = -9353.25, cy = 6490.8, width = 2108.3, height = 2190.8, name = "B 区" },
    }
    
    if #rectsA == 0 or #rectsB == 0 then
        print("[Layer4Play2] 警告：使用默认空矩形配置")
        rectsA = {}
        rectsB = {}
    else
        print(string.format("[Layer4Play2] 关卡 4 玩法 2 矩形配置：A 区%d个，B 区%d个", #rectsA, #rectsB))
        for _, cfg in ipairs(rectsA) do
            print(string.format("  A[%s]: %.1f,%.1f -> %.1f,%.1f", cfg.id, cfg.cx - cfg.width/2, cfg.cy - cfg.height/2, cfg.cx + cfg.width/2, cfg.cy + cfg.height/2))
        end
        for _, cfg in ipairs(rectsB) do
            print(string.format("  B[%s]: %.1f,%.1f -> %.1f,%.1f", cfg.id, cfg.cx - cfg.width/2, cfg.cy - cfg.height/2, cfg.cx + cfg.width/2, cfg.cy + cfg.height/2))
        end
    end
    
    Layer4Play2.initMobSpawnRectListeners(rectsA, rectsB)
    
    print("[Layer4Play2] 玩法 2 初始化完成")
end

function Layer4Play2.shutdown()
    if not Layer4Play2.started and not Layer4Play2.finished then
        -- 允许重复调用清理
    end
    Layer4Play2.started = false
    
    -- 销毁 Boss
    Layer4Play2.destroyPlay1Boss()
    
    -- 停止刷怪计时器
    if Layer4Play2.play2MobTimer then
        Layer4Play2.play2MobTimer:stop()
        print("[Layer4Play2] 停止刷怪计时器")
        Layer4Play2.play2MobTimer = nil
    end
    
    -- 销毁所有刷怪单位
    if #Layer4Play2.play2MobHandles > 0 then
        print(string.format("[Layer4Play2] §2b: 销毁 %d 个刷怪单位", #Layer4Play2.play2MobHandles))
        for _, h in ipairs(Layer4Play2.play2MobHandles) do
            if h then pcall(function() Unit.fromHandle(h):destroy() end) end
        end
        Layer4Play2.play2MobHandles = {}
    end
    
    if Layer4Play2.play2WallHandle then
        pcall(function() cj.RemoveDestructable(Layer4Play2.play2WallHandle) end)
        print("[Layer4Play2] 清理竖墙 1")
        Layer4Play2.play2WallHandle = nil
    end
    
    -- 清理钥匙玩法监听/门区域
    Layer4Play2.destroyPlay2KeyListeners()
    
    -- 销毁刷怪区监听
    Layer4Play2.destroyMobSpawnRectListeners()
    
    print("[Layer4Play2] 关闭")
end

--|=============================================================
--[§3 兼容别名]
--|=============================================================
Layer4Play2EntryPos     = Layer4Play2.entryPos
Layer4Play2RevivePos    = Layer4Play2.revivePos
Layer4Play2TeleportPos  = Layer4Play2.teleportPos
Layer4Play2PotionShopPos= Layer4Play2.potionShopPos

--|=============================================================
--[返回模块]
--|=============================================================
return Layer4Play2
