local ffi = require("ffi")

--- @class SMODS.CrashHandler.StackTraceFormatter
--- @field lines string[]
--- @field refs table
local stackfmt = {
    lines = {},
    size = 0,
    maxSize = 1000000,
    refs = {},

    maxStringLength = 1000,
    knownTables = {
        [package.loaded] = '[package.loaded]',
        [package.loaders] = '[package.loaders]',
        [love] = '[love]',
        [_G] = '[_G]',
    }
}

--#region types

--- @alias SMODS.CrashHandler.StackTraceFormatter.TypeFunc fun(val: any, fmt: SMODS.CrashHandler.StackTraceFormatter): string

--- @type table<string, SMODS.CrashHandler.StackTraceFormatter.TypeFunc>
stackfmt.types = {}

local strmap = {
    ["\r"] = "\\r",
    ["\n"] = "\\n",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
    ["\""] = "\\\"",
    ["\\"] = "\\\\",
    ["\0"] = "\\0",
}

local function strrep(match)
    return strmap[match]
end

stackfmt.types["string"] = function(val, fmt)
    -- trim
    local len = val:len()
    local alen = len
    local hasMore = len > fmt.maxStringLength
    if hasMore then
        len = fmt.maxStringLength
        val = val:sub(1, len)
    end

    -- replace control characters
    val = val:gsub("[\r\n\t\v\"\\%z]", strrep)

    -- quotation marks
    if hasMore then
        return string.format("\"%s\"..%d more", val, alen - len)
    else
        return string.format('"%s"', val)
    end
end

stackfmt.types["function"] = function(val)
    if not debug then
        return string.format("[function: <%p>]", val)
    end

    local info = debug.getinfo(val, "Slf")
    local src = info.linedefined ~= -1 and info.lastlinedefined ~= -1
        and string.format(" %s:%d-%d", info.source, info.linedefined, info.lastlinedefined)
        or ""

    return string.format("[%s function: <%p>%s]", info.what, val, src)
end

stackfmt.types["table"] = function(val, fmt)
    return fmt.knownTables[val] or string.format("[table: <%p>]", val)
end

stackfmt.types["userdata"] = function(val)
    return string.format("[%s]", val)
end

stackfmt.types["cdata"] = function(val)
    local t = ffi.typeof(val)
    local sok, size = pcall(ffi.sizeof, val)
    local tok, tinfo = pcall(ffi.typeinfo, val) --- @diagnostic disable-line
    size = sok and size or '?' --- @diagnostic disable-line

    return tok
        and string.format('[%s[%s]]', val, size)
        or string.format('[cdata[%s]: %p (%s)]', size, val, t)
end

--#endregion

--- @protected
--- @param line string
function stackfmt:put(line)
    if self:sizeLimitReached() then return end
    self.size = self.size + #line
    table.insert(self.lines, line)
end

--- @protected
--- @param fmt string
function stackfmt:putf(fmt, ...)
    return self:put(fmt:format(...))
end

--- @protected
function stackfmt:sizeLimitReached()
    return self.size >= self.maxSize
end

--- @protected
--- @param stack SMODS.CrashHandler.Stack
function stackfmt:formatHead(stack)
    local funcsrc = stack.source
    if funcsrc:sub(1,1) == '@' or funcsrc:sub(1,1) == '=' then funcsrc = funcsrc:sub(2) end

    if funcsrc then
        local kind, id, path = funcsrc:match('^%[([^ ]+) ([^ ]+) "(.+)"%]$')
        if kind then
            funcsrc = kind == 'SMODS' and id == '_' and string.format('[%s] %s', kind, path)
                or string.format('[%s: %s] %s', kind, id, path)
        end
    end

    return string.format(
        ' - %s%s (%s%s%s)',
        funcsrc, -- function source
        stack.currentline ~= -1 and ':'..stack.currentline or '', -- current line
        stack.namewhat ~= '' and stack.namewhat..' ' or '', -- field
        stack.name and stack.name or '?', -- call name
        stack.linedefined ~= -1 and string.format(':%d-%d', stack.linedefined, stack.lastlinedefined) or '' -- line range
    )
end

function stackfmt:formatVal(val)
    local valtype = type(val)
    return self.types[valtype] and self.types[valtype](val, self) or tostring(val)
end

--- @protected
function stackfmt:formatVarEntry(name, val)
    if type(val) == "table" and not self.knownTables[val] then
        self.refs[val] = true
    end
    self:putf('   - %s: %s', name, self:formatVal(val))
end

--- @protected
--- @param stack SMODS.CrashHandler.Stack
function stackfmt:formatStack(stack)
    if self:sizeLimitReached() then return end
    self:put(self:formatHead(stack))

    self:put('   locals:')
    for i,v in ipairs(stack.locals) do
        self:formatVarEntry(v[1], v[2])
    end

    self:put('   upvalues:')
    for i=1, 200, 1 do
        local k, v = debug.getupvalue(stack.func, i)
        if not k then break end
        self:formatVarEntry(k, v)
    end
end

--- @param tbl any
--- @param stack? string
--- @param maxDepth? number If 0, don't inspect the table
--- @param indentLevel? number
function stackfmt:inspectTable(tbl, stack, maxDepth, indentLevel)
    stack = stack or "  "
    maxDepth = maxDepth or 2
    indentLevel = indentLevel or 0

    if type(tbl) ~= 'table' then return self:formatVal(tbl) end
    if self.knownTables[tbl] then return self.knownTables[tbl] end
    if maxDepth <= 0 then return '{...}' end
    if not next(tbl) then return '{}' end

    local parts = {'{'}
    local indent = '\n'..string.rep(stack, indentLevel+1)
    local prop = 0
    for k,v in pairs(tbl) do
        prop = prop + 1
        if prop > 50 then
            table.insert(parts, indent)
            table.insert(parts, '(more...)')
            break
        end

        table.insert(parts, indent)
        table.insert(parts, self:formatVal(k))
        table.insert(parts, ': ')
        table.insert(parts, self:inspectTable(v, stack, maxDepth - 1, indentLevel + 1))
    end

    table.insert(parts, '\n')
    table.insert(parts, string.rep(stack, indentLevel))
    table.insert(parts, '}')

    return table.concat(parts)
end

--- @param stacklist SMODS.CrashHandler.Stack[]
--- @param maxSize? number
function stackfmt:format(stacklist, maxSize)
    self.lines = {}
    self.refs = {}
    self.size = 0
    self.maxSize = maxSize or 1000000

    for i,stack in ipairs(stacklist) do
        if self:sizeLimitReached() then break end
        self:formatStack(stack)
    end
    if next(self.refs) then
        self:put("")
        self:put("References:")
        for k in pairs(self.refs) do
            if self:sizeLimitReached() then break end
            self:putf("[%p]: %s", k, self:inspectTable(k))
            self:putf("")
        end
    end

    return table.concat(self.lines, '\n'), self.refs
end

return stackfmt