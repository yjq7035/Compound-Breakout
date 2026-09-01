--|=============================================================
-- Layer5 — 第五关卡模块
--|
-- 职责：
--   1. 存放第五关卡坐标（入口/复活、传送）
--   2. §1: 创建可破坏物（墙壁、障碍物等）
--   3. §2: 玩法系统
--   4. §3: 通关条件检测
--|=============================================================

-- ============================================================
-- [常量] 关卡 5 坐标配置
-- ============================================================

Layer5 = {}
Layer5.__index = Layer5

--|=============================================================
-- §1 坐标
--|=============================================================
Layer5.entryPos     = { x = -8000.0, y = 1000.0, name = "关卡 5 入口/复活" }
Layer5.revivePos    = { x = -8000.0, y = 1000.0, name = "关卡 5 复活点" }
Layer5.teleportPos  = { x = -8000.0, y = 1000.0, name = "关卡 5 传送点" }

--|=============================================================
-- §1: 可破坏物定义
-- ============================================================

Layer5.destructables = {
    -- 横墙 1-10
    { index = 1, x = -8200.0,  y = 500.0,  id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 1" },
    { index = 2, x = -8100.0,  y = 600.0,  id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 2" },
    { index = 3, x = -8000.0,  y = 700.0,  id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 3" },
    { index = 4, x = -7900.0,  y = 800.0,  id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 4" },
    { index = 5, x = -7800.0,  y = 900.0,  id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 5" },
    { index = 6, x = -8100.0,  y = 1100.0, id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 6" },
    { index = 7, x = -8200.0,  y = 1200.0, id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 7" },
    { index = 8, x = -8150.0,  y = 1300.0, id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 8" },
    { index = 9, x = -8100.0,  y = 1400.0, id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 9" },
    { index = 10, x = -8050.0, y = 1500.0, id = "B000", dir = "H", face = 270, hp = 500, name = "横墙 10" },
    
    -- 竖墙 1-5
    { index = 11, x = -8250.0, y = 800.0,  id = "DL84", dir = "V", face = 0,   hp = 500, name = "竖墙 1" },
    { index = 12, x = -8150.0, y = 900.0,  id = "DL84", dir = "V", face = 0,   hp = 500, name = "竖墙 2" },
    { index = 13, x = -8050.0, y = 1000.0, id = "DL84", dir = "V", face = 0,   hp = 500, name = "竖墙 3" },
    { index = 14, x = -7950.0, y = 1100.0, id = "DL84", dir = "V", face = 0,   hp = 500, name = "竖墙 4" },
    { index = 15, x = -7850.0, y = 1200.0, id = "DL84", dir = "V", face = 0,   hp = 500, name = "竖墙 5" },
}

Layer5.handles     = {}    -- destructable handle 列表
Layer5.wallMap     = {}    -- index -> handle
Layer5.createDone  = false
Layer5.started     = false
Layer5.finished    = false

--|=============================================================
-- §1: 可破坏物管理
-- ============================================================

--- 创建可破坏物（墙体）
---@param w table 墙体配置
---@return Destroyable|nil 可破坏物对象
local function createDestructable(w)
    if not w or not w.x or not w.y or not w.id then
        print(string.format("[Layer5] createDestructable: nil params w=%s", tostring(w and w.name or w)))
        return nil
    end
    
    local face = w.face or (w.dir == "H" and 270 or 0)
    local typeId = c2i(w.id) or 0
    local x, y = tonumber(w.x), tonumber(w.y)
    
    if not x or not y then
        print(string.format("[Layer5] createDestructable: bad coords id=%s", tostring(w.id)))
        return nil
    end
    
    -- 创建可破坏物
    local d = Destroyable:new(x, y, typeId, face, 1, 0)
    if d then
        print(string.format("[Layer5] ✓ 创建可破坏物：%s at %.1f,%.1f (%s)", w.name, x, y, w.dir))
        return d
    else
        print(string.format("[Layer5] ✗ 创建可破坏物失败：%s", w.name or "?"))
        return nil
    end
end

--- 批量创建所有可破坏物
function Layer5.createDestructables()
    if Layer5.createDone then
        print("[Layer5] 可破坏物已创建，跳过")
        return
    end
    
    print("[Layer5] §1: 开始创建可破坏物...")
    
    for _, w in ipairs(Layer5.destructables) do
        local d = createDestructable(w)
        if d then
            d:setLife(w.hp)
            
            -- 注册摧毁事件监听器：输出凶手名字
            d:onDestroyed(function(srcHandle, destructable)
                -- 从 handle 获取凶手单位对象
                local srcUnit = Unit.fromHandle(srcHandle)
                
                if srcUnit then
                    -- 获取凶手名字
                    local killerName = srcUnit:getName()
                    
                    -- 获取可破坏物信息
                    local destructableType = destructable:getTypeCode()
                    local destructableName = destructable:getName()
                    local destructablePos = { x = destructable:getX(), y = destructable:getY() }
                    local destructableId = destructable:getId()
                    
                    -- 输出凶手信息到控制台
                    print(string.format("[Layer5] ⊘ 可破坏物 [%s] 被摧毁！凶手：%s (ID=%d) 位置：%.1f,%.1f", 
                        destructableName, killerName, destructableId, destructablePos.x, destructablePos.y))
                    
                    -- 如果需要 UI 显示，可以取消注释以下代码
                    -- if SystemMessage and SystemMessage.send then
                    --     SystemMessage.send({
                    --         {"STR", "凶手：" .. killerName .. " 摧毁了 " .. destructableName .. "!"},
                    --         SystemMessage.COLOR_WARN
                    --     }, 3.0)
                    -- end
                else
                    print(string.format("[Layer5] ⊘ 可破坏物 [%s] 被摧毁！凶手 unknown", 
                        destructable and destructable:getName() or "?"))
                end
            end)
            
            table.insert(Layer5.handles, d)
            Layer5.wallMap[w.index] = d
        else
            print(string.format("[Layer5] ✗ 可破坏物 %s 创建失败", w.name))
        end
    end
    
    Layer5.createDone = true
    print(string.format("[Layer5] §1: 共创建 %d 个可破坏物", #Layer5.handles))
end

--- 销毁所有可破坏物
function Layer5.destroyDestructables()
    if not Layer5.createDone and #Layer5.handles == 0 and not next(Layer5.wallMap) then
        return
    end
    
    print("[Layer5] §1: 销毁所有可破坏物...")
    
    for _, d in ipairs(Layer5.handles) do
        if d then
            pcall(function() d:destroy() end)
        end
    end
    
    Layer5.handles = {}
    Layer5.wallMap = {}
    Layer5.createDone = false
    print("[Layer5] 所有可破坏物已销毁")
end

--|=============================================================
-- §2 玩法配置
-- ============================================================

Layer5.playConfig = {
    mobSpawnRects = {
        { id = "A", cx = -9500.0, cy = 800.0, width = 3000.0, height = 2000.0, name = "矩形 A 刷怪区" },
        { id = "B", cx = -8000.0, cy = 1600.0, width = 2000.0, height = 3000.0, name = "矩形 B 刷怪区" },
    },
    finishArea = {
        { id = "C", minx = -7500.0, miny = 500.0, maxx = -7000.0, maxy = 1700.0, name = "矩形 C 通关区" },
    },
}

Layer5.playTriggered = false
Layer5.mobHandles = {}

--|=============================================================
-- §3 关卡生命周期
-- ============================================================

function Layer5.start()
    if Layer5.started then
        print("[Layer5] 已启动，跳过")
        return
    end
    
    Layer5.started = true
    Layer5.finished = false
    Layer5.playTriggered = false
    Layer5.mobHandles = {}
    
    print(string.format("[Layer5] 启动 %.1f,%.1f", Layer5.entryPos.x, Layer5.entryPos.y))
    
    -- 创建可破坏物
    Layer5.createDestructables()
end

function Layer5.shutdown()
    if not Layer5.started and not Layer5.finished then
        -- 允许重复调用清理
    end
    
    Layer5.started = false
    print("[Layer5] 关闭")
    
    -- 销毁所有可破坏物
    Layer5.destroyDestructables()
end

--|=============================================================
-- §4 兼容别名
-- ============================================================

Layer5EntryPos     = Layer5.entryPos
Layer5RevivePos    = Layer5.revivePos
Layer5TeleportPos  = Layer5.teleportPos

return Layer5
