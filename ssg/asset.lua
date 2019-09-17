
-- 2019 (c) kontakt@herrsch.de

-- possible names of this module
-- source
-- origin
-- asset
-- pointer
-- record
-- heap
-- file register
-- fragment

-- TODO write this into a file class that can handle getters and setters for modifieng its data



local mime = require "mimetype"
local b64 = require "base64"
local md = require "markdown"

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

print(mime.guess("herrsch/content/test.jpg"))
-- print("<img src=\""..image64("herrsch/content/test4.jpg").src.."\">")


-- TODO unite both funcs as we can read binary
-- and then either use as text or convert to b64 or whatever
--"rb" read mode is ok for any usage as it seems


function markdownhtml(path)
    local f = io.open(path, "rb")
    local src = f:read("*a")
    io.close(f)
    return md(src) -- html
end


-- print(markdownhtml("herrsch/content/description.md"))