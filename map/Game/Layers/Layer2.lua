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
-- 生命周期
-- ------------------------------------------------------------
Layer2.started = false

function Layer2.start()
    if Layer2.started then return end
    Layer2.started = true
    print(string.format("[Layer2] 启动 入口/复活 %.1f,%.1f 药剂商店 %.1f,%.1f",
        Layer2.entryPos.x, Layer2.entryPos.y, Layer2.potionShopPos.x, Layer2.potionShopPos.y))
    -- TODO: 关卡2 墙、营地、Boss 等后续扩展
end

function Layer2.shutdown()
    if not Layer2.started then return end
    Layer2.started = false
    print("[Layer2] 关闭")
end

return Layer2
