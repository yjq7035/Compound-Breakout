-- ============================================================
-- Destroyable 类 — 可破坏物（基础 OOP 层）
-- 调用方式：
--   local d = Destroyable:new(x, y, typeId, facing, scale, variation)
--   local d = Destroyable:new(x, y, typeId)  -- 简写（默认 facing=0, scale=1, variation=0）
--   d:setLife(100)
--   d:takeDamage(30)
--   d:destroy()
--   local d = Destroyable.fromHandle(h)
-- ============================================================

---@class Destroyable 可破坏物
Destroyable = {}
Destroyable.__index = Destroyable

---@class DestroyableState 可破坏物状态
Destroyable._handle = nil
Destroyable._index = nil
Destroyable._id = nil

-- 生命值
Destroyable.life = 0
-- 最大生命值
Destroyable.maxLife = 0
-- 是否已破坏
Destroyable.isDestroyed = false

-- 可破坏物对象映射表（handle -> Destroyable）
local destroyableMap = {}

-- fromHandle 对象缓存
local fromHandleCache = {}

------------------------------------------------------------------
-- 内部工厂 / 工具
------------------------------------------------------------------

--- 创建可破坏物对象
---@return table
local function newDestroyable()
    local obj = { 
        _handle = nil, 
        _index = nil, 
        _id = nil,
        life = 0,
        maxLife = 0,
        isDestroyed = false
    }
    setmetatable(obj, Destroyable)
    return obj
end

------------------------------------------------------------------
-- 构造 / 销毁
------------------------------------------------------------------

--- 在指定坐标创建可破坏物
---@param x number X 坐标
---@param y number Y 坐标
---@param typeId string|integer 可破坏物对象 ID（如 'B000'）
---@param facing number|nil 面向角度（默认 0）
---@param scale number|nil 缩放比例（默认 1）
---@param variation integer|nil 变异类型（默认 0）
---@return Destroyable
function Destroyable:new(x, y, typeId, facing, scale, variation)
    if (x == nil or y == nil or typeId == nil) then return end
    
    local obj = newDestroyable()
    
    -- cj.CreateDestructable 参数：
    -- objectid(integer), x(real), y(real), face(real), scale(real), variation(integer)
    local handle = cj.CreateDestructable(c2i(typeId), x, y, facing or 0, scale or 1, variation or 0)
    
    if (handle == nil) then return end
    
    obj._handle = handle
    obj._index = cj.GetHandleId(handle)
    obj._id = typeId
    
    -- 默认生命值
    obj.maxLife = 100
    obj.life = 100
    
    -- 注册到映射表
    destroyableMap[obj._index] = obj
    fromHandleCache[obj._index] = obj
    
    -- 嵌入框架映射
    Unit.embed(obj._handle, { 
        id = obj._id,
        destroyable = obj._index 
    })
    
    return obj
end

--- 从已有 handle 创建 Destroyable 对象
---@param h userdata 可破坏物 handle
---@return Destroyable|nil
function Destroyable.fromHandle(h)
    if (h == nil) then return end
    local key = cj.GetHandleId(h)
    local cached = fromHandleCache[key]
    if cached and cached._handle == h then
        return cached
    end
    -- handle 已销毁或缓存失效，清理
    if destroyableMap[key] then
        destroyableMap[key] = nil
    end
    return nil
end

--- 销毁可破坏物
---@return Destroyable
function Destroyable:destroy()
    if (self._handle == nil) then return self end
    
    if self._index then
        -- 从缓存中移除
        fromHandleCache[self._index] = nil
        -- 从框架映射中清理
        Unit.removeData(self._handle)
        destroyableMap[self._index] = nil
    end
    
    -- cj.RemoveDestructable 删除可破坏物
    cj.RemoveDestructable(self._handle)
    self._handle = nil
    self.isDestroyed = true
    
    return self
end

--- 检查可破坏物是否有效
---@return boolean
function Destroyable:isValid()
    return self._handle ~= nil and not self.isDestroyed
end

--- 检查可破坏物是否已破坏
---@return boolean
function Destroyable:IsDestroyed()
    return self.isDestroyed
end

------------------------------------------------------------------
-- 生命值管理
------------------------------------------------------------------

--- 设置生命值
---@param life number 生命值
---@return Destroyable
function Destroyable:setLife(life)
    if (self._handle ~= nil and life ~= nil) then
        -- cj.SetDestructableLife 参数：destructable, lifeMax, lifeCur
        cj.SetDestructableLife(self._handle, cj.c2i("100"), cj.c2i(life))
        self.life = life
    end
    return self
end

--- 设置最大生命值
---@param maxLife number 最大生命值
---@return Destroyable
function Destroyable:setMaxLife(maxLife)
    if (self._handle ~= nil and maxLife > 0) then
        cj.SetDestructableLife(self._handle, cj.c2i(maxLife), cj.c2i(math.min(self.life, maxLife)))
        self.maxLife = maxLife
        self.life = math.min(self.life, maxLife)
    end
    return self
end

--- 增加生命值
---@param amount number 增加量
---@return Destroyable
function Destroyable:addLife(amount)
    if (self._handle ~= nil and amount > 0) then
        local newLife = math.min(self.maxLife, self.life + amount)
        cj.SetDestructableLife(self._handle, cj.c2i("100"), cj.c2i(newLife))
        self.life = newLife
    end
    return self
end

--- 减少生命值（等同于受到伤害）
---@param amount number 减少量
---@return Destroyable
function Destroyable:subLife(amount)
    return self:takeDamage(amount)
end

------------------------------------------------------------------
-- 伤害系统
------------------------------------------------------------------

--- 受到伤害
---@param dmg number 伤害值
---@return Destroyable
function Destroyable:takeDamage(dmg)
    if (self._handle == nil or self.isDestroyed) then return self end
    
    -- 应用伤害
    self.life = self.life - dmg
    
    -- 检查是否死亡
    if (self.life <= 0) then
        self.life = 0
        self:destroy()
    end
    
    return self
end

--- 受到穿透伤害（无视防御）
---@param dmg number 伤害值
---@return Destroyable
function Destroyable:takePierceDamage(dmg)
    if (self._handle == nil or self.isDestroyed) then return self end
    
    self.life = self.life - dmg
    
    if (self.life <= 0) then
        self.life = 0
        self:destroy()
    end
    
    return self
end

--- 受到致命伤害（直接销毁）
---@param dmg number 伤害值
---@return Destroyable
function Destroyable:takeFatalDamage(dmg)
    if (self._handle == nil) then return self end
    
    self:destroy()
    return self
end

--- 修复生命值
---@param heal number 治疗量
---@return Destroyable
function Destroyable:heal(heal)
    if (self._handle == nil or self.isDestroyed) then return self end
    
    self.life = math.min(self.maxLife, self.life + heal)
    cj.SetDestructableLife(self._handle, cj.c2i("100"), cj.c2i(self.life))
    return self
end

--- 复活可破坏物（从死亡状态恢复生命）
---@param life number 生命值
---@param birth boolean 是否重生成
---@return Destroyable
function Destroyable:restoreLife(life, birth)
    if (self._handle == nil) then return self end
    
    -- cj.DestructableRestoreLife 参数：destructable, life, birth
    cj.DestructableRestoreLife(self._handle, life or 100, birth or true)
    self.life = life or 100
    return self
end

--- 获取当前生命值百分比
---@return number 0-100
function Destroyable:getLifePercent()
    if (self.maxLife == 0) then return 0 end
    return (self.life / self.maxLife) * 100
end

--- 获取剩余生命值
---@return number
function Destroyable:getRemainingLife()
    return self.life
end

--- 获取最大生命值
---@return number
function Destroyable:getMaxLife()
    return self.maxLife
end

------------------------------------------------------------------
-- 特效系统
------------------------------------------------------------------

--- 显示受伤特效
---@param effectName string 特效名称（如 "spell_lightning"）
---@return Destroyable
function Destroyable:onDamage(effectName)
    if (self._handle == nil or self.isDestroyed) then return self end
    
    -- cj.AddSpecialEffectTarget 参数：
    -- modelName(string), targetWidget(widget), attachPoint(string)
    local effect = cj.AddSpecialEffectTarget(effectName, self._handle, "TOP")
    if (effect ~= nil) then
        Timer:new(0.5, false, function()
            if effect ~= nil then
                effect:destroy()
                effect = nil
            end
        end)
    end
    
    return self
end

--- 显示破坏特效
---@param effectName string 特效名称（如 "titleboom"）
---@return Destroyable
function Destroyable:onDestroy(effectName)
    if (self._handle == nil) then return self end
    
    -- cj.AddSpecialEffectTarget 参数：
    -- modelName(string), targetWidget(widget), attachPoint(string)
    local effect = cj.AddSpecialEffectTarget(effectName, self._handle, "BOTTOM")
    if (effect ~= nil) then
        Timer:new(0.3, false, function()
            if effect ~= nil then
                effect:destroy()
                effect = nil
            end
        end)
    end
    
    return self
end

--- 获取可破坏物对象（通过 handle）
---@param h userdata 可破坏物 handle
---@return Destroyable|nil
function Destroyable.get(h)
    if (h == nil) then return end
    local key = cj.GetHandleId(h)
    return destroyableMap[key]
end
