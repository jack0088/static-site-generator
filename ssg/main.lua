if _VERSION <= "Lua 5.1" then
    package.path = "./?/init.lua;./?/main.lua;"..package.path
end


local fs = require "plumber"
local json = require "json"
local compile = require "compiler"
local gui = require "gui"


function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
end


--filesystem.openfolder() -- to open finder and show project folder?
--love.system.openURL("file://") -- to run the project in browser?


function love.directorydropped(path)
    local url = path.."/config.json"
    if not fs.exists(url) then -- prepare project environment
        fs.makefile(url)
        fs.writefile(url, json.encode{
            render = "",
            entryfile = "index.html",
            publish = "",
            plugins = {}
        })
    end
    love.filedropped(url) -- redirect request
end


function love.filedropped(data)
    local url
    if type(data) == "string" then
        url = data
    else
        url = data:getFilename()
        data:close()
    end
    local meta = fs.fileinfo(url)
    compile(url)
end
