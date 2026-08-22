-- ============================================================
-- Texture / Ubersplat 类 — 纹理与地面纹理变化
-- 通过 common.lua / KK_japi.lua 已注册函数封装
-- 调用方式：
--   local u = Ubersplat:new(0, 0, "Splat01", 255, 0, 0, 255, false, false)
--   u:show(true)
--   u:destroy()
--   local z = Texture.getZ(512, 512)
-- ============================================================

-----------------------------------------------------------------
-- Texture — 地形纹理工具（静态）
-----------------------------------------------------------------

---@class Texture 地形纹理工具（静态）
Texture = {}
Texture.__index = Texture
Texture._handle = nil


--- 获取地形 Z 轴高度
---@param x number
---@param y number
---@return number
function Texture.getZ(x, y)
    return cdz.DzGetTerrainZ(x, y)
end

--- 获取地形悬崖高度
---@param x number
---@param y number
---@return integer
function Texture.getCliffLevel(x, y)
    return cj.GetTerrainCliffLevel(x, y)
end

--- 获取指定坐标地形类型
---@param x number
---@param y number
---@return integer
function Texture.getType(x, y)
    return cj.GetTerrainType(x, y)
end

--- 获取地形样式（同类型下的变体）
---@param x number
---@param y number
---@return integer
function Texture.getVariance(x, y)
    return cj.GetTerrainVariance(x, y)
end

--- 改变地形类型
---@param x number
---@param y number
---@param terrainType integer 地形ID
---@param variation integer 变体
---@param area integer 影响区域大小
---@param shape integer 形状
function Texture.setType(x, y, terrainType, variation, area, shape)
    if (terrainType == nil) then return end
    cj.SetTerrainType(x, y, terrainType, variation or 0, area or 1, shape)
end

--- 直接替换地形（更新外显与通行数据）
---@param x integer
---@param y integer
---@param typeId integer 地形类型码
---@param variation integer 变体
---@param area real 影响半径
function Texture.change(x, y, typeId, variation, area)
    if (typeId == nil) then return end
    cdz.DzChangeTerrain(x, y, typeId, variation or 0, area or 1)
end

--- 设置昼夜模型（地形 + 单位）
---@param terrainDNC string 地形日夜模型文件
---@param unitDNC string 单位日夜模型文件
function Texture.setDayNightModels(terrainDNC, unitDNC)
    if (terrainDNC == nil or unitDNC == nil) then return end
    cj.SetDayNightModels(terrainDNC, unitDNC)
end

--- 设置天空模型
---@param skyModel string 天空模型文件
function Texture.setSky(skyModel)
    if (skyModel == nil) then return end
    cj.SetSkyModel(skyModel)
end

--- 替换单位贴图
---@param unit userdata
---@param texturePath string 贴图路径
---@param texId integer 贴图索引（0为主贴图）
function Texture.setUnitTexture(unit, texturePath, texId)
    if (unit == nil or texturePath == nil) then return end
    cdz.DzSetUnitTexture(unit, texturePath, texId or 0)
end


-----------------------------------------------------------------
-- Ubersplat 类 — 地面纹理变化
-- ============================================================
-- 地面纹理是一个覆盖在地形上的半透明材质层，
-- 可控制显示/隐藏、渲染、生命周期等。
-- 调用方式：
--   local u = Ubersplat:new(0, 0, "Splat01", 255, 255, 255, 255)
--   u:show(true)
--   u:finish()
--   u:destroy()
-- ============================================================

---@class Ubersplat 地面纹理变化
Ubersplat = {}
Ubersplat.__index = Ubersplat

local function newUbersplat()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Ubersplat)
    return obj
end

--- 创建地面纹理变化
---@param x number X坐标
---@param y number Y坐标
---@param name string 纹理名称（如 "Splat01"）
---@param r integer 红 0-255
---@param g integer 绿 0-255
---@param b integer 蓝 0-255
---@param a integer Alpha 0-255
---@param forcePaused boolean|nil true=创建时暂停
---@param noBirthTime boolean|nil true=无出生动画
---@return Ubersplat
function Ubersplat:new(x, y, name, r, g, b, a, forcePaused, noBirthTime)
    if (x == nil or y == nil or name == nil) then return end
    if (r == nil or g == nil or b == nil or a == nil) then return end
    local obj = newUbersplat()
    obj._handle = cj.CreateUbersplat(x, y, name, r, g, b, a,
        (forcePaused ~= nil) and forcePaused or false,
        (noBirthTime ~= nil) and noBirthTime or false)
    return obj
end

--- 从已有 handle 创建 Ubersplat 对象
---@param h userdata ubersplat handle
---@return Ubersplat
function Ubersplat.fromHandle(h)
    if (h == nil) then return end
    local obj = newUbersplat()
    obj._handle = h
    return obj
end

--- 销毁地面纹理变化
---@return Ubersplat
function Ubersplat:destroy()
    if (self._handle ~= nil) then
        cj.DestroyUbersplat(self._handle)
        self._handle = nil
    end
    return self
end

--- 结束地面纹理变化（播放结束动画）
---@return Ubersplat
function Ubersplat:finish()
    if (self._handle ~= nil) then
        cj.FinishUbersplat(self._handle)
    end
    return self
end

--- 重置地面纹理变化（重新播放出生动画）
---@return Ubersplat
function Ubersplat:reset()
    if (self._handle ~= nil) then
        cj.ResetUbersplat(self._handle)
    end
    return self
end

--- 显示/隐藏
---@param flag boolean
---@return Ubersplat
function Ubersplat:show(flag)
    if (self._handle ~= nil) then
        cj.ShowUbersplat(self._handle, (flag ~= nil) and flag or true)
    end
    return self
end

--- 隐藏
---@return Ubersplat
function Ubersplat:hide()
    return self:show(false)
end

--- 设置渲染状态
---@param flag boolean
---@return Ubersplat
function Ubersplat:setRender(flag)
    if (self._handle ~= nil) then
        cj.SetUbersplatRender(self._handle, (flag ~= nil) and flag or true)
    end
    return self
end

--- 设置永久渲染（屏幕外也渲染）
---@param flag boolean
---@return Ubersplat
function Ubersplat:setRenderAlways(flag)
    if (self._handle ~= nil) then
        cj.SetUbersplatRenderAlways(self._handle, (flag ~= nil) and flag or true)
    end
    return self
end

--- 保存 ubersplat handle 到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Ubersplat:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveUbersplatHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取 ubersplat handle 并返回 Ubersplat 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Ubersplat
function Ubersplat.loadHandle(t, pk, ck)
    local h = cj.LoadUbersplatHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newUbersplat()
    obj._handle = h
    return obj
end
