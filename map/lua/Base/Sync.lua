-- ============================================================
-- Sync 类 — 数据同步对象（自动前缀，互不冲突）
-- 调用方式：
--   local sync = Sync:new(function(syncPlayer, data)
--       -- 收到同步数据时回调
--   end)
--   sync:send("hello")
-- ============================================================

---@class Sync 数据同步对象
Sync = {}
Sync.__index = Sync

local _counter = 0  -- 自增计数器，确保前缀唯一

-----------------------------------------------------------------
-- 构造
-----------------------------------------------------------------

--- 创建同步对象，自动生成唯一前缀并注册接收监听
---@param onReceive fun(syncPlayer: Player, data: string): string? 接收回调 (syncPlayer: Player, data: string) string?
---@return Sync
function Sync:new(onReceive)
    _counter = _counter + 1
    local prefix = "SYNC_" .. _counter .. "_"

    local obj = {
        _prefix = prefix,
        _trigger = cj.CreateTrigger(),
    }
    setmetatable(obj, Sync)

    -- 注册同步接收（server=false，不走平台服务器）
    cdz.DzTriggerRegisterSyncData(obj._trigger, prefix, false)
    cj.TriggerAddAction(obj._trigger, function()
        if onReceive then
            onReceive(Player.fromHandle(cdz.DzGetTriggerSyncPlayer()), cdz.DzGetTriggerSyncData())
        end
    end)

    return obj
end

-----------------------------------------------------------------
-- 发送
-----------------------------------------------------------------

--- 发送同步数据（立即发送）
---@param data string 数据内容
---@return Sync
function Sync:send(data)
    if self._prefix == nil or data == nil then return self end
    cdz.DzSyncDataImmediately(self._prefix, data)
    return self
end
