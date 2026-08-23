-- ============================================================
-- Layer1 — 第一关卡模块
--
-- 归属：Game/Layers/  战役关卡模块目录
-- 职责：
--   1. 存放第一关卡所有坐标集合（Layer1Area）
--   2. 封装关卡力量墙的创建/销毁（可破坏物，非单位）
--   3. 提供关卡生命周期入口：Layer1.createWalls / Layer1.destroyWalls
--
-- 坐标来源（用户提供，2026-08-23）：
--   1. -11147.3, -12794.7  横墙  B000 parent Dofw FixedRot 270
--   2. -13345.1, -11943.7  竖墙  DL84 parent Dofw FixedRot 0
--   3. -11393.4, -14058.5  竖墙  DL84
--   4. -9975.7,  -14137.8  竖墙  DL84
--
-- 调用：
--   require "Game.Layers.Layer1"
--   Layer1.createWalls()   -- 创建4面力量墙
--   Layer1.destroyWalls()  -- 移除4面墙
-- ============================================================

Layer1 = {}
Layer1.__index = Layer1

-- ------------------------------------------------------------
-- 墙体定义（非单位：可破坏物 destructable）
-- B000 = 横墙，DL84 = 竖墙，见 table/destructable.ini
-- ------------------------------------------------------------
Layer1.WALL_H = "B000"
Layer1.WALL_V = "DL84"

--- 第一关卡墙体坐标表（对外暴露，供编辑器/调试使用）
--- 字段：x, y, id, dir
Layer1.walls = {
    { x = -11147.3, y = -12794.7, id = "B000", dir = "H", face = 270, name = "横墙1" },
    { x = -13345.1, y = -11943.7, id = "DL84", dir = "V", face = 0,   name = "竖墙1" },
    { x = -11393.4, y = -14058.5, id = "DL84", dir = "V", face = 0,   name = "竖墙2" },
    { x = -9975.7,  y = -14137.8, id = "DL84", dir = "V", face = 0,   name = "竖墙3" },
}

-- 兼容旧全局：Layer1Area = 第一关卡坐标集合（供 GameCoords.lua 迁移前代码访问）
Layer1Area = Layer1.walls

-- 运行时句柄
Layer1.handles = {}  -- { destructable handle, ... }

-- ------------------------------------------------------------
-- 内部：单面墙创建
-- ------------------------------------------------------------
local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    -- cj.CreateDestructable(objectId, x, y, face, scale, variation)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then
        print(string.format("[Layer1] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else
        print(string.format("[Layer1] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y))
    end
    return h
end

--- 创建第一关卡所有力量墙（幂等：已存在则跳过）
---@return table handles
function Layer1.createWalls()
    if #Layer1.handles > 0 then
        print("[Layer1] 墙体已存在，跳过重复创建 count=" .. #Layer1.handles)
        return Layer1.handles
    end
    Layer1.handles = {}
    for _, w in ipairs(Layer1.walls) do
        local h = createOne(w)
        if h then table.insert(Layer1.handles, h) end
    end
    print("[Layer1] 第一关卡墙体创建完成 count=" .. #Layer1.handles .. "/4")
    return Layer1.handles
end

--- 移除第一关卡所有力量墙
function Layer1.destroyWalls()
    for _, h in ipairs(Layer1.handles) do
        if h then
            cj.RemoveDestructable(h)
        end
    end
    local n = #Layer1.handles
    Layer1.handles = {}
    print("[Layer1] 第一关卡墙体已移除 count=" .. n)
end

--- 获取墙体数量
---@return integer
function Layer1.getCount()
    return #Layer1.handles
end

--- 是否已创建
---@return boolean
function Layer1.isCreated()
    return #Layer1.handles > 0
end

return Layer1
