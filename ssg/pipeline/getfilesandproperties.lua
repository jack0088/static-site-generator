local mime = require "ssg.mime"
local b64 = require "ssg.base64"
local md = require "ssg.markdown"

-- TODO you get a placeholder {{foobar.baz}}
-- filter the placeholder to identify @path vs. an objects .property
-- then decide about the routine to use to get the desired content
-- return object with properties specific to that file-type

-- @path (string) relative- or absolute path to the file
-- returns (string) base64 formated, web-compatible query to use in <img src""> HTML tags
function image64(path)
    local f = io.open(path, "rb")
    local src = f:read("*a")
    local ftype = mime.guess(path)
    local query = "data:"..ftype..";base64,"..b64.encode(src)
    io.close(f)
    return {
        url = path,
        mime = ftype,
        src = query
    }
end

--print("<img src=\""..image64("content/test4.jpg").src.."\">")




function markdownhtml(path)
    local f = io.open(path, "rb")
    local src = f:read("*a")
    io.close(f)
    return md(src) -- html
end


print(markdownhtml("content/description.md"))