if _VERSION <= "Lua 5.1" then
    package.path = "./?/init.lua;./?/main.lua;"..package.path
end


local fs = require "plumber"
local json = require "json"
local compile = require "compiler"
local CONFIG


function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
    if not CONFIG then
        love.graphics.printf(
            "missing project configuration\ndrag & drop your project folder here...",
            0,
            love.graphics.getHeight() * 0.425,
            love.graphics.getWidth(),
            "center"
        )
    else
        love.graphics.printf("project opened", 0, 0, 400)
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
