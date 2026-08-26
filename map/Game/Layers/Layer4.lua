-- ============================================================
-- Layer4 — 第四关卡模块
--
-- 坐标：入口/复活/传送 -8518.2,747.9（由关卡3通关后传送至此）
--
-- 职责：
--   1. 存放第四关卡坐标（入口/复活、传送）
--   2. 提供关卡生命周期：Layer4.start / Layer4.shutdown
--   3. 后续扩展：墙体、刷怪、Boss 等
-- ============================================================

Layer4 = {}
Layer4.__index = Layer4

-- ============================================================
-- §1 坐标
-- ============================================================

Layer4.entryPos    = { x = -8518.2, y = 747.9, name = "关卡 4 入口/复活/传送" }
Layer4.revivePos   = { x = -8518.2, y = 747.9, name = "关卡 4 复活点" }
Layer4.teleportPos = { x = -8518.2, y = 747.9, name = "关卡 4 传送点" }
Layer4.potionShopPos = { x = -8518.2, y = 747.9, name = "关卡 4 药剂商店（占位）" }

-- ============================================================
-- §2 生命周期
-- ============================================================

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
    -- TODO: 关卡 4 墙体、刷怪、Boss 等后续扩展
end

function Layer4.shutdown()
    if not Layer4.started then return end
    Layer4.started = false
    print("[Layer4] 关闭")
end

-- ============================================================
-- §3 兼容别名
-- ============================================================

Layer4EntryPos    = Layer4.entryPos
Layer4RevivePos   = Layer4.revivePos
Layer4TeleportPos = Layer4.teleportPos

return Layer4
