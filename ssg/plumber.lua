-- Run Shell scripts to access systems in-build low-level functionality
-- that otherwise would be accessible through external dependencies exclusevly;
-- This library is primarily used to access the filesystem and OS statistics by its own internal tools
-- 2019 (c) kontakt@herrsch.de

local sh = require "shell" -- every os.execute command becomes accessible as global function call
local fs = {} -- namespace for unix low-level plumbing method wrappers


-- @str (string): the string to trim
-- removes whitespaces, tabs and line-break characters from beginning and ending of a string
-- returns (string)
function fs.trim(str)
    if type(str) ~= "string" then str = tostring(str or "") end
    local mask = "[ \t\r\n]*"
    local result = str:gsub("^"..mask, ""):gsub(mask.."$", "")
    return result
end


-- @platform (string) operating system to check against; returns (boolean) true on match
-- platform regex could be: linux*, windows* darwin*, cygwin*, mingw* (everything else might count as unknown)
-- returns (string) operating system identifier
function fs.os(platform)
    local plat = fs.trim(tostring(sh.uname("-s")))
    if type(platform) == "string" then return type(plat:lower():match("^"..platform:lower())) ~= "nil" end
    return plat
end


-- @path (string) relative- or absolute path to a file or folder
-- returns (boolean)
function fs.exists(path)
    return sh.test("-e", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to a file or folder
-- returns (string) mime-type of the resource
function fs.mime(path)
    -- NOTE for more predictable web-compilant results use the mime.lua module!
    return fs.trim(tostring(sh.file("--mime-type", "-b", "'"..path.."'")))
end


-- @path (string) relative- or absolute path to a file
-- returns (boolean)
function fs.isfile(path)
    return sh.test("-f", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to a folder
-- returns (boolean)
function fs.isfolder(path)
    return sh.test("-d", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the (sub-)folder
-- @filter (string) filename to check against; or regex expression mask, see https://www.cyberciti.biz/faq/grep-regular-expressions
-- returns (boolen or table) nil if @path leads to a file instead of a folder;
-- true on a match with @filter + an array of files that match the @filter criteria;
-- otherwise an array of files inside that folder
function fs.infolder(path, filter)
    if not fs.isfolder(path) then return nil end
    local content = fs.trim(tostring(sh.ls("'"..path.."'"):grep("'"..(filter or "").."'")))
    local list = {}
    for resource in content:gmatch("[^\r\n]*") do
        table.insert(list, resource)
    end
    if filter then return content ~= "", list end
    return list
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.createdat(path)
    return fs.trim(tostring(sh.stat("-f", "%B", "'"..path.."'"))) -- TODO need to verify on other platforms than MacOS
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.modifiedat(path)
    return fs.trim(tostring(sh.date("-r", "'"..path.."'", "+%s"))) -- TODO need to verify on other platforms than MacOS
end


-- @path (string) relative- or absolute path to the new, empty file
-- does not override existing file but updates its timestamp
-- returns (boolean) true on success
function fs.makefile(path)
    if fs.isfolder(path) then return false end
    return sh.touch("'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the new (sub-)folder
-- folder name must not contain special characters, except: spaces, plus- & minus signs and underscores
-- does nothing to existing (sub-)folder or its contents
-- returns (boolean) true on success
function fs.makefolder(path)
    if fs.isfile(path) then return false end
    return sh.mkdir("-p", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the file
-- skips non-existing file as well
-- returns (boolean) true on success
function fs.deletefile(path)
    return sh.rm("-f", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the (sub-)folder
-- deletes recursevly any sub-folder and its contents
-- skips non-existing folder
-- returns (boolean) true on success
function fs.deletefolder(path)
    return sh.rm("-rf", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to folder or file
-- @rights (string or number) permission level, see http://permissions-calculator.org
-- fs.permissions(path) returns (string) an encoded 4 octal digit representing the permission level
-- fs.permissions(path, right) recursevly sets permission level and returns (boolean) true for successful assignment
function fs.permissions(path, right)
    local fmt = "%03d"
    if type(path) ~= "string" or (not fs.isfile(path) and not fs.isfolder(path)) then return nil end
    if type(right) == "number" then
        -- NOTE seems you can not go below chmod 411 on MacOS
        -- as the operating system resets it automatically to the next higher permission level
        -- because the User (who created the file) at least holds a read access
        -- thus trying to set rights to e.g. 044 would result in 644
        -- which means User group automatically gets full rights (7 bits instead of 0)
        return sh.chmod("-R", string.format(fmt, right), "'"..path.."'").__exitcode == 0 --and tonumber(fs.permissions(path)) == tonumber(right)
    end
    if fs.os("darwin") then -- MacOS
        return string.format(fmt, fs.trim(tostring(sh.stat("-r '"..path.."'"):awk("'{print $3}'"):tail("-c 4"))))
    elseif fs.os("linux") then -- Linux
        return sh.stat("-c", "'%a'", "'"..path.."'") -- TODO needs testing
    elseif fs.os("windows") then -- Windows
        -- TODO?
    end
    return nil -- answer for unknown OS
end


return fs
