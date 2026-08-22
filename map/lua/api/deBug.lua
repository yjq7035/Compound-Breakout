-- ============================================================
-- deBug — 调试与错误处理工具
-- ============================================================

DEBUGGING = true
JassRuntime = require "jass.runtime"
JassRuntime.console = true
JassRuntime.sleep = false

local console = require "jass.console"

-----------------------------------------------------------------
-- error_handle — 未捕获 Lua 错误的兜底输出
-----------------------------------------------------------------
JassRuntime.error_handle = function(msg)
    local lines = debug.traceback(tostring(msg))
    console.write("========lua-err========")
    for line in lines:gmatch("[^\n]+") do
        console.write(line)
    end
    console.write("=========================")
end

-----------------------------------------------------------------
-- print — 接管原生 print，逐行输出避免截断
-----------------------------------------------------------------
print = function(...)
    local n = select("#", ...)
    local text
    if (n <= 1) then
        text = tostring(...)
    else
        local parts = {}
        for i = 1, n do
            parts[i] = tostring(select(i, ...))
        end
        text = table.concat(parts, "\t")
    end
    -- 多行文本逐行发送，避免 JassConsole.write 单行截断
    if (text:find("\n")) then
        for line in text:gmatch("[^\n]+") do
            console.write(line)
        end
    else
        console.write(text)
    end
end

-----------------------------------------------------------------
-- tlen — table 长度（不依赖 #）
-----------------------------------------------------------------
function tlen(t)
    local n = 0
    for _ in pairs(t or {}) do
        n = n + 1
    end
    return n
end

-----------------------------------------------------------------
-- stack — 打印当前调用栈
-----------------------------------------------------------------
function stack(...)
    local parts = { "[TRACE]" }
    local n = select("#", ...)
    for i = 1, n do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    parts[#parts + 1] = ""
    parts[#parts + 1] = debug.traceback("", 2)
    for line in table.concat(parts, " "):gmatch("[^\n]+") do
        console.write(line)
    end
end

-----------------------------------------------------------------
-- dump — 递归打印 table/值
-----------------------------------------------------------------
function dump(value, description, nesting)
    if (type(nesting) ~= "number") then nesting = 10 end
    local lookup = {}
    local result = {}
    local tb = debug.traceback("", 2)
    local src = "- dump from: " .. (tb:match("[^\n]+") or "?")
    if (tb:match("[^\n]+\n([^\n]+)")) then
        src = "- dump from: " .. (tb:match("[^\n]+\n([^\n]+)") or "?")
        src = src:gsub("^[\t ]*", "")
    end

    local function fmt(v)
        if (type(v) == "string") then return "\"" .. v .. "\"" end
        return tostring(v)
    end

    local function walk(val, desc, indent, nest, keyLen)
        desc = desc or "<var>"
        local pad = ""
        if (type(keyLen) == "number") then
            pad = string.rep(" ", keyLen - #fmt(desc))
        end
        if (type(val) ~= "table") then
            result[#result + 1] = string.format("%s%s%s = %s", indent, fmt(desc), pad, fmt(val))
        elseif lookup[tostring(val)] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, fmt(desc), pad)
        else
            lookup[tostring(val)] = true
            if (nest > nesting) then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, fmt(desc))
                return
            end
            result[#result + 1] = string.format("%s%s = {", indent, fmt(desc))
            local sub = indent .. "    "
            local keys = {}
            local maxLen = 0
            local vals = {}
            for k, v in pairs(val) do
                if (k ~= "___message") then
                    keys[#keys + 1] = k
                    local kStr = fmt(k)
                    local kLen = #kStr
                    if (kLen > maxLen) then maxLen = kLen end
                    vals[k] = v
                end
            end
            table.sort(keys, function(a, b)
                if (type(a) == "number" and type(b) == "number") then return a < b end
                return tostring(a) < tostring(b)
            end)
            for _, k in ipairs(keys) do
                walk(vals[k], k, sub, nest + 1, maxLen)
            end
            result[#result + 1] = string.format("%s}", indent)
        end
    end

    walk(value, description, " ", 1)
    local text = src .. "\n" .. table.concat(result, "\n")
    for line in text:gmatch("[^\n]+") do
        console.write(line)
    end
end

-----------------------------------------------------------------
-- err — 快捷错误调试
-----------------------------------------------------------------
function err(val)
    console.write("=========sl-err=========")
    if (type(val) == "table") then
        dump(val)
    else
        for line in tostring(val):gmatch("[^\n]+") do
            console.write(line)
        end
    end
    stack()
    console.write("=========================")
end

-----------------------------------------------------------------
-- wrapJass — 用 xpcall 包装 Jass 原生函数
-- 在 lua.lua 中 API 加载完成后调用：
--   wrapJass(cj, "cj")
--   wrapJass(cdz, "cdz")
-----------------------------------------------------------------
function wrapJass(tbl, name)
    if (not tbl) then return end
    for k, v in pairs(tbl) do
        if (type(v) == "function") then
            local fn = v
            local fnName = tostring(k)
            tbl[k] = function(...)
                local results = {}
                local ok = xpcall(function(...)
                    results = { fn(...) }
                end, function(err)
                    console.write("========lua-err========")
                    console.write("[错误 / Error] " .. name .. "." .. fnName .. " 崩溃 / crashed:")
                    for line in tostring(err):gmatch("[^\n]+") do
                        console.write(line)
                    end
                    console.write("---")
                    console.write("[调用栈 / Call Stack]:")
                    for line in debug.traceback("", 2):gmatch("[^\n]+") do
                        console.write(line)
                    end
                    console.write("=========================")
                end, ...)
                if (not ok) then return nil end
                return table.unpack(results)
            end
        end
    end
end


