-- ============================================================
-- GameInit — 游戏初始化
--
-- 功能：
--   1. 开启战争迷雾 (FogEnable)
--   2. 开启黑色阴影 (FogMaskEnable)
--
-- 调用：
--   require "Game.GameInit"  -- 自动执行初始化，无需手动调用
--
-- 说明：
--   - 使用 Terrain 封装 + cj 原生双重调用，确保生效
--   - 立即执行 + 0秒延时二次执行，防止被地图默认设置覆盖
-- ============================================================

GameInit = {}

--- 应用迷雾设置
function GameInit.apply()
    -- 封装 API（见 Terrain.lua:284,290）
    if Terrain and Terrain.setFogEnabled then
        Terrain.setFogEnabled(true)
    else
        cj.FogEnable(true)
    end

    if Terrain and Terrain.setFogMaskEnabled then
        Terrain.setFogMaskEnabled(true)
    else
        cj.FogMaskEnable(true)
    end

    -- 原生兜底（双保险）
    cj.FogEnable(true)
    cj.FogMaskEnable(true)
end

--- 初始化入口
function GameInit.init()
    GameInit.apply()

    -- 延迟 0 秒再执行一次，确保在地图初始化完成后覆盖编辑器默认配置
    Timer:new(0, false, function()
        GameInit.apply()
    end)
end

-- 自动初始化
GameInit.init()
