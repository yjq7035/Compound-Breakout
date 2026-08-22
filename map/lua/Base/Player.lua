-- ============================================================
-- Player 类 — 玩家
-- 调用方式：
--   local p = Player:new(0)
--   p:setGold(1000)
--   p:addGold(500)
--   local name = p:getName()
--   p:send("你好")         -- 向该玩家发送消息
--   Player.sendAll("全体消息")        -- 向所有玩家发送消息
--   Player.sendAllPrint("消息+控制台") -- 向所有玩家发送消息并输出到控制台
--   Player.loc()         -- 获取本地玩家
--   平台服务器存档（原 Platform.lua 已并入）：
--   p:get("key") / p:set("key", v) / p:saveServer("key") / p:getInt("key") / Player.saveAll("key")
-- ============================================================

---@class Player 玩家
Player = {}
Player.__index = Player

Player._handle = nil
Player._index = nil
Player.hero = nil  --玩家英雄



-- 玩家状态常量
Player.GOLD = PLAYER_STATE_RESOURCE_GOLD
Player.LUMBER = PLAYER_STATE_RESOURCE_LUMBER
Player.FOOD_USED = PLAYER_STATE_RESOURCE_FOOD_USED
Player.FOOD_CAP = PLAYER_STATE_RESOURCE_FOOD_CAP

-----------------------------------------------------------------
-- 内部工厂 / 常量表
-----------------------------------------------------------------
local playerList = {}

local function newPlayer()
    local obj = { _handle = nil, _index = nil, id = 0 }
    setmetatable(obj, Player)
    return obj
end

-----------------------------------------------------------------
-- 构造
-----------------------------------------------------------------

--- 通过玩家索引创建 Player 对象（0 = 玩家1, bj_MAX_PLAYERS-1 = 最后一个）
--- 若同一 id 已创建过则直接返回缓存实例（保证 .hero 等动态属性一致性）
---@param id integer 玩家索引 0-23
---@return Player
function Player:new(id)
    id = id or 0
    if playerList[id] then
        return playerList[id]
    end
    local obj = newPlayer()
    obj._index = id
    obj._handle = cj.Player(id)
    obj.id = id
    playerList[id] = obj
    return obj
end

--- 从已有handle创建 Player 对象
---@param h userdata player handle
---@return Player
function Player.fromHandle(h)
    if (h == nil) then return end
    local id = cj.GetPlayerId(h)
    -- 优先从缓存获取，保证 .hero 等动态属性一致性
    if playerList[id] then
        return playerList[id]
    end
    local obj = newPlayer()
    obj._handle = h
    obj._index = id
    obj.id = id
    playerList[id] = obj
    return obj
end

--- 获取玩家英雄
---@return Unit , Hero
function Player:Hero()
    return Unit.fromHandle(self.hero._handle) , Hero.fromHandle(self.hero._handle)
end


-----------------------------------------------------------------
-- 消息发送
-----------------------------------------------------------------

--- 向该玩家发送消息（屏幕顶端飘字）
---@param msg string|number 消息内容
---@return Player
function Player:send(msg)
    if (self._handle ~= nil and msg ~= nil) then
        cj.DisplayTextToPlayer(self._handle, 0, 0, tostring(msg))
    end
    return self
end

--- 向所有玩家发送消息（屏幕顶端飘字）
---@param msg string|number 消息内容
function Player.sendAll(msg)
    if (msg == nil) then return end
    local text = tostring(msg)
    for _, h in ipairs(Player.players) do
        cj.DisplayTextToPlayer(h, 0, 0, text)
    end
end

--- 向所有玩家发送消息，同时输出到控制台（print）
---@param msg string|number 消息内容
function Player.sendAllPrint(msg)
    if (msg == nil) then return end
    local text = tostring(msg)
    Player.sendAll(text)
    print(text)
end

-----------------------------------------------------------------
-- 基础属性
-----------------------------------------------------------------

--- 获取玩家ID（0-based索引）
---@return integer
function Player:getId()
    return self._index
end

--- 获取玩家名称
---@return string
function Player:getName()
    if (self._handle == nil) then return "" end
    return cj.GetPlayerName(self._handle)
end

--- 设置玩家名称
---@param name string
---@return Player
function Player:setName(name)
    if (self._handle ~= nil and name ~= nil) then
        cj.SetPlayerName(self._handle, name)
    end
    return self
end

--- 获取玩家颜色
---@return playercolor
function Player:getColor()
    if (self._handle == nil) then return end
    return cj.GetPlayerColor(self._handle)
end

--- 设置玩家颜色
---@param color playercolor
---@return Player
function Player:setColor(color)
    if (self._handle ~= nil) then
        cj.SetPlayerColor(self._handle, color)
    end
    return self
end

--- 获取种族
---@return race
function Player:getRace()
    if (self._handle == nil) then return end
    return cj.GetPlayerRace(self._handle)
end

--- 获取队伍
---@return integer
function Player:getTeam()
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerTeam(self._handle)
end

--- 设置队伍
---@param team integer
---@return Player
function Player:setTeam(team)
    if (self._handle ~= nil) then
        cj.SetPlayerTeam(self._handle, team)
    end
    return self
end

-----------------------------------------------------------------
-- 状态判断
-----------------------------------------------------------------

--- 是否电脑
---@return boolean
function Player:isComputer()
    if (self._handle == nil) then return false end
    return cj.GetPlayerController(self._handle) == MAP_CONTROL_COMPUTER
        or cj.GetPlayerSlotState(self._handle) ~= PLAYER_SLOT_STATE_PLAYING
end

--- 是否玩家（人工操作）
---@return boolean
function Player:isUser()
    -- if not self then return false end
    return cj.GetPlayerController(self._handle) == MAP_CONTROL_USER
end

--- 是否正在游戏
---@return boolean
function Player:isPlaying()
    if not self then return false end
    return (cj.GetPlayerSlotState(self._handle) == PLAYER_SLOT_STATE_PLAYING)
end

--- 是否中立（id >= 12）
---@return boolean
function Player:isNeutral()
    return self._index >= 12
end

--- 是否观察者
---@return boolean
function Player:isObserver()
    if (self._handle == nil) then return false end
    return cj.IsPlayerObserver(self._handle)
end

--- 是否可选
---@return boolean
function Player:isSelectable()
    if (self._handle == nil) then return false end
    return cj.GetPlayerSelectable(self._handle)
end

--- 获取槽位状态
---@return boolean
function Player:getSlotState()
    if (self._handle == nil) then return false end
    return cj.GetPlayerSlotState(self._handle)
end

--- 获取控制类型
---@return mapcontrol
function Player:getController()
    if (self._handle == nil) then return end
    return cj.GetPlayerController(self._handle)
end

-----------------------------------------------------------------
-- 资源
-----------------------------------------------------------------

--- 获取玩家状态值
---@param state playerstate 状态类型（如 Player.GOLD）
---@return integer
function Player:getState(state)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerState(self._handle, state)
end

--- 设置玩家状态值
---@param state playerstate
---@param value integer
---@return Player
function Player:setState(state, value)
    if (self._handle ~= nil) then
        cj.SetPlayerState(self._handle, state, math.floor(value))
    end
    return self
end

--- 获取金币
---@return integer
function Player:getGold()
    return self:getState(Player.GOLD)
end

--- 设置金币
---@param val integer
---@return Player
function Player:setGold(val)
    return self:setState(Player.GOLD, val)
end

--- 增加金币
---@param val integer
---@return Player
function Player:addGold(val)
    return self:setGold(self:getGold() + val)
end

--- 获取木材
---@return integer
function Player:getLumber()
    return self:getState(Player.LUMBER)
end

--- 设置木材
---@param val integer
---@return Player
function Player:setLumber(val)
    return self:setState(Player.LUMBER, val)
end

--- 增加木材
---@param val integer
---@return Player
function Player:addLumber(val)
    return self:setLumber(self:getLumber() + val)
end

--- 获取已用人口
---@return integer
function Player:getFoodUsed()
    return self:getState(Player.FOOD_USED)
end

--- 获取人口上限
---@return integer
function Player:getFoodCap()
    return self:getState(Player.FOOD_CAP)
end

-----------------------------------------------------------------
-- 科技
-----------------------------------------------------------------

--- 研究科技
---@param techId integer 科技ID
---@param level integer 等级
---@return Player
function Player:setTechResearched(techId, level)
    if (self._handle ~= nil) then
        cj.SetPlayerTechResearched(self._handle, techId, level)
    end
    return self
end

--- 获取科技研究等级
---@param techId integer
---@param specificOnly boolean 是否仅精确匹配
---@return boolean
function Player:getTechResearched(techId, specificOnly)
    if (self._handle == nil) then return false end
    return cj.GetPlayerTechResearched(self._handle, techId, (specificOnly ~= nil) and specificOnly or true)
end

--- 获取科技计数
---@param techId integer
---@param specificOnly boolean
---@return integer
function Player:getTechCount(techId, specificOnly)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerTechCount(self._handle, techId, (specificOnly ~= nil) and specificOnly or true)
end

--- 设置科技最大等级
---@param techId integer
---@param maxLevel integer
---@return Player
function Player:setTechMax(techId, maxLevel)
    if (self._handle ~= nil) then
        cj.SetPlayerTechMaxAllowed(self._handle, techId, maxLevel)
    end
    return self
end

--- 获取科技最大等级
---@param techId integer
---@return integer
function Player:getTechMax(techId)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerTechMaxAllowed(self._handle, techId)
end

--- 设置技能是否可用
---@param abilId integer 技能ID
---@param available boolean
---@return Player
function Player:setAbilityAvailable(abilId, available)
    if (self._handle ~= nil) then
        cj.SetPlayerAbilityAvailable(self._handle, abilId, (available ~= nil) and available or true)
    end
    return self
end

-----------------------------------------------------------------
-- 联盟 / 外交
-----------------------------------------------------------------

--- 是否同盟
---@param other Player|nil 对方玩家
---@return boolean
function Player:isAlly(other)
    if other == nil then return false end
    return cj.IsPlayerAlly(self._handle, other._handle)
end

--- 是否敌对
---@param other Player|nil 对方玩家
---@return boolean
function Player:isEnemy(other)
    if other == nil then return true end
    return cj.IsPlayerEnemy(self._handle, other._handle)
end

--- 设置联盟状态
---@param otherPlayer userdata 对方玩家
---@param whichType alliancetype 联盟类型
---@param value boolean
---@return Player
function Player:setAlliance(otherPlayer, whichType, value)
    if (self._handle ~= nil) then
        cj.SetPlayerAlliance(self._handle, otherPlayer, whichType, value)
    end
    return self
end

--- 获取联盟状态
---@param otherPlayer userdata
---@param whichType alliancetype
---@return boolean
function Player:getAlliance(otherPlayer, whichType)
    if (self._handle == nil) then return false end
    return cj.GetPlayerAlliance(self._handle, otherPlayer, whichType)
end

--- 是否在指定玩家组中
---@param force userdata force handle
---@return boolean
function Player:isInForce(force)
    if (self._handle == nil) then return false end
    return cj.IsPlayerInForce(self._handle, force)
end

-----------------------------------------------------------------
-- 单位数量 / 得分
-----------------------------------------------------------------

--- 获取单位数量
---@param includeIncomplete boolean 是否包含未完成
---@return integer
function Player:getUnitCount(includeIncomplete)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerUnitCount(self._handle, (includeIncomplete ~= nil) and includeIncomplete or false)
end

--- 获取指定类型单位数量
---@param unitName string 单位ID字符串
---@param includeIncomplete boolean
---@param includeUpgrades boolean
---@return integer
function Player:getTypedUnitCount(unitName, includeIncomplete, includeUpgrades)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerTypedUnitCount(self._handle, unitName, includeIncomplete or false, includeUpgrades or false)
end

--- 获取建筑数量
---@param includeIncomplete boolean
---@return integer
function Player:getStructureCount(includeIncomplete)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerStructureCount(self._handle, (includeIncomplete ~= nil) and includeIncomplete or false)
end

--- 获取得分
---@param scoreType playerscore 得分类型
---@return integer
function Player:getScore(scoreType)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerScore(self._handle, scoreType)
end

-----------------------------------------------------------------
-- 属性加成 / 经验加成
-----------------------------------------------------------------

--- 获取属性加成（生命上限%）
---@return number
function Player:getHandicap()
    if (self._handle == nil) then return 1 end
    return cj.GetPlayerHandicap(self._handle)
end

--- 设置属性加成
---@param val number
---@return Player
function Player:setHandicap(val)
    if (self._handle ~= nil) then
        cj.SetPlayerHandicap(self._handle, val)
    end
    return self
end

--- 获取经验加成
---@return number
function Player:getHandicapXP()
    if (self._handle == nil) then return 1 end
    return cj.GetPlayerHandicapXP(self._handle)
end

--- 设置经验加成
---@param val number
---@return Player
function Player:setHandicapXP(val)
    if (self._handle ~= nil) then
        cj.SetPlayerHandicapXP(self._handle, val)
    end
    return self
end

--- 增加经验加成
---@param val number
---@return Player
function Player:addHandicapXP(val)
    if (self._handle ~= nil) then
        cj.SetPlayerHandicapXP(self._handle, self:getHandicapXP() + val)
    end
    return self
end

-----------------------------------------------------------------
-- 起始位置
-----------------------------------------------------------------

--- 获取起始位置索引
---@return integer
function Player:getStartLoc()
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerStartLocation(self._handle)
end

--- 获取起始位置X
---@return number
function Player:getStartLocX()
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerStartLocationX(self._handle)
end

--- 获取起始位置Y
---@return number
function Player:getStartLocY()
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerStartLocationY(self._handle)
end

--- 设置起始位置
---@param index integer
---@return Player
function Player:setStartLoc(index)
    if (self._handle ~= nil) then
        cj.SetPlayerStartLocation(self._handle, index)
    end
    return self
end

-----------------------------------------------------------------
-- 控制 / 计分
-----------------------------------------------------------------

--- 设置控制类型
---@param ctrl mapcontrol
---@return Player
function Player:setController(ctrl)
    if (self._handle ~= nil) then
        cj.SetPlayerController(self._handle, ctrl)
    end
    return self
end

--- 设置是否在计分屏显示
---@param flag boolean
---@return Player
function Player:setOnScoreScreen(flag)
    if (self._handle ~= nil) then
        cj.SetPlayerOnScoreScreen(self._handle, (flag ~= nil) and flag or true)
    end
    return self
end

--- 转移所有单位所有权
---@param newOwner integer 新玩家索引
---@return Player
function Player:transferUnits(newOwner)
    if (self._handle ~= nil) then
        cj.SetPlayerUnitsOwner(self._handle, newOwner)
    end
    return self
end

--- 投降/踢出
---@param result playergameresult 游戏结果
---@return Player
function Player:remove(result)
    if (self._handle ~= nil) then
        cj.RemovePlayer(self._handle, result or PLAYER_GAME_RESULT_DEFEAT)
    end
    return self
end

-----------------------------------------------------------------
-- 税率
-----------------------------------------------------------------

--- 获取税率
---@param otherPlayer userdata 对方玩家
---@param resource playerstate 资源类型
---@return integer
function Player:getTaxRate(otherPlayer, resource)
    if (self._handle == nil) then return 0 end
    return cj.GetPlayerTaxRate(self._handle, otherPlayer, resource)
end

--- 设置税率
---@param otherPlayer userdata
---@param resource playerstate
---@param rate integer
---@return Player
function Player:setTaxRate(otherPlayer, resource, rate)
    if (self._handle ~= nil) then
        cj.SetPlayerTaxRate(self._handle, otherPlayer, resource, rate)
    end
    return self
end

-----------------------------------------------------------------
-- 种族偏好
-----------------------------------------------------------------

--- 设置种族偏好
---@param pref racepreference
---@return Player
function Player:setRacePref(pref)
    if (self._handle ~= nil) then
        cj.SetPlayerRacePreference(self._handle, pref)
    end
    return self
end

--- 设置种族是否可选
---@param selectable boolean
---@return Player
function Player:setRaceSelectable(selectable)
    if (self._handle ~= nil) then
        cj.SetPlayerRaceSelectable(self._handle, (selectable ~= nil) and selectable or true)
    end
    return self
end

-----------------------------------------------------------------
-- 哈希表
-----------------------------------------------------------------

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Player:save(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SavePlayerHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Player
function Player.load(t, pk, ck)
    local h = cj.LoadPlayerHandle(t, pk, ck)
    if (h == nil) then return end
    return Player.fromHandle(h)
end

-----------------------------------------------------------------
-- 静态工具
-----------------------------------------------------------------

--- 获取本地玩家handle
---@return userdata
function Player.loc()
    return cj.GetLocalPlayer()
end

--- 获取玩家handle（通过索引）
---@param id integer
---@return userdata
function Player.handle(id)
    return cj.Player(id)
end

--- 获取事件触发玩家handle
---@return userdata
function Player.trigger()
    return cj.GetTriggerPlayer()
end

--- 获取所有玩家数
---@return integer
function Player.count()
    return bj_MAX_PLAYERS
end

-----------------------------------------------------------------
-- 平台存档（原 Platform.lua，已并入 Player 对象方法）
-- 用法：
--   pl:get(key)              -- 读取（缓存命中直接返回，未命中拉服务器）
--   pl:set(key, "1000")     -- 写入（标记脏，自动启动 0.1s 保存定时器）
--   pl:saveServer(key)       -- 立即保存（跳过定时器）
--   Player.saveAll(key)       -- 立即保存所有玩家的此 key
--   pl:getPublic(key)        -- 读取公有存档组
--   pl:setPublic(key, val)   -- 写入公有存档组
--   pl:useConsumable(id)     -- 使用商城消耗型道具
--   pl:getInt(key)           -- 读取并转整数（nil 安全，返回 0）
--   Player.toInt(str)         -- 字符串转整数（静态工具）
--   pl:getVIPLevel()/isBlueVIP()/isRedVIP()/getLadderLevel()
-- 说明：get 带缓存穿透，set 带脏标记 + 懒启动定时器异步保存；
--       队列空自动停定时器，下次 set 自动重启。
--       注意：Player:save 已被哈希表存档占用，平台立即保存命名为 saveServer。
-----------------------------------------------------------------
local Dz_timer = nil     -- 定时器引用，nil=未运行
local SAVE_INTERVAL = 0.1      -- 定时周期（秒）
local _queue = {}                   -- {{keyName, pid}, ...} 待存队列
local _cache = {}                   -- _cache[keyName][pid] = value
local _dirty = {}                   -- _dirty[keyName][pid] = true
-----------------------------------------------------------------
-- 定时器管理
-----------------------------------------------------------------

local function timerStart()
    Dz_timer = Timer:new(SAVE_INTERVAL, true, function()
        if Dz_timer == nil then
            return
        end

        if #_queue == 0 then
            Dz_timer:destroy()
            Dz_timer = nil
            return
        end

        local item = table.remove(_queue, 1)
        if item == nil then
            return
        end

        local keyName = item[1]
        local pid = item[2]

        local dirtyMap = _dirty[keyName]
        if not dirtyMap or not dirtyMap[pid] then
            return
        end

        local cacheMap = _cache[keyName]
        if not cacheMap or cacheMap[pid] == nil then
            _dirty[keyName][pid] = nil
            return
        end

        cdz.DzAPI_Map_SaveServerValue(cj.Player(pid), keyName, tostring(cacheMap[pid]))
        _dirty[keyName][pid] = nil
    end)
end

-----------------------------------------------------------------
-- 平台存档读写（Player 对象方法）
-----------------------------------------------------------------

--- 读取服务器存档值（带缓存穿透）
--- @param keyName string 存档 key
--- @return string|nil 存档值
function Player:get(keyName)
    if self == nil or keyName == nil then return nil end
    local pid = self._index

    -- 缓存命中
    if _cache[keyName] and _cache[keyName][pid] ~= nil then
        return _cache[keyName][pid]
    end

    -- 缓存未命中，拉服务器
    local value = cdz.DzAPI_Map_GetServerValue(self._handle, keyName)

    -- 写入缓存
    if not _cache[keyName] then _cache[keyName] = {} end
    _cache[keyName][pid] = value

    return value
end

--- 设置服务器存档值（带缓存 + 定时延迟保存）
--- @param keyName string 存档 key
--- @param value string|nil 存档值
--- @return Player 支持链式
function Player:set(keyName, value)
    if self == nil or keyName == nil then return self end
    local pid = self._index

    -- 确保缓存和脏表存在
    if not _cache[keyName] then _cache[keyName] = {} end
    if not _dirty[keyName] then _dirty[keyName] = {} end

    local strVal = value ~= nil and tostring(value) or nil

    -- 值没变且不是脏状态，跳过
    if _cache[keyName][pid] == strVal and not _dirty[keyName][pid] then
        return self
    end

    _cache[keyName][pid] = strVal

    if strVal == nil then
        -- 删除
        _dirty[keyName][pid] = nil
        for i = #_queue, 1, -1 do
            if _queue[i][1] == keyName and _queue[i][2] == pid then
                table.remove(_queue, i)
            end
        end
        return self
    end

    -- 标记脏，入队
    if not _dirty[keyName][pid] then
        _dirty[keyName][pid] = true
        table.insert(_queue, { keyName, pid })
        if Dz_timer == nil then timerStart() end
    end

    return self
end

--- 立即保存到服务器（跳过定时器等待）
--- 说明：Player:save 已被哈希表存档占用，平台立即保存命名为 saveServer
--- @param keyName string 存档 key
--- @return Player
function Player:saveServer(keyName)
    if self == nil or keyName == nil then return self end
    local pid = self._index

    local cacheMap = _cache[keyName]
    if not cacheMap or cacheMap[pid] == nil then return self end

    cdz.DzAPI_Map_SaveServerValue(self._handle, keyName, tostring(cacheMap[pid]))
    if _dirty[keyName] then _dirty[keyName][pid] = nil end
    -- 从队列移除
    for i = #_queue, 1, -1 do
        if _queue[i][1] == keyName and _queue[i][2] == pid then
            table.remove(_queue, i)
        end
    end
    return self
end

--- 立即保存所有玩家的此 key
--- @param keyName string 存档 key
function Player.saveAll(keyName)
    if keyName == nil then return end
    local dirtyMap = _dirty[keyName]
    if not dirtyMap then return end

    for pid, _ in pairs(dirtyMap) do
        if _cache[keyName] and _cache[keyName][pid] ~= nil then
            cdz.DzAPI_Map_SaveServerValue(cj.Player(pid), keyName, tostring(_cache[keyName][pid]))
            _dirty[keyName][pid] = nil
        end
    end

    -- 清理队列
    local i = 1
    while i <= #_queue do
        if _queue[i][1] == keyName then
            table.remove(_queue, i)
        else
            i = i + 1
        end
    end
end

--- 读取并转整数（nil 安全，返回 0）
--- @param keyName string 存档 key
--- @return integer
function Player:getInt(keyName)
    if self == nil then return 0 end
    local v = self:get(keyName)
    if v == nil or v == "" then return 0 end
    return cj.S2I(v)
end

-----------------------------------------------------------------
-- 平台直通接口（无缓存，直接调用平台 API）
-----------------------------------------------------------------

--- 读取服务器公有存档组
--- @param keyName string
--- @return string|nil
function Player:getPublic(keyName)
    return cdz.DzAPI_Map_GetPublicArchive(self._handle, keyName)
end

--- 保存服务器公有存档组
--- @param keyName string
--- @param value string 值
function Player:setPublic(keyName, value)
    cdz.DzAPI_Map_SavePublicArchive(self._handle, keyName, tostring(value))
end

--- 使用商城消耗型道具
--- @param itemId string 道具ID
function Player:useConsumable(itemId)
    cdz.DzAPI_Map_UseConsumablesItem(self._handle, itemId)
end

--- 获取玩家平台VIP等级
--- @return integer
function Player:getVIPLevel()
    return cdz.DzAPI_Map_GetPlatformVIP(self._handle)
end

--- 玩家是否主播VIP
--- @return boolean
function Player:isBlueVIP()
    return cdz.DzAPI_Map_IsBlueVIP(self._handle)
end

--- 玩家是否职业选手VIP
--- @return boolean
function Player:isRedVIP()
    return cdz.DzAPI_Map_IsRedVIP(self._handle)
end

--- 获取玩家天梯等级
--- @return integer
function Player:getLadderLevel()
    return cdz.DzAPI_Map_GetLadderLevel(self._handle)
end

--- 测试大厅预约人数
--- @return integer
function Player:getMapOrderNum()
    return cdz.RequestExtraIntegerData(109, nil, nil, nil, false, 0, 0, 0)
end

--- 使用商城道具(数量型)
--- 通过 RequestExtraBooleanData(42) 发送请求，DZMIC 同步数据触发即表示使用成功
--- @param key string 道具key
--- @param count integer 使用数量
--- @param callback fun(P: Player, Key: string) 使用成功回调，参数为触发玩家和同步数据返回的key
--- @return boolean -- 是否成功发送请求，与是否成功使用无关
function Player:useKeyItem(key, count, callback)
    if self._handle == nil then return false end

    -- 初始化全局 DZMIC 监听（只注册一次）
    if not Player._dzmicTrigger then
        Player._dzmicTrigger = cj.CreateTrigger()
        cdz.DzTriggerRegisterSyncData(Player._dzmicTrigger, "DZMIC", true)
        Player._dzmicCallbacks = {}
        cj.TriggerAddAction(Player._dzmicTrigger, function()
            local pid = cj.GetPlayerId(cdz.DzGetTriggerSyncPlayer())
            local data = cdz.DzGetTriggerSyncData()
            local cb = Player._dzmicCallbacks[pid]
            if cb then
                Player._dzmicCallbacks[pid] = nil
                cb(Player.fromHandle(cdz.DzGetTriggerSyncPlayer()), data)
            end
        end)
    end

    -- 发送使用请求
    local ok = cdz.RequestExtraBooleanData(42, self._handle, key, nil, false, count, 0, 0)
    if ok and callback then
        Player._dzmicCallbacks[self:getId()] = callback
    end
    return ok
end

-----------------------------------------------------------------
-- 平台相关工具 / 玩家数据
-----------------------------------------------------------------

--- 字符串转换为整数（静态工具，原 string:toInt）
--- @param s string
--- @return integer
function Player.toInt(s)
    return cj.S2I(s)
end

--- 玩家最近一次上安利墙时间
--- @return integer
function Player:getLastRecommendTime()
    return cdz.RequestExtraIntegerData(67, self._handle, nil, nil, false, 0, 0, 0)
end

--- 玩家地图商城道具剩余数量
--- 获取玩家地图商城道具剩余数量。仅对次数消耗型商品有效
--- @param Key string 存档 key
--- @return integer
function Player:getIntData(Key)
    return cdz.RequestExtraIntegerData(41, self._handle, Key, nil, false, 0, 0, 0) 
end

--- 获取玩家地图等级排名
--- @return integer
function Player:getMapLevelRank()
    return cdz.DzAPI_Map_GetMapLevelRank(self._handle)
end

--- 获取玩家平台ID
--- @return string
function Player:getUserID()
    return cdz.DzAPI_Map_GetUserID(self._handle)
end

--- 获取玩家天梯排名
--- @return integer
function Player:getLadderRank()
    return cdz.DzAPI_Map_GetLadderRank(self._handle)
end

--- 获取玩家地图等级
--- @return integer
function Player:getMapLevel()
    return cdz.DzAPI_Map_GetMapLevel(self._handle)
end

--- 获取玩家助力榜排名
--- @return integer
function Player:getSupportRank()
    return cdz.RequestExtraIntegerData(120, self._handle, nil, nil, false, 0, 0, 0)
end

--- 获取服务器存档错误码
--- @return integer
function Player:getErrorCode()
    return cdz.DzAPI_Map_GetServerValueErrorCode(self._handle)
end

--- 玩家是否拥有商城道具
--- @return boolean
function Player:hasMallItem(key)
    if self._handle == nil or key == nil then return false end
    return cdz.DzAPI_Map_HasMallItem(self._handle, tostring(key))
end

--- 商城道具数量（内存镜像：开局 0.5s 首播 + 5s 巡检刷新）
--- ★ 铁律B：禁止在同步逻辑直接调 getIntData（仅本机有真值 → 各机分叉 → desync），
---   一律读 HeroInit._platMirror 镜像（GameHeroInit 广播填充，各机同源）。
--- @param key string 商城道具 key（item 码，自动转镜像 key）
--- @param def integer 镜像未就绪时的默认值
--- @return integer
function Player:mallCount(key, def)
    local H = _G.GameHeroInit
    if H and H.platInt then return H.platInt(self, "int:" .. key, def) end
    return def or 0
end

--- 同步扣减商城道具数量（使用道具成功回调内调用：DZMIC/_sync 回调=全机同步 → 各机一致扣减）
--- 平台侧由 useKeyItem 实际消费，此处只扣各机内存镜像，保证后续同步读取同源
--- @param key string 商城道具 key
--- @param n integer 扣减数量（默认 1）
function Player:consumeMall(key, n)
    local H = _G.GameHeroInit
    if H and H.platConsume then H.platConsume(self, key, n or 1) end
end

--- 获取测试预约人数
--- @return integer
function Player:getTestReservation()
    return cdz.RequestExtraIntegerData(109, nil, nil, nil, false, 0, 0, 0)
end

-----------------------------------------------------------------
-- 框架辅助属性（hplayer 桥接占位，由外部对接）
-----------------------------------------------------------------
-- 以下函数被 eventBinder, attribute, award, skill 等模块引用，
-- 若未实现会被默认空函数替代，运行时不会崩

Player.players = Player.players or {}
Player.qty_current = 0
Player.qty_max = bj_MAX_PLAYERS
Player.player_status = { gaming = "gaming" }

Player.addGoldStatic = rawget(_G, "hplayer_addGold") or function(p, val) Player.fromHandle(p):addGold(val) end
Player.addLumberStatic = rawget(_G, "hplayer_addLumber") or function(p, val) Player.fromHandle(p):addLumber(val) end
Player.addGoldRatio  = rawget(_G, "hplayer_addGoldRatio")  or function() end
Player.addLumberRatio = rawget(_G, "hplayer_addLumberRatio") or function() end
Player.addExpRatio   = rawget(_G, "hplayer_addExpRatio")   or function() end
Player.addSellRatio  = rawget(_G, "hplayer_addSellRatio")  or function() end
Player.getExpRatio   = rawget(_G, "hplayer_getExpRatio")   or function() return 100 end
Player.getSellRatio  = rawget(_G, "hplayer_getSellRatio")  or function() return 100 end
Player.getStatus     = rawget(_G, "hplayer_getStatus")     or function() return Player.player_status.gaming end
Player.index         = rawget(_G, "hplayer_index")         or function(p) return cj.GetPlayerId(p) end
Player.isComputer    = rawget(_G, "hplayer_isComputer")    or function(p) return Player.fromHandle(p):isComputer() end
Player.addDamage     = rawget(_G, "hplayer_addDamage")     or function() end
Player.addBeDamage   = rawget(_G, "hplayer_addBeDamage")   or function() end
Player.addKill       = rawget(_G, "hplayer_addKill")       or function() end
Player.setCameraShaking  = rawget(_G, "hplayer_setCameraShaking")  or function() end
Player.isCameraShaking   = rawget(_G, "hplayer_isCameraShaking")   or function() return false end
Player.setCameraQuaking  = rawget(_G, "hplayer_setCameraQuaking")  or function() end
Player.isCameraQuaking   = rawget(_G, "hplayer_isCameraQuaking")   or function() return false end



-- 初始化 players 数组
for i = 0, bj_MAX_PLAYERS - 1, 1 do
    Player.players[i + 1] = Player.handle(i)
end
