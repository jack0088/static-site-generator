local class = require "class"
local gui = {}
gui.label = class()
gui.field = class()


function gui.label:new(text, x, y)
    self.x = x or 0
    self.y = y or 0
    self.text = text or "empty"
end


function gui.label:draw()
end


function gui.field:new(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 128
    self.height = height or 32
end


function gui.field:draw()
end


return gui
