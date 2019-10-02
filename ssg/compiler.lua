-- Trace placeholders inside files and repace them by other file contents
-- 2019 (c) kontakt@herrsch.de

local fs = require "plumber"


local function render(file, context)
end


local function publish(folder)
end


local function run(config)
    --search for config or create a default one
    --load plugins, if any
    --call render (+ inject plugins)
    --call publish (+ inject plugins)
end


return run
