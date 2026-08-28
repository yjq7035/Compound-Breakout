--|=============================================================
-- Layer4 — 第四关卡模块
--|
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡3通关后传送至此）
--
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. §1b: 创建墙体
--   3. 后续扩展：刷怪、Boss 等
--|=============================================================

Layer4 = {}
Layer4.__index = Layer4

--|=============================================================
-- §1 坐标
--|=============================================================

Layer4.entryPos    = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4.revivePos   = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4.teleportPos = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4.potionShopPos = { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

--|=============================================================
-- §1b 墙体坐标与定义（关卡 4 设定）
-- §1b: 使用 walls[1..6] 数组统一管理，创建时直接遍历
--|=============================================================

-- 横墙 (H) - B000
Layer4.wallH1 = { x = -8543.2, y = 3544.7, id = "B000", dir = "H", name = "横墙 1" }
Layer4.wallH2 = { x = -12897.8, y = 3844.4, id = "B000", dir = "H", name = "横墙 2" }
Layer4.wallH3 = { x = -10070.3, y = 5306.5, id = "B000", dir = "H", name = "横墙 3" }

-- 竖墙 (V) - DL84
Layer4.wallV1 = { x = -9596.7, y = 4296.7, id = "DL84", dir = "V", name = "竖墙 1" }
Layer4.wallV2 = { x = -12457.2, y = 2074.7, id = "DL84", dir = "V", name = "竖墙 2" }
Layer4.wallV3 = { x = -11647.0, y = 2867.7, id = "DL84", dir = "V", name = "竖墙 3" }

-- 墙体定义与运行时（横墙 B000, 竖墙 DL84）
Layer4.WALL_H = "B000"
Layer4.WALL_V = "DL84"

-- §1b: 墙体坐标数组（创建时遍历使用）
Layer4.walls = {
    { index = 1, x = -8543.2, y = 3544.7, id = "B000", dir = "H", face = 270, name = "横墙 1" },
    { index = 2, x = -12897.8, y = 3844.4, id = "B000", dir = "H", face = 270, name = "横墙 2" },
    { index = 3, x = -10070.3, y = 5306.5, id = "B000", dir = "H", face = 270, name = "横墙 3" },
    { index = 4, x = -9596.7, y = 4296.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 1" },
    { index = 5, x = -12457.2, y = 2074.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 2" },
    { index = 6, x = -11647.0, y = 2867.7, id = "DL84", dir = "V", face = 0,   name = "竖墙 3" },
}

Layer4.handles    = {}  -- destructable handle 列表
Layer4.wallMap    = {}  -- index -> handle
Layer4.createDone = false  -- §1b: 墙体是否已创建

--|=============================================================
-- §2 生命周期
--|=============================================================

Layer4.started = false
Layer4.finished = false

function Layer4.start()
    if Layer4.started then return end
    Layer4.started = true
    Layer4.finished = false
    print(string.format("[Layer4] 启动 入口/复活/传送 %.1f,%.1f", Layer4.entryPos.x, Layer4.entryPos.y))
    if SystemMessage and SystemMessage.send then
        SystemMessage.send({{"STR", "关卡 4 已启动", SystemMessage.COLOR_SUCCESS}}, 3.0)
    else
        Player.sendAll("关卡 4 已启动")
    end
    -- §1b: 创建所有墙体
    Layer4.createWalls()
end

function Layer4.shutdown()
    if not Layer4.started then return end
    Layer4.started = false
    print("[Layer4] 关闭")
    -- §2a: 清理所有墙体（如果存在）
    Layer4.destroyWalls()
end

--|=============================================================
-- §1b: 墙体管理
--|=============================================================

local function createOne(w)
    if not w or not w.x or not w.y or not w.id then return nil end
    local face = w.face or (w.dir == "H" and 270 or 0)
    return cj.CreateDestructable(c2i(w.id), w.x, w.y, face, 1, 0)
end

-- §1b: 创建所有横墙和竖墙（关卡 4 启动时）
function Layer4.createWalls()
    if Layer4.createDone then return end
    print("[Layer4] §1b: 开始创建墙体...")
    for _, w in ipairs(Layer4.walls) do
        local h = createOne(w)
        if h then
            table.insert(Layer4.handles, h)
            Layer4.wallMap[w.index] = h
            print(string.format("  ✓ %s: %.1f,%.1f (%s)", w.name, w.x, w.y, w.dir))
        else
            print(string.format("  ✗ %s 创建失败", w.name))
        end
    end
    Layer4.createDone = true
end

-- §1b: 销毁所有墙体（关卡结束时）
function Layer4.destroyWalls()
    if not Layer4.createDone then return end
    print("[Layer4] §1b: 销毁所有墙体...")
    for _, h in ipairs(Layer4.handles) do
        if h then
            pcall(function() cj.RemoveDestructable(h) end)
            print(string.format("  ✓ 移除 %s", type(h)))
        end
    end
    Layer4.handles = {}
    Layer4.wallMap = {}
end

--|=============================================================
-- §3 兼容别名（保留）
--|=============================================================

Layer4EntryPos    = Layer4.entryPos
Layer4RevivePos   = Layer4.revivePos
Layer4TeleportPos = Layer4.teleportPos
Layer4PotionShopPos = Layer4.potionShopPos

return Layer4