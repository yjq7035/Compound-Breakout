-- ============================================================
-- Layer2 — 第二关卡模块
--
-- 职责：
--   1. 存放第二关卡坐标（入口/复活、药剂商店）
--   2. 提供关卡生命周期：Layer2.start / Layer2.shutdown
-- ============================================================

Layer2 = {}
Layer2.__index = Layer2

-- ------------------------------------------------------------
-- 坐标
-- ------------------------------------------------------------
Layer2.entryPos      = { x = -11398.9, y = -7748.4, name = "关卡2入口/复活" }
Layer2.revivePos     = { x = -11398.9, y = -7748.4, name = "关卡2复活点" }
Layer2.potionShopPos = { x = -10883.1, y = -7679.4, name = "关卡2药剂商店" }

-- 兼容全局
Layer2EntryPos      = Layer2.entryPos
Layer2RevivePos     = Layer2.revivePos
Layer2PotionShopPos = Layer2.potionShopPos

-- ------------------------------------------------------------
-- 墙体定义（非单位：可破坏物 destructable）
-- 用户提供 2026-08-25：
--   竖墙10：-11775.9,-9896.5 / -9095,-10082.8 / -9095,-10855 / -9095,-11618 / -9095,-12400 / -9095,-13165 / -9865,-10855 / -9865,-11618 / -9865,-12400 / -9865,-13165
--   横墙2：-11224.8,-10484.6 / -9490,-13448
--   竖墙 DL84 face 0，横墙 B000 face 270（同 Layer1）
-- ------------------------------------------------------------
Layer2.WALL_H = "B000"
Layer2.WALL_V = "DL84"

Layer2.walls = {
    { x = -11775.9, y = -9896.5,  id = "DL84", dir = "V", face = 0,   name = "竖墙1" },
    { x = -9095,    y = -10082.8, id = "DL84", dir = "V", face = 0,   name = "竖墙2" },
    { x = -9095,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙3" },
    { x = -9095,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙4" },
    { x = -9095,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙5" },
    { x = -9095,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙6" },
    { x = -9865,    y = -10855,   id = "DL84", dir = "V", face = 0,   name = "竖墙7" },
    { x = -9865,    y = -11618,   id = "DL84", dir = "V", face = 0,   name = "竖墙8" },
    { x = -9865,    y = -12400,   id = "DL84", dir = "V", face = 0,   name = "竖墙9" },
    { x = -9865,    y = -13165,   id = "DL84", dir = "V", face = 0,   name = "竖墙10" },
    { x = -11224.8, y = -10484.6, id = "B000", dir = "H", face = 270, name = "横墙1" },
    { x = -9490,    y = -13448,   id = "B000", dir = "H", face = 270, name = "横墙2" },
}
Layer2Area = Layer2.walls

-- 运行时
Layer2.handles = {} -- destructable handle 列表
Layer2.wallMap = {} -- wallIndex -> handle

-- ------------------------------------------------------------
-- 墙工具
-- ------------------------------------------------------------
local function distance(ax, ay, bx, by) return ((ax - bx) ^ 2 + (ay - by) ^ 2) ^ 0.5 end

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    local h = cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
    if h then print(string.format("[Layer2] 力量墙已创建 %s id=%s at %.1f,%.1f face=%d", w.name or w.dir, w.id, w.x, w.y, face))
    else print(string.format("[Layer2] 力量墙创建失败 %s id=%s at %.1f,%.1f", w.name or w.dir, w.id, w.x, w.y)) end
    return h
end

function Layer2.createWalls()
    if #Layer2.handles > 0 then print("[Layer2] 墙体已存在，跳过 count=" .. #Layer2.handles) return Layer2.handles end
    Layer2.handles = {}; Layer2.wallMap = {}
    for i, w in ipairs(Layer2.walls) do
        local h = createOne(w)
        if h then table.insert(Layer2.handles, h); Layer2.wallMap[i] = h end
    end
    print("[Layer2] 第二关卡墙体创建完成 count=" .. #Layer2.handles .. "/" .. #Layer2.walls)
    return Layer2.handles
end

function Layer2.destroyWalls()
    for _, h in ipairs(Layer2.handles) do if h then cj.RemoveDestructable(h) end end
    local n = #Layer2.handles
    Layer2.handles = {}; Layer2.wallMap = {}
    if n > 0 then print("[Layer2] 第二关卡墙体已移除 count=" .. n) end
end

function Layer2.getCount() return #Layer2.handles end
function Layer2.isCreated() return #Layer2.handles > 0 end

-- 最近墙匹配移除（供营地/Boss击杀触发调用）
function Layer2.removeWallNear(tx, ty, reason)
    if not tx or not ty then return false end
    local bestIdx, bestDist = nil, 1e9
    for i, w in ipairs(Layer2.walls) do
        local d = distance(tx, ty, w.x, w.y)
        if d < bestDist then bestDist = d; bestIdx = i end
    end
    if not bestIdx then return false end
    local h = Layer2.wallMap[bestIdx]
    local w = Layer2.walls[bestIdx]
    if h then
        cj.RemoveDestructable(h)
        Layer2.wallMap[bestIdx] = nil
        for k, vh in ipairs(Layer2.handles) do if vh == h then table.remove(Layer2.handles, k) break end end
        print(string.format("[Layer2] 墙已移除 %s (最近 %.1f码) tx=%.1f,%.1f -> wall %s %.1f,%.1f reason=%s", w.name, bestDist, tx, ty, w.name, w.x, w.y, reason or ""))
        if SystemMessage and SystemMessage.send then
            local wallMsg = string.format("力量墙已销毁 - %s - %s", reason or w.name, w.name)
            SystemMessage.send({{"STR", wallMsg, SystemMessage.COLOR_INFO}}, 3.0)
        end
        return true
    else
        print(string.format("[Layer2] 墙已不存在或已移除 %s 最近 %.1f码", w.name, bestDist))
        return false
    end
end

-- ------------------------------------------------------------
-- 生命周期
-- ------------------------------------------------------------
Layer2.started = false

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    Layer2.createWalls()
    -- TODO: 关卡2 营地、Boss 等后续扩展
end

function Layer2.shutdown()
    if not Layer2.started then return end
    Layer2.started = false
    Layer2.destroyWalls()
    print("[Layer2] 关闭")
end

return Layer2
