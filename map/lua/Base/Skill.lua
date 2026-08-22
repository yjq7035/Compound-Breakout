-- ============================================================
-- Skill 类 — 单位技能操作
-- 通过 common.lua / KK_japi.lua 已注册函数封装
-- 调用方式：
--   local s = Skill:new(unit, FourCC("AHbz"))
--   s:setLevel(3)
--   s:disable()
--   s:setManaCost(75)
--   s:enable()
--   s:resetCooldown()
--   s:remove()
-- ============================================================

---@class Skill 单位技能
Skill = {
    _handle = nil,
    _index = 0,
    _unit = nil,
    _abilityId = 0,
}
Skill.__index = Skill
Skill._handle = nil

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newSkill()
    local obj = { _handle = nil, _index = 0, _unit = nil, _abilityId = 0 }
    setmetatable(obj, Skill)
    return obj
end

-----------------------------------------------------------------
-- 构造
-----------------------------------------------------------------

--- 创建一个 Skill 对象，代表指定单位上的某个技能
---@param unit userdata 单位
---@param abilityId integer 技能ID（可用 FourCC 转换）
---@return Skill
function Skill:new(unit, abilityId)
    if (unit == nil) then return end
    local obj = newSkill()
    obj._unit = unit
    obj._abilityId = abilityId
    return obj
end

--- 从已有技能 handle 创建 Skill 对象
---@param h userdata ability handle
---@param unit userdata 对应的单位
---@param abilityId integer|nil 技能ID（可省略，传入后内部会尝试获取）
---@return Skill
function Skill.fromHandle(h, unit, abilityId)
    if (h == nil or unit == nil) then return end
    local obj = newSkill()
    obj._handle = h
    obj._unit = unit
    obj._abilityId = abilityId or cdz.EXGetAbilityId(h)
    return obj
end

-----------------------------------------------------------------
-- 静态：添加 / 移除 / 查询
-----------------------------------------------------------------

--- 给单位添加技能
---@param unit Unit
---@return boolean
function Skill:add(unit)
    if (unit == nil) then return false end
    return cj.UnitAddAbility(unit, self._handle)
end

--- 从单位移除技能
---@param unit Unit
---@return boolean
function Skill:remove(unit)
    if (unit == nil) then return false end
    return cj.UnitRemoveAbility(unit, self._handle)
end

--- 单位是否拥有该技能
---@param unit Unit
---@return boolean
function Skill:has(unit)
    if (unit == nil) then return false end
    return cdz.DzUnitHasAbility(unit, self._handle)
end

--- 查找单位上的技能 handle
---@param unit Unit
---@return userdata|nil ability handle
function Skill:find(unit)
    if (unit == nil) then return nil end
    return cdz.DzUnitFindAbility(unit, self._handle)
end

--- 设置技能永久性
---@param unit Unit
---@param permanent boolean
---@return boolean
function Skill:setPermanent(unit, permanent)
    if (unit == nil) then return false end
    return cj.UnitMakeAbilityPermanent(unit, permanent, self._handle)
end

--- 重置单位所有技能冷却
---@param unit Unit
function Skill:resetAllCooldown(unit)
    if (unit == nil) then return end
    cj.UnitResetCooldown(unit)
end

--- 获取单位的普攻技能 handle
---@param unit Unit
---@return userdata|nil
function Skill:getAttackAbility(unit)
    if (unit == nil) then return nil end
    return cdz.DzGetAttackAbility(unit)
end

--- 结束普攻技能CD
---@param unit Unit
function Skill:endAttackCooldown(unit)
    if (unit == nil) then return end
    cdz.DzAttackAbilityEndCooldown(unit)
end

--- 英雄学习技能
---@param unit Unit
function Skill:selectHeroSkill(unit)
    if (unit == nil) then return end
    cj.SelectHeroSkill(unit, self._handle)
end

--- 修改英雄剩余技能点数（正数增加，负数减少）
---@param unit Unit
---@param delta integer
---@return integer 新的技能点数
function Skill:modifyHeroSkillPoints(unit, delta)
    if (unit == nil or delta == nil) then return 0 end
    return cj.UnitModifySkillPoints(unit, delta)
end

--- 设置玩家某一技能是否允许使用
---@param player Unit
---@param allows boolean
function Skill:setPlayerAvailable(player, allows)
    if (player == nil) then return end
    cj.SetPlayerAbilityAvailable(player, self._handle, allows)
end

-----------------------------------------------------------------
-- 实例方法：存在性检查
-----------------------------------------------------------------

--- 获取内部 ability handle
--- 如果未缓存，通过 DzUnitFindAbility 查找
---@return userdata|nil
function Skill:getHandle()
    if (self._handle ~= nil) then
        return self._handle
    end
    if (self._unit == nil or self._abilityId == 0) then return nil end
    local h = cdz.DzUnitFindAbility(self._unit, self._abilityId)
    if (h ~= nil) then
        self._handle = h
    end
    return self._handle
end

--- 该技能在单位上是否存在（handle 有效）
---@return boolean
function Skill:exists()
    return self:getHandle() ~= nil
end

--- 获取单位
---@return userdata
function Skill:getUnit()
    return self._unit
end

--- 获取技能ID
---@return integer
function Skill:getAbilityId()
    return self._abilityId
end

-----------------------------------------------------------------
-- 实例方法：等级
-----------------------------------------------------------------

--- 获取当前技能等级
---@return integer
function Skill:getLevel()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cj.GetUnitAbilityLevel(self._unit, self._abilityId)
end

--- 设置技能等级
---@param level integer
---@return Skill
function Skill:setLevel(level)
    if (self._unit ~= nil and self._abilityId ~= 0 and level ~= nil) then
        cj.SetUnitAbilityLevel(self._unit, self._abilityId, level)
    end
    return self
end

--- 提升一级
---@return integer 新等级
function Skill:incLevel()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cj.IncUnitAbilityLevel(self._unit, self._abilityId)
end

--- 降低一级
---@return integer 新等级
function Skill:decLevel()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cj.DecUnitAbilityLevel(self._unit, self._abilityId)
end

-----------------------------------------------------------------
-- 实例方法：冷却
-----------------------------------------------------------------

--- 获取当前冷却剩余时间
---@return number
function Skill:getCooldown()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityCool(self._unit, self._abilityId)
end

--- 设置当前冷却时间
---@param cool number
---@return Skill
function Skill:setCooldown(cool)
    if (self._unit ~= nil and self._abilityId ~= 0 and cool ~= nil) then
        cdz.DzSetUnitAbilityCool(self._unit, self._abilityId, cool, cool)
    end
    return self
end

--- 获取最大冷却时间
---@return number
function Skill:getMaxCooldown()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityMaxCool(self._unit, self._abilityId)
end

--- 重置此技能冷却
---@return Skill
function Skill:resetCooldown()
    if (self._unit ~= nil and self._abilityId ~= 0) then
        cdz.DzSetUnitAbilityCool(self._unit, self._abilityId, 0, 0)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：魔法消耗
-----------------------------------------------------------------

--- 获取魔法消耗
---@return integer
function Skill:getManaCost()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityCost(self._unit, self._abilityId)
end

--- 设置魔法消耗
---@param cost integer
---@return Skill
function Skill:setManaCost(cost)
    if (self._unit ~= nil and self._abilityId ~= 0 and cost ~= nil) then
        cdz.DzSetUnitAbilityCost(self._unit, self._abilityId, cost)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：距离 / 范围
-----------------------------------------------------------------

--- 获取施法距离
---@return number
function Skill:getRange()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityRange(self._unit, self._abilityId)
end

--- 设置施法距离
---@param range number
---@return Skill
function Skill:setRange(range)
    if (self._unit ~= nil and self._abilityId ~= 0 and range ~= nil) then
        cdz.DzSetUnitAbilityRange(self._unit, self._abilityId, range)
    end
    return self
end

--- 获取技能作用范围（AoE）
---@return number
function Skill:getArea()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityArea(self._unit, self._abilityId)
end

--- 设置技能作用范围（AoE）
---@param area number
---@return Skill
function Skill:setArea(area)
    if (self._unit ~= nil and self._abilityId ~= 0 and area ~= nil) then
        cdz.DzSetUnitAbilityArea(self._unit, self._abilityId, area)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：启用 / 禁用
-----------------------------------------------------------------

--- 禁用技能
---@return Skill
function Skill:disable()
    if (self._unit ~= nil and self._abilityId ~= 0) then
        cdz.DzSetUnitAbilityDisable(self._unit, self._abilityId)
    end
    return self
end

--- 启用技能
---@return Skill
function Skill:enable()
    if (self._unit ~= nil and self._abilityId ~= 0) then
        cdz.DzSetUnitAbilityEnable(self._unit, self._abilityId)
    end
    return self
end

--- 判断技能是否被禁用
---@return boolean
function Skill:isDisabled()
    if (self._unit == nil or self._abilityId == 0) then return false end
    return cdz.DzGetUnitAbilityIsDisabled(self._unit, self._abilityId)
end

--- 设置禁用计数（单位被禁用该技能的次数）
---@return integer
function Skill:getDisabledCount()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityDisabledCount(self._unit, self._abilityId)
end

-----------------------------------------------------------------
-- 实例方法：图标 / 提示
-----------------------------------------------------------------

--- 获取技能图标路径
---@return string
function Skill:getIcon()
    if (self._unit == nil or self._abilityId == 0) then return "" end
    return cdz.DzGetUnitAbilityArt(self._unit, self._abilityId)
end

--- 设置技能图标
---@param art string 路径
---@return Skill
function Skill:setIcon(art)
    if (self._unit ~= nil and self._abilityId ~= 0 and art ~= nil) then
        cdz.DzSetUnitAbilityArt(self._unit, self._abilityId, art)
    end
    return self
end

--- 获取技能提示
---@return string
function Skill:getTooltip()
    if (self._unit == nil or self._abilityId == 0) then return "" end
    return cdz.DzGetUnitAbilityTip(self._unit, self._abilityId)
end

--- 设置技能提示
---@param tip string
---@return Skill
function Skill:setTooltip(tip)
    if (self._unit ~= nil and self._abilityId ~= 0 and tip ~= nil) then
        cdz.DzSetUnitAbilityTip(self._unit, self._abilityId, tip)
    end
    return self
end

--- 获取技能提示（扩展）
---@return string
function Skill:getExtendedTip()
    if (self._unit == nil or self._abilityId == 0) then return "" end
    return cdz.DzGetUnitAbilityUberTip(self._unit, self._abilityId)
end

--- 设置技能提示（扩展）
---@param tip string
---@return Skill
function Skill:setExtendedTip(tip)
    if (self._unit ~= nil and self._abilityId ~= 0 and tip ~= nil) then
        cdz.DzSetUnitAbilityUberTip(self._unit, self._abilityId, tip)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：施法前后摇 / 持续时间
-----------------------------------------------------------------

--- 获取施法前摇
---@return number
function Skill:getCastPoint()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityCastPoint(self._unit, self._abilityId)
end

--- 设置施法前摇
---@param point number
---@return Skill
function Skill:setCastPoint(point)
    if (self._unit ~= nil and self._abilityId ~= 0 and point ~= nil) then
        cdz.DzSetUnitAbilityCastPoint(self._unit, self._abilityId, point)
    end
    return self
end

--- 获取施法后摇（施法回复）
---@return number
function Skill:getBackSwing()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityBackSwing(self._unit, self._abilityId)
end

--- 设置施法后摇（施法回复）
---@param swing number
---@return Skill
function Skill:setBackSwing(swing)
    if (self._unit ~= nil and self._abilityId ~= 0 and swing ~= nil) then
        cdz.DzSetUnitAbilityBackSwing(self._unit, self._abilityId, swing)
    end
    return self
end

--- 获取技能持续时间（普通）
---@return number
function Skill:getDuration()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityDuration(self._unit, self._abilityId)
end

--- 设置技能持续时间（普通）
---@param duration number
---@return Skill
function Skill:setDuration(duration)
    if (self._unit ~= nil and self._abilityId ~= 0 and duration ~= nil) then
        cdz.DzSetUnitAbilityDuration(self._unit, self._abilityId, duration)
    end
    return self
end

--- 获取技能持续时间（英雄）
---@return number
function Skill:getHeroDuration()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityHeroDuration(self._unit, self._abilityId)
end

--- 设置技能持续时间（英雄）
---@param duration number
---@return Skill
function Skill:setHeroDuration(duration)
    if (self._unit ~= nil and self._abilityId ~= 0 and duration ~= nil) then
        cdz.DzSetUnitAbilityHeroDuration(self._unit, self._abilityId, duration)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：按钮位置 / 命令ID
-----------------------------------------------------------------

--- 设置技能按钮位置
---@param pos integer 0~11
---@return Skill
function Skill:setButtonPos(pos)
    if (self._unit ~= nil and self._abilityId ~= 0 and pos ~= nil) then
        cdz.DzSetUnitAbilityButtonPos(self._unit, self._abilityId, pos)
    end
    return self
end

--- 获取命令ID
---@return integer
function Skill:getOrderId()
    if (self._unit == nil or self._abilityId == 0) then return 0 end
    return cdz.DzGetUnitAbilityOrderId(self._unit, self._abilityId)
end

-----------------------------------------------------------------
-- 实例方法：刷新 UI
-----------------------------------------------------------------

--- 刷新技能显示（调用后生效修改）
---@return Skill
function Skill:update()
    if (self._unit ~= nil and self._abilityId ~= 0) then
        cdz.DzSetUnitAbilityUpdate(self._unit, self._abilityId)
    end
    return self
end

-----------------------------------------------------------------
-- 实例方法：移除
-----------------------------------------------------------------

--- 从单位移除该技能
---@return Skill
function Skill:remove()
    if (self._unit ~= nil and self._abilityId ~= 0) then
        cj.UnitRemoveAbility(self._unit, self._abilityId)
    end
    return self
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存技能 handle 到哈希表
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@return boolean
function Skill:saveHandle(t, pk, ck)
    local h = self:getHandle()
    if (h == nil) then return false end
    return cj.SaveAbilityHandle(t, pk, ck, h)
end

--- 从哈希表读取技能 handle，并还原到指定单位
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@param unit userdata 技能所属单位
---@return Skill
function Skill.loadHandle(t, pk, ck, unit)
    local h = cj.LoadAbilityHandle(t, pk, ck)
    if (h == nil or unit == nil) then return end
    local obj = newSkill()
    obj._handle = h
    obj._unit = unit
    obj._abilityId = cdz.EXGetAbilityId(h)
    return obj
end
