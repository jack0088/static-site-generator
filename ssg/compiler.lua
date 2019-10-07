-- Trace placeholders inside files and repace them by other file contents
-- 2019 (c) kontakt@herrsch.de

local fs = require "plumber"
local pretty = require "prettify"


local function render(file, context)
end


local function publish(folder)
end


local function run(config)
    assert(type(config) == "table", "received a faulty project configuration file")
    --load plugins, if any
    --call render (+ inject plugins)
    --call publish (+ inject plugins)
    print(pretty(config))
end


return run
