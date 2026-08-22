-- ============================================================
-- Quest 类 — 任务系统
-- 调用方式：
--   local q = Quest:new("消灭恶魔", "前往地狱之门消灭恶魔领主")
--   q:setIconPath([[ReplaceableTextures\CommandButtons\BTNCRIT.blp]])
--   q:setRequired(true):setDiscovered(true)
--   local item = q:createItem("杀死恶魔领主 0/1")
--   item:setCompleted(true)
--   q:setCompleted(true)
-- ============================================================

---@class Quest 任务
Quest = {}
Quest.__index = Quest
Quest._handle = nil
Quest._items = nil

--@type QuestItem[]

---@class QuestItem 任务需求项
QuestItem = {}
QuestItem.__index = QuestItem
QuestItem._handle = nil

-----------------------------------------------------------------
-- 内部工厂
-----------------------------------------------------------------
local function newQuest()
    local obj = { _handle = nil, _index = nil, _items = {} }
    setmetatable(obj, Quest)
    return obj
end

local function newItem()
    local obj = { _handle = nil, _index = nil }
    setmetatable(obj, QuestItem)
    return obj
end

-----------------------------------------------------------------
-- Quest 构造 / 销毁
-----------------------------------------------------------------

--- 创建一个新任务
---@param title string|nil 任务标题
---@param description string|nil 任务描述
---@return Quest
function Quest:new(title, description)
    local obj = newQuest()
    obj._handle = cj.CreateQuest()
    if (title) then cj.QuestSetTitle(obj._handle, title) end
    if (description) then cj.QuestSetDescription(obj._handle, description) end
    return obj
end

--- 销毁任务
---@return Quest
function Quest:destroy()
    if (self._handle ~= nil) then
        cj.DestroyQuest(self._handle)
        self._handle = nil
    end
    return self
end

-----------------------------------------------------------------
-- 属性设置
-----------------------------------------------------------------

--- 设置任务标题
---@param title string
---@return Quest
function Quest:setTitle(title)
    if (self._handle ~= nil and title ~= nil) then
        cj.QuestSetTitle(self._handle, title)
    end
    return self
end

--- 设置任务说明
---@param desc string
---@return Quest
function Quest:setDescription(desc)
    if (self._handle ~= nil and desc ~= nil) then
        cj.QuestSetDescription(self._handle, desc)
    end
    return self
end

--- 设置任务图标路径
---@param iconPath string
---@return Quest
function Quest:setIconPath(iconPath)
    if (self._handle ~= nil and iconPath ~= nil) then
        cj.QuestSetIconPath(self._handle, iconPath)
    end
    return self
end

--- 设置是否为主要任务
---@param required boolean
---@return Quest
function Quest:setRequired(required)
    if (self._handle ~= nil) then
        cj.QuestSetRequired(self._handle, required)
    end
    return self
end

-----------------------------------------------------------------
-- 状态设置
-----------------------------------------------------------------

--- 设置任务完成状态
---@param completed boolean
---@return Quest
function Quest:setCompleted(completed)
    if (self._handle ~= nil) then
        cj.QuestSetCompleted(self._handle, completed)
    end
    return self
end

--- 设置任务失败状态
---@param failed boolean
---@return Quest
function Quest:setFailed(failed)
    if (self._handle ~= nil) then
        cj.QuestSetFailed(self._handle, failed)
    end
    return self
end

--- 设置任务被发现状态
---@param discovered boolean
---@return Quest
function Quest:setDiscovered(discovered)
    if (self._handle ~= nil) then
        cj.QuestSetDiscovered(self._handle, discovered)
    end
    return self
end

--- 启用/禁用任务
---@param enabled boolean
---@return Quest
function Quest:setEnabled(enabled)
    if (self._handle ~= nil) then
        cj.QuestSetEnabled(self._handle, enabled)
    end
    return self
end

-----------------------------------------------------------------
-- 状态查询
-----------------------------------------------------------------

--- 任务是否完成
---@return boolean
function Quest:isCompleted()
    if (self._handle == nil) then return false end
    return cj.IsQuestCompleted(self._handle)
end

--- 任务是否被发现
---@return boolean
function Quest:isDiscovered()
    if (self._handle == nil) then return false end
    return cj.IsQuestDiscovered(self._handle)
end

--- 任务是否激活
---@return boolean
function Quest:isEnabled()
    if (self._handle == nil) then return false end
    return cj.IsQuestEnabled(self._handle)
end

--- 任务是否失败
---@return boolean
function Quest:isFailed()
    if (self._handle == nil) then return false end
    return cj.IsQuestFailed(self._handle)
end

--- 是否是主要任务
---@return boolean
function Quest:isRequired()
    if (self._handle == nil) then return false end
    return cj.IsQuestRequired(self._handle)
end

-----------------------------------------------------------------
-- 任务需求项管理
-----------------------------------------------------------------

--- 创建一条任务需求项
---@param description string|nil 需求项描述
---@return QuestItem
function Quest:createItem(description)
    if (self._handle == nil) then return end
    local obj = newItem()
    obj._handle = cj.QuestCreateItem(self._handle)
    obj._quest = self
    if (description) then
        cj.QuestItemSetDescription(obj._handle, description)
    end
    table.insert(self._items, obj)
    return obj
end

--- 获取已创建的第 index 条需求项（从1开始）
---@param index integer
---@return QuestItem|nil
function Quest:getItem(index)
    return self._items[index]
end

--- 已创建的需求项总数
---@return integer
function Quest:itemCount()
    return #self._items
end

-----------------------------------------------------------------
-- 哈希表存取
-----------------------------------------------------------------

--- 保存任务handle到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Quest:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveQuestHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取任务并返回 Quest 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Quest
function Quest.loadHandle(t, pk, ck)
    local h = cj.LoadQuestHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newQuest()
    obj._handle = h
    return obj
end

-----------------------------------------------------------------
-- 静态工具
-----------------------------------------------------------------

--- 闪烁任务对话框按钮
function Quest.flashDialogButton()
    cj.FlashQuestDialogButton()
end

--- 强制更新任务对话框
function Quest.forceUpdate()
    cj.ForceQuestDialogUpdate()
end


-- ============================================================
-- QuestItem 类 — 任务需求项
-- ============================================================

--- 设置需求项完成状态
---@param completed boolean
---@return QuestItem
function QuestItem:setCompleted(completed)
    if (self._handle ~= nil) then
        cj.QuestItemSetCompleted(self._handle, completed)
    end
    return self
end

--- 设置需求项描述文本
---@param description string
---@return QuestItem
function QuestItem:setDescription(description)
    if (self._handle ~= nil and description ~= nil) then
        cj.QuestItemSetDescription(self._handle, description)
    end
    return self
end

--- 需求项是否已完成
---@return boolean
function QuestItem:isCompleted()
    if (self._handle == nil) then return false end
    return cj.IsQuestItemCompleted(self._handle)
end

--- 返回所属的 Quest 对象
---@return Quest|nil
function QuestItem:getQuest()
    return self._handle
end

--- 保存需求项handle到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function QuestItem:saveHandle(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveQuestItemHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取需求项并返回 QuestItem 对象
---@param t hashtable
---@param pk integer
---@param ck integer
---@return QuestItem
function QuestItem.loadHandle(t, pk, ck)
    local h = cj.LoadQuestItemHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newItem()
    obj._handle = h
    return obj
end
