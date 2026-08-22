-- ============================================================
-- Terrain / Doodad / TerrainDeform 类 — 地形与装饰物
-- 通过 common.lua / KK_japi.lua 已注册函数封装
-- 调用方式：
--   local t = Terrain.getType(0, 0)
--   local ok = Terrain.isWalkable(512, 512)
--   local d = Doodad:new(FourCC("LTlt"), 0, 0, 0, 0, 1)
--   d:setColor(0xFFFF0000)
--   d:remove()
-- ============================================================

-----------------------------------------------------------------
-- TERRAIN — 地形类型常量表
-----------------------------------------------------------------

--- 地形类型ID（默认16个，修改过地形的请自行补充）
TERRAIN = {
    LORDS_DIRT          = c2i('Ldrt'),  -- 洛丹伦(夏) 泥地
    LORDS_DIRTROUGH     = c2i('Ldro'),  -- 洛丹伦(夏) 坑洼泥土
    LORDS_DIRTGRASS     = c2i('Ldrg'),  -- 洛丹伦(夏) 草色泥土
    LORDS_ROCK          = c2i('Lrok'),  -- 洛丹伦(夏) 岩石
    LORDS_GRASS         = c2i('Lgrs'),  -- 洛丹伦(夏) 草地
    LORDS_GRASSDARK     = c2i('Lgrd'),  -- 洛丹伦(夏) 深色草地
    CITY_DIRTROUGH      = c2i('Ydtr'),  -- 城邦 坑洼泥土
    CITY_BLACKMARBLE    = c2i('Yblm'),  -- 城邦 黑色大理石
    CITY_BRICKTILES     = c2i('Ybtl'),  -- 城邦 砖
    CITY_ROUNDTILES     = c2i('Yrtl'),  -- 城邦 圆形地形
    CITY_GRASS          = c2i('Ygsb'),  -- 城邦 草地
    CITY_GRASSTRIM      = c2i('Yhdg'),  -- 城邦 平整草地
    CITY_WHITEMARBLE    = c2i('Ywmb'),  -- 城邦 白色大理石
    DALARAN_DIRTROUGH   = c2i('Xdtr'),  -- 达拉然 坑洼泥土
    DALARAN_BLACKMARBLE = c2i('Xblm'),  -- 达拉然 黑色大理石
    DALARAN_BRICKTILES  = c2i('Xbtl'),  -- 达拉然 砖
}

-----------------------------------------------------------------
-- Terrain — 地形工具（静态）
-----------------------------------------------------------------

---@class Terrain 地形工具（静态）
Terrain = {}

-----------------------------------------------------------------
-- 地形查询
-----------------------------------------------------------------

--- 获取指定坐标的地形类型
---@param x number
---@param y number
---@return integer
function Terrain.getType(x, y)
    return cj.GetTerrainType(x, y)
end

--- 获取地形样式（同一类型下的变体编号）
---@param x number
---@param y number
---@return integer
function Terrain.getVariance(x, y)
    return cj.GetTerrainVariance(x, y)
end

--- 获取地形悬崖高度
---@param x number
---@param y number
---@return integer
function Terrain.getCliffLevel(x, y)
    return cj.GetTerrainCliffLevel(x, y)
end

--- 获取地形 Z 轴高度
---@param x number
---@param y number
---@return number
function Terrain.getZ(x, y)
    return cdz.DzGetTerrainZ(x, y)
end

--- 检查坐标是否与指定地形类型匹配
---@param x number
---@param y number
---@param terrainType integer
---@return boolean
function Terrain.isType(x, y, terrainType)
    return Terrain.getType(x, y) == terrainType
end

-----------------------------------------------------------------
-- 地形类型修改
-----------------------------------------------------------------

--- 改变地形类型（更新外显）
---@param x number
---@param y number
---@param terrainType integer 地形类型ID
---@param variation integer|nil 变体
---@param area integer|nil 影响区域大小
---@param shape integer|nil 形状
function Terrain.setType(x, y, terrainType, variation, area, shape)
    if (terrainType == nil) then return end
    cj.SetTerrainType(x, y, terrainType, variation or 0, area or 1, shape)
end

--- 直接替换地形（更新外显与通行数据，KK扩展）
---@param x integer
---@param y integer
---@param typeId integer 地形类型码
---@param variation integer|nil 变体
---@param area real|nil 影响半径
function Terrain.change(x, y, typeId, variation, area)
    if (typeId == nil) then return end
    cdz.DzChangeTerrain(x, y, typeId, variation or 0, area or 1)
end

-----------------------------------------------------------------
-- 通行状态
-----------------------------------------------------------------

--- 指定坐标是否可通行（指定路径类型）
---@param x number
---@param y number
---@param pathingType pathingtype 路径类型
---@return boolean
function Terrain.isPathable(x, y, pathingType)
    if (pathingType == nil) then return false end
    return not cj.IsTerrainPathable(x, y, pathingType)
end

--- 是否可步行
---@param x number
---@param y number
---@return boolean
function Terrain.isWalkable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
end

--- 是否可飞行通行
---@param x number
---@param y number
---@return boolean
function Terrain.isFlyable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_FLYABILITY)
end

--- 是否水面可通行（可漂浮）
---@param x number
---@param y number
---@return boolean
function Terrain.isFloatable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
end

--- 是否两栖可通行
---@param x number
---@param y number
---@return boolean
function Terrain.isAmphibious(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_AMPHIBIOUSPATHING)
end

--- 是否可建造
---@param x number
---@param y number
---@return boolean
function Terrain.isBuildable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_BUILDABILITY)
end

--- 是否荒芜地表可通行
---@param x number
---@param y number
---@return boolean
function Terrain.isBlightPathable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_BLIGHTPATHING)
end

--- 是否采集时可通行
---@param x number
---@param y number
---@return boolean
function Terrain.isHarvestable(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_PEONHARVESTPATHING)
end

--- 是否水面
---@param x number
---@param y number
---@return boolean
function Terrain.isWater(x, y)
    return not cj.IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
end

--- 是否地面（非水面）
---@param x number
---@param y number
---@return boolean
function Terrain.isLand(x, y)
    return cj.IsTerrainPathable(x, y, PATHING_TYPE_FLOATABILITY)
end

--- 设置地形通行状态
---@param x number
---@param y number
---@param pathingType pathingtype
---@param blocked boolean true=不可通行 false=可通行
function Terrain.setPathable(x, y, pathingType, blocked)
    if (pathingType == nil or blocked == nil) then return end
    cj.SetTerrainPathable(x, y, pathingType, blocked)
end

-----------------------------------------------------------------
-- 荒芜（Blight）
-----------------------------------------------------------------

--- 判断坐标是否有荒芜
---@param x number
---@param y number
---@return boolean
function Terrain.isBlighted(x, y)
    return cj.IsPointBlighted(x, y)
end

--- 设置/移除荒芜（圆形范围）
---@param player userdata
---@param x number
---@param y number
---@param radius number
---@param addBlight boolean true=创建荒芜 false=移除荒芜
function Terrain.setBlight(player, x, y, radius, addBlight)
    if (player == nil) then return end
    cj.SetBlight(player, x, y, radius or 128, (addBlight ~= nil) and addBlight or true)
end

--- 添加荒芜
---@param player userdata
---@param x number
---@param y number
---@param radius number|nil
function Terrain.addBlight(player, x, y, radius)
    Terrain.setBlight(player, x, y, radius, true)
end

--- 移除荒芜
---@param player userdata
---@param x number
---@param y number
---@param radius number|nil
function Terrain.removeBlight(player, x, y, radius)
    Terrain.setBlight(player, x, y, radius, false)
end

--- 设置/移除荒芜（矩形区域）
---@param player userdata
---@param rect rect
---@param addBlight boolean
function Terrain.setBlightRect(player, rect, addBlight)
    if (player == nil or rect == nil) then return end
    cj.SetBlightRect(player, rect, (addBlight ~= nil) and addBlight or true)
end

-----------------------------------------------------------------
-- 地形迷雾
-----------------------------------------------------------------

--- 设置地形迷雾（含颜色）
---@param style fogstate 迷雾样式
---@param zStart number 起始Z
---@param zEnd number 结束Z
---@param density number 密度
---@param r number 红 0-255
---@param g number 绿 0-255
---@param b number 蓝 0-255
function Terrain.setFog(style, zStart, zEnd, density, r, g, b)
    cj.SetTerrainFogEx(style, zStart or 0, zEnd or 5000, density or 1, r or 0, g or 0, b or 0)
end

--- 重置地形迷雾为默认
function Terrain.resetFog()
    cj.ResetTerrainFog()
end

--- 启用/禁用战争迷雾
---@param enable boolean
function Terrain.setFogEnabled(enable)
    cj.FogEnable((enable ~= nil) and enable or true)
end

--- 启用/禁用黑色阴影
---@param enable boolean
function Terrain.setFogMaskEnabled(enable)
    cj.FogMaskEnable((enable ~= nil) and enable or true)
end

--- 战争迷雾是否开启
---@return boolean
function Terrain.isFogEnabled()
    return cj.IsFogEnabled()
end

--- 黑色阴影是否开启
---@return boolean
function Terrain.isFogMaskEnabled()
    return cj.IsFogMaskEnabled()
end

--- 启用/禁用世界迷雾边界（染色）
---@param flag boolean
function Terrain.setFogBoundary(flag)
    cj.EnableWorldFogBoundary(flag)
end

-----------------------------------------------------------------
-- 水面
-----------------------------------------------------------------

--- 设置水颜色
---@param r integer 0-255
---@param g integer 0-255
---@param b integer 0-255
---@param a integer 0-255
function Terrain.setWaterColor(r, g, b, a)
    cj.SetWaterBaseColor(r or 0, g or 0, b or 255, a or 255)
end

--- 开启/关闭水面变形
---@param enable boolean
function Terrain.setWaterDeforms(enable)
    cj.SetWaterDeforms((enable ~= nil) and enable or true)
end

-----------------------------------------------------------------
-- 鼠标地形坐标
-----------------------------------------------------------------

--- 获取鼠标在游戏内的地形 X 坐标
---@return number
function Terrain.getMouseX()
    return cdz.DzGetMouseTerrainX()
end

--- 获取鼠标在游戏内的地形 Y 坐标
---@return number
function Terrain.getMouseY()
    return cdz.DzGetMouseTerrainY()
end

--- 获取鼠标在游戏内的地形 Z 坐标
---@return number
function Terrain.getMouseZ()
    return cdz.DzGetMouseTerrainZ()
end

--- 获取鼠标在游戏内的地形坐标
---@return number, number, number x, y, z
function Terrain.getMousePos()
    return cdz.DzGetMouseTerrainX(), cdz.DzGetMouseTerrainY(), cdz.DzGetMouseTerrainZ()
end

-----------------------------------------------------------------
-- Doodad 类 — 地形装饰物
-- ============================================================
-- KK_japi 扩展提供完整 doodad 控制。
-- 调用方式：
--   local d = Doodad:new(FourCC("LTlt"), 0, 0, 0, 0, 1)
--   d:setColor(0xFFFF0000)
--   d:setVisible(false)
--   d:remove()
-- ============================================================

---@class Doodad 地形装饰物
Doodad = {}
Doodad.__index = Doodad

local function newDoodad()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, Doodad)
    return obj
end

--- 创建地形装饰物
---@param doodadCode integer 装饰物类型ID
---@param x number X
---@param y number Y
---@param z number Z
---@param degree number 面向角度
---@param scale number 缩放
---@return Doodad
function Doodad:new(doodadCode, x, y, z, degree, scale)
    if (doodadCode == nil or x == nil or y == nil) then return end
    local obj = newDoodad()
    obj._handle = cdz.DzDoodadCreate(doodadCode, 0, x, y, z or 0, degree or 0, scale or 1)
    return obj
end

--- 从 handle 创建
---@param h userdata doodad handle
---@return Doodad
function Doodad.fromHandle(h)
    if (h == nil) then return end
    local obj = newDoodad()
    obj._handle = h
    return obj
end

--- 删除装饰物
---@return Doodad
function Doodad:remove()
    if (self._handle ~= nil) then
        cdz.DzDoodadRemove(self._handle)
        self._handle = nil
    end
    return self
end

--- 获取类型ID
---@return integer
function Doodad:getTypeId()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetTypeId(self._handle)
end

--- 获取 X 坐标
---@return number
function Doodad:getX()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetX(self._handle)
end

--- 获取 Y 坐标
---@return number
function Doodad:getY()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetY(self._handle)
end

--- 获取 Z 坐标
---@return number
function Doodad:getZ()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetZ(self._handle)
end

--- 获取坐标
---@return number, number, number
function Doodad:getPos()
    return self:getX(), self:getY(), self:getZ()
end

--- 设置位置
---@param x number
---@param y number
---@param z number|nil
---@return Doodad
function Doodad:setPos(x, y, z)
    if (self._handle ~= nil) then
        cdz.DzDoodadSetPosition(self._handle, x, y, z or 0)
    end
    return self
end

--- 设置颜色
---@param color integer ARGB
---@return Doodad
function Doodad:setColor(color)
    if (self._handle ~= nil and color ~= nil) then
        cdz.DzDoodadSetColor(self._handle, color)
    end
    return self
end

--- 设置模型
---@param modelFile string 模型路径
---@return Doodad
function Doodad:setModel(modelFile)
    if (self._handle ~= nil and modelFile ~= nil) then
        cdz.DzDoodadSetModel(self._handle, modelFile)
    end
    return self
end

--- 显示/隐藏
---@param visible boolean
---@return Doodad
function Doodad:setVisible(visible)
    if (self._handle ~= nil) then
        cdz.DzDoodadSetVisible(self._handle, (visible ~= nil) and visible or true)
    end
    return self
end

--- 隐藏
---@return Doodad
function Doodad:hide()
    return self:setVisible(false)
end

--- 设置队伍颜色
---@param colorId integer 玩家颜色ID
---@return Doodad
function Doodad:setTeamColor(colorId)
    if (self._handle ~= nil and colorId ~= nil) then
        cdz.DzDoodadSetTeamColor(self._handle, colorId)
    end
    return self
end

--- 播放动画
---@param animName string 动画名
---@param animRandom boolean|nil 是否随机播放
---@return Doodad
function Doodad:playAnimation(animName, animRandom)
    if (self._handle ~= nil and animName ~= nil) then
        cdz.DzDoodadSetAnimation(self._handle, animName, (animRandom ~= nil) and animRandom or false)
    end
    return self
end

--- 设置动画播放速度
---@param scale number 倍率
---@return Doodad
function Doodad:setTimeScale(scale)
    if (self._handle ~= nil and scale ~= nil) then
        cdz.DzDoodadSetTimeScale(self._handle, scale)
    end
    return self
end

--- 获取动画播放速度
---@return number
function Doodad:getTimeScale()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetTimeScale(self._handle)
end

--- 获取动画数量
---@return integer
function Doodad:getAnimationCount()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetAnimationCount(self._handle)
end

--- 获取当前动画索引
---@return integer
function Doodad:getCurrentAnimation()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetCurrentAnimationIndex(self._handle)
end

--- 获取第 i 个动画名称
---@param index integer
---@return string
function Doodad:getAnimationName(index)
    if (self._handle == nil or index == nil) then return "" end
    return cdz.DzDoodadGetAnimationName(self._handle, index)
end

--- 矩阵缩放
---@param x number
---@param y number
---@param z number
---@return Doodad
function Doodad:scale(x, y, z)
    if (self._handle ~= nil) then
        cdz.DzDoodadSetOrientMatrixScale(self._handle, x, y, z)
    end
    return self
end

--- 矩阵旋转
---@param degree number 角度
---@param x number 旋转轴X
---@param y number 旋转轴Y
---@param z number 旋转轴Z
---@return Doodad
function Doodad:rotate(degree, x, y, z)
    if (self._handle ~= nil and degree ~= nil) then
        cdz.DzDoodadSetOrientMatrixRotate(self._handle, degree, x or 0, y or 0, z or 1)
    end
    return self
end

--- 重置矩阵
---@return Doodad
function Doodad:resetTransform()
    if (self._handle ~= nil) then
        cdz.DzDoodadSetOrientMatrixResize(self._handle)
    end
    return self
end

--- 获取 Doodad 内存地址（高级用法）
---@return integer
function Doodad:getAddress()
    if (self._handle == nil) then return 0 end
    return cdz.DzDoodadGetAddress(self._handle)
end

-----------------------------------------------------------------
-- Doodad 静态工具（批量操作）
-----------------------------------------------------------------

--- 获取当前地形装饰物总数
---@return integer
function Doodad.getCount()
    return cdz.DzGetDoodadsCount()
end

--- 播放圆形范围内地形装饰物动画（原生 JASS）
---@param x number
---@param y number
---@param radius number
---@param doodadID integer 装饰物类型ID
---@param animName string 动画名
---@param animRandom boolean|nil
function Doodad.playAnimationInRange(x, y, radius, doodadID, animName, animRandom)
    if (doodadID == nil or animName == nil) then return end
    cj.SetDoodadAnimation(x, y, radius or 512, doodadID, true, animName, (animRandom ~= nil) and animRandom or false)
end

--- 播放矩形区域内地形装饰物动画（原生 JASS）
---@param rect rect
---@param doodadID integer
---@param animName string
---@param animRandom boolean|nil
function Doodad.playAnimationInRect(rect, doodadID, animName, animRandom)
    if (rect == nil or doodadID == nil or animName == nil) then return end
    cj.SetDoodadAnimationRect(rect, doodadID, animName, (animRandom ~= nil) and animRandom or false)
end

--- 批量矩阵缩放（按索引）
---@param index integer
---@param x number
---@param y number
---@param z number
function Doodad.setMatScale(index, x, y, z)
    cdz.DzSetDoodadsMatScale(index, x, y, z)
end

--- 批量矩阵旋转X
---@param index integer
---@param degree number
function Doodad.setMatRotateX(index, degree)
    cdz.DzSetDoodadsMatRotateX(index, degree)
end

--- 批量矩阵旋转Y
---@param index integer
---@param degree number
function Doodad.setMatRotateY(index, degree)
    cdz.DzSetDoodadsMatRotateY(index, degree)
end

--- 批量矩阵旋转Z
---@param index integer
---@param degree number
function Doodad.setMatRotateZ(index, degree)
    cdz.DzSetDoodadsMatRotateZ(index, degree)
end

--- 批量矩阵重置
---@param index integer
function Doodad.resetMat(index)
    cdz.DzSetDoodadsMatReset(index)
end


-----------------------------------------------------------------
-- TerrainDeform 类 — 地形变形
-- ============================================================
-- 支持弹坑、波纹、冲击波、随机变形。
-- 调用方式：
--   local crater = TerrainDeform:newCrater(0, 0, 256, -64, 5000, true)
--   crater:stop(1000)
-- ============================================================

---@class TerrainDeform 地形变形
TerrainDeform = {}
TerrainDeform.__index = TerrainDeform

local function newDeform()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, TerrainDeform)
    return obj
end

--- 创建弹坑变形
---@param x number 中心X
---@param y number 中心Y
---@param radius number 半径
---@param depth number 深度（负数=下陷）
---@param duration integer 持续时间(ms)
---@param permanent boolean 是否永久
---@return TerrainDeform
function TerrainDeform:newCrater(x, y, radius, depth, duration, permanent)
    if (x == nil or y == nil) then return end
    local obj = newDeform()
    obj._handle = cj.TerrainDeformCrater(x, y, radius or 128, depth or -32, duration or 3000, (permanent ~= nil) and permanent or false)
    return obj
end

--- 创建波纹变形
---@param x number 中心X
---@param y number 中心Y
---@param radius number 半径
---@param depth number 深度
---@param duration integer 持续时间(ms)
---@param count integer 波纹数量
---@param spaceWaves number 波纹间距
---@param timeWaves number 波纹时间间隔
---@return TerrainDeform
function TerrainDeform:newRipple(x, y, radius, depth, duration, count, spaceWaves, timeWaves)
    if (x == nil or y == nil) then return end
    local obj = newDeform()
    obj._handle = cj.TerrainDeformRipple(x, y, radius or 128, depth or -16, duration or 3000,
        count or 3, spaceWaves or 64, timeWaves or 0.25, 0, false)
    return obj
end

--- 创建冲击波变形
---@param x number 起点X
---@param y number 起点Y
---@param dirX number 方向X
---@param dirY number 方向Y
---@param distance number 距离
---@param speed number 速度
---@param radius number 半径
---@param depth number 深度
---@return TerrainDeform
function TerrainDeform:newWave(x, y, dirX, dirY, distance, speed, radius, depth)
    if (x == nil or y == nil) then return end
    local obj = newDeform()
    obj._handle = cj.TerrainDeformWave(x, y, dirX or 1, dirY or 0, distance or 512,
        speed or 256, radius or 128, depth or -32, 3000, 1)
    return obj
end

--- 创建随机变形
---@param x number
---@param y number
---@param radius number
---@param minDelta number 最小高度变化
---@param maxDelta number 最大高度变化
---@param duration integer 持续时间(ms)
---@return TerrainDeform
function TerrainDeform:newRandom(x, y, radius, minDelta, maxDelta, duration)
    if (x == nil or y == nil) then return end
    local obj = newDeform()
    obj._handle = cj.TerrainDeformRandom(x, y, radius or 128, minDelta or -16, maxDelta or 16,
        duration or 3000, 100)
    return obj
end

--- 停止变形
---@param duration integer 恢复过程持续时间(ms)
---@return TerrainDeform
function TerrainDeform:stop(duration)
    if (self._handle ~= nil) then
        cj.TerrainDeformStop(self._handle, duration or 0)
        self._handle = nil
    end
    return self
end

--- 停止所有地形变形
function TerrainDeform.stopAll()
    cj.TerrainDeformStopAll()
end
