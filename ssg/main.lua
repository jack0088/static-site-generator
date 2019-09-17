if _VERSION > "Lua 5.1" then
    unpack = unpack or table.unpack
else
    package.path = "./?/init.lua;"..package.path
end


local pretty = require "prettify"
local mime = require "mimetype"
local json = require "json"
local fs = require "floppy"


function love.load()
    print("static-site-generator is watching you...")
    if json then print("JSON is included", type(json)) end
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
end

--love.system.openURL("file://") -- for running the project?

function love.directorydropped(path)
    print("dropped folder:", path)
    --fs.writefile(path.."/config.json", "huhu, hello world!")
end


function love.filedropped(data)
    print(data)
end
