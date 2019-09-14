if _VERSION > "Lua 5.1" then
    unpack = unpack or table.unpack
else
    package.path = "./?/init.lua;"..package.path
end


function love.load()
    print("ssg is watching you...")
end
