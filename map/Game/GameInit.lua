-- ============================================================
-- GameInit — 游戏初始化
--
-- 功能：
--   1. 开启战争迷雾 / 黑色阴影（Terrain 封装）
--   2. 创建6个展示英雄（玩家15）到 SelectHeroPos 对应位置
--      - 左侧3个（索引1-3）面向 0 度
--      - 右侧3个（索引4-6）面向 180 度
--   3. 选择英雄区域可见（Visibility 封装）
--   4. 初始流程：镜头 → 难度对话框 → 小精灵 → 控制选英事件
--
-- 调用：
--   require "Game.GameInit"  -- 自动执行初始化，无需手动调用
-- ============================================================

GameInit = {}

-- 6个英雄ID（顺序对应 SelectHeroPos 1~6）
-- 左3：治疗(HQz9)、坦克(Off0)、远程(E00R 原E2nx已保留以排查ID冲突)
-- 右3：战士(Nnax)、法师(O8zj)、召唤(U74y)
GameInit.SelectHeroIds = { "HQz9", "Off0","Ee17",  "Nnax", "O8zj", "U74y" }
GameInit.wispId = "end5"
GameInit.controlAbilityId = "Av3d"
GameInit.initWallId = "B000" -- 力量之墙(横墙) destructable，非单位

-- 运行时状态
GameInit.selectHeroUnits = {} -- { handle, id, posIndex }
GameInit.difficulty = nil
GameInit.controlEvent = nil
GameInit.selectedCount = 0
GameInit.heroTaken = {}
GameInit.playerSelected = {}
GameInit.onlinePlayers = {}
GameInit.initWall = nil -- 初始力量墙句柄（可破坏物）

--- 应用迷雾设置（仅通过 Terrain 封装，不直调 cj）
function GameInit.apply()
    Terrain.setFogEnabled(true)
    Terrain.setFogMaskEnabled(true)
end

--- 创建6个英雄到选英点（玩家15）
function GameInit.createSelectHeroes()
    if not SelectHeroPos then return end
    local ids = GameInit.SelectHeroIds
    local p15 = Player:new(15)
    GameInit.selectHeroUnits = {}

    for i = 1, #SelectHeroPos do
        local pos = SelectHeroPos[i]
        local hid = ids[i]
        if pos and hid then
            local facing = (i <= 3) and 0 or 180
            local x, y = pos[1], pos[2]
            local obj = nil
            local tryCreate = function(px, py)
                local h = nil
                if Unit and Unit.new then
                    h = Unit:new(p15, hid, px, py, facing)
                    if h and h._handle then return h end
                end
                if Hero and Hero.new then
                    h = Hero:new(p15, hid, px, py, facing)
                    if h and h._handle then return h end
                end
                return h
            end

            obj = tryCreate(x, y)

            -- 左1(E2nx)曾创建失败，追加重试偏移，规避路径阻塞/创建时序问题
            if not obj or not obj._handle then
                print("[GameInit] 选英英雄创建失败 i=" .. i .. " id=" .. hid .. " at " .. x .. "," .. y .. " 重试偏移")
                for _, off in ipairs({{64,0},{0,64},{-64,0},{0,-64}}) do
                    obj = tryCreate(x + off[1], y + off[2])
                    if obj and obj._handle then
                        print("[GameInit] 重试成功 i=" .. i .. " offset " .. off[1] .. "," .. off[2])
                        break
                    end
                end
            end

            if obj and obj._handle then
                if obj.setPathing then obj:setPathing(false) end
                obj:setPosition(x, y)
                table.insert(GameInit.selectHeroUnits, {
                    handle = obj._handle,
                    obj = obj,
                    id = hid,
                    index = i,
                })
            else
                print("[GameInit] 选英英雄最终失败 i=" .. i .. " id=" .. hid)
            end
        end
    end
    -- 调试输出总数
    print("[GameInit] 选英英雄创建完成 数量=" .. #GameInit.selectHeroUnits .. "/6")
    if #GameInit.selectHeroUnits ~= 6 then
        print("[GameInit] 警告：选英英雄数量不足6，请检查地形阻塞或单位ID")
    end
end

--- 设置选择英雄区域可见（仅通过 Visibility 封装）
function GameInit.applySelectHeroVisibility()
    -- 1) 矩形区域整体可见
    if SelectHeroArea then
        for pid = 0, 3 do
            local p = Player:new(pid)
            local vis = Visibility.newRect(p, SelectHeroArea, FOG_OF_WAR_VISIBLE, true, false)
            if vis then vis:start() end
        end
    end
    -- 2) 每个选英点圆形可见（半径 1200），防止矩形异常时仍保证可见
    if SelectHeroPos then
        for pid = 0, 3 do
            local p = Player:new(pid)
            for i = 1, #SelectHeroPos do
                local pos = SelectHeroPos[i]
                local vis = Visibility.newRadius(p, pos[1], pos[2], 1200, FOG_OF_WAR_VISIBLE, true, false)
                if vis then vis:start() end
            end
        end
    end
end

-----------------------------------------------------------------
-- 初始流程：镜头 + 难度 + 小精灵
-----------------------------------------------------------------

--- 获取在线用户玩家列表（0..3）
function GameInit.getOnlinePlayers()
    local list = {}
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p:isPlaying() and p:isUser() then
            table.insert(list, p)
        end
    end
    return list
end

--- 获取首个在线用户玩家
function GameInit.getFirstOnlinePlayer()
    local list = GameInit.getOnlinePlayers()
    return list[1]
end

--- 将所有玩家镜头移动到 UserPos
function GameInit.moveCamerasToUserPos()
    if not UserPos then return end
    local x, y = UserPos[1], UserPos[2]
    -- Camera.panTo 为本地镜头操作，同步调用下各客户端同步移动
    Camera.panTo(x, y)
    Camera.setQuickPos(x, y)
end

--- 弹出难度选择对话框（仅给首个在线玩家）
function GameInit.showDifficultyDialog()
    local first = GameInit.getFirstOnlinePlayer()
    if not first then return end

    local title = "请选择难度"
    local buttons = {
        { value = "normal", label = "普通难度" },
    }

    Dialog.create(first, title, buttons, function(val)
        GameInit.difficulty = val
        -- 广播提示（可选）
        Player.sendAll("难度已选择: 普通难度")

        -- 选择后为每个在线玩家创建小精灵
        GameInit.spawnWisps()
        -- 注册控制事件
        GameInit.registerControlEvent()
    end)
end

--- 创建初始力量墙（横墙，非单位的可破坏物 B000）
--- 在 InitWallPos 位置横向放置，带路径阻塞
function GameInit.createInitWall()
    if GameInit.initWall then return GameInit.initWall end
    if not InitWallPos then return nil end
    local x, y = InitWallPos[1], InitWallPos[2]
    -- B000 = 力量之墙(横墙) parent Dofw FixedRot 270，本身带碰撞/不可通行
    local wall = cj.CreateDestructable(c2i(GameInit.initWallId), x, y, 270, 1, 0)
    GameInit.initWall = wall
    if wall then
        print("[GameInit] 初始力量墙(横) B000 已创建 at " .. x .. "," .. y .. " handle=" .. tostring(wall))
    else
        print("[GameInit] 初始力量墙创建失败 at " .. x .. "," .. y)
    end
    return wall
end

--- 为每个在线玩家在 UserPos 创建小精灵（并同步创建初始力量墙）
function GameInit.spawnWisps()
    if not UserPos then return end
    local list = GameInit.getOnlinePlayers()
    GameInit.onlinePlayers = list
    local x, y = UserPos[1], UserPos[2]
    for _, p in ipairs(list) do
        Unit:new(p, GameInit.wispId, x, y, 270)
    end
    -- 难度选择后、创建小精灵时同步创建力量之墙（横）在 InitWallPos，仅创建一次
    GameInit.createInitWall()
end

-----------------------------------------------------------------
-- 控制英雄事件：小精灵 Av3d -> 英雄 移动到 ControlHeroPos
-----------------------------------------------------------------

function GameInit.registerControlEvent()
    if GameInit.controlEvent then return end
    if not ControlHeroPos then return end

    GameInit.selectedCount = 0
    GameInit.heroTaken = {}
    GameInit.playerSelected = {}

    local targetId = c2i(GameInit.controlAbilityId)

    GameInit.controlEvent = Event:new(nil, EVENT_PLAYER_UNIT_SPELL_EFFECT, function(ev)
        if ev.spellId ~= targetId then return end

        local casterHandle = ev.unit
        local targetHandle = ev.spellTargetUnit
        if not casterHandle or not targetHandle then return end

        local casterUnit = Unit.fromHandle(casterHandle)
        local targetUnit = Unit.fromHandle(targetHandle)
        if not casterUnit or not targetUnit then return end

        local casterPlayer = casterUnit:getOwner()
        if not casterPlayer then return end
        local casterPid = casterPlayer:getId()

        -- 仅允许在线用户的小精灵触发
        if casterPlayer:isUser() == false then return end
        if GameInit.playerSelected[casterPid] then return end

        -- 校验目标是否为待选英雄（6个之一）
        local isSelectHero = false
        for _, entry in ipairs(GameInit.selectHeroUnits) do
            if entry.handle == targetHandle then
                isSelectHero = true
                break
            end
        end
        if not isSelectHero then return end

        -- 英雄是否已被选
        local hid = targetUnit._index or 0
        -- 使用 handleId 作为 key（若 _index 为空则用 handle hash）
        local key = hid ~= 0 and hid or tostring(targetHandle)
        if GameInit.heroTaken[key] then return end

        -- 执行移动：转移所有权 + 移动到 ControlHeroPos
        local cx, cy = ControlHeroPos[1], ControlHeroPos[2]
        targetUnit:setOwner(casterPlayer, true)
        targetUnit:setPosition(cx, cy)
        -- 让英雄停止当前动作
        targetUnit:stop()

        -- 同步将触发玩家的镜头移动到转移后位置（仅该玩家客户端）
        if cj.GetLocalPlayer() == casterPlayer._handle then
            Camera.panTo(cx, cy)
            Camera.setQuickPos(cx, cy)
        end

        -- 记录
        GameInit.heroTaken[key] = true
        GameInit.playerSelected[casterPid] = true
        GameInit.selectedCount = GameInit.selectedCount + 1

        Player.sendAll(
            casterPlayer:getName() .. " 选择了 " .. targetUnit:getName()
        )

        -- 当所有在线玩家都已选择，销毁事件
        local need = #GameInit.onlinePlayers
        if need == 0 then
            need = #GameInit.getOnlinePlayers()
        end
        if GameInit.selectedCount >= need and need > 0 then
            if GameInit.controlEvent then
                GameInit.controlEvent:destroy()
                GameInit.controlEvent = nil
            end
            Player.sendAll("所有玩家已完成英雄选择")
        end
    end)
end

--- 初始化入口
function GameInit.init()
    GameInit.apply()

    -- 延迟 0 秒再执行一次，确保覆盖编辑器默认配置
    Timer:new(0, false, function()
        GameInit.apply()
    end)

    -- 选英英雄、视野、镜头与难度流程
    Timer:new(0, false, function()
        GameInit.createSelectHeroes()
        GameInit.applySelectHeroVisibility()
        GameInit.moveCamerasToUserPos()
    end)

    -- 难度对话框延时弹出，确保镜头与单位已就绪
    Timer:new(0.5, false, function()
        GameInit.showDifficultyDialog()
    end)
end

-- 自动初始化
GameInit.init()
