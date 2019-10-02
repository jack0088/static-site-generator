-- if _VERSION > "Lua 5.1" then
--     unpack = unpack or table.unpack
-- else
--     package.path = "./?/init.lua;./?/main.lua;"..package.path
-- end



local gui = require "gui"
local compile = require "compiler"

local uiempty = love.graphics.newImage("dropfile.jpg")

-- TODO introduce a simplified scene manager to work with different ui's

function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
    love.graphics.draw(uiempty)
end

--filesystem.openfolder() -- to open finder and show project folder?
--love.system.openURL("file://") -- to run the project in browser?

function love.directorydropped(path)
    -- try find config in user save directory | compiler.run(config)
    compile(path)
end


function love.filedropped(data)
    print("dopping files is not supported right now, maybe later")
    print("dropped file:", data)
end
