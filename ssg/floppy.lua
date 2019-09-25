-- Run Shell scripts to access systems in-build low-level functionality
-- that otherwise would be accessible through external dependencies exclusevly;
-- note that frameworks like love2d are also sandboxed due to security reasons and with this lib you can work around this limitation
-- This library is primarily used to access the filesystem and OS statistics by its own internal tools
-- 2019 (c) kontakt@herrsch.de


local sh = require "shell" -- every os.execute command becomes accessible as a function call
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


function fs.quote(paraphrase)
    --paraphrase:gsub("%s", [[\\ ]])
    local new = string.format('"%s"', paraphrase)
    print(new)
    return new
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
    return sh.test("-e", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to a file or folder
-- returns (string) mime-type of the resource
function fs.mimetype(path)
    -- NOTE for more predictable web-compilant results use the mime.lua module!
    return fs.trim(tostring(sh.file("--mime-type", "-b", fs.quote(path))))
end


-- @path (string) relative- or absolute path to a file
-- returns (boolean)
function fs.isfile(path)
    return fs.exists(path) and sh.test("-f", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to a folder
-- returns (boolean)
function fs.isfolder(path)
    print(sh.test("-d", fs.quote(path)).__exitcode)
    return fs.exists(path) and sh.test("-d", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the (sub-)folder
-- @filter (string) filename to check against; or regex expression mask, see https://www.cyberciti.biz/faq/grep-regular-expressions
-- returns (boolen or table) nil if @path leads to a file instead of a folder;
-- true on a match with @filter + an array of files that match the @filter criteria;
-- otherwise an array of files inside that folder
function fs.infolder(path, filter)
    if not fs.isfolder(path) then return nil end
    local content = fs.trim(tostring(sh.ls(fs.quote(path)):grep(fs.quote(filter or ""))))
    local list = {}
    for resource in content:gmatch("[^\r\n]*") do
        table.insert(list, resource)
    end
    if filter then return content ~= "", list end
    return list
end


-- returns (string) of the current location you are at
function fs.currentfolder()
    return fs.trim(tostring(sh.echo("$(pwd)")))
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.createdat(path)
    return fs.trim(tostring(sh.stat("-f", "%B", fs.quote(path)))) -- TODO need to verify on other platforms than MacOS
end


-- @path (string) relative- or absolute path to the file or (sub-)folder
-- returns (string) epoch/ unix date timestamp
function fs.modifiedat(path)
    return fs.trim(tostring(sh.date("-r", fs.quote(path), "+%s"))) -- TODO need to verify on other platforms than MacOS
end


-- @path (string) relative- or absolute path to the new, empty file
-- does not override existing file but updates its timestamp
-- returns (boolean) true on success
function fs.makefile(path)
    if fs.isfolder(path) then return false end
    return sh.touch(fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the new (sub-)folder
-- folder name must not contain special characters, except: spaces, plus- & minus signs and underscores
-- does nothing to existing (sub-)folder or its contents
-- returns (boolean) true on success
function fs.makefolder(path)
    if fs.isfile(path) then return false end
    return sh.mkdir("-p", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the file
-- skips non-existing file as well
-- returns (boolean) true on success
function fs.deletefile(path)
    return sh.rm("-f", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the (sub-)folder
-- deletes recursevly any sub-folder and its contents
-- skips non-existing folder
-- returns (boolean) true on success
function fs.deletefolder(path)
    return sh.rm("-rf", fs.quote(path)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the file
-- returns (table) that contains information about the file, e.g. path, directory, filename, file extension, raw content, etc
function fs.readfile(path)
    local mime = require "mimetype" -- TODO remove these
    local b64 = require "base64"
    if not fs.isfile(path) then return nil end
    local obj = {}
    local f = io.open(path, "rb")
    if not f then return nil end
    obj.url = path
    obj.media_type = fs.mimetype(path)
    obj.content_type, obj.directory, obj.name, obj.extension = mime.guess(obj.url)
    obj.raw_content = f:read("*a")
    obj.base64_source = "data:"..obj.mime..";base64,"..b64.encode(obj.raw)
    -- TODO? make File its own class with getters for .base64 and .mime
    f:close()
    return obj
end


function fs.writefile(path, data)
    -- TODO? check permissions before write?
    if fs.isfolder(path) then return false end
    if not fs.exists(path) then fs.makefile(path) end
    local f = io.open(path, "wb")
    if not f then return false end
    f:write(data)
    f:close()
    return true
end


-- @path (string) relative- or absolute path to the file or (sub-)folder you want to copy
-- @location (string) is the new place of the copied resource, NOTE that this string can also contain a new name for the copied resource!
-- includes nested files and folders
-- returns (boolean) true on success
function fs.copy(path, location)
    return sh.cp("-a", fs.quote(path), fs.quote(location)).__exitcode == 0
end


-- @path (string) relative- or absolute path to the file or (sub-)folder you want to move to another location
-- @location (string) is the new place of the moved rosource, NOTE that this string can also contain a new name for the copied resource!
-- includes nested files and folders
-- returns (boolean) true on success
function fs.move(path, location)
    if not fs.exists(path) then return false end
    return sh.mv(fs.quote(path), fs.quote(location)).__exitcode == 0
end


-- returns (string) current content of the system clipboard
function fs.readclipboard()
    if fs.os("darwin") then -- MacOS
        -- TODO if we pass around other types like files
        -- can we have custom string formats that we encode/parse or do we need to support other formats than strings as well?
        return fs.trim(tostring(sh.pbpaste())) --return fs.trim(tostring(sh.echo("`pbpaste`")))
    elseif fs.os("linux") then -- Linux
        -- TODO use xclip
    end
    return nil
end


-- @data (string) the content to insert into the clipboard
-- returns (boolean) true on success
function fs.writeclipboard(data)
    if fs.os("darwin") then -- MacOS
        return sh.echo(fs.quote(data)):pbcopy().__exitcode == 0
    elseif fs.os("linux") then -- Linux
        -- TODO use xclip
    end
    return false
end


-- @path (string) relative- or absolute path to folder or file
-- @rights (string or number) permission level, see http://permissions-calculator.org
-- fs.permissions(path) returns (string) an encoded 4 octal digit representing the permission level
-- fs.permissions(path, right) recursevly sets permission level and returns (boolean) true for successful assignment
function fs.permissions(path, right)
    local fmt = "%03d"
    if type(path) ~= "string" or not fs.exists(path) then return nil end
    if type(right) == "number" then
        -- NOTE seems you can not go below chmod 411 on MacOS
        -- as the operating system resets it automatically to the next higher permission level
        -- because the User (who created the file) at least holds a read access
        -- thus trying to set rights to e.g. 044 would result in 644
        -- which means User group automatically gets full rights (7 bits instead of 0)
        return sh.chmod("-R", string.format(fmt, right), fs.quote(path)).__exitcode == 0 --and tonumber(fs.permissions(path)) == tonumber(right)
    end
    if fs.os("darwin") then -- MacOS
        return string.format(fmt, fs.trim(tostring(sh.stat("-r", fs.quote(path)):awk("'{print $3}'"):tail("-c 4"))))
    elseif fs.os("linux") then -- Linux
        return sh.stat("-c", "'%a'", fs.quote(path)) -- TODO needs testing
    elseif fs.os("windows") then -- Windows
        -- TODO?
    end
    return nil -- answer for unknown OS
end


return fs
