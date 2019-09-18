-- Recursevly format any Lua table for debugging purposes
-- @t (required table): the table to create a string from
-- @o (optional string): whitespaces for indentation of nested tables; is most cases only used by the recursive self-call and is set automatically is that case
local function prettify(t, o)
    o = o or ""
    if type(t) == "table" then
        local s = "{"
        for k, v in pairs(t) do
            if type(k) ~= "number" then k = '"'..k..'"' end
            if v ~= t then s = s.."\n    "..o.."["..k.."] = "..prettify(v, o.."    ").."," end
        end
        return s:sub(1, -2).."\n"..o.."}"
    else
        return type(t) == "string" and '"'..tostring(t)..'"' or tostring(t)
    end
end

return prettify
