require "ssg.sh" -- every os.execute command becomes accessible as global function call

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


-- @check (string) OS to check against; returns (boolean) true on match
-- platform regex for @check could be: linux*, windows* darwin*, cygwin*, mingw* (everything else might count as unknown)
-- returns (string) operating system identifier
function fs.platform(check)
    local plat = fs.trim(uname("-s").__input)
    if type(check) == "string" then return type(string.match(string.lower(plat), "^"..string.lower(check))) ~= nil end
    return plat
end


-- @path (string) relative- or absolute path to a file or folder
-- returns (boolean)
function fs.exists(path)
    return test("-e", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to a file
-- returns (boolean)
function fs.isfile(path)
    return test("-f", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to a folder
-- returns (boolean)
function fs.isfolder(path)
    return test("-d", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the new, empty file
-- does not override existing file but updates its timestamp
-- returns (boolean) true on success
function fs.makefile(path)
    if fs.isfolder(path) then return false end
    return touch("'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the new (sub-)folder
-- folder name must not contain special characters, except: spaces, plus- & minus signs and underscores
-- does nothing to existing (sub-)folder or its contents
-- returns (boolean) true on success
function fs.makefolder(path)
    if fs.isfile(path) then return false end
    return mkdir("-p", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the file
-- skips non-existing file as well
-- returns (boolean) true on success
function fs.deletefile(path)
    return rm("-f", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the (sub-)folder
-- deletes recursevly any sub-folder and its contents
-- skips non-existing folder
-- returns (boolean) true on success
function fs.deletefolder(path)
    return rm("-rf", "'"..path.."'").__exitcode == 0
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.createdat(path)
    return fs.trim(stat("-f", "%B", "'"..path.."'").__input) -- TODO check on other platforms than MacOS
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.modifiedat(path)
    return fs.trim(date("-r", "'"..path.."'", "+%s").__input)
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
        return chmod("-R", string.format(fmt, right), "'"..path.."'").__exitcode == 0 --and tonumber(fs.permissions(path)) == tonumber(right)
    end
    if fs.platform("darwin") then -- MacOS
        return string.format(fmt, fs.trim(stat("-r '"..path.."'"):awk("'{print $3}'"):tail("-c 4").__input))
    elseif fs.platform("linux") then -- Linux
        return stat("-c", "'%a'", "'"..path.."'") -- TODO needs testing
    elseif fs.platform("windows") then -- Windows
        -- TODO?
    end
    return nil -- answer for unknown OS
end


return fs