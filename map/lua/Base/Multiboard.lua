-- ============================================================
-- Multiboard 类 — 多面板
-- Leaderboard 类 — 排行榜
-- ============================================================

---@class Multiboard 多面板
Multiboard = {}
Multiboard.__index = Multiboard

---@class Leaderboard 排行榜
Leaderboard = {}
Leaderboard.__index = Leaderboard

-----------------------------------------------------------------
-- Multiboard
-----------------------------------------------------------------
local function newMultiboard()
    local obj = { _handle = nil, _rows = 0, _cols = 0 }
    setmetatable(obj, Multiboard)
    return obj
end

--- 创建空多面板
---@param title string|nil 标题
---@return Multiboard
function Multiboard:new(title)
    local obj = newMultiboard()
    obj._handle = cj.CreateMultiboard()
    if title then cj.MultiboardSetTitleText(obj._handle, title) end
    return obj
end

--- 销毁
---@return Multiboard
function Multiboard:destroy()
    if self._handle ~= nil then
        cj.DestroyMultiboard(self._handle)
        self._handle = nil
    end
    return self
end

--- 设置标题文本
---@param text string
---@return Multiboard
function Multiboard:setTitle(text)
    if self._handle ~= nil then
        cj.MultiboardSetTitleText(self._handle, text)
    end
    return self
end

--- 设置行列数
---@param rows integer
---@param cols integer
---@return Multiboard
function Multiboard:setSize(rows, cols)
    if self._handle ~= nil then
        cj.MultiboardSetRowCount(self._handle, rows)
        cj.MultiboardSetColumnCount(self._handle, cols)
        self._rows = rows
        self._cols = cols
    end
    return self
end

--- 获取行数
---@return integer
function Multiboard:getRowCount()
    if self._handle == nil then return 0 end
    return cj.MultiboardGetRowCount(self._handle)
end

--- 获取列数
---@return integer
function Multiboard:getColumnCount()
    if self._handle == nil then return 0 end
    return cj.MultiboardGetColumnCount(self._handle)
end

--- 设置所有单元格宽度（小数，0.08 ≈ 8%屏幕宽度）
---@param width number 宽度值（典型 0.04 ~ 0.15）
---@return Multiboard
function Multiboard:setAllItemWidth(width)
    if self._handle ~= nil then
        cj.MultiboardSetItemsWidth(self._handle, width)
    end
    return self
end

--- 设置指定单元格宽度
---@param row integer
---@param col integer
---@param width number 宽度值（典型 0.04 ~ 0.15）
---@return Multiboard
function Multiboard:setItemWidth(row, col, width)
    if self._handle ~= nil then
        local mbi = cj.MultiboardGetItem(self._handle, row, col)
        if mbi then
            cj.MultiboardSetItemWidth(mbi, width)
            cj.MultiboardReleaseItem(mbi)
        end
    end
    return self
end

--- 设置所有单元格样式
---@param showValue boolean
---@param showIcon boolean
---@return Multiboard
function Multiboard:setAllItemStyle(showValue, showIcon)
    if self._handle ~= nil then
        cj.MultiboardSetItemsStyle(self._handle, showValue, showIcon)
    end
    return self
end

--- 设置指定单元格文本
---@param row integer
---@param col integer
---@param text string
---@return Multiboard
function Multiboard:setText(row, col, text)
    if self._handle ~= nil then
        local mbi = cj.MultiboardGetItem(self._handle, row, col)
        if mbi then
            cj.MultiboardSetItemValue(mbi, text)
            cj.MultiboardReleaseItem(mbi)
        end
    end
    return self
end

--- 设置指定单元格图标
---@param row integer
---@param col integer
---@param iconPath string
---@return Multiboard
function Multiboard:setIcon(row, col, iconPath)
    if self._handle ~= nil then
        local mbi = cj.MultiboardGetItem(self._handle, row, col)
        if mbi then
            cj.MultiboardSetItemIcon(mbi, iconPath)
            cj.MultiboardReleaseItem(mbi)
        end
    end
    return self
end

--- 设置指定单元格样式
---@param row integer
---@param col integer
---@param showValue boolean
---@param showIcon boolean
---@return Multiboard
function Multiboard:setItemStyle(row, col, showValue, showIcon)
    if self._handle ~= nil then
        local mbi = cj.MultiboardGetItem(self._handle, row, col)
        if mbi then
            cj.MultiboardSetItemStyle(mbi, showValue, showIcon)
            cj.MultiboardReleaseItem(mbi)
        end
    end
    return self
end

--- 设置指定单元格颜色
---@param row integer
---@param col integer
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return Multiboard
function Multiboard:setItemColor(row, col, r, g, b, a)
    if self._handle ~= nil then
        local mbi = cj.MultiboardGetItem(self._handle, row, col)
        if mbi then
            cj.MultiboardSetItemValueColor(mbi, r, g, b, a)
            cj.MultiboardReleaseItem(mbi)
        end
    end
    return self
end

--- 设置多面板显示
---@param show boolean
---@return Multiboard
function Multiboard:show(show)
    if self._handle ~= nil then
        cj.MultiboardDisplay(self._handle, show)
    end
    return self
end

--- 是否显示
---@return boolean
function Multiboard:isShown()
    if self._handle == nil then return false end
    return cj.IsMultiboardDisplayed(self._handle)
end

--- 获取frame handle
---@return userdata|nil
function Multiboard:getFrame()
    if self._handle == nil then return end
    return cdz.DzMultiboardGetFrame(self._handle)
end

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Multiboard:save(t, pk, ck)
    if self._handle == nil then return false end
    return cj.SaveMultiboardHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Multiboard
function Multiboard.load(t, pk, ck)
    local h = cj.LoadMultiboardHandle(t, pk, ck)
    if h == nil then return end
    local obj = newMultiboard()
    obj._handle = h
    return obj
end

-----------------------------------------------------------------
-- Leaderboard 排行榜
-- 基于 WC3 原生排行榜（cj.* 已映射的原生函数）
-- 说明：原生排行榜【没有“列(Column)”概念】——每行 = 1 个玩家，
--   含 名称(label) + 数值(value)（+ 可选图标）。本项目 cj 映射的是
--   “索引项”API：LeaderboardAddItem 返回索引，后续用
--   LeaderboardSetItemValue(lb, index, val) 改值、LeaderboardSetItem*Color 上色。
--   （原 Multiboard.lua 里的 LeaderboardSetTitle / LeaderboardAddPlayer /
--    LeaderboardModifyPlayer / LeaderboardSetPlayerColor 等都是臆造名，
--    标准 WC3 无这些原生，已按真实 API 重写。）
-----------------------------------------------------------------
local function newLeaderboard()
    local obj = { _handle = nil, _items = {} }
    setmetatable(obj, Leaderboard)
    return obj
end

--- 取玩家句柄（兼容 Player 对象 / 原生 userdata）
local function _lbPlayerHandle(Pl)
    return Pl._handle or Pl
end

--- 取玩家内部索引键（用于 _items 表）
local function _lbPlayerKey(Pl)
    return cj.GetHandleId(_lbPlayerHandle(Pl))
end

--- 创建排行榜
---@param title string|nil 标题
---@return Leaderboard
function Leaderboard:new(title)
    local obj = newLeaderboard()
    obj._handle = cj.CreateLeaderboard()
    if title then cj.LeaderboardSetLabel(obj._handle, title) end
    -- 默认显示 名称 + 数值（不显示图标）
    cj.LeaderboardSetStyle(obj._handle, true, true, true, false)
    return obj
end

--- 销毁
---@return Leaderboard
function Leaderboard:destroy()
    if self._handle ~= nil then
        cj.DestroyLeaderboard(self._handle)
        self._handle = nil
        self._items = {}
    end
    return self
end

--- 设置标题文本
---@param text string
---@return Leaderboard
function Leaderboard:setTitle(text)
    if self._handle ~= nil then
        cj.LeaderboardSetLabel(self._handle, text)
    end
    return self
end

--- 添加玩家行（并设初始数值）
--- LeaderboardAddItem 返回 leaderboard handle，需再用 LeaderboardGetPlayerIndex 取索引
---@param Pl Player|userdata
---@param value number 初始数值
---@return Leaderboard
function Leaderboard:addPlayer(Pl, value)
    if self._handle == nil then return self end
    local key = _lbPlayerKey(Pl)
    if self._items[key] ~= nil then return self end   -- 已添加则跳过
    local h = _lbPlayerHandle(Pl)
    local label = cj.GetPlayerName(h) or ""
    cj.LeaderboardAddItem(self._handle, label, value, h)
    local idx = cj.LeaderboardGetPlayerIndex(self._handle, h)
    -- WC3 索引通常 1-based；返回 ≤0 视为无效，回退到按玩家操作
    if type(idx) == "number" and idx > 0 then
        self._items[key] = idx
    else
        -- 缓存玩家句柄而非索引，后续 modifyPlayer/removePlayer 走原生玩家路径
        self._items[key] = h
    end
    return self
end

--- 修改玩家数值
---@param Pl Player|userdata
---@param value number
---@return Leaderboard
function Leaderboard:modifyPlayer(Pl, value)
    if self._handle == nil then return self end
    local key = _lbPlayerKey(Pl)
    local cached = self._items[key]
    if cached == nil then return self end
    if type(cached) == "number" then
        -- 缓存的是索引（1-based）
        cj.LeaderboardSetItemValue(self._handle, cached, value)
    else
        -- 缓存的是玩家句柄，走原生按玩家改值路径
        local h = _lbPlayerHandle(Pl)
        local idx = cj.LeaderboardGetPlayerIndex(self._handle, h)
        if type(idx) == "number" and idx > 0 then
            cj.LeaderboardSetItemValue(self._handle, idx, value)
            -- 更新缓存为索引，后续更快
            self._items[key] = idx
        end
    end
    return self
end

--- 移除玩家行
---@param Pl Player|userdata
---@return Leaderboard
function Leaderboard:removePlayer(Pl)
    if self._handle == nil then return self end
    local key = _lbPlayerKey(Pl)
    local cached = self._items[key]
    if cached ~= nil then
        if type(cached) == "number" then
            cj.LeaderboardRemoveItem(self._handle, cached)
        else
            cj.LeaderboardRemovePlayerItem(self._handle, _lbPlayerHandle(Pl))
        end
        self._items[key] = nil
    end
    return self
end

--- 设置玩家名称（label）
---@param Pl Player|userdata
---@param text string
---@return Leaderboard
function Leaderboard:setPlayerText(Pl, text)
    if self._handle == nil then return self end
    local key = _lbPlayerKey(Pl)
    local cached = self._items[key]
    if cached == nil then return self end
    local idx = nil
    if type(cached) == "number" then
        idx = cached
    else
        local h = _lbPlayerHandle(Pl)
        idx = cj.LeaderboardGetPlayerIndex(self._handle, h)
        if type(idx) == "number" and idx > 0 then
            self._items[key] = idx
        else
            return self
        end
    end
    cj.LeaderboardSetItemLabel(self._handle, idx, text)
    return self
end

--- 设置玩家整行颜色（名称 + 数值 同时着色）
---@param Pl Player|userdata
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return Leaderboard
function Leaderboard:setPlayerColor(Pl, r, g, b, a)
    if self._handle == nil then return self end
    local key = _lbPlayerKey(Pl)
    local cached = self._items[key]
    if cached == nil then return self end
    local idx = nil
    if type(cached) == "number" then
        idx = cached
    else
        local h = _lbPlayerHandle(Pl)
        idx = cj.LeaderboardGetPlayerIndex(self._handle, h)
        if type(idx) == "number" and idx > 0 then
            self._items[key] = idx
        else
            return self  -- 取不到索引，跳过
        end
    end
    cj.LeaderboardSetItemLabelColor(self._handle, idx, r, g, b, a)
    cj.LeaderboardSetItemValueColor(self._handle, idx, r, g, b, a)
    return self
end

--- 设置整块数值（value）颜色
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return Leaderboard
function Leaderboard:setValueColor(r, g, b, a)
    if self._handle ~= nil then
        cj.LeaderboardSetValueColor(self._handle, r, g, b, a)
    end
    return self
end

--- 设置排序：true=升序，false=降序（高伤置顶用 false）
---@param ascending boolean
---@return Leaderboard
function Leaderboard:setSortByValue(ascending)
    if self._handle ~= nil then
        cj.LeaderboardSortItemsByValue(self._handle, ascending)
    end
    return self
end

--- 设置显示
---@param show boolean
---@return Leaderboard
function Leaderboard:show(show)
    if self._handle ~= nil then
        cj.LeaderboardDisplay(self._handle, show)
    end
    return self
end

--- 是否显示
---@return boolean
function Leaderboard:isShown()
    if self._handle == nil then return false end
    return cj.IsLeaderboardDisplayed(self._handle)
end

--- 获取frame handle
---@return userdata|nil
function Leaderboard:getFrame()
    if self._handle == nil then return end
    return cdz.DzLeaderboardGetFrame(self._handle)
end

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Leaderboard:save(t, pk, ck)
    if self._handle == nil then return false end
    return cj.SaveLeaderboardHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Leaderboard
function Leaderboard.load(t, pk, ck)
    local h = cj.LoadLeaderboardHandle(t, pk, ck)
    if h == nil then return end
    local obj = newLeaderboard()
    obj._handle = h
    return obj
end