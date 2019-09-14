if _VERSION > "Lua 5.1" then
    unpack = unpack or table.unpack
else
    package.path = "./?/init.lua;"..package.path
end

local json = require "json"

function love.load()
    print("static-site-generator is watching you...")
    if json then print("JSON is included", type(json)) end
end
