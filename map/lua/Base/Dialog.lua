-- ============================================================
-- Dialog 类 — 对话框
-- 调用方式：
--   local d = Dialog:new("请选择")
--   d:addButton("选项一", "Q"):addButton("选项二", "W")
--   d:show(player, function(val) print(val) end)
-- ============================================================

---@class Dialog 对话框
Dialog = {}
Dialog.__index = Dialog
Dialog._handle = nil

-----------------------------------------------------------------
-- Dialog
-----------------------------------------------------------------
local function _hotkey(key)
    if (key == nil) then return 0 end
    if (type(key) == "number") then return key end
    if (type(key) == "string") then return string.byte(key, 1) end
    return 0
end

local function newDialog()
    local obj = { _handle = nil, _index = nil, _buttons = {}, _action = nil }
    setmetatable(obj, Dialog)
    return obj
end

--- 创建空对话框
---@param title string|nil 标题
---@return Dialog
function Dialog:new(title)
    local obj = newDialog()
    obj._handle = cj.DialogCreate()
    if (title) then cj.DialogSetMessage(obj._handle, title) end
    return obj
end

--- 销毁
---@return Dialog
function Dialog:destroy()
    if (self._handle ~= nil) then
        cj.DialogDestroy(self._handle)
        self._handle = nil
    end
    return self
end

--- 设置标题
---@param title string
---@return Dialog
function Dialog:setTitle(title)
    if (self._handle ~= nil and title ~= nil) then
        cj.DialogSetMessage(self._handle, title)
    end
    return self
end

--- 添加按钮
---@param label string 按钮文本
---@param hotkey integer|string|nil 热键（字符或键码）
---@return Dialog
function Dialog:addButton(label, hotkey)
    if (self._handle == nil or label == nil) then return self end
    local key = _hotkey(hotkey)
    local btn = cj.DialogAddButton(self._handle, label, key)
    table.insert(self._buttons, { button = btn, value = label, label = label })
    return self
end

--- 添加按钮（带返回值）
---@param value any 点击后返回的值
---@param label string 按钮文本
---@param hotkey integer|string|nil 热键
---@return Dialog
function Dialog:addButtonVal(value, label, hotkey)
    if (self._handle == nil or label == nil) then return self end
    local key = _hotkey(hotkey)
    local btn = cj.DialogAddButton(self._handle, label, key)
    table.insert(self._buttons, { button = btn, value = value, label = label })
    return self
end

--- 添加退出游戏按钮
---@param doScore boolean 是否显示得分
---@param label string 按钮文本
---@param hotkey integer|string|nil 热键
---@return Dialog
function Dialog:addQuit(doScore, label, hotkey)
    if (self._handle == nil or label == nil) then return self end
    local key = _hotkey(hotkey)
    cj.DialogAddQuitButton(self._handle, doScore, label, key)
    return self
end

--- 清空按钮
---@return Dialog
function Dialog:clear()
    if (self._handle ~= nil) then
        cj.DialogClear(self._handle)
    end
    self._buttons = {}
    return self
end

--- 显示给玩家
---@param Pl Player 玩家
---@param action function|nil 按钮点击回调
---@return Dialog
function Dialog:show(Pl, action)
    if (self._handle == nil) then return self end

    if (action ~= nil) then
        self._action = action
        local trig = cj.CreateTrigger()
        cj.TriggerRegisterDialogEvent(trig, self._handle)
        cj.TriggerAddAction(trig, function()
            local clicked = cj.GetClickedButton()
            for _, btn in ipairs(self._buttons) do
                if btn.button == clicked then
                    self._action(btn.value)
                    break
                end
            end
        end)
    end
    print("显示给玩家 " .. Pl:getName())
    -- print("对话框句柄：" .. self._handle)
    cj.DialogDisplay(Pl._handle, self._handle, true)
    return self
end

--- 隐藏
---@param Pl Player 玩家
---@return Dialog
function Dialog:hide(Pl)
    if (self._handle ~= nil and Pl._handle ~= nil) then
        cj.DialogDisplay(Pl._handle, self._handle, false)
    end
    return self
end

--- 设置异步模式
---@param async boolean
---@return Dialog
function Dialog:setAsync(async)
    if (self._handle ~= nil) then
        cj.DialogSetAsync(self._handle, (async ~= nil) and async or true)
    end
    return self
end

--- 一站式创建并显示
---@param Pl Player 玩家
---@param title string 对话框标题
---@param buttons table 按钮配置 { value, label } 或 string[]
---@param action function 回调
---@return Dialog
function Dialog.create(Pl, title, buttons, action)
    if (buttons == nil or #buttons <= 0) then return end
    if (Pl == nil) then return end

    local d = Dialog:new(title)
    for _, btn in ipairs(buttons) do
        if (type(btn) == "table") then
            d:addButtonVal(btn.value, btn.label, btn.value)
        else
            d:addButton(btn, btn)
        end
    end
    d:show(Pl, action)
    return d
end

--- 获取被点击的对话框（事件回调中调用）
---@return userdata
function Dialog.getClicked()
    return cj.GetClickedDialog()
end

--- 保存到哈希表
---@param t hashtable
---@param pk integer
---@param ck integer
---@return boolean
function Dialog:save(t, pk, ck)
    if (self._handle == nil) then return false end
    return cj.SaveDialogHandle(t, pk, ck, self._handle)
end

--- 从哈希表读取
---@param t hashtable
---@param pk integer
---@param ck integer
---@return Dialog
function Dialog.load(t, pk, ck)
    local h = cj.LoadDialogHandle(t, pk, ck)
    if (h == nil) then return end
    local obj = newDialog()
    obj._handle = h
    return obj
end
