-- Run Shell scripts with Lua syntax
-- found on https://github.com/zserge/luash
-- modified 2019 by kontakt@herrsch.de

local Shell = {}


-- converts key and it's argument to "-k" or "-k=v" or just ""
local function arg(k, a)
	if not a then return k end
	if type(a) == "string" and #a > 0 then return k.."=\""..a.."\"" end
	if type(a) == "number" then return k.."="..tostring(a) end
	if type(a) == "boolean" and a == true then return k end
	error("invalid argument type", type(a), a)
end


-- converts nested tables into a flat list of arguments and concatenated input
local function flatten(t)
	local result = {args = {}, input = ""}
	local function f(t)
		local keys = {}
		for k = 1, #t do
			keys[k] = true
			local v = t[k]
			if type(v) == "table" then
				f(v)
			else
				table.insert(result.args, v)
			end
		end
		for k, v in pairs(t) do
			if k == "__input" then
				result.input = result.input..v
			elseif not keys[k] and k:sub(1, 1) ~= "_" then
				local key = "-"..k
				if #k > 1 then key = "-"..key end
				table.insert(result.args, arg(key, v))
			end
		end
	end
	f(t)
	return result
end


-- returns a function that executes the command with given args and returns its
-- output, exit status etc
local function command(cmd, ...)
	local prearg = {...}
	return function(...)
		local args = flatten({...})
		local s = cmd
		for _, v in ipairs(prearg) do
			s = s.." ".. v
		end
		for k, v in pairs(args.args) do
			s = s.." "..v
		end
		if args.input then
			s = s.." <"..Shell.tmpfile
			local f = io.open(Shell.tmpfile, "w")
			if f then
				f:write(args.input)
				f:close()
			end
		end
		local p = io.popen(s, "r")
		local _, exit, status, output
		if p then
			output = p:read("*a")
			_, exit, status = p:close()
			os.remove(Shell.tmpfile)
		end
		local t = {
			__input = output,
			__exitcode = exit == "exit" and status or 127,
			__signal = exit == "signal" and status or 0,
		}
		local mt = {
			__index = function(self, k, ...)
                return Shell[k] --, ...
			end,
			__tostring = function(self)
				-- return trimmed command output as a string
				return self.__input:match("^%s*(.-)%s*$")
			end
		}
		return setmetatable(t, mt)
	end
end


Shell.command = command
Shell.tmpfile = "/tmp/luashell" -- default (should be adjusted for sandboxed applications)

-- Shell(cmd, ...) and Shell.cmd(...) and Shell.command(cmd, ...) are all equal calls
return setmetatable(Shell, {
    __index = function(_, cmd, ...) return command(cmd, ...) end;
	__call = function(_, cmd, ...) return command(cmd, ...) end
})
