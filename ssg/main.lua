if _VERSION <= "Lua 5.1" then
    package.path = "./?/init.lua;./?/main.lua;"..package.path
end


local fs = require "plumber"
local json = require "json"
local compile = require "compiler"
local CONFIG


local function rgba(r, g, b, a)
    return r/255, g/255, b/255, a/255
end


function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
    
    local w, h = love.graphics.getDimensions()
    local lh = 18 -- line height

    if not CONFIG then
        love.graphics.printf("missing project configuration\ndrag & drop your project folder here...", 0, h * 0.425, w, "center")
    else
        love.graphics.translate(10, 10)

        love.graphics.setColor(rgba(255, 255, 255, 255))
        love.graphics.printf("Project path", 0, 0, w)
        love.graphics.printf(CONFIG.fileinfo.path, 0, lh, w-20, "left")

        love.graphics.setColor(rgba(70, 118, 188, 255))
        love.graphics.printf("Close Project", 0, 5*lh, w, "center")

        love.graphics.setColor(rgba(255, 255, 255, 255))
        love.graphics.printf("Render folder", 0, 7*lh, w)
        love.graphics.setColor(rgba(70, 118, 188, 255))
        love.graphics.printf(CONFIG.settings.render, 0, 8*lh, w)

        love.graphics.setColor(rgba(255, 255, 255, 255))
        love.graphics.printf("Entry file (normally index.html)", 0, 10*lh, w)
        love.graphics.setColor(rgba(70, 118, 188, 255))
        love.graphics.printf(CONFIG.settings.entryfile, 0, 11*lh, w)

        love.graphics.setColor(rgba(255, 255, 255, 255))
        love.graphics.printf("Publish folder", 0, 13*lh, w)
        love.graphics.setColor(rgba(70, 118, 188, 255))
        love.graphics.printf(CONFIG.settings.publish, 0, 14*lh, w)
    end
end


--filesystem.openfolder() -- to open finder and show project folder?
--love.system.openURL("file://") -- to run the project in browser?


function love.directorydropped(path)
    love.filedropped(path.."/config.json") -- redirect request
end


function love.filedropped(data)
    local url
    if type(data) == "string" then
        url = data
    else
        url = data:getFilename()
        data:close()
    end

    local project_config = json.decode(fs.readfile(url) or "{}")
    CONFIG = {}
    CONFIG.settings = {
        render = project_config.render or "",
        entryfile = project_config.entryfile or "",
        publish = project_config.publish or "",
        plugins = project_config.plugins or {}, -- TODO? implement plugins system?
        ftp_server = project_config.ftp_server or "",
        ftp_port = project_config.ftp_port or 21,
        ftp_user = project_config.ftp_user or "",
        ftp_password = project_config.ftp_password or ""
    }
    fs.writefile(url, json.encode(CONFIG.settings)) -- update project config with defaults
    CONFIG.fileinfo = fs.fileinfo(url)

    compile(CONFIG.settings)
end
