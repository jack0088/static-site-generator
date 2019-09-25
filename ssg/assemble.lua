-- Trace placeholders inside files and repace them by other file contents
-- 2019 (c) kontakt@herrsch.de

local pretty = require "prettify"
local fs = require "floppy"
local tracer = {}


function tracer.render(folder)
    print(fs.exists(folder), fs.isfolder(folder), fs.isfile(folder))
    -- if not fs.isfile(folder.."/index.html") then print("oh") return false end
    -- print(folder)
end


function tracer.publish(folder)
end


function tracer.run(plugins)
end


return tracer
