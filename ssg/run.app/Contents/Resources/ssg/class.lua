--[[
    Providing object inheritance; the correct way!
    (Sub-)Classes are linked through their table meta-methods until they finally get instanciated.
    (This way we can extend parent classes even after their creation while still being able to see these extesions in the sub-classes.)
    Instances are shallow copies of their entire inheritance chain.
    (At which point they become unique objects without any relation to their parents.)

    2019 (c) kontakt@herrsch.de
--]]


-- This is the super (base) class for all new class objects
-- which has important methods that all classes might want to use
-- This super class is NOT copied to instance objects once classes get instanciated!
local super = {
    -- Return the parent object of a given class object
    -- @something (required table): class object whose parent should be returned
    parent = function(something)
        return (getmetatable(something) or {}).__index
    end;
    -- Check if an object is a parent of nother one
    -- @anything (required table): reference object whose relation we want to check (the derivant)
    -- @something (required table): relative object which might be the parent of our derivant (=@anything)
    derivant = function(anything, something)
        return anything:parent() == something
    end
}
super.__index = super

-- Make a shallow copy of a class while walking down the entire inheritance chain
-- Call the constructor of the new class instance (if there is any) and return its return value
-- or simply return the new class instance itself, if there the instance has no constructor method
-- @something (required table): class object to shallow-copy recursevly
-- @... (optional arguments): argements are passed to the optional class constructor
local function replica(something, ...)
    local meta = getmetatable(something)
    local copy = meta and replica(meta.__index) or {}
    if something ~= super then for k, v in pairs(something) do copy[k] = v end end
    return copy.new and (copy:new(...) or copy) or copy
end

-- Create a new class object or create a sub-class from an already existing class
-- @something (optional table): parent class to sub-call from
local function thing(something)
    if not something or not getmetatable(something) then something = setmetatable(something or {}, super) end
    return setmetatable({}, {__index = something, __call = replica})
end

-- TODO somehow implement getters & setters on top of this library

return thing