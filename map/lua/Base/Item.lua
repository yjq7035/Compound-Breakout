---@diagnostic disable: duplicate-set-field
-- ============================================================
-- Item 类 — 物品
-- 重构要点：
--   1）destroy() 先移出地图再删除，避免 War3 "丢失物品"提示
--   2）修复 isPaid() / isPerishable() 调错 API 的 bug
--   3）去除冗余的类级字段定义（_handle / _index 等由实例初始化）
--   4）统一错误处理，增强健壮性
-- ============================================================

---@class Item 物品
Item = {}
Item.__index = Item

-----------------------------------------------------------------
-- 内部工厂 / 工具
-----------------------------------------------------------------
local function newItem()
    local obj = {
        _handle = nil,
        _index  = nil,
        _id     = nil,
        _type   = nil,
    }
    setmetatable(obj, Item)
    return obj
end

--- 从各种输入中提取 userdata handle
---@param v any  Unit/Hero/Item 对象 | userdata handle
---@return userdata|nil
local function resolveHandle(v)
    if v == nil then return nil end
    if type(v) == "userdata" then return v end
    if type(v) == "table" and v._handle ~= nil and type(v._handle) == "userdata" then
        return v._handle
    end
    return nil
end

--- 检查 self._handle 是否有效
---@return boolean
local function isValid(self)
    return self._handle ~= nil and type(self._handle) == "userdata"
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建物品到坐标
---@param itemId integer|string  物品 ID（四字符码或整数）
---@param x number
---@param y number
---@return Item|nil
function Item:new(itemId, x, y)
    if itemId == nil then return nil end
    if type(itemId) == "string" then itemId = c2i(itemId) end

    local obj = newItem()
    obj._handle = cj.CreateItem(itemId, x, y)
    if type(obj._handle) ~= "userdata" then
        print("[Item] 创建物品失败 itemId=" .. tostring(itemId) .. "（无效 ID）")
        return nil
    end
    _G._PT = _G._PT or {}; _G._PT.item = (_G._PT.item or 0) + 1  -- [PROBE] 临时诊断
    _G._PT.itemLastId = cj.GetHandleId(obj._handle)  -- [PROBE] 金丝雀：最新物品句柄ID（跨机对照 id 流）
    obj._index = cj.GetHandleId(obj._handle)
    obj._id    = itemId
    obj._type  = i2c(itemId)
    -- QG-08：写入物品提示 userdata（名称 + 清洗后的描述），使其优先于原生 SLK 文本
    --   ItemTooltip 全局运行时已存在；不可用则跳过（显示层有 Obj.Item 回退）。
    --   key 必须是数字 3（ITEM_DESC_KEY），不是字符串 "desc"。
    local itemTooltip = _G.ItemTooltip
    local objItem = rawget(_G, "Obj") and rawget(_G.Obj, "Item")
    if itemTooltip and objItem and obj._type then
        local data = objItem[obj._type]
        if data then
            local name = data.Name or ""
            local cleanUbertip = itemTooltip._cleanUbertip
            local uber = (cleanUbertip and cleanUbertip(data.Ubertip or "")) or ""
            local nameKey = itemTooltip.ITEM_NAME_KEY
            local descKey = itemTooltip.ITEM_DESC_KEY
            if nameKey then obj:setUserDataString(nameKey, name) end
            if descKey then obj:setUserDataString(descKey, uber) end
        end
    end
    return obj
end

--- 从已有 handle 创建 Item 对象
---@param h userdata  物品 handle
---@return Item
function Item.fromHandle(h)
    if h == nil then return nil end
    local obj = newItem()
    obj._handle = h
    obj._index  = cj.GetHandleId(h)
    obj._id     = cj.GetItemTypeId(h)
    obj._type   = i2c(obj._id)
    return obj
end

--- 销毁物品
--- 始终使用 0 延迟 Timer 推迟到下一 tick 执行，
--- 避免在拾取事件处理中直接 RemoveItem 导致 War3 弹出"丢失物品"
---@param delay number|nil  延迟秒数（默认 0 = 下一 tick）
---@return Item
function Item:destroy(delay)
    if not isValid(self) then return self end
    delay = delay or 0

    local function doRemove()
        if not isValid(self) then return end
        cj.RemoveItem(self._handle)
        self._handle = nil
    end

    -- 始终走 Timer，即使 delay=0 也延到下一 tick，
    -- 避免在拾取事件上下文中直接删除，War3 就不弹"丢失物品"
    Timer:new(delay, false, doRemove)
    return self
end

-----------------------------------------------------------------
-- 标识
-----------------------------------------------------------------

--- 获取物品 ID（数字）
---@return integer
function Item:getId()
    if not isValid(self) then return 0 end
    return cj.GetItemTypeId(self._handle)
end

--- 获取物品类型码（四字符）
---@return string
function Item:getTypeCode()
    return i2c(self:getId())
end

--- 获取物品名称
---@return string
function Item:getName()
    if not isValid(self) then return "" end
    return cj.GetItemName(self._handle)
end

--- 获取物品等级
---@return integer
function Item:getLevel()
    if not isValid(self) then return 0 end
    return cj.GetItemLevel(self._handle)
end

--- 获取物品类型（ITPE_* 常量）
---@return integer|nil
function Item:getType()
    if not isValid(self) then return nil end
    return cj.GetItemType(self._handle)
end




-----------------------------------------------------------------
-- 所有者
-----------------------------------------------------------------

--- 获取物品所属玩家
---@return userdata|nil
function Item:getPlayer()
    if not isValid(self) then return nil end
    return cj.GetItemPlayer(self._handle)
end

--- 设置物品所属玩家
---@param pl Player|userdata
---@param changeColor boolean|nil  默认 true
---@return Item
function Item:setPlayer(pl, changeColor)
    if not isValid(self) or pl == nil then return self end
    local handle = (type(pl) == "table" and pl._handle) or pl
    cj.SetItemPlayer(self._handle, handle, (changeColor ~= nil) and changeColor or true)
    return self
end

-----------------------------------------------------------------
-- 位置
-----------------------------------------------------------------

--- 获取 X 坐标
---@return number
function Item:getX()
    if not isValid(self) then return 0 end
    return cj.GetItemX(self._handle)
end

--- 获取 Y 坐标
---@return number
function Item:getY()
    if not isValid(self) then return 0 end
    return cj.GetItemY(self._handle)
end

--- 设置位置
---@param x number
---@param y number
---@return Item
function Item:setPosition(x, y)
    if not isValid(self) then return self end
    cj.SetItemPosition(self._handle, x, y)
    return self
end

-----------------------------------------------------------------
-- 充能 / 数据
-----------------------------------------------------------------

--- 获取当前使用次数
---@return integer
function Item:getCharges()
    if not isValid(self) then return 0 end
    return cj.GetItemCharges(self._handle)
end

--- 设置使用次数
---@param charges integer
---@return Item
function Item:setCharges(charges)
    if not isValid(self) then return self end
    cj.SetItemCharges(self._handle, charges)
    return self
end

--- 获取自定义值
---@return integer
function Item:getUserData()
    if not isValid(self) then return 0 end
    return cj.GetItemUserData(self._handle)
end

--- 设置自定义值
---@param data integer
---@return Item
function Item:setUserData(data)
    if not isValid(self) then return self end
    cj.SetItemUserData(self._handle, data)
    return self
end


--- 设置物品自定义字符串数据
---@param key string
---@param value string
---@return Item
function Item:setUserDataString(key, value)
    if not isValid(self) then return self end
    -- 注意：EXSetItemDataString 与 EXGetItemDataString 一样是“类型级”存储，
    -- 第一个参数必须是 itemId（整数），不是物品 handle。
    -- 原先传 self._handle 导致写入落到实例而非类型，getUserDataString 按 typeId 读不到。
    cdz.EXSetItemDataString(self:getId(), key, value)
    return self
end

--- 获取物品自定义字符串数据
---@param index integer
---@return string|nil
function Item:getUserDataString(index)
    if not isValid(self) then return nil end
    local st = cdz.EXGetItemDataString(self:getId(), index)
    return st
end



-----------------------------------------------------------------
-- 状态
-----------------------------------------------------------------

--- 设置可见性
---@param visible boolean
---@return Item
function Item:setVisible(visible)
    if not isValid(self) then return self end
    cj.SetItemVisible(self._handle, (visible ~= nil) and visible or true)
    return self
end

--- 是否可见
---@return boolean
function Item:isVisible()
    if not isValid(self) then return false end
    return cj.IsItemVisible(self._handle)
end

--- 设置无敌
---@param flag boolean
---@return Item
function Item:setInvulnerable(flag)
    if not isValid(self) then return self end
    cj.SetItemInvulnerable(self._handle, (flag ~= nil) and flag or true)
    return self
end

--- 是否无敌
---@return boolean
function Item:isInvulnerable()
    if not isValid(self) then return false end
    return cj.IsItemInvulnerable(self._handle)
end

--- 设置是否可丢弃
---@param droppable boolean
---@return Item
function Item:setDroppable(droppable)
    if not isValid(self) then return self end
    cj.SetItemDroppable(self._handle, (droppable ~= nil) and droppable or true)
    return self
end

--- 设置死亡掉落
---@param drop boolean
---@return Item
function Item:setDropOnDeath(drop)
    if not isValid(self) then return self end
    cj.SetItemDropOnDeath(self._handle, (drop ~= nil) and drop or true)
    return self
end

--- 设置是否可贩卖
---@param pawnable boolean
---@return Item
function Item:setPawnable(pawnable)
    if not isValid(self) then return self end
    cj.SetItemPawnable(self._handle, (pawnable ~= nil) and pawnable or true)
    return self
end

--- 设置掉落物品 ID
---@param unitId integer|string
---@return Item
function Item:setDropID(unitId)
    if not isValid(self) then return self end
    if type(unitId) == "string" then unitId = c2i(unitId) end
    cj.SetItemDropID(self._handle, unitId)
    return self
end

-----------------------------------------------------------------
-- 查询状态
-----------------------------------------------------------------

--- 物品是否已被拾取（在单位物品栏中）
---@return boolean
function Item:isOwned()
    if not isValid(self) then return false end
    return cj.IsItemOwned(self._handle)
end

--- 是否神力符类型
---@return boolean
function Item:isPowerUp()
    if not isValid(self) then return false end
    return cj.IsItemPowerup(self._handle)
end

--- 是否可贩卖（实例级别）
---@return boolean
function Item:isPawnable()
    if not isValid(self) then return false end
    return cj.IsItemPawnable(self._handle)
end

--- 是否可出售
---@return boolean
function Item:isSellable()
    if not isValid(self) then return false end
    return cj.IsItemSellable(self._handle)
end

-----------------------------------------------------------------
-- 单位交互
-----------------------------------------------------------------

--- 将物品给予单位
---@param unit Unit|userdata
---@return boolean
function Item:giveToUnit(unit)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil then return false end
    return cj.UnitAddItem(uh, self._handle)
end

--- 单位使用物品（无目标）
---@param unit Unit|userdata
---@return boolean
function Item:useByUnit(unit)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil then return false end
    return cj.UnitUseItem(uh, self._handle)
end

--- 单位使用物品到坐标
---@param unit Unit|userdata
---@param x number
---@param y number
---@return boolean
function Item:useByUnitAt(unit, x, y)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil then return false end
    return cj.UnitUseItemPoint(uh, self._handle, x, y)
end

--- 单位使用物品到目标
---@param unit Unit|userdata
---@param target userdata
---@return boolean
function Item:useByUnitTarget(unit, target)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil or target == nil then return false end
    return cj.UnitUseItemTarget(uh, self._handle, target)
end

--- 单位丢弃物品到坐标
---@param unit Unit|userdata
---@param x number
---@param y number
---@return boolean
function Item:dropByUnit(unit, x, y)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil then return false end
    return cj.UnitDropItemPoint(uh, self._handle, x, y)
end

--- 单位丢弃物品到指定栏位
---@param unit Unit|userdata
---@param slot integer  0-5
---@return boolean
function Item:dropToSlot(unit, slot)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil or slot == nil then return false end
    return cj.UnitDropItemSlot(uh, self._handle, slot)
end

--- 单位丢弃物品到目标单位
---@param unit Unit|userdata
---@param target userdata
---@return boolean
function Item:dropToUnit(unit, target)
    if not isValid(self) then return false end
    local uh = resolveHandle(unit)
    if uh == nil or target == nil then return false end
    return cj.UnitDropItemTarget(uh, self._handle, target)
end

-----------------------------------------------------------------
-- 模型 / 视觉（DzAPI 扩展）
-----------------------------------------------------------------
--- 设置物品模型
---@param modelFile string
---@return Item
function Item:setModel(modelFile)
    if isValid(self) and modelFile ~= nil then
        cdz.DzItemSetModel(self._handle, modelFile)
    end
    return self
end

--- 设置物品头像
---@param modelFile string
---@return Item
function Item:setPortrait(modelFile)
    if isValid(self) and modelFile ~= nil then
        cdz.DzItemSetPortrait(self._handle, modelFile)
    end
    return self
end

--- 设置物品大小
---@param size number
---@return Item
function Item:setSize(size)
    if isValid(self) and size ~= nil then
        cdz.DzItemSetSize(self._handle, size)
    end
    return self
end

--- 获取物品大小
---@return number
function Item:getSize()
    if not isValid(self) then return 0 end
    return cdz.DzItemGetSize(self._handle)
end

--- 设置物品透明度
---@param alpha number
---@return Item
function Item:setAlpha(alpha)
    if isValid(self) and alpha ~= nil then
        cdz.DzItemSetAlpha(self._handle, alpha)
    end
    return self
end

--- 设置物品颜色
---@param color number
---@return Item
function Item:setColor(color)
    if isValid(self) and color ~= nil then
        cdz.DzItemSetVertexColor(self._handle, color)
    end
    return self
end

--- 获取物品颜色
---@return number
function Item:getColor()
    if not isValid(self) then return 0 end
    return cdz.DzItemGetVertexColor(self._handle)
end

--- 重置物品颜色
---@return Item
function Item:resetColor()
    if isValid(self) then
        cdz.DzItemResetColor(self._handle)
    end
    return self
end

--- 设置物品碰撞大小
---@param size number
---@return Item
function Item:setCollisionSize(size)
    if isValid(self) and size ~= nil then
        cdz.DzSetItemCollisionSize(self._handle, size)
    end
    return self
end

--- 获取物品碰撞大小
---@return number
function Item:getCollisionSize()
    if not isValid(self) then return 0 end
    return cdz.DzGetItemCollisionSize(self._handle)
end

-----------------------------------------------------------------
-- 矩阵变换（DzAPI 扩展）
-----------------------------------------------------------------

--- 重置物品变换矩阵
---@return Item
function Item:resetTransform()
    if isValid(self) then cdz.DzItemMatReset(self._handle) end
    return self
end

--- 旋转物品 X 轴
---@param degree number
---@return Item
function Item:rotateX(degree)
    if isValid(self) and degree ~= nil then
        cdz.DzItemMatRotateX(self._handle, degree)
    end
    return self
end

--- 旋转物品 Y 轴
---@param degree number
---@return Item
function Item:rotateY(degree)
    if isValid(self) and degree ~= nil then
        cdz.DzItemMatRotateY(self._handle, degree)
    end
    return self
end

--- 旋转物品 Z 轴
---@param degree number
---@return Item
function Item:rotateZ(degree)
    if isValid(self) and degree ~= nil then
        cdz.DzItemMatRotateZ(self._handle, degree)
    end
    return self
end

--- 缩放物品
---@param x number
---@param y number
---@param z number
---@return Item
function Item:scale(x, y, z)
    if isValid(self) and x ~= nil and y ~= nil and z ~= nil then
        cdz.DzItemMatScale(self._handle, x, y, z)
    end
    return self
end

-----------------------------------------------------------------
-- 技能（DzAPI 扩展）
-----------------------------------------------------------------

--- 获取物品技能（栏位索引）
---@param index integer  默认 0
---@return ability|nil
function Item:getAbility(index)
    if not isValid(self) then return nil end
    return cdz.DzGetItemAbility(self._handle, index or 0)
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存物品 handle 到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Item:save(t, pk, ck)
    if not isValid(self) then return false end
    return cj.SaveItemHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取物品 handle 并返回 Item 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Item|nil
function Item.load(t, pk, ck)
    local h = cj.LoadItemHandle(t, pk, ck)
    if h == nil then return nil end
    return Item.fromHandle(h)
end

-----------------------------------------------------------------
-- 静态工具
-----------------------------------------------------------------

--- 获取物品 ID（从 handle 或 Item 对象）
---@param it userdata|Item  物品 handle 或 Item 对象
---@return integer
function Item.getId(it)
    if it == nil then return 0 end
    if type(it) == "table" then
        if not isValid(it) then return 0 end
        return cj.GetItemTypeId(it._handle)
    end
    return cj.GetItemTypeId(it)
end

--- 是否为神力符类型（按物品类型 ID）
---@param itemId integer|string
---@return boolean
function Item.isPowerUp(itemId)
    if itemId == nil then return false end
    if type(itemId) == "string" then itemId = c2i(itemId) end
    return cj.IsItemIdPowerup(itemId)
end

--- 是否可贩卖（按物品类型 ID）
---@param itemId integer|string
---@return boolean
function Item.isPawnable(itemId)
    if itemId == nil then return false end
    if type(itemId) == "string" then itemId = c2i(itemId) end
    return cj.IsItemIdPawnable(itemId)
end

--- 是否可出售（按物品类型 ID）
---@param itemId integer|string
---@return boolean
function Item.isSellable(itemId)
    if itemId == nil then return false end
    if type(itemId) == "string" then itemId = c2i(itemId) end
    return cj.IsItemIdSellable(itemId)
end

--- 是否可被销毁（按物品类型 ID）
---@param itemId integer|string
---@return boolean
function Item.isPerishable(itemId)
    if itemId == nil then return false end
    if type(itemId) == "string" then itemId = c2i(itemId) end
    return cj.IsItemIdPerishable(itemId)
end

--- 获取物品金币价格
---@param it userdata  物品 handle
---@return integer
function Item.getGoldCost(it)
    if it == nil then return 0 end
    return cj.GetItemGoldCost(it)
end

--- 获取物品木材价格
---@param it userdata  物品 handle
---@return integer
function Item.getLumberCost(it)
    if it == nil then return 0 end
    return cj.GetItemWoodCost(it)
end


