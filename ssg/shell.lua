-- @str (string) the string to trim
-- returns (string) with removed whitespaces, tabs and line-break characters from beginning- and ending of the string
local function trim(str)
    if type(str) ~= "string" then str = tostring(str or "") end
    local mask = "[ \t\r\n]*"
    return str:gsub("^"..mask, ""):gsub(mask.."$", "")
end


-- @val (any) the value to wrap in qoutes
-- returns (string) value converted to string and wrapped into quotation marks
local function quote(val)
    return "\""..tostring(val or "").."\""
end


-- @fragments (table) list of values
-- returns (string) concatenated string of all items similar to table.concat
local function toquery(fragments)
    local query = ""
    for _, frag in ipairs(fragments) do
        local f = tostring(frag)
        if f:match("%s+") then f = quote(f) end
        if not query:match("=$") then f = " "..f end
        query = query..f
    end
    return trim(query)
end


-- @... (any) first argument should be the utility name fallowed by its list of parameters
-- returns (string or nil, boolean) return value of utility call or nil, and its status
local function cmd(...)
    local tmpfile = "/tmp/shlua"
    local exitcode = "; echo $? >>"..tmpfile
    local command = os.execute(toquery{...}.." >>"..tmpfile..exitcode)
    local console = io.open(tmpfile, "r")
    local report, status = console:read("*a"):match("(.*)(%d+)[\r\n]*$") -- response, exitcode
    report = trim(report)
    status = tonumber(status) == 0
    console:close()
    os.remove(tmpfile)
    return report ~= "" and report or nil, status
end


-- add api like shell[utility](arguments) or shell.utility(arguments)
local shell = setmetatable({}, {__index = function(_, utility, ...)
    return cmd(utility, ...)
end})


local filesystem = {}


-- @platform (string) operating system to check against; returns (boolean) true on match
-- platform regex could be: linux*, windows* darwin*, cygwin*, mingw* (everything else might count as unknown)
-- returns (string) operating system identifier
-- NOTE love.system.getOS() is another way of retreving it if this library is used in this context
function filesystem.os(platform)
    local plat = shell.uname("-s")
    if type(platform) == "string" then return type(plat:lower():match("^"..platform:lower())) ~= "nil" end
    return plat
end


-- print(filesystem.os())
print(shell.test())