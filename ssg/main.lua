if _VERSION > "Lua 5.1" then
    unpack = unpack or table.unpack
else
    package.path = "./?/init.lua;./?/main.lua;"..package.path
end



local sh = require "shell"
local love = {}

print(sh("ls", ".", "/Users/herrsch/Downloads/test"))


function love.load()
end


function love.draw()
    love.graphics.setBackgroundColor(.2, .2, .3, 1)
end

--love.system.openURL("file://") -- for running the project?

function love.directorydropped(path)
    -- try find config in user save directory
    -- assembler.run(config_file)
    assembler.render(path) -- debug
end


function love.filedropped(data)
    print(data)
end
