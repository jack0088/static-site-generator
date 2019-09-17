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
local super = {}
super.__index = super

-- Return the parent object of a given class object
-- @klass (required table): class object whose parent should be returned
super.parent = function(klass) return klass.__parent end

-- Check if an object is a parent of nother one
-- @klass (required table): reference object whose relation we want to check (the derivant)
-- @subklass (required table): relative object which might be the parent of our derivant (=@klass)
super.derivant = function(klass, subklass) return klass:parent() == subklass end

-- Make a shallow copy of a class while walking down the entire inheritance chain
-- Call the constructor of the new class instance (if there is any) and return its return value
-- or simply return the new class instance itself, if there the instance has no constructor method
-- @array (required table): class object to shallow-copy recursevly
-- @... (optional arguments): argements are passed to the optional class constructor
local function replica(array, ...)
    local copy = array.__parent and replica(array.__parent) or {}
    if array ~= super then
        for k, v in pairs(array) do
            if k ~= "__parent" then copy[k] = v end
        end
    end
    return copy.new and (copy:new(...) or copy) or copy
end

-- Create a new class object or create a sub-class from an already existing class
-- @something (optional table): parent class to sub-call from
local function class(parent)
    local proxy = function(array, key, value)
        if type(array) == "nil" or type(key) == "nil" then return nil end
        if type(value) == "nil" then
            if key:lower():match("^[gs]et_(.+)") then return rawget(array, key) end -- access with getter/setter prefix
            local getter = rawget(array, "get_"..key) -- try find getter on prefixless access
            if type(getter) == "function" then return getter(array) end -- however ignore non-function getter
            return rawget(array, key) or array.__parent[key]
        end
        if key:lower():match("^[gs]et_(.+)") then -- with getter/setter prefix
            assert(type(value) == "function", "getter/setter assignment must be a function value")
            rawset(array, key, value)
            return value
        end
        local setter = rawget(array, "set_"..key)
        if type(setter) == "function" then return setter(array, value) or value end
        rawset(array, key, value)
        return value
    end
    return setmetatable({__parent = parent or super}, {__index = proxy, __newindex = proxy, __call = replica})
end


local pretty = require "prettify"
local thing = class()
thing.foobar = "foobarval"
function thing:get_lol() return self.__lol__value__ end
function thing:set_lol(v) self.__lol__value__ = v return "fuuuck yeas!" end
thing.lol = "newlolvalthroughsetter"

local men = class(thing)
men.human = true
men.get_lol = function(this) return this.__lol__value__, "nothing here" end
-- men.lol = "menlol"
local a, b = men.lol
-- print(a, b)
local bob = men()
bob.bob = true
men.human = false
print(pretty(men))
print(pretty(bob))


return class