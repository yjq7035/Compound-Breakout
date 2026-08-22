-- ============================================================
-- Lightning 类 — 闪电效果
-- 通过 common.lua / KK_japi.lua 已注册函数封装
-- 调用方式：
--   local l = Lightning:new("CLPB", false, 0, 0, 512, 512)
--   l:setColor(1, 0, 0, 1)
--   l:move(false, 0, 0, 256, 256)
--   l:destroy()
-- ============================================================
LIGHTNING_CLPB = "CLPB" -- 闪电链主
LIGHTNING_CLSB = "CLSB" -- 闪电链次
LIGHTNING_DRAB = "DRAB" -- 汲取
LIGHTNING_DRAL = "DRAL" -- 生命汲取
LIGHTNING_DRAM = "DRAM" -- 魔法汲取
LIGHTNING_AFOD = "AFOD" -- 死亡之指
LIGHTNING_FORK = "FORK" -- 叉状闪电
LIGHTNING_HWPB = "HWPB" -- 医疗波主
LIGHTNING_HWSB = "HWSB" -- 医疗波次
LIGHTNING_CHIM = "CHIM" -- 闪电攻击
LIGHTNING_LEAS = "LEAS" -- 魔法镣枷
LIGHTNING_MBUR = "MBUR" -- 法力燃烧
LIGHTNING_MFPB = "MFPB" -- 魔力之焰
LIGHTNING_SPLK = "SPLK" -- 灵魂锁链


---@class Lightning 闪电效果
Lightning = {}
Lightning.__index = Lightning
Lightning._handle = nil

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newLightning()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Lightning)
    return obj
end

-----------------------------------------------------------------
-- 构造 / 销毁
-----------------------------------------------------------------

--- 创建闪电效果（2D）
---@param codeName string 闪电类型码，如 "CLPB"
---@param checkVisibility boolean 是否检测可见性
---@param x1 number 起点X
---@param y1 number 起点Y
---@param x2 number 终点X
---@param y2 number 终点Y
---@return Lightning
function Lightning:new(codeName, checkVisibility, x1, y1, x2, y2)
    if (codeName == nil or checkVisibility == nil or x1 == nil or y1 == nil or x2 == nil or y2 == nil) then return end
    local obj = newLightning()
    obj._handle = cj.AddLightning(codeName, checkVisibility, x1, y1, x2, y2)
    return obj
end

--- 创建闪电效果（3D，指定Z轴）
---@param codeName string 闪电类型码
---@param checkVisibility boolean
---@param x1 number 起点X
---@param y1 number 起点Y
---@param z1 number 起点Z
---@param x2 number 终点X
---@param y2 number 终点Y
---@param z2 number 终点Z
---@return Lightning
function Lightning:newEx(codeName, checkVisibility, x1, y1, z1, x2, y2, z2)
    if (codeName == nil or checkVisibility == nil) then return end
    if (x1 == nil or y1 == nil or z1 == nil or x2 == nil or y2 == nil or z2 == nil) then return end
    local obj = newLightning()
    obj._handle = cj.AddLightningEx(codeName, checkVisibility, x1, y1, z1, x2, y2, z2)
    return obj
end

--- 从已有 handle 创建 Lightning 对象
---@param h userdata lightning handle
---@return Lightning
function Lightning.fromHandle(h)
    if (h == nil) then return end
    local obj = newLightning()
    obj._handle = h
    return obj
end

--- 销毁闪电效果
---@return Lightning
function Lightning:destroy()
    if (self._handle ~= nil) then
        cj.DestroyLightning(self._handle)
        self._handle = nil
    end
    return self
end

-----------------------------------------------------------------
-- 移动
-----------------------------------------------------------------

--- 移动闪电（2D）
---@param checkVisibility boolean
---@param x1 number 起点X
---@param y1 number 起点Y
---@param x2 number 终点X
---@param y2 number 终点Y
---@return boolean
function Lightning:move(checkVisibility, x1, y1, x2, y2)
    if (self._handle == nil) then return false end
    return cj.MoveLightning(self._handle, checkVisibility, x1, y1, x2, y2)
end

--- 移动闪电（3D，指定Z轴）
---@param checkVisibility boolean
---@param x1 number 起点X
---@param y1 number 起点Y
---@param z1 number 起点Z
---@param x2 number 终点X
---@param y2 number 终点Y
---@param z2 number 终点Z
---@return boolean
function Lightning:moveEx(checkVisibility, x1, y1, z1, x2, y2, z2)
    if (self._handle == nil) then return false end
    return cj.MoveLightningEx(self._handle, checkVisibility, x1, y1, z1, x2, y2, z2)
end

-----------------------------------------------------------------
-- 颜色控制
-----------------------------------------------------------------

--- 设置颜色
---@param r number 红 0~1
---@param g number 绿 0~1
---@param b number 蓝 0~1
---@param a number Alpha 0~1
---@return boolean
function Lightning:setColor(r, g, b, a)
    if (self._handle == nil) then return false end
    return cj.SetLightningColor(self._handle, r, g, b, a)
end

--- 获取红色值
---@return number
function Lightning:getColorR()
    if (self._handle == nil) then return 0 end
    return cj.GetLightningColorR(self._handle)
end

--- 获取绿色值
---@return number
function Lightning:getColorG()
    if (self._handle == nil) then return 0 end
    return cj.GetLightningColorG(self._handle)
end

--- 获取蓝色值
---@return number
function Lightning:getColorB()
    if (self._handle == nil) then return 0 end
    return cj.GetLightningColorB(self._handle)
end

--- 获取Alpha值
---@return number
function Lightning:getColorA()
    if (self._handle == nil) then return 0 end
    return cj.GetLightningColorA(self._handle)
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存闪电效果 handle 到哈希表
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@return boolean
function Lightning:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveLightningHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取闪电效果并返回 Lightning 对象
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@return Lightning
function Lightning.loadHandle(t, pk, ck)
    local h = cj.LoadLightningHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newLightning()
    obj._handle = h
    return obj
end
