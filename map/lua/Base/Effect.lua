
-- ============================================================
-- Effect 类 — 所有特效相关操作统一为对象方法
-- 调用方式：
--   local e = Effect:new(model, x, y, z, duration)
--   e:setAlpha(128):setColor(0xFFFF0000):setZ(100)
--   e:destroy()
-- ============================================================

---@class Effect 特效
Effect = {}
Effect.__index = Effect
Effect._handle = nil


--[[
魔兽争霸3 单位模型特效挂载点位常量集合
用途：绑定特效、投射物、漂浮文字、光环、粒子效果
规则：挂点字符串大小写、空格严格匹配模型，不存在则自动降级为origin
]]
-- 躯干基础点位
EFFECT_POINT_ORIGIN = "origin"        -- 模型基准原点，兜底默认点位
EFFECT_POINT_HEAD = "head"            -- 头部基础位置
EFFECT_POINT_HEADTOP = "headtop"      -- 头顶最高点，漂浮文字/头顶光环专用
EFFECT_POINT_CHEST = "chest"          -- 胸口躯干中心
EFFECT_POINT_CHESTTOP = "chesttop"    -- 胸腔上部、锁骨区域
EFFECT_POINT_LEGS = "legs"            -- 双腿中间腿部中心

-- 手部与武器点位
EFFECT_POINT_WEAPON = "weapon"        -- 主武器握持点
EFFECT_POINT_WEAPON2 = "weapon2"      -- 副手/第二武器点位
EFFECT_POINT_HAND_LEFT = "hand left"  -- 左手手掌
EFFECT_POINT_HAND_RIGHT = "hand right"-- 右手手掌

-- 肩背点位
EFFECT_POINT_SHOULDER_LEFT = "shoulder left"    -- 左肩
EFFECT_POINT_SHOULDER_RIGHT = "shoulder right"  -- 右肩
EFFECT_POINT_BACK = "back"                      -- 背部中心

-- 足部点位
EFFECT_POINT_FOOT = "foot"            -- 双脚通用点位
EFFECT_POINT_FOOT_LEFT = "foot left"  -- 左脚脚底
EFFECT_POINT_FOOT_RIGHT = "foot right"-- 右脚脚底

-- 远程弹道发射点
EFFECT_POINT_MISSILE = "missile"      -- 飞弹、弓箭、法术弹道出口

-- 特殊生物部件点位
EFFECT_POINT_WING_LEFT = "wing left"   -- 左翼
EFFECT_POINT_WING_RIGHT = "wing right"-- 右翼
EFFECT_POINT_TAIL = "tail"            -- 尾巴根部
EFFECT_POINT_HORN = "horn"            -- 头部尖角
EFFECT_POINT_MOUNT = "mount"          -- 坐骑挂载点（骑马英雄）



-----------------------------------------------------------------
-- 内部辅助：创建一个新的 Effect 实例
-----------------------------------------------------------------
local function newEffect(model)
    local obj = {
        _handle = nil,
        _index = nil,
        model = model or "",
        -- 本地坐标缓存：创建/移动特效时同步更新，getX/Y/Z 直接读取，
        -- 不从 KK EX 插件回读，保证跨机取值一致（避免坐标分叉 desync）
        x = nil,
        y = nil,
        z = nil,
    }
    setmetatable(obj, Effect)
    return obj
end

-----------------------------------------------------------------
-- 创建特效（坐标）
-----------------------------------------------------------------

--- 在XY坐标创建特效
---@param model string 特效模型路径
---@param x number X坐标
---@param y number Y坐标
---@param z number|nil Z高度
---@param duration number|nil 控制方式：
---   nil/0 → 播放一次后立即销毁（删除型播放）
---   <0    → 不自动删除，需手动 destroy
---   >0    → 持续 duration 秒后自动销毁
---@return Effect
function Effect:new(model, x, y, z, duration)
    if (model == nil or model == "") then return end
    local obj = newEffect(model)
    z = z or 0
    duration = duration or 0

    local e = cj.AddSpecialEffect(model, x, y)
    obj._handle = e
    obj._index = cj.GetHandleId(obj._handle)
    -- 同步本地坐标缓存（创建位置）
    obj.x = x
    obj.y = y
    obj.z = z
    if (type(z) == "number" and z ~= 0) then
        cdz.EXSetEffectZ(e, z)
    end

    if (duration == 0) then
        -- 播放一次后立即销毁（删除型播放）
        cj.DestroyEffect(e)
        obj._handle = nil
        obj._index = cj.GetHandleId(obj._handle)
    elseif (duration > 0) then
        -- [DESYNC-FIX] 确定性定时销毁：改用项目内核 Timer（10ms tick、按插入序、
        -- 游戏时间驱动，跨机在同一 tick 销毁同一句柄）。
        -- 原 cdz.DzRemoveEffectTimed 把销毁交给 KK 插件侧 JASS 计时器，与 Lua 对象
        -- 生命周期双轨：引擎定时销毁后 obj._handle 仍残留，调用方再 destroy/remove
        -- 会对已回收/复用的特效槽位二次 DestroyEffect → 特效句柄序列跨机分叉 → desync。
        -- 定时回调走 obj:remove()（内部置空 _handle，杜绝二次销毁）。
        Timer:new(duration, false, function()
            obj:remove()
        end)
    end
    -- duration < 0 时不自动删除，保持 obj._handle 有效
    return obj
end

--- 创建特效绑定到单位
---@param model string 模型路径
---@param targetUnit userdata 目标单位
---@param attachPoint string 附着点，如 "'origin'" | "'head'" | "'chest'"
---@param duration number|nil 控制方式同 :new
---@return Effect
function Effect:newAttach(model, targetUnit, attachPoint, duration)
    if (model == nil or model == "" or targetUnit == nil or attachPoint == nil) then return end
    local obj = newEffect(model)
    duration = duration or 0

    local e = cj.AddSpecialEffectTarget(model, targetUnit, attachPoint)
    obj._handle = e
    obj._index = cj.GetHandleId(obj._handle)
    -- 同步本地坐标缓存：附着特效以目标单位当前位置为初始坐标
    obj.x = cj.GetUnitX(targetUnit)
    obj.y = cj.GetUnitY(targetUnit)
    obj.z = nil
    obj._attachUnit = targetUnit

    if (duration == 0) then
        cj.DestroyEffect(obj._handle)
        obj._handle = nil
        obj._index = cj.GetHandleId(obj._handle)
    elseif (duration > 0) then
        -- [DESYNC-FIX] 同 :new —— 用内核 Timer 确定性销毁（原 DzDieEffectTimed 与
        -- Lua 对象生命周期双轨，句柄残留易对回收槽位二次销毁 → 句柄序列分叉 → desync）。
        -- 定时回调走 obj:destroy()（播放死亡动画 + 置空 _handle）。
        Timer:new(duration, false, function()
            obj:destroy()
        end)
    end
    return obj
end
-----------------------------------------------------------------
-- 特效动作
-----------------------------------------------------------------
---创建坐标特效动作
---@param str string 特效路径
---@param x number X坐标
---@param y number Y坐标
---@param actionFunc fun(effect: Effect) 动作函数
---@return Effect
function Effect:newAddCoord(str,x,y,actionFunc)
    local obj = self:new(str, x, y, nil, -1)
    actionFunc(obj)
    return obj
end

---创建绑定特效动作
---@param str string 特效路径
---@param targetUnit userdata 目标单位
---@param attachPoint string 附着点，如 "'origin'" | "'head'" | "'chest'"
---@param actionFunc fun(effect: Effect) 动作函数
---@return Effect
function Effect:newAddAttach(str,targetUnit,attachPoint,actionFunc)
    local obj = self:newAttach(str, targetUnit, attachPoint, -1)
    actionFunc(obj)
    return obj
end

-----------------------------------------------------------------
-- 销毁
-----------------------------------------------------------------

--- 播放死亡动画后销毁
---@return Effect
function Effect:destroy()
    if (self._handle ~= nil) then
        cj.DestroyEffect(self._handle)
        self._handle = nil
    end
    return self
end

--- 立即删除（不播放死亡动画）
---@return Effect
function Effect:remove()
    if (self._handle ~= nil) then
        cdz.DzRemoveEffect(self._handle)
        self._handle = nil
    end
    return self
end

--- 先播放死亡动画，再经过 time 秒后删除
---@param time number 延迟秒数
---@return Effect
function Effect:dieTimed(time)
    if (self._handle ~= nil and time ~= nil) then
        if (time <= 0) then
            -- time<=0 插件 DzDieEffectTimed 会直接返回 false（不销毁）→ 特效永久泄漏；
            -- 语义上"0 秒后删除"= 立即销毁
            cj.DestroyEffect(self._handle)
            self._handle = nil
        else
            cdz.DzDieEffectTimed(self._handle, time)
            self._handle = nil
        end
    end
    return self
end

--- 直接删除，经过 time 秒后删除
---@param time number 延迟秒数
---@return Effect
function Effect:removeTimed(time)
    if (self._handle ~= nil and time ~= nil) then
        if (time <= 0) then
            cdz.DzRemoveEffect(self._handle)
            self._handle = nil
        else
            cdz.DzRemoveEffectTimed(self._handle, time)
            self._handle = nil
        end
    end
    return self
end

-----------------------------------------------------------------
-- 位置
-----------------------------------------------------------------

--- 设置特效坐标
---@param x number X
---@param y number Y
---@param z number Z
---@return Effect
function Effect:setPos(x, y, z)
    if (self._handle ~= nil) then
        cdz.DzSetEffectPos(self._handle, x, y, z)
    end
    -- 同步本地坐标缓存
    self.x = x
    self.y = y
    self.z = z
    return self
end

--- 移动特效到XY（不改变Z）
---@param x number X
---@param y number Y
---@return Effect
function Effect:moveXY(x, y)
    if (self._handle ~= nil) then
        cdz.EXSetEffectXY(self._handle, x, y)
    end
    -- 同步本地坐标缓存
    self.x = x
    self.y = y
    return self
end

--- 设置Z高度
---@param z number Z
---@return Effect
function Effect:setZ(z)
    if (self._handle ~= nil) then
        cdz.EXSetEffectZ(self._handle, z)
    end
    -- 同步本地坐标缓存
    self.z = z
    return self
end

--- 更新智能坐标（绑定单位移动后调用；同步刷新本地坐标缓存）
---@return Effect
function Effect:updatePos()
    if (self._handle ~= nil) then
        cdz.DzUpdateEffectSmartPosition(self._handle)
    end
    if (self._attachUnit ~= nil) then
        self.x = cj.GetUnitX(self._attachUnit)
        self.y = cj.GetUnitY(self._attachUnit)
    end
    return self
end

-----------------------------------------------------------------
-- 获取属性
-----------------------------------------------------------------

--- 获取X坐标（读取本地缓存，nil 返回 0；不再从 KK EX 插件回读）
---@return number
function Effect:getX()
    return self.x or 0
end

--- 获取Y坐标（读取本地缓存，nil 返回 0；不再从 KK EX 插件回读）
---@return number
function Effect:getY()
    return self.y or 0
end

--- 获取Z高度（读取本地缓存，nil 返回 0；不再从 KK EX 插件回读）
---@return number
function Effect:getZ()
    return self.z or 0
end

--- 获取特效大小（缩放值）
---@return number
function Effect:getSize()
    if (self._handle == nil) then return 0 end
    return cdz.EXGetEffectSize(self._handle)
end

--- 获取透明度 (0-255)
---@return integer
function Effect:getAlpha()
    if (self._handle == nil) then return 255 end
    return cdz.DzGetEffectVertexAlpha(self._handle)
end

--- 获取颜色值
---@return integer
function Effect:getColor()
    if (self._handle == nil) then return 0 end
    return cdz.DzGetEffectVertexColor(self._handle)
end

-----------------------------------------------------------------
-- 缩放 / 旋转 / 变换
-----------------------------------------------------------------

--- 矩阵缩放（XYZ轴独立）
---@param x number X缩放
---@param y number Y缩放
---@param z number Z缩放
---@return Effect
function Effect:scale(x, y, z)
    if (self._handle ~= nil and x ~= nil and y ~= nil and z ~= nil) then
        cdz.EXEffectMatScale(self._handle, x, y, z)
    end
    return self
end

--- 等比缩放（单值，非矩阵）
---@param s number 缩放值
---@return Effect
function Effect:setScale(s)
    if (self._handle ~= nil and s ~= nil) then
        cdz.DzSetEffectScale(self._handle, s)
    end
    return self
end

--- 设置特效大小
---@param size number
---@return Effect
function Effect:setSize(size)
    if (self._handle ~= nil and size ~= nil) then
        cdz.EXSetEffectSize(self._handle, size)
    end
    return self
end

--- 绕X轴旋转（矩阵）- 自身翻转
---@param degree number 角度
---@param noReset boolean|nil true 时不重置矩阵（可组合多个旋转）
---@return Effect
function Effect:rotateX(degree, noReset)
    if (self._handle ~= nil and degree ~= nil) then
        if not noReset then cdz.EXEffectMatReset(self._handle) end
        cdz.EXEffectMatRotateX(self._handle, degree)
    end
    return self
end

--- 绕Y轴旋转（矩阵）- 上下旋转
---@param degree number 角度
---@param noReset boolean|nil true 时不重置矩阵（可组合多个旋转）
---@return Effect
function Effect:rotateY(degree, noReset)
    if (self._handle ~= nil and degree ~= nil) then
        if not noReset then cdz.EXEffectMatReset(self._handle) end
        cdz.EXEffectMatRotateY(self._handle, degree)
    end
    return self
end

--- 绕Z轴旋转（矩阵）- 水平旋转
---@param degree number 角度
---@param noReset boolean|nil true 时不重置矩阵（可组合多个旋转）
---@return Effect
function Effect:rotateZ(degree, noReset)
    if (self._handle ~= nil and degree ~= nil) then
        if not noReset then cdz.EXEffectMatReset(self._handle) end
        cdz.EXEffectMatRotateZ(self._handle, degree)
    end
    return self
end

--- 重置矩阵变换（清空所有缩放/旋转）
---@return Effect
function Effect:resetTransform()
    if (self._handle ~= nil) then
        cdz.EXEffectMatReset(self._handle)
    end
    return self
end

-----------------------------------------------------------------
-- 视觉（颜色 / 透明度 / 可见性）
-----------------------------------------------------------------

--- 设置透明度
---@param alpha integer 0-255, 0全透明 255不透明
---@return Effect
function Effect:setAlpha(alpha)
    if (self._handle ~= nil and alpha ~= nil) then
        cdz.DzSetEffectVertexAlpha(self._handle, alpha)
    end
    return self
end

--- 设置颜色
---@param color integer RGBA颜色值
---@return Effect
function Effect:setColor(color)
    if (self._handle ~= nil and color ~= nil) then
        cdz.DzSetEffectVertexColor(self._handle, color)
    end
    return self
end

--- 设置队伍颜色
---@param playerColorId integer 玩家颜色ID
---@return Effect
function Effect:setTeamColor(playerColorId)
    if (self._handle ~= nil and playerColorId ~= nil) then
        cdz.DzSetEffectTeamColor(self._handle, playerColorId)
    end
    return self
end

--- 显示/隐藏
---@param visible showhideoption true=显示 false=隐藏
---@return Effect
function Effect:setVisible(visible)
    if (self._handle ~= nil) then
        cdz.DzSetEffectVisible(self._handle, visible)
    end
    return self
end

--- 设置迷雾可见
---@param v boolean
---@return Effect
function Effect:setFogVisible(v)
    if (self._handle ~= nil) then
        cdz.DzSetEffectFogVisible(self._handle, v)
    end
    return self
end

--- 设置黑色阴影可见
---@param v boolean
---@return Effect
function Effect:setMaskVisible(v)
    if (self._handle ~= nil) then
        cdz.DzSetEffectMaskVisible(self._handle, v)
    end
    return self
end

--- 设置始终渲染（屏幕外也渲染）
---@param v boolean
---@return Effect
function Effect:setAlwaysRender(v)
    if (self._handle ~= nil) then
        cdz.DzSetEffectAlwaysRender(self._handle, v)
    end
    return self
end

-----------------------------------------------------------------
-- 动画
-----------------------------------------------------------------

--- 设置播放速度
---@param spd number 速度倍率
---@return Effect
function Effect:setSpeed(spd)
    if (self._handle ~= nil and spd ~= nil) then
        cdz.EXSetEffectSpeed(self._handle, spd)
    end
    return self
end

--- 通过整数ID播放动画
---@param animId1 integer 动画ID
---@param animId2 integer 动画ID(变色时用，否则为空)
---@return Effect
function Effect:setAnimation(animId1, animId2)
    if (self._handle ~= nil) then
        cdz.DzSetEffectAnimation(self._handle, animId1, animId2 or 0)
    end
    return self
end

--- 通过字符串名称播放动画
---@param animName1 string 动画名
---@param animName2 string|nil 动画名(变色时用，否则为空)
---@return Effect
function Effect:playAnimation(animName1, animName2)
    if (self._handle ~= nil) then
        cdz.DzPlayEffectAnimation(self._handle, animName1, animName2 or "")
    end
    return self
end

--- 重新播放出生动画
---@return Effect
function Effect:replayBirth()
    if (self._handle ~= nil) then
        cdz.DzEffectReplayBirth(self._handle)
    end
    return self
end

-----------------------------------------------------------------
-- 模型
-----------------------------------------------------------------

--- 更换模型
---@param modelFile string 模型文件路径
---@return Effect
function Effect:setModel(modelFile)
    if (self._handle ~= nil and modelFile ~= nil) then
        cdz.DzSetEffectModel(self._handle, modelFile)
    end
    return self
end

--- 设置绑定特效的缩放
---@param x number X
---@param y number Y
---@param z number Z
---@return Effect
function Effect:setAttachScale(x, y, z)
    if (self._handle ~= nil) then
        cdz.DzSetEffectAttachedModelScale(self._handle, x, y, z)
    end
    return self
end

-----------------------------------------------------------------
-- 绑定关系
-----------------------------------------------------------------

--- 绑定到单位
---@param unit userdata 目标单位
---@param attachPoint string 附着点
---@return Effect
function Effect:bindUnit(unit, attachPoint)
    if (self._handle ~= nil and unit ~= nil and attachPoint ~= nil) then
        cdz.DzBindEffect(unit, attachPoint, self._handle)
    end
    -- 记录绑定单位，供 updatePos 刷新本地坐标缓存
    if (unit ~= nil) then
        self._attachUnit = unit
    end
    return self
end

--- 绑定到另一个特效
---@param targetEffect userdata 目标特效handle
---@param attachPoint string 附着点
---@return Effect
function Effect:bindEffect(targetEffect, attachPoint)
    if (self._handle ~= nil and targetEffect ~= nil and attachPoint ~= nil) then
        cdz.DzEffectBindEffect(self._handle, attachPoint, targetEffect)
    end
    return self
end

--- 解除绑定
---@return Effect
function Effect:unbind()
    if (self._handle ~= nil) then
        cdz.DzUnbindEffect(self._handle)
    end
    return self
end

-----------------------------------------------------------------
-- 特效组设置
-----------------------------------------------------------------

--- 设置特效组黑名单（异步坐标专用）
---@param v boolean
---@return Effect
function Effect:setGroupBlacklist(v)
    if (self._handle ~= nil) then
        cdz.DzSetEffectGroupBlacklist(self._handle, v)
    end
    return self
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存特效handle到哈希表
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@return boolean
function Effect:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveEffectHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取特效并返回 Effect 对象
---@param t hashtable 哈希表
---@param pk integer 父键
---@param ck integer 子键
---@return Effect
function Effect.loadHandle(t, pk, ck)
    local e = cj.LoadEffectHandle(t, pk, ck)
    if (e == nil) then return end
    local obj = newEffect()
    obj._handle = e
    obj._index = cj.GetHandleId(obj._handle)
    return obj
end

-----------------------------------------------------------------
-- 工具函数（纯查询，不涉及对象状态）
-----------------------------------------------------------------

--- 获取技能特效路径（通过技能字符串）
---@param abilityString string
---@param effectType effecttype
---@param index integer|nil
---@return string
function Effect.getAbilityEffect(abilityString, effectType, index)
    index = index or 0
    return cj.GetAbilityEffect(abilityString, effectType, index)
end

--- 获取技能特效路径（通过技能ID）
---@param abilityId integer
---@param effectType effecttype
---@param index integer|nil
---@return string
function Effect.getAbilityEffectById(abilityId, effectType, index)
    index = index or 0
    return cj.GetAbilityEffectById(abilityId, effectType, index)
end

--- 转换整型为特效类型
---@param i integer
---@return effecttype
function Effect.convertType(i)
    return cj.ConvertEffectType(i)
end


-- ============================================================
-- EffectGroup 类 — 特效组
-- ============================================================

---@class EffectGroup 特效组
EffectGroup = {}
EffectGroup.__index = EffectGroup
EffectGroup._handle = nil
EffectGroup._index = nil

local function newGroup()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, EffectGroup)
    return obj
end

--- 创建特效组
---@return EffectGroup
function EffectGroup:new()
    local obj = newGroup()
    obj._handle = cdz.DzEffectGroupCreate()
    obj._index = cj.GetHandleId(obj._handle)
    return obj
end

--- 添加特效
---@param effect userdata 特效handle
---@param check boolean 是否检查重复
---@return integer
function EffectGroup:add(effect, check)
    if (self._handle == nil or effect == nil) then return 0 end
    check = (check ~= nil) and check or true
    return cdz.DzEffectGroupAdd(self._handle, effect, check)
end

--- 移出特效
---@param effect userdata
---@param flag boolean
function EffectGroup:remove(effect, flag)
    if (self._handle ~= nil and effect ~= nil) then
        cdz.DzEffectGroupRemove(self._handle, effect, flag)
    end
end

--- 是否包含
---@param effect userdata
---@return boolean
function EffectGroup:contains(effect)
    if (self._handle == nil or effect == nil) then return false end
    return cdz.DzEffectGroupContains(self._handle, effect)
end

--- 数量
---@return integer
function EffectGroup:getSize()
    if (self._handle == nil) then return 0 end
    return cdz.DzEffectGroupGetSize(self._handle)
end

--- 第N个特效handle
---@param index integer
---@return userdata|nil
function EffectGroup:at(index)
    if (self._handle == nil or index == nil) then return nil end
    return cdz.DzEffectGroupAt(self._handle, index)
end

--- 清空
function EffectGroup:clear()
    if (self._handle ~= nil) then
        cdz.DzEffectGroupClear(self._handle)
    end
end

--- 销毁特效组
function EffectGroup:destroy()
    if (self._handle ~= nil) then
        cdz.DzEffectGroupDestroy(self._handle)
        self._handle = nil
    end
end

--- 范围枚举
---@param x number 中心X
---@param y number 中心Y
---@param radius number 半径
---@param includeDummy boolean 是否包含假单位
---@param checkLos boolean 是否检查视野
---@return integer 枚举数量
function EffectGroup:enumRange(x, y, radius, includeDummy, checkLos)
    if (self._handle == nil) then return 0 end
    return cdz.DzEffectGroupEnumRange(self._handle, x, y, radius, includeDummy, checkLos)
end

--- 矩形区域枚举
---@param rect rect 区域
---@param includeDummy boolean
---@param checkLos boolean
---@return integer
function EffectGroup:enumRect(rect, includeDummy, checkLos)
    if (self._handle == nil) then return 0 end
    return cdz.DzEffectGroupEnumRect(self._handle, rect, includeDummy, checkLos)
end

--- 遍历（for each），在回调中用 DzGetEnumEffect() 获取当前特效handle
---@param callback function
function EffectGroup:forEach(callback)
    if (self._handle == nil or callback == nil) then return end
    cdz.DzForEffectGroup(self._handle)
end

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
function EffectGroup:saveHandle(t, pk, ck)
    if (self._handle ~= nil) then
        cdz.SaveDzEffectGroupHandle(t, pk, ck, self._handle)
    end
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return EffectGroup
function EffectGroup.loadHandle(t, pk, ck)
    local h = cdz.LoadDzEffectGroupHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newGroup()
    obj._handle = h
    obj._index = cj.GetHandleId(obj._handle)
    return obj
end

--- 从整数handle ID 创建
---@param handleId integer
---@return EffectGroup
function EffectGroup.fromHandle(handleId)
    local h = cdz.DzHandle2EffectGroup(handleId)
    if (h == nil) then return end
    local obj = newGroup()
    obj._handle = h
    obj._index = cj.GetHandleId(obj._handle)
    return obj
end


-- ============================================================
-- UI 帧特效（与 Effect 对象无关，保留为静态方法）
-- ============================================================

--- 为UI frame添加模型特效
---@param frame userdata UI frame
---@param modelFile string 模型路径
---@param attachPoint string 附着点（如 "Chest"）
---@return userdata|nil
function Effect.frameAddModel(frame, modelFile, attachPoint)
    if (frame == nil or modelFile == nil or attachPoint == nil) then return end
    return cdz.DzFrameAddModelEffect(frame, modelFile, attachPoint)
end

--- 移除UI frame的模型特效
---@param frame userdata UI frame
---@param modelFrame userdata 模型frame
function Effect.frameRemoveModel(frame, modelFrame)
    if (frame == nil or modelFrame == nil) then return end
    cdz.DzFrameRemoveModelEffect(frame, modelFrame)
end


