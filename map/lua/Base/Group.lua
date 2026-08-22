-- ============================================================
-- Group 类 — 单位组（纯 Lua 实现，不依赖原生 group handle）
--
-- 设计：
--   - 全局底层单位表 (_unitPool) 管理所有已知单位
--   - Group 对象用 _units Lua table 存储单位引用
--   - 不再使用 cj.CreateGroup() 原生单位组
--
-- 调用方式：
--   local g = Group:new()
--   g:addUnit(unit)
--   g:forEach(function(unit) print(unit) end)
--   g:destroy()
--
--   Group.GLOBAL           -- 全局单位组（共享实例）
-- ============================================================

---@class Group 单位组
Group = {}
Group.__index = Group

-----------------------------------------------------------------
-- 全局底层单位表（所有单位的注册中心）
-----------------------------------------------------------------
-- _unitPool: handleId (integer) -> unit (userdata)
-- 存储所有已知的有效单位，死亡单位也保留直至 handle 彻底失效
Group._unitPool    = {}
Group._initialized = false

-- [LAN-SYNC] 缓存顺序 = 注册顺序：注册事件（初始扫描/进图事件/脚本创建）按游戏时序触发，
-- 双机执行同一脚本 → 注册时序跨机一致 → 数组顺序跨机一致。
-- 新增单位一律追加到尾部（_poolAppend），移除用 table.remove（后面的自动顶上来），全程不排序。
-- cleanPool 重建时按注册序号（_unitReg，唯一递增）排序恢复原序：
-- 序号唯一 → 严格全序 → table.sort 输出与 pairs() 哈希迭代序无关。
-- ★ 禁止用 GetHandleId 决胜：句柄是机器本地的（2026-08-13 实测双机差 7236 槽位）。
local function regLess(a, b)
    local ra, rb = Group._unitReg[a] or 0, Group._unitReg[b] or 0
    if ra ~= rb then return ra < rb end
    return false  -- 理论不可达：注册序号唯一，不同单位不可能同序
end

-- 排序缓存：纯注册序数组（追加维护）；cleanPool 每 3 秒全量重建一次过滤失效单位
Group._poolSorted = nil

-- 注册序号表：unit -> 递增序号（跨机一致的顺序键，见上注释）
Group._unitReg   = {}
Group._unitRegSeq = 0

-- 追加到缓存尾部（数组顺序 = 注册顺序，跨机一致）
local function _poolAppend(unit)
    local arr = Group._poolSorted
    if arr == nil then
        Group._poolSorted = { unit }
        return
    end
    arr[#arr + 1] = unit
end

-----------------------------------------------------------------
-- 初始化（由 _autoInit 在 map init 时自动调用）
-----------------------------------------------------------------
-- 底层表操作函数（外部也可调用）
-----------------------------------------------------------------

--- 验证单位 handle 是否仍然有效（死亡也算有效）
---@param unit userdata
---@return boolean
function Group._isValidUnit(unit)
    if (unit == nil) then return false end
    local id = cj.GetHandleId(unit)
    if (id == nil or id == 0) then return false end
    -- 额外校验 GetUnitTypeId：RemoveUnit 后 handle 虽未回收但 typeId 归零
    return cj.GetUnitTypeId(unit) ~= 0
end

--- 将单位注册到全局底层表（外部调用）
---@param unit userdata
function Group.registerPoolUnit(unit)
    if (unit == nil) then return end
    local id = cj.GetHandleId(unit)
    if (id == nil or id == 0) then return end
    if Group._unitPool[id] == unit then
        -- 防重复注册：同句柄已在池中；兜底补发序号（正常不会缺，防御性）
        if Group._unitReg[unit] == nil then
            Group._unitRegSeq = Group._unitRegSeq + 1
            Group._unitReg[unit] = Group._unitRegSeq
        end
        return
    end
    Group._unitPool[id] = unit
    -- 分配注册序号：注册事件（进图/脚本创建）按游戏时序触发，跨机一致
    Group._unitRegSeq = Group._unitRegSeq + 1
    Group._unitReg[unit] = Group._unitRegSeq
    -- 同步追加到确定性排序缓存尾部（顺序 = 注册顺序）
    _poolAppend(unit)
end

-- 内部注册（由 _autoInit / create 事件触发）
local function _registerUnit(unit)
    Group.registerPoolUnit(unit)
end

--- 从底层表移除单位
---@param unit userdata
function Group.unregisterPoolUnit(unit)
    if (unit == nil) then return end
    local id = cj.GetHandleId(unit)
    if (id == nil or id == 0) then return end
    Group._unitPool[id] = nil
    Group._unitReg[unit] = nil  -- 注销即释放注册序号
    -- 从缓存移除（线性扫描；销毁是低频操作）。table.remove 自动前移，
    -- 中间单位被移除后，后面的单位顶上，保持注册序不变
    local arr = Group._poolSorted
    if arr ~= nil then
        for i = #arr, 1, -1 do
            if arr[i] == unit then
                table.remove(arr, i)
                break
            end
        end
    end
end

--- 从底层表移除单位（通过 handle ID）
---@param id integer handleId
function Group.unregisterPoolUnitById(id)
    if (id == nil) then return end
    local unit = Group._unitPool[id]
    Group._unitPool[id] = nil
    if (unit ~= nil) then Group._unitReg[unit] = nil end
end

--- 查询单位是否在底层表中
---@param unit userdata
---@return boolean
function Group.hasPoolUnit(unit)
    if (unit == nil) then return false end
    local id = cj.GetHandleId(unit)
    if (id == nil or id == 0) then return false end
    return Group._unitPool[id] ~= nil
end

--- 清理底层表中已失效的单位（handle ID 彻底不见的单位）
---@return integer --清理掉的数目
function Group.cleanPool()
    -- 强制重建排序缓存：重建即过滤失效单位（从 _unitPool 移除）
    Group._poolSorted = nil
    return Group._forEachPoolUnit(function() end)
end

--- 遍历底层表（确定性排序序），自动清理无效单位，有效单位执行回调
--- 返回 false 可终止遍历（用于 count 限制）
---@return integer --本次清理掉的无效单位数量
---@param callback fun(unit:userdata):boolean|nil
function Group._forEachPoolUnit(callback)
    local cleaned = 0
    local arr = Group._poolSorted
    if arr == nil then
        -- 重建：从 _unitPool 收集有效单位 + 确定性排序（同时清理失效键）
        arr = {}
        for id, unit in pairs(Group._unitPool) do
            if (unit == nil or not Group._isValidUnit(unit)) then
                Group._unitPool[id] = nil
                Group._unitReg[unit] = nil  -- 失效单位释放注册序号
                cleaned = cleaned + 1
            else
                arr[#arr + 1] = unit
            end
        end
        table.sort(arr, regLess)  -- 按注册序号恢复注册序（序号唯一 → 严格全序，与 pairs 哈希序无关）
        Group._poolSorted = arr
    end
    -- 快照迭代：回调内可能注册/销毁单位，直接改 arr 会破坏遍历
    local snapshot = {}
    for i, unit in ipairs(arr) do snapshot[i] = unit end
    for _, unit in ipairs(snapshot) do
        if (unit ~= nil and Group._isValidUnit(unit)) then
            if callback(unit) == false then
                break
            end
        end
    end
    return cleaned
end

--- 初始化：扫描全图单位 + 单位进入地图事件
function Group._autoInit()
    if (Group._initialized) then return end

    local ok, err = pcall(function()
        -- 1. 扫描全图所有预置单位加入底层表（不排序：缓存顺序 = 注册顺序，
        --    注册时序由游戏时序保证跨机一致；再次排序纯属浪费）
        local world = cj.GetWorldBounds()
        local temp  = cj.CreateGroup()
        cj.GroupEnumUnitsInRect(temp, world, nil)
        cj.ForGroup(temp, function()
            _registerUnit(cj.GetEnumUnit())
        end)
        cj.DestroyGroup(temp)

        -- 2. 监听单位进入地图事件，自动注册到底层表
        Event:newRect(world, function(e)
            _registerUnit(e.unit)
        end)

        -- 3. 每3秒清理一次底层表中失效的单位
        local timer = cj.CreateTimer()
        cj.TimerStart(timer, 3.0, true, function()
            Group.cleanPool()
        end)
    end)

    if (not ok) then
        print("[Group._autoInit] ERROR: " .. tostring(err))
        return
    end
    Group._initialized = true
end

-- 在模块加载时立即初始化（地图脚本加载时预置单位已存在）
Group._autoInit()

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newGroup()
    local obj      = { _units = {} }
    setmetatable(obj, Group)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建单位组
---@return Group
function Group:new()
    return newGroup()
end

--- 从原生 handle 创建（兼容接口，实际从底层表查找）
---@param h userdata group handle（忽略，保留接口兼容）
---@return Group
function Group.fromHandle(h)
    -- 原生 group 已废弃，此方法返回空 Group 对象
    return newGroup()
end

--- 销毁单位组（清空引用，不销毁原生 handle）
---@return Group
function Group:destroy()
    self._units = {}
    return self
end

-----------------------------------------------------------------
-- 单位增减
-----------------------------------------------------------------

--- 校验并移除本组中已失效的单位
---@return Group
function Group:validate()
    local valid = {}
    for _, u in ipairs(self._units) do
        if (Group._isValidUnit(u)) then
            table.insert(valid, u)
        end
    end
    self._units = valid
    return self
end

--- 添加单位
---@param unit userdata 单位handle
---@return Group
function Group:addUnit(unit)
    if (unit == nil or not Group._isValidUnit(unit)) then return self end
    -- 去重
    for _, u in ipairs(self._units) do
        if (u == unit) then return self end
    end
    table.insert(self._units, unit)
    return self
end

--- 移除单位
---@param unit userdata
---@return Group
function Group:removeUnit(unit)
    if (unit == nil) then return self end
    for i, u in ipairs(self._units) do
        if (u == unit) then
            table.remove(self._units, i)
            break
        end
    end
    return self
end

--- 清空单位组
---@return Group
function Group:clear()
    self._units = {}
    return self
end

--- 单位是否在组中
---@param unit userdata
---@return boolean
function Group:contains(unit)
    if (unit == nil) then return false end
    for _, u in ipairs(self._units) do
        if (u == unit) then return true end
    end
    return false
end

-----------------------------------------------------------------
-- 枚举（纯 Lua 实现，遍历底层表筛选）
-----------------------------------------------------------------

--- 范围内枚举单位
---@param x number 中心X
---@param y number 中心Y
---@param radius number 半径
---@param filter fun(unit:userdata)|nil Lua过滤函数 function(unit) -> boolean
---@return Group
function Group:enumRange(x, y, radius, filter)
    self._units = {}
    local r2 = radius * radius
    Group._forEachPoolUnit(function(unit)
        local dx = cj.GetUnitX(unit) - x
        local dy = cj.GetUnitY(unit) - y
        if (dx * dx + dy * dy <= r2) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
            end
        end
    end)
    return self
end

--- 范围内枚举（数量限制）
---@param x number
---@param y number
---@param radius number
---@param filter function|nil
---@param count integer 数量上限
---@return Group
function Group:enumRangeCounted(x, y, radius, filter, count)
    self._units = {}
    local limit = count or 1
    local n     = 0
    local r2    = radius * radius
    Group._forEachPoolUnit(function(unit)
        if (n >= limit) then return false end
        local dx = cj.GetUnitX(unit) - x
        local dy = cj.GetUnitY(unit) - y
        if (dx * dx + dy * dy <= r2) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
                n = n + 1
            end
        end
    end)
    return self
end

--- 矩形区域内枚举
---@param rect userdata rect handle
---@param filter function|nil Lua过滤函数
---@return Group
function Group:enumRect(rect, filter)
    self._units = {}
    if (rect == nil) then return self end
    Group._forEachPoolUnit(function(unit)
        local U = Unit.fromHandle(unit)
        if (U and U:isInRect(rect)) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
            end
        end
    end)
    return self
end

--- 矩形区域内枚举（数量限制）
---@param rect userdata
---@param filter function|nil
---@param count integer
---@return Group
function Group:enumRectCounted(rect, filter, count)
    self._units = {}
    if (rect == nil) then return self end
    local limit = count or 1
    local n     = 0
    Group._forEachPoolUnit(function(unit)
        if (n >= limit) then return false end
        local U = Unit.fromHandle(unit)
        if (U and U:isInRect(rect)) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
                n = n + 1
            end
        end
    end)
    return self
end

--- 枚举某玩家的单位
---@param player userdata 玩家handle
---@param filter function|nil
---@return Group
function Group:enumPlayer(player, filter)
    self._units = {}
    if (player == nil) then return self end
    local pid = cj.GetPlayerId(player)
    Group._forEachPoolUnit(function(unit)
        if (cj.GetPlayerId(cj.GetOwningPlayer(unit)) == pid) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
            end
        end
    end)
    return self
end

--- 枚举指定类型的单位
---@param unitType string|integer 单位ID（四字符码字符串或整数）
---@param filter function|nil
---@return Group
function Group:enumType(unitType, filter)
    self._units = {}
    local typeId = (type(unitType) == "string") and cj.FourCC(unitType) or unitType
    Group._forEachPoolUnit(function(unit)
        if (cj.GetUnitTypeId(unit) == typeId) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
            end
        end
    end)
    return self
end

--- 枚举指定类型（数量限制）
---@param unitType string|integer
---@param filter function|nil
---@param count integer
---@return Group
function Group:enumTypeCounted(unitType, filter, count)
    self._units = {}
    local typeId = (type(unitType) == "string") and cj.FourCC(unitType) or unitType
    local limit  = count or 1
    local n      = 0
    Group._forEachPoolUnit(function(unit)
        if (n >= limit) then return false end
        if (cj.GetUnitTypeId(unit) == typeId) then
            if (filter == nil or filter(unit)) then
                table.insert(self._units, unit)
                n = n + 1
            end
        end
    end)
    return self
end

--- 枚举玩家选中单位（使用临时原生 group 兼容）
---@param player userdata
---@param filter function|nil
---@return Group
function Group:enumSelected(player, filter)
    self._units = {}
    if (player == nil) then return self end
    local temp = cj.CreateGroup()
    cj.GroupEnumUnitsSelected(temp, player, nil)
    cj.ForGroup(temp, function()
        local u = cj.GetEnumUnit()
        if (u ~= nil) then
            if (filter == nil or filter(u)) then
                table.insert(self._units, u)
            end
        end
    end)
    cj.DestroyGroup(temp)
    return self
end

--- 枚举编队单位（KK_japi，使用临时原生 group 兼容）
---@param player userdata
---@param controlIndex integer|nil 编队索引，nil 表示所有编队单位
---@param includeDisabled boolean|nil 是否包含已禁用单位
---@return Group
function Group:enumControlGroup(player, controlIndex, includeDisabled)
    self._units = {}
    if (player == nil) then return self end
    local temp = cj.CreateGroup()
    cdz.DzGroupEnumPlayerControlGroup(temp, player, controlIndex or 0, includeDisabled ~= nil and includeDisabled or false)
    cj.ForGroup(temp, function()
        local u = cj.GetEnumUnit()
        if (u ~= nil) then
            Group._registerUnit(u)
            table.insert(self._units, u)
        end
    end)
    cj.DestroyGroup(temp)
    return self
end

-----------------------------------------------------------------
-- 遍历
-----------------------------------------------------------------

--- 遍历单位组内所有单位
---@param callback fun(unit:userdata) 回调函数，接收 unit 参数
---@return Group
function Group:forEach(callback)
    if (callback == nil) then return self end
    self:validate()
    for _, unit in ipairs(self._units) do
        callback(unit)
    end
    return self
end

-----------------------------------------------------------------
-- 大小
-----------------------------------------------------------------

--- 获取单位组中单位数量
---@return integer
function Group:getCount()
    self:validate()
    return #self._units
end

--- 获取指定索引的单位（索引从 0 开始，兼容原生接口）
---@param index integer
---@return userdata|nil
function Group:getUnitAt(index)
    self:validate()
    return self._units[index + 1]
end

-----------------------------------------------------------------
-- 命令（对组内每个单位逐发出）
-----------------------------------------------------------------

--- 发布命令（无目标）
---@param order string|integer 命令
---@return boolean
function Group:order(order)
    if (order == nil) then return false end
    self:validate()
    for _, unit in ipairs(self._units) do
        if (type(order) == "string") then
            cj.IssueImmediateOrder(unit, order)
        else
            cj.IssueImmediateOrderById(unit, order)
        end
    end
    return true
end

--- 发布命令到坐标
---@param order string|integer
---@param x number
---@param y number
---@return boolean
function Group:orderPoint(order, x, y)
    if (order == nil) then return false end
    self:validate()
    for _, unit in ipairs(self._units) do
        if (type(order) == "string") then
            cj.IssuePointOrder(unit, order, x, y)
        else
            cj.IssuePointOrderById(unit, order, x, y)
        end
    end
    return true
end

--- 发布命令到目标单位
---@param order string|integer
---@param target userdata 目标widget
---@return boolean
function Group:orderTarget(order, target)
    if (order == nil or target == nil) then return false end
    self:validate()
    for _, unit in ipairs(self._units) do
        if (type(order) == "string") then
            cj.IssueTargetOrder(unit, order, target)
        else
            cj.IssueTargetOrderById(unit, order, target)
        end
    end
    return true
end

--- 移动
---@param x number
---@param y number
---@return boolean
function Group:move(x, y)
    return self:orderPoint("move", x, y)
end

--- 攻击（坐标）
---@param x number
---@param y number
---@return boolean
function Group:attack(x, y)
    return self:orderPoint("attack", x, y)
end

--- 攻击目标
---@param target userdata
---@return boolean
function Group:attackTarget(target)
    return self:orderTarget("attack", target)
end

--- 停止
---@return boolean
function Group:stop()
    return self:order("stop")
end

-----------------------------------------------------------------
-- 队列命令（KK_japi 扩展，使用临时原生 group）
-----------------------------------------------------------------

--- 添加命令到队列（无目标）
---@param orderId integer 命令ID
---@return Group
function Group:queueOrder(orderId)
    if (orderId == nil) then return self end
    self:validate()
    local temp = cj.CreateGroup()
    for _, unit in ipairs(self._units) do
        cj.GroupAddUnit(temp, unit)
    end
    cdz.DzQueueGroupImmediateOrderById(temp, orderId)
    cj.DestroyGroup(temp)
    return self
end

--- 添加命令到队列（坐标）
---@param orderId integer
---@param x number
---@param y number
---@return Group
function Group:queueOrderPoint(orderId, x, y)
    if (orderId == nil) then return self end
    self:validate()
    local temp = cj.CreateGroup()
    for _, unit in ipairs(self._units) do
        cj.GroupAddUnit(temp, unit)
    end
    cdz.DzQueueGroupPointOrderById(temp, orderId, x, y)
    cj.DestroyGroup(temp)
    return self
end

--- 添加命令到队列（目标）
---@param orderId integer
---@param target userdata
---@return boolean
function Group:queueOrderTarget(orderId, target)
    if (orderId == nil or target == nil) then return false end
    self:validate()
    local temp = cj.CreateGroup()
    for _, unit in ipairs(self._units) do
        cj.GroupAddUnit(temp, unit)
    end
    local result = cdz.DzQueueGroupTargetOrderById(temp, orderId, target)
    cj.DestroyGroup(temp)
    return result
end

-----------------------------------------------------------------
-- 哈希表（兼容接口）
-----------------------------------------------------------------

--- 保存到哈希表（保存单位 handle ID）
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Group:save(t, pk, ck)
    -- 原生 group handle 已废弃，此方法不再有意义
    -- 如需保存单位组，请自行序列化 _units
    return false
end

--- 从哈希表读取（不再支持）
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Group|nil
function Group.load(t, pk, ck)
    return nil
end

-----------------------------------------------------------------
-- 框架辅助（桥接）
-----------------------------------------------------------------

--- 全局单位组（共享实例）
Group.GLOBAL = Group.GLOBAL or newGroup()

--- 添加单位（静态方法，支持 handle 或 Group 对象）
---@param g userdata|Group 单位组handle或Group对象
---@param u userdata 单位handle
function Group.addUnit(g, u)
    if (g == nil or u == nil) then return end
    if (type(g) == "table") then
        g:addUnit(u)
    end
end

--- 移除单位（静态方法，支持 handle 或 Group 对象）
---@param g userdata|Group 单位组handle或Group对象
---@param u userdata 单位handle
function Group.removeUnit(g, u)
    if (g == nil or u == nil) then return end
    if (type(g) == "table") then
        g:removeUnit(u)
    end
end

return Group
