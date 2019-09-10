require "ssg.sh" -- every os.execute command becomes accessible as global function call

local fs = {} -- namespace for unix low-level plumbing method wrappers


--[[
    @path (string) relative- or absolute path to a file or folder
    returns (boolean)
--]]
function fs.exists(path)
    return test("-e", "'"..path.."'").__exitcode == 0
end


--[[
    @path (string) relative- or absolute path to a file
    returns (boolean)
--]]
function fs.isfile(path)
    return test("-f", "'"..path.."'").__exitcode == 0
end


--[[
    @path (string) relative- or absolute path to a folder
    returns (boolean)
--]]
function fs.isfolder(path)
    return test("-d", "'"..path.."'").__exitcode == 0
end


--[[
    @path (string) relative or absolute path to folder or file
    @rights (string or number) octal permission, see http://permissions-calculator.org
    fs.permission(path) returns (string) an encoded 4 octal digit representing the permission level
    fs.permission(path, rights) returns (boolean) true for successful assignment at sucessful back-check
--]]
function fs.permissions(path, rights)
    local fmt = "%04d"
    if type(rights) == "number" then
        -- NOTE I think you can not go below chmod 444 on MacOS because there is always User, Group and Other
        -- thus trying to set rights to 044 would result in 644
        return chmod("-R", string.format(fmt, rights), "'"..path.."'").__exitcode == 0 and tonumber(rights) == tonumber(fs.permissions(path))
    end
    -- TODO not sure about Linux support, maybe need to check platform and use `stat -c '%a' '<path>'`
    return string.format(fmt, stat("-r '"..path.."'"):awk("'{print $3}'"):tail("-c 4").__input)
end


--[[
    @path (string) relative- or absolute path to the new, empty file
    does not override existing file but updates its timestamp
    returns (boolean) true on success
--]]
function fs.makefile(path)
    return touch("'"..path.."'").__exitcode == 0
end


--[[
    @path (string) relative- or absolute path to the new (sub-)folder
    folder name must not contain special characters, except: spaces, plus- & minus signs and underscores
    does nothing to existing (sub-)folder
    returns (boolean) true on success
--]]
function fs.makefolder(path)
    if not fs.isfolder(path) then
        if not fs.isfile(path) then
            return mkdir("-p", "'"..path.."'").__exitcode == 0
        else
            -- path resolves into [existing] file
            -- or includes special characters
            return false
        end
    end
    return true -- folder exists already
end


--[[
    @path (string) relative- or absolute path to the file
    skips non-existing file as well
    returns (boolean) true on success
--]]
function fs.deletefile(path)
    if fs.isfile(path) then
        return rm("-f", "'"..path.."'").__exitcode == 0
    end
    return false
end


--[[
    @path (string) relative- or absolute path to the (sub-)folder
    skips non-existing folder
    returns (boolean) true on success
--]]
function fs.deletefolder(path)
    if fs.isfolder(path) then
        return rm("-rf", "'"..path.."'").__exitcode == 0
    end
    return false
end


print(fs.makefolder("foo/baz .-_ lol.txt/bar"))







return fs