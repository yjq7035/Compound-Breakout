-- ============================================================
-- Obj — 物编数据读取（通过 KKAPI EXExecuteScript）
--
-- 使用 metatable __index 实现 obj.Type["id"].Field 式访问
-- 底层调用 EXExecuteScript 执行 "jass.slk.item[id].field" 读取物编
--
-- 使用方式：
--   Obj.Item["a005"].Name       → "锁子甲 Lv.5"
--   Obj.Item.a005.Art           → [[ReplaceableTextures\...]]
--   Obj.Item.a005.Tip           → 物品提示
--   Obj.Item.a005.Ubertip       → 物品扩展提示
--   Obj.Unit["hfoo"].Name       → "步兵"
--   Obj.Unit.hfoo.Art           → 单位图标
--   Obj.Ability["AHbz"].Name    → "暴风雪"
--   Obj.Buff["B000"].Name       → 增益名称
--
-- 直接调用：
--   Obj.Item["a005"]:get("Name")   → 同上
-- ============================================================

---@class Obj
Obj = {}

-----------------------------------------------------------------
-- 缓存（弱引用，不阻GC）
-----------------------------------------------------------------
local _cache = setmetatable({}, { __mode = "kv" })

-----------------------------------------------------------------
-- 基础执行器：通过 EXExecuteScript 运行 Lua 代码
-----------------------------------------------------------------
function Obj.exec(code)
    if not code then return "" end
    local ok, result = pcall(cdz.EXExecuteScript, code)
    if ok and result then
        return tostring(result)
    end
    return ""
end

-----------------------------------------------------------------
-- Slk 路径映射（对应 jass.slk 的表结构）
-- 属性名（如 "Art"、"Name"、"Tip"、"Ubertip"）直接作为字段名传入
-----------------------------------------------------------------
local SLK_PATH = {
    Item    = "require('jass.slk').item",
    Unit    = "require('jass.slk').unit",
    Ability = "require('jass.slk').ability",
    Buff    = "require('jass.slk').buff",
    Destructable = "require('jass.slk').destructable",
}

--- 通用 SLK 读取
---@param slkPath string 如 "require('jass.slk').item"
---@param id string 对象 ID（如 "a005"）
---@param field string 字段名（如 "Art"）
---@return string
local function readSlk(slkPath, id, field)
    if not id or not field then return "" end
    local key = slkPath .. "|" .. id .. "|" .. field
    local cached = _cache[key]
    if cached ~= nil then return cached end

    -- 生成 Lua 表达式: require('jass.slk').item["a005"].Art
    -- 使用方括号访问，因为物品ID可能不是合法Lua标识符
    local code = string.format("%s[\"%s\"].%s", slkPath, id, field)
    local result = Obj.exec(code)
    _cache[key] = result
    return result
end

-----------------------------------------------------------------
-- 公共读取方法
-----------------------------------------------------------------

--- 读取物品属性
---@param itemId string 物品 ID（如 "a005"）
---@param field string 字段名（如 "Art", "Name", "Tip", "Ubertip"）
---@return string
function Obj.getItemData(itemId, field)
    return readSlk(SLK_PATH.Item, itemId, field)
end

--- 读取单位属性
---@param unitId string 单位 ID（如 "hfoo"）
---@param field string 字段名（如 "Art", "Name", "Tip", "Ubertip", "Scale"）
---@return string
function Obj.getUnitData(unitId, field)
    return readSlk(SLK_PATH.Unit, unitId, field)
end

--- 读取技能属性
function Obj.getAbilityData(abilId, field)
    return readSlk(SLK_PATH.Ability, abilId, field)
end

--- 读取增益属性
---@param buffId string 增益 ID（如 "B000"）
---@param field string 字段名（如 "Bufftip"）
---@return string
function Obj.getBuffData(buffId, field)
    return readSlk(SLK_PATH.Buff, buffId, field)
end

-----------------------------------------------------------------
-- 元表工厂
-----------------------------------------------------------------
local function makeProxy(slkPath)
    return setmetatable({}, {
        __index = function(self, id)
            if type(id) ~= "string" then return nil end
            local cached = rawget(self, id)
            if cached then return cached end

            local proxy = setmetatable({}, {
                __index = function(_, field)
                    if type(field) == "string" then
                        return readSlk(slkPath, id, field)
                    end
                    return nil
                end,
                __tostring = function()
                    return string.format("ObjProxy[%s]", id)
                end,
            })
            rawset(self, id, proxy)
            return proxy
        end,
    })
end

-----------------------------------------------------------------
-- 物编访问入口
-----------------------------------------------------------------
Obj.Item    = makeProxy(SLK_PATH.Item)
Obj.Unit    = makeProxy(SLK_PATH.Unit)
Obj.Ability = makeProxy(SLK_PATH.Ability)
Obj.Buff    = makeProxy(SLK_PATH.Buff)
