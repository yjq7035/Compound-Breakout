-- ============================================================
-- Hero 类 — 英雄
-- 继承自 Unit，提供英雄专属的属性和操作
-- 调用方式：
--   local h = Hero:new(Player(0), 'Hmkg', 0, 0, 270)
--   h:addXP(1000, true)
--   h:setLevel(5, true)
--   h:learn('AHab', 1)
--   local str = h:getStr(true)
--   h:revive(0, 0, true)
--   h:destroy()
--
--   Hero.embed(hUnit, { id = "Hmkg" })
-- ============================================================

---@class Hero 英雄
Hero = {}
Hero.__index = Hero
Hero._handle = nil
Hero._index = nil



-- 英雄框架映射表
local heroMap = {}

-- 主属性常量（映射到 raw integer）
Hero.PRIMARY_STR = 0
Hero.PRIMARY_AGI = 1
Hero.PRIMARY_INT = 2

-----------------------------------------------------------------
-- 内部工厂 / 工具
-----------------------------------------------------------------
--- 从 Player/Hero/Unit 对象或裸 handle/ID 中提取 handle
---@param obj table|userdata|number|nil
---@return userdata|nil
local function resolveHandle(obj)
    if (obj == nil) then return nil end
    if (type(obj) == "number") then return cj.Player(obj) end
    if (type(obj) == "table") then
        if (obj._handle ~= nil) then return obj._handle end
    end
    if (type(obj) == "userdata") then return obj end
    return nil
end

local function newHero()
    local obj = { _handle = nil, _index = nil, _id = nil, _type = nil, _data = {} }
    setmetatable(obj, Hero)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建英雄到坐标
---@param pl Player|userdata 玩家对象 或 玩家handle
---@param unitId integer|string 英雄ID
---@param x number X坐标
---@param y number Y坐标
---@param facing number|nil 面向角度（默认 bj_UNIT_FACING）
---@return Hero
function Hero:new(pl, unitId, x, y, facing)
    if (pl == nil or unitId == nil) then return end
    if (type(unitId) == "string") then unitId = c2i(unitId) end

    local obj = newHero()
    local p = resolveHandle(pl)
    facing = facing or bj_UNIT_FACING

    obj._handle = cj.CreateUnit(p, unitId, x, y, facing)
    obj._index = cj.GetHandleId(obj._handle)
    obj._id = unitId
    obj._type = i2c(unitId)

    obj:embed({ id = obj._type })

    -- 自动注册伤害触发器（如果伤害系统已就绪）
    Event.registerDamageUnit(obj._handle)

    -- 主动注册到底层单位池
    Group.registerPoolUnit(obj._handle)

    return obj
end

--- 从已有handle创建 Hero 对象
--- 不检查是否为英雄类型，由调用方保证
---@param h userdata 单位handle
---@return Hero, userdata
function Hero.fromHandle(h)
    if (h == nil) then return end
    local obj = newHero()
    obj._handle = h
    obj._index = cj.GetHandleId(h)
    obj._id = cj.GetUnitTypeId(h)
    obj._type = i2c(obj._id)
    return obj , obj._handle
end

--- 销毁英雄
---@param delay number|nil 延迟秒数（默认0=立即）
---@return Hero
function Hero:destroy(delay)
    if (self._handle == nil) then return self end
    delay = delay or 0
    if (delay <= 0) then
        Group.unregisterPoolUnit(self._handle)
        cj.RemoveUnit(self._handle)
        self:removeData()
        self._handle = nil
    else
        Timer:new(delay, false, function()
            if (self._handle ~= nil) then
                Group.unregisterPoolUnit(self._handle)
                cj.RemoveUnit(self._handle)
                self:removeData()
                self._handle = nil
            end
        end)
    end
    return self
end

-----------------------------------------------------------------
-- 框架注册
-----------------------------------------------------------------

--- 将英雄注册到框架映射表
---@param data table|nil 附加数据 { id = string }
---@return Hero
function Hero:embed(data)
    if (self._handle == nil) then return self end
    local key = cj.GetHandleId(self._handle)
    heroMap[key] = data or {}
    return self
end

--- 获取注册的框架数据
---@param h userdata 英雄handle
---@return table|nil
function Hero.getData(h)
    if (h == nil) then return end
    return heroMap[cj.GetHandleId(h)]
end

--- 从框架映射中移除自己
---@return Hero
function Hero:removeData()
    if (self._handle == nil) then return self end
    heroMap[cj.GetHandleId(self._handle)] = nil
    return self
end

-----------------------------------------------------------------
-- 等级 / 经验
-----------------------------------------------------------------

--- 获取英雄等级
---@return integer
function Hero:getLevel()
    if (self._handle == nil) then return 0 end
    return cj.GetHeroLevel(self._handle)
end

--- 设置英雄等级
---@param level integer 目标等级
---@param showEyeCandy boolean|nil 是否播放特效（默认 true）
---@return Hero
function Hero:setLevel(level, showEyeCandy)
    if (self._handle ~= nil) then
        local sc = (showEyeCandy ~= nil) and showEyeCandy or true
        cj.SetHeroLevel(self._handle, level, sc)
    end
    return self
end

--- 获取英雄当前经验值
---@return integer
function Hero:getXP()
    if (self._handle == nil) then return 0 end
    return cj.GetHeroXP(self._handle)
end

--- 设置英雄经验值
---@param xp integer 目标经验值
---@param showEyeCandy boolean|nil 是否播放特效（默认 true）
---@return Hero
function Hero:setXP(xp, showEyeCandy)
    if (self._handle ~= nil) then
        local sc = (showEyeCandy ~= nil) and showEyeCandy or true
        cj.SetHeroXP(self._handle, xp, sc)
    end
    return self
end

--- 增加英雄经验值
---@param xp integer 增加的经验值
---@param showEyeCandy boolean|nil 是否播放特效（默认 true）
---@return Hero
function Hero:addXP(xp, showEyeCandy)
    if (self._handle ~= nil) then
        local sc = (showEyeCandy ~= nil) and showEyeCandy or true
        cj.AddHeroXP(self._handle, xp, sc)
    end
    return self
end

--- 降低英雄等级
---@param levels integer 降低的等级数
---@return boolean
function Hero:stripLevel(levels)
    if (self._handle == nil) then return false end
    return cj.UnitStripHeroLevel(self._handle, levels or 1)
end

--- 暂停/恢复英雄的经验获取
---@param flag boolean true=暂停经验获取
---@return Hero
function Hero:suspendXP(flag)
    if (self._handle ~= nil) then
        cj.SuspendHeroXP(self._handle, (flag ~= nil) and flag or true)
    end
    return self
end

-----------------------------------------------------------------
-- 属性（力量 / 敏捷 / 智力）
-----------------------------------------------------------------

--- 获取力量
---@param includeBonuses boolean|nil 是否包含加成（默认 true）
---@return integer
function Hero:getStr(includeBonuses)
    if (self._handle == nil) then return 0 end
    local ib = (includeBonuses ~= nil) and includeBonuses or true
    return cj.GetHeroStr(self._handle, ib)
end

--- 设置力量
---@param val integer 新力量值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:setStr(val, permanent)
    if (self._handle ~= nil) then
        local p = (permanent ~= nil) and permanent or true
        cj.SetHeroStr(self._handle, val, p)
    end
    return self
end

--- 增加力量
---@param val integer 增加的力量值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:addStr(val, permanent)
    if (self._handle ~= nil) then
        local ib = (permanent ~= nil) and permanent or true
        cj.SetHeroStr(self._handle, (cj.GetHeroStr(self._handle, ib) or 0) + val, ib)
    end
    return self
end

--- 获取敏捷
---@param includeBonuses boolean|nil 是否包含加成（默认 true）
---@return integer
function Hero:getAgi(includeBonuses)
    if (self._handle == nil) then return 0 end
    local ib = (includeBonuses ~= nil) and includeBonuses or true
    return cj.GetHeroAgi(self._handle, ib)
end

--- 设置敏捷
---@param val integer 新敏捷值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:setAgi(val, permanent)
    if (self._handle ~= nil) then
        local p = (permanent ~= nil) and permanent or true
        cj.SetHeroAgi(self._handle, val, p)
    end
    return self
end

---增加敏捷
---@param val integer 增加的敏捷值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:addAgi(val, permanent)
    if (self._handle ~= nil) then
        local ib = (permanent ~= nil) and permanent or true
        cj.SetHeroAgi(self._handle, (cj.GetHeroAgi(self._handle, ib) or 0) + val, ib)
    end
    return self
end

--- 获取智力
---@param includeBonuses boolean|nil 是否包含加成（默认 true）
---@return integer
function Hero:getInt(includeBonuses)
    if (self._handle == nil) then return 0 end
    local ib = (includeBonuses ~= nil) and includeBonuses or true
    return cj.GetHeroInt(self._handle, ib)
end

--- 设置智力
---@param val integer 新智力值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:setInt(val, permanent)
    if (self._handle ~= nil) then
        local ib = (permanent ~= nil) and permanent or true
        cj.SetHeroInt(self._handle, val, ib)
    end
    return self
end

--- 增加智力
---@param val integer 增加的智力值
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:addInt(val, permanent)
    if (self._handle ~= nil) then
        local ib = (permanent ~= nil) and permanent or true
        cj.SetHeroInt(self._handle, (cj.GetHeroInt(self._handle, ib) or 0) + val, ib)
    end
    return self
end

--- 同时获取三项属性
---@param includeBonuses boolean|nil 是否包含加成（默认 true）
---@return integer, integer, integer
function Hero:getAttrs(includeBonuses)
    if (self._handle == nil) then return 0, 0, 0 end
    local ib = (includeBonuses ~= nil) and includeBonuses or true
    return cj.GetHeroStr(self._handle, ib),
           cj.GetHeroAgi(self._handle, ib),
           cj.GetHeroInt(self._handle, ib)
end

--- 同时设置三项属性
---@param strVal integer
---@param agiVal integer
---@param intVal integer
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:setAttrs(strVal, agiVal, intVal, permanent)
    if (self._handle ~= nil) then
        local p = (permanent ~= nil) and permanent or true
        cj.SetHeroStr(self._handle, strVal, p)
        cj.SetHeroAgi(self._handle, agiVal, p)
        cj.SetHeroInt(self._handle, intVal, p)
    end
    return self
end

--- 同时增加三项属性
---@param strVal integer
---@param agiVal integer
---@param intVal integer
---@param permanent boolean|nil 是否永久改变（默认 true）
---@return Hero
function Hero:addAttrs(strVal, agiVal, intVal, permanent)
    if (self._handle ~= nil) then
        local ib = (permanent ~= nil) and permanent or true
        cj.SetHeroStr(self._handle, (cj.GetHeroStr(self._handle, ib) or 0) + strVal, ib)
        cj.SetHeroAgi(self._handle, (cj.GetHeroAgi(self._handle, ib) or 0) + agiVal, ib)
        cj.SetHeroInt(self._handle, (cj.GetHeroInt(self._handle, ib) or 0) + intVal, ib)
    end
    return self
end


--- 获取总属性值（力量 + 敏捷 + 智力）
---@param includeBonuses boolean|nil 是否包含加成（默认 true）
---@return integer
function Hero:getTotalAttrs(includeBonuses)
    local str, agi, int = self:getAttrs(includeBonuses)
    return str + agi + int
end

-----------------------------------------------------------------
-- 主属性（DzAPI 扩展）
-----------------------------------------------------------------

--- 获取主属性基础值
---@return integer
function Hero:getPrimaryAttr()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetHeroPrimaryAttribute(self._handle, false)
end

--- 获取主属性总值（含加成）
---@return integer
function Hero:getPrimaryAttrTotal()
    if (self._handle == nil) or not JassDz["DzGetHeroPrimaryAttribute"] then return end
    return cdz.DzGetHeroPrimaryAttribute(self._handle, true)
end

--- 获取属性成长
---@param attrType integer 属性类型（Hero.PRIMARY_STR / AGI / INT）
---@return number
function Hero:getAttrGrowth(attrType)
    if (self._handle == nil) then return 0 end
    return cdz.DzGetHeroPrimaryAttributePlus(self._handle, attrType or Hero.PRIMARY_STR)
end

--- 获取主属性类型（0=力量 1=敏捷 2=智力）
---@return integer
function Hero:getPrimaryAttrType()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetHeroPrimaryAttributeType(self._handle)
end

--- 设置主属性基础值
---@param val integer
---@return Hero
function Hero:setPrimaryAttr(val)
    if (self._handle ~= nil) then
        cdz.DzSetHeroPrimaryAttribute(self._handle, val)
    end
    return self
end

--- 设置属性成长
---@param attrType integer 属性类型
---@param growth number 成长值
---@param add boolean|nil 是否累加（默认 false=覆盖）
---@return Hero
function Hero:setAttrGrowth(attrType, growth, add)
    if (self._handle ~= nil) then
        cdz.DzSetHeroPrimaryAttributePlus(self._handle, attrType or 0, growth, (add ~= nil) and add or false)
    end
    return self
end

--- 设置主属性类型
---@param attrType integer 0=力量 1=敏捷 2=智力
---@param add boolean|nil 是否累加修改（默认 false=覆盖）
---@return Hero
function Hero:setPrimaryAttrType(attrType, add)
    if (self._handle ~= nil) then
        cdz.DzSetHeroPrimaryAttributeType(self._handle, attrType or 0, (add ~= nil) and add or false)
    end
    return self
end

-----------------------------------------------------------------
-- 技能点数 / 学习技能
-----------------------------------------------------------------

--- 获取未分配技能点数
---@return integer
function Hero:getSkillPoints()
    if (self._handle == nil) then return 0 end
    return cj.GetHeroSkillPoints(self._handle)
end

--- 增加/减少技能点数
---@param delta integer 变化量（正数=增加，负数=减少）
---@return boolean
function Hero:modSkillPoints(delta)
    if (self._handle == nil) then return false end
    return cj.UnitModifySkillPoints(self._handle, delta or 1)
end

--- 学习技能
---@param abilCode integer|string 要学习的技能ID
---@return Hero
function Hero:learn(abilCode)
    if (self._handle == nil) then return self end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    cj.SelectHeroSkill(self._handle, abilCode)
    return self
end

--- 获取技能持续时间（DzAPI 扩展，英雄专属）
---@param abilCode integer|string
---@return number
function Hero:getAbilityHeroDuration(abilCode)
    if (self._handle == nil) then return 0 end
    if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
    return cdz.DzGetUnitAbilityHeroDuration(self._handle, abilCode)
end

--- 设置技能持续时间（DzAPI 扩展，英雄专属）
---@param abilCode integer|string
---@param duration number 持续时间
---@return Hero
function Hero:setAbilityHeroDuration(abilCode, duration)
    if (self._handle ~= nil) then
        if (type(abilCode) == "string") then abilCode = c2i(abilCode) end
        cdz.DzSetUnitAbilityHeroDuration(self._handle, abilCode, duration)
    end
    return self
end

-----------------------------------------------------------------
-- 复活
-----------------------------------------------------------------

--- 在指定坐标复活英雄
---@param x number
---@param y number
---@param doEyecandy boolean|nil 是否播放特效（默认 true）
---@return boolean
function Hero:revive(x, y, doEyecandy)
    if (self._handle == nil) then return false end
    local ec = (doEyecandy ~= nil) and doEyecandy or true
    return cj.ReviveHero(self._handle, x, y, ec)
end

--- 判断英雄是否死亡可复活
---@return boolean
function Hero:isRevivable()
    if (self._handle == nil) then return false end
    return cj.IsUnitType(self._handle, UNIT_TYPE_HERO) and cj.IsUnitType(self._handle, UNIT_TYPE_DEAD)
end

-----------------------------------------------------------------
-- 称谓
-----------------------------------------------------------------

--- 获取英雄称谓（如 "大魔法师"）
---@return string
function Hero:getProperName()
    if (self._handle == nil) then return "" end
    return cj.GetHeroProperName(self._handle)
end

--- 设置英雄称谓（DzAPI 扩展）
---@param name string
---@return Hero
function Hero:setProperName(name)
    if (self._handle ~= nil and name ~= nil) then
        cdz.DzSetUnitProperName(self._handle, name)
    end
    return self
end

-----------------------------------------------------------------
-- 平台接口
-----------------------------------------------------------------

--- 更新平台的玩家英雄数据（DzAPI 扩展）
---@return Hero
function Hero:updatePlayerHero()
    if (self._handle ~= nil) then
        cdz.DzAPI_Map_UpdatePlayerHero(cj.GetOwningPlayer(self._handle), self._handle)
    end
    return self
end

-----------------------------------------------------------------
-- 静态工具
-----------------------------------------------------------------

--- 判断指定单位ID是否为英雄类型
---@param unitId integer|string
---@return boolean
function Hero.isHeroType(unitId)
    if (unitId == nil) then return false end
    if (type(unitId) == "string") then unitId = c2i(unitId) end
    return cj.IsHeroUnitId(unitId)
end

--- 从Unit/Hero对象或handle创建Hero对象（自动判断是否为英雄）
---@param u Unit|Hero|userdata Unit/Hero对象 或 单位handle
---@return Hero|nil 非英雄单位返回nil
function Hero.fromUnit(u)
    if (u == nil) then return nil end
    if (type(u) == "table") then
        local mt = getmetatable(u)
        if (mt == Hero) then return u end
        if (mt == Unit) then
            local id = cj.GetUnitTypeId(u._handle)
            if (Hero.isHeroType(id)) then return Hero.fromHandle(u._handle) end
        end
        return nil
    end
    if (type(u) == "userdata") then
        local id = cj.GetUnitTypeId(u)
        if (Hero.isHeroType(id)) then return Hero.fromHandle(u) end
    end
    return nil
end

--- 获取英雄的HandleId
---@param h userdata 英雄handle
---@return integer
function Hero.handleId(h)
    if (h == nil) then return 0 end
    return cj.GetHandleId(h)
end

