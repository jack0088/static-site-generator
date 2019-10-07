if _VERSION <= "Lua 5.1" then
    package.path = "./?/init.lua;./?/main.lua;"..package.path
end


local fs = require "plumber"
local json = require "json"
local compile = require "compiler"
local gui = require "gui"
local CONFIG


function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
    if CONFIG then
        love.graphics.printf("project opened", 0, 0, 400)
    else
        love.graphics.printf("project config missing", 0, 0, 400)
    end
end


--filesystem.openfolder() -- to open finder and show project folder?
--love.system.openURL("file://") -- to run the project in browser?


function love.directorydropped(path)
    love.filedropped(path.."/config.json") -- redirect request
end


function love.filedropped(data)
    local url
    local default_config = {
        render = "",
        entryfile = "",
        publish = "",
        plugins = {}
        ftp = {
            server = "",
            port = "21",
            user = "",
            password = ""
        }
    })
    
    if type(data) == "string" then
        url = data
    else
        url = data:getFilename()
        data:close()
    end

    if not fs.exists(url) then
        fs.makefile(url)
        fs.writefile(url, json.encode(default_config))
    end

    CONFIG = {}
    CONFIG.fileinfo = fs.fileinfo(url)
    CONFIG.settings = json.decode(fs.readfile(url))

    compile(CONFIG.settings)
end
