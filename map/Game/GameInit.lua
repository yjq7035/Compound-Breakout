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
-- 左3：治疗(HQz9)、坦克(Off0)、远程(H7jn)
-- 右3：战士(Nnax)、法师(O8zj)、召唤(U74y)
GameInit.SelectHeroIds = { "HQz9", "Off0","H7jn",  "Nnax", "O8zj", "U74y" }
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
GameInit.currentLayer = 0 -- 当前关卡 0=未开始 1=关卡 1 2=关卡 2
GameInit.reviveEvent = nil -- 英雄死亡复活事件
-- 默认初始关卡：1=关卡 1，2=关卡 2（可根据需要修改）
GameInit.initialLayer = 3

--- 应用迷雾设置（仅通过 Terrain 封装，不直调 cj）
function GameInit.apply()
    Terrain.setFogEnabled(true)
    Terrain.setFogMaskEnabled(true)
    -- 全图可见：为所有玩家清除迷雾掩码（使用整个地图边界）
    for pid = 0, 3 do
        local p = Player:new(pid)
        if p then
            local worldRect = Rect.world()
            local vis = Visibility.newRect(p, worldRect, FOG_OF_WAR_VISIBLE, true, false)
            if vis then vis:start() end
        end
    end
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
        -- 广播提示：中央系统信息
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "难度已选择: 普通难度", SystemMessage.COLOR_SUCCESS}}, 3.0)
        else
            Player.sendAll("难度已选择: 普通难度")
        end

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

--- 移除初始力量墙（选英完成后调用）
function GameInit.removeInitWall()
    if GameInit.initWall then
        cj.RemoveDestructable(GameInit.initWall)
        print("[GameInit] 初始力量墙已移除")
        if SystemMessage and SystemMessage.send then
            SystemMessage.send({{"STR", "力量墙已销毁 - 初始横墙", SystemMessage.COLOR_INFO}}, 3.0)
        end
        GameInit.initWall = nil
    end
end

--- 获取当前关卡复活点
function GameInit.getCurrentRevivePos()
    if GameInit.currentLayer == 4 and Layer4 and Layer4.revivePos then
        return Layer4.revivePos
    end
    if GameInit.currentLayer == 3 and Layer3 and Layer3.revivePos then
        return Layer3.revivePos
    end
    if GameInit.currentLayer == 2 and Layer2 and Layer2.revivePos then
        return Layer2.revivePos
    end
    if Layer1 and Layer1.revivePos then
        return Layer1.revivePos
    end
    return { x = -11787.8, y = -14967.1 }
end

--- 设置所有在线玩家初始金币200
function GameInit.giveInitialGold()
    local list = GameInit.getOnlinePlayers()
    for _, p in ipairs(list) do
        p:setState(PLAYER_STATE_RESOURCE_GOLD, 200)
    end
    print("[GameInit] 初始金币200已发放 count=" .. #list)
end

--- 注册英雄死亡 20秒后复活（当前关卡复活点）- 真计时器+计时器窗口+中央消息
function GameInit.registerReviveEvent()
    if GameInit.reviveEvent then return end
    GameInit.reviveEvent = Event:new(nil, EVENT_PLAYER_UNIT_DEATH, function(ev)
        local dying = ev.unit
        if not dying then return end
        if not cj.IsUnitType(dying, UNIT_TYPE_HERO) then return end
        local owner = Player.fromHandle(cj.GetOwningPlayer(dying))
        if not owner or not owner:isUser() then return end
        -- 仅处理在线玩家英雄
        local pid = owner:getId()
        if pid < 0 or pid > 3 then return end
        local rev = GameInit.getCurrentRevivePos()
        local x, y = rev.x, rev.y
        local reviveSec = 20
        -- 英雄称谓：优先取 ProperName（称谓），空则回退 GetUnitName
        local heroProper = ""
        local okProper = pcall(function() heroProper = cj.GetHeroProperName(dying) end)
        if not okProper or not heroProper or heroProper == "" then
            local okName = pcall(function() heroProper = cj.GetUnitName(dying) end)
            if not okName or not heroProper or heroProper == "" then heroProper = "英雄" end
        end
        local playerName = owner:getName()
        if not playerName or playerName == "" then playerName = "玩家"..pid end
        print(string.format("[GameInit] 玩家%d 英雄死亡，%d秒后复活 at %.1f,%.1f", pid, reviveSec, x, y))
        -- 中央系统信息：通报谁的英雄 称谓 死亡，多少秒后复活
        if SystemMessage and SystemMessage.send then
            local icon = SystemMessage.getUnitIcon(dying)
            local msgText = string.format("%s 的 %s 死亡，%d秒后复活", playerName, heroProper, reviveSec)
            if icon and icon ~= "" then
                SystemMessage.send({{"art", icon}, {"STR", msgText, SystemMessage.COLOR_FAIL}}, 3.0)
            else
                SystemMessage.send({{"STR", msgText, SystemMessage.COLOR_FAIL}}, 3.0)
            end
        end
        -- 真计时器倒计时，计时器窗口仅用英雄称谓
        local dialogText = heroProper
        local t
        t = Timer:new(reviveSec, false, function()
            -- 定时器到期/销毁时窗口由 Timer:destroy / _tick 自动销毁，此处仅处理复活
            if dying and cj.GetUnitTypeId(dying) ~= 0 then
                if cj.IsUnitType(dying, UNIT_TYPE_DEAD) then
                    cj.ReviveHero(dying, x, y, true)
                    print(string.format("[GameInit] 玩家%d 英雄已复活", pid))
                    if SystemMessage and SystemMessage.send then
                        local icon2 = SystemMessage.getUnitIcon(dying)
                        local reviveText = string.format("%s 的 %s 已复活", playerName, heroProper)
                        if icon2 and icon2 ~= "" then
                            SystemMessage.send({{"art", icon2}, {"STR", reviveText, SystemMessage.COLOR_SUCCESS}}, 3.0)
                        else
                            SystemMessage.send({{"STR", reviveText, SystemMessage.COLOR_SUCCESS}}, 3.0)
                        end
                    end
                    if cj.GetLocalPlayer() == owner._handle then
                        Camera.panTo(x, y)
                    end
                end
            end
            -- 显式销毁窗口（兜底，Timer已在_tick或destroy中处理）
            if t and not t._dead then t:destroy() end
        end, nil, true, dialogText)
    end)
end

--- 启动关卡 2（选英完成后）
function GameInit.startLayer2()
    if GameInit.currentLayer >= 2 then return end
    GameInit.currentLayer = 2
    -- 移除初始力量墙
    GameInit.removeInitWall()
    GameInit.giveInitialGold()
    GameInit.registerReviveEvent()
    -- 启动关卡 2 模块
    local ok, L2 = pcall(require, "Game.Layers.Layer2")
    if ok and L2 and L2.start then
        L2.start()
    else
        print("[GameInit] Layer2 启动失败 " .. tostring(L2))
    end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 2 已启动", SystemMessage.COLOR_INFO}}, 3.0)
    else
        Player.sendAll("关卡 2 已启动")
    end
end

--- 启动关卡 3（选英完成后）
function GameInit.startLayer3()
    if GameInit.currentLayer >= 3 then return end
    GameInit.currentLayer = 3
    GameInit.removeInitWall()
    GameInit.giveInitialGold()
    GameInit.registerReviveEvent()
    local ok, L3 = pcall(require, "Game.Layers.Layer3")
    if ok and L3 and L3.start then
        L3.start()
    else
        print("[GameInit] Layer3 启动失败 " .. tostring(L3))
    end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 3 已启动", SystemMessage.COLOR_INFO}}, 3.0)
    else
        Player.sendAll("关卡 3 已启动")
    end
end

--- 启动关卡 4（关卡3通关后）
function GameInit.startLayer4()
    if GameInit.currentLayer >= 4 then return end
    GameInit.currentLayer = 4
    GameInit.giveInitialGold()
    GameInit.registerReviveEvent()
    local ok, L4 = pcall(require, "Game.Layers.Layer4")
    if ok and L4 and L4.start then
        L4.start()
    else
        print("[GameInit] Layer4 启动失败 " .. tostring(L4))
    end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_INFO}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
end

--- 启动关卡 1（选英完成后）
function GameInit.startLayer1()
    if GameInit.currentLayer >= 1 then return end
    GameInit.currentLayer = 1
    -- 移除初始力量墙
    GameInit.removeInitWall()
    GameInit.giveInitialGold()
    GameInit.registerReviveEvent()
    -- 启动关卡 1 模块
    local ok, L1 = pcall(require, "Game.Layers.Layer1")
    if ok and L1 and L1.start then
        L1.start()
    else
        print("[GameInit] Layer1 启动失败 " .. tostring(L1))
    end
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 1 已启动", SystemMessage.COLOR_INFO}}, 3.0)
    else
        Player.sendAll("关卡 1 已启动")
    end
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

        -- 执行移动：转移所有权 + 移动到对应关卡的入口位置（兼容数组/对象，支持关卡3）
        local cx, cy
        -- 兼容 ControlHeroPos 为 {-11790,-15228} 数组或 {x=..,y=..} 对象两种写法
        if ControlHeroPos then
            if ControlHeroPos.x and ControlHeroPos.y then
                cx, cy = ControlHeroPos.x, ControlHeroPos.y
            elseif ControlHeroPos[1] and ControlHeroPos[2] then
                cx, cy = ControlHeroPos[1], ControlHeroPos[2]
            end
        end
        if GameInit.initialLayer == 4 then
            if Layer4 and Layer4.entryPos then
                cx, cy = Layer4.entryPos.x, Layer4.entryPos.y
            elseif Layer4EntryPos then
                cx, cy = Layer4EntryPos.x, Layer4EntryPos.y
            else
                cx, cy = -8518.2, 747.9
            end
            print(string.format("[GameInit] 玩家选择英雄后传送到关卡 4 入口：%.1f, %.1f", cx or 0, cy or 0))
        elseif GameInit.initialLayer == 3 then
            if Layer3 and Layer3.entryPos then
                cx, cy = Layer3.entryPos.x, Layer3.entryPos.y
            elseif Layer3EntryPos then
                cx, cy = Layer3EntryPos.x, Layer3EntryPos.y
            else
                cx, cy = -11915.5, -1952.6
            end
            print(string.format("[GameInit] 玩家选择英雄后传送到关卡 3 入口：%.1f, %.1f", cx or 0, cy or 0))
        elseif GameInit.initialLayer == 2 then
            if Layer2 and Layer2.entryPos then
                cx, cy = Layer2.entryPos.x, Layer2.entryPos.y
            elseif Layer2EntryPos then
                cx, cy = Layer2EntryPos.x, Layer2EntryPos.y
            else
                cx, cy = -11398.9, -7748.4
            end
            print(string.format("[GameInit] 玩家选择英雄后传送到关卡 2 入口：%.1f, %.1f", cx or 0, cy or 0))
        elseif GameInit.initialLayer == 1 then
            if Layer1 and Layer1.revivePos then
                cx, cy = Layer1.revivePos.x, Layer1.revivePos.y
            elseif Layer1RevivePos then
                cx, cy = Layer1RevivePos.x, Layer1RevivePos.y
            else
                cx, cy = cx or -11787.8, cy or -14967.1
            end
            print(string.format("[GameInit] 玩家选择英雄后传送到关卡 1 入口：%.1f, %.1f", cx or 0, cy or 0))
        else
            print(string.format("[GameInit] 玩家选择英雄后传送到默认位置：%.1f, %.1f", cx or 0, cy or 0))
        end
        if not cx or not cy then
            print("[GameInit] 错误：传送目标坐标为 nil，回退到 ControlHeroPos")
            if ControlHeroPos.x then cx, cy = ControlHeroPos.x, ControlHeroPos.y else cx, cy = ControlHeroPos[1], ControlHeroPos[2] end
        end
        
        targetUnit:setOwner(casterPlayer, true)
        -- 关键修复：选英展示阶段为避免堆叠而 setPathing(false)，转移后必须恢复碰撞/寻路，否则英雄会无视地形与不可通行
        if targetUnit.setPathing then targetUnit:setPathing(true) end
        pcall(cj.SetUnitPathing, targetHandle, true)
        targetUnit:setPosition(cx, cy)
        -- 让英雄停止当前动作
        targetUnit:stop()
        
        local heruo = Hero.fromHandle(targetHandle)
        heruo:addAttrs(1000,1000,1000)

        -- 同步将触发玩家的镜头移动到转移后位置（仅该玩家客户端）
        if cj.GetLocalPlayer() == casterPlayer._handle then
            Camera.panTo(cx, cy)
            Camera.setQuickPos(cx, cy)
        end

        -- 记录
        GameInit.heroTaken[key] = true
        GameInit.playerSelected[casterPid] = true
        GameInit.selectedCount = GameInit.selectedCount + 1

        -- 中央系统信息：选择英雄
        local selIcon = ""
        if SystemMessage and SystemMessage.getUnitIcon then selIcon = SystemMessage.getUnitIcon(targetHandle) or "" end
        local selText = casterPlayer:getName() .. " 选择了 " .. targetUnit:getName()
        if SystemMessage and SystemMessage.send then
            if selIcon and selIcon ~= "" then
                SystemMessage.send({{"art", selIcon}, {"STR", selText, SystemMessage.COLOR_SUCCESS}}, 3.0)
            else
                SystemMessage.send({{"STR", selText, SystemMessage.COLOR_SUCCESS}}, 3.0)
            end
        else
            Player.sendAll(selText)
        end

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
            if SystemMessage and SystemMessage.send then
                SystemMessage.send({{"STR", "所有玩家已完成英雄选择", SystemMessage.COLOR_SUCCESS}}, 3.0)
            else
                Player.sendAll("所有玩家已完成英雄选择")
            end
            -- 根据 initialLayer 启动对应关卡（已补关卡3/4）
            if GameInit.initialLayer == 4 then
                GameInit.startLayer4()
            elseif GameInit.initialLayer == 3 then
                GameInit.startLayer3()
            elseif GameInit.initialLayer == 2 then
                GameInit.startLayer2()
            else
                GameInit.startLayer1()
            end
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
