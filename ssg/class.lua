--[[
    Providing object inheritance; the correct way!
    (Sub-)Classes are linked through their table meta-methods until they finally get instanciated.
    (This way we can extend parent classes even after their creation while still being able to see these extesions in the sub-classes.)
    Instances are shallow copies of their entire inheritance chain.
    (At which point they become unique objects without any relation to their parents.)

    2019 (c) kontakt@herrsch.de
--]]


-- Base class for all new (parentless) class objects
-- Only useful to provide important methods across all (sub-)classes
-- Properties and methods of this object are NOT copied to instances of classes!
local super = {}
super.__index = super

-- Return the parent object of a given class object
-- @object (required table): class object whose parent should be returned
super.parent = function(object) return object.__parent end

-- Check if an object is a parent of nother one
-- @child (required table): reference object whose relation we want to check (the derivant)
-- @parent (required table): relative object which might be the parent of our derivant
super.derivant = function(child, parent) return child:parent() == parent end

-- Guide every access to any table key through this proxy to apply validation checks and inject custom behaviour
-- @object (required table) is a class object whose property we want to (re-)assign or to read
-- @key (required string) is the property we try to access
-- @value (optional of any type) is the new value we want to assign to that @object[@key]
-- returns (any type) the value that the getter, setter or the propery returned
local function proxy(object, key, value)
    if type(object) == "nil" or type(key) == "nil" then return nil end
    local get = rawget(object, "get_"..key)
    local set = rawget(object, "set_"..key)
    local getset = key:lower():match("^[gs]et_(.+)")
    if type(value) == "nil" then
        if getset then return rawget(object, key) end -- access with getter/setter prefix
        if type(get) == "function" then return get(object) end -- try find getter on prefixless access, however ignore non-function getter
        return rawget(object, key) or object.__parent[key]
    end
    if getset then -- with getter/setter prefix
        assert(type(rawget(object, getset)) == "nil", "getter/setter assignment failed due to conflict with existing property")
        assert(type(value) == "function", "getter/setter assignment must be a function value")
        rawset(object, key, value)
        return value
    end
    if type(set) == "function" then return set(object, value) or value end
    assert(type(get) == "nil", "property assignment failed due to conflict with existing getter")
    rawset(object, key, value)
    return value
end

-- Make a shallow copy of a class while walking down the entire inheritance chain
-- Call the constructor of the new class instance (if there is any) and return its return value
-- or simply return the new class instance itself, if there the instance has no constructor method
-- @object (required table): class object to shallow-copy recursevly
-- @... (optional arguments): argements are passed to the optional class constructor
local function replica(object, ...)
    local copy = object.__parent and replica(object.__parent) or {}
    if object ~= super then
        for k, v in pairs(object) do
            if k ~= "__parent" then copy[k] = v end
        end
    end
    return copy.new and (copy:new(...) or copy) or copy
end

-- This wrapper adds a proxy to a class instance to maintain gettter/setter support
-- @... (required arguments) the list starts with the class to instanciate from,
-- and is fallowed by optional number and type of arguments to that the instance constructor might need
-- returns (table) an instance of a class
local function cast(...)
    return setmetatable(replica(...), {__index = proxy, __newindex = proxy}) -- support getter/setter
end

-- Create a new class object or create a sub-class from an already existing class
-- @parent (optional table): parent class to sub-call from
local function class(parent)
    return setmetatable({__parent = parent or super}, {__index = proxy, __newindex = proxy, __call = cast})
end

return class
