--[[
    A library for convenient description and generation of HTML layouts via Lua!
    Build DOM objects by chaining, grouping and nesting of HTML elements
    The purpose of this library is to allow mixing Lua and HTML code in the same context
    2019 (c) kontakt@herrsch.de

    EXAMPLE (1): a single html element
        dom.meta{charset = "utf-8"}

    RESULT (1):
        <meta charset="utf-8">

    EXAMPLE (2): hierarchical nesting of html elements
        dom.head{
            dom.title "404",
            dom.meta{charset = "utf-8"}
        }
    
    RESULT (2):
        <head><title>404</title><meta charset="utf-8"></head>

    EXAMPLE (3): top level group, single and nested html elements
        local dom = require "dom"

        local msg = {}
        for i = 1, 10 do
            local echo = string.format("%s: sorry, i could not find this page", i)
            table.insert(msg, dom.p(echo))
        end

        local view = dom{ -- especially useful when sourcing because no enclosing html tag is generated for this group
            dom["!doctype"] "html",
            dom.html{
                dom.head{
                    dom.title "404",
                    dom.meta{charset = "utf-8"}
                },
                dom.body{
                    dom.h1 "not found",
                    msg
                }
            }
        }

        return view.htmlsource -- this actually triggers the generation of the html query string

    RESULT (3):
        <!doctype html>
        <html>
            <head>
                <title>404</title>
                <meta charset="utf-8">
            </head>
            <body>
                <h1>not found</h1>
                <p>1: sorry, i could not find this page</p>
                <p>2: sorry, i could not find this page</p>
                <p>3: sorry, i could not find this page</p>
                <p>4: sorry, i could not find this page</p>
                <p>5: sorry, i could not find this page</p>
                <p>6: sorry, i could not find this page</p>
                <p>7: sorry, i could not find this page</p>
                <p>8: sorry, i could not find this page</p>
                <p>9: sorry, i could not find this page</p>
                <p>10: sorry, i could not find this page</p>
            </body>
        </html>
    
    EXAMPLE (4): escape special characters
        escape(view.htmlsource)

    EXAMPLE (5): access elements and element attributes
        print(view.html.head.meta.attributes.charset) -- utf-8

    EXAMPLE (6): append a html element; after the fact
        local url = "/"
        local key = view.html.body.innerHTML
        key[#key + 1] = dom.p(string.format('requested url: %s', url))
--]]




-- alphabetically sorted list of self-closing HTML tags (these omit their closing tags)
local SELF_CLOSING_TAGS = {
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
    "!doctype"
}


-- unsorted list of unsafe HTML characters
local SPECIAL_CHARACTERS = {
    ["{"] = "&#123;",
    ["}"] = "&#125;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["&"] = "&amp;",
    ["/"] = "&#47;",
    ['"'] = "&quot;",
    ["'"] = "&#39;"
}


-- Remove whitespaces, tabs and newline characters from beginning and ending of a string
-- @str (required string): the string to trim
local function trim(str)
    if type(str) ~= "string" then return str end
    local mask = "[ \t\r\n]*"
    return str:gsub("^"..mask, ""):gsub(mask.."$", "")
end


-- Escape unsafe HTML characters
-- @str (required string): a string (possibly) containg unsafe HTML characters
local function escape(str)
    if type(str) ~= "string" then return str end
    local blacklist = ""
    for char in pairs(SPECIAL_CHARACTERS) do blacklist = blacklist.."%"..char end
    return trim(str):gsub("["..blacklist.."]", SPECIAL_CHARACTERS)
end


-- Determine if element needs a closing tag
-- @element (required string): tag name of a HTML element
local function solo(element)
    for _, elem in ipairs(SELF_CLOSING_TAGS) do
        if elem == element then return true end
    end
    return false
end


-- Generate and serialize a HTML tag from a descriptor node
-- @node (required table): a descriptor node object to generate the HTML markup from
local function source(node)
    if not node then return end
    if type(node) == "string" then return node end
    if #node > 0 then
        local src = ''
        for _, n in ipairs(node) do
            src = src..source(n)
        end
        return src
    end
    if not node.tagName and node.innerHTML then -- container/group
        return source(node.innerHTML)
    end
    local standalone, attributes = solo(node.tagName), ''
    if type(node.attributes) == "table" then
        for k, v in pairs(node.attributes) do
            attributes = attributes..string.format(v ~= '' and ' %s="%s"' or ' %s', k, v)
        end
    end
    return string.format(
        '%s%s%s',
        string.format( -- opening tag?
            '<%s%s%s>',
            node.tagName,
            attributes,
            (standalone and node.innerHTML) and ' '..source(node.innerHTML) or ''
        ),
        not standalone and source(node.innerHTML) or '', -- content inside element open/close tags?
        not standalone and string.format('</%s>', node.tagName) or '' -- closing tag?
    )
end


-- Versatile getter-method that generates and returns HTML markup of a given descriptor node
-- @node (required table): the node to generate the markup from
-- @property (required string): choose a NON-EXISTING node property name to trigger the generation of a HTML markup query string
local function generate(node, property)
    if property ~= "tagName" and property ~= "attributes" and property ~= "innerHTML" then
        if type(node.innerHTML) == "table" then
            for k, v in ipairs(node.innerHTML) do
                if v.tagName == property then
                    return v -- show tree
                end
            end
        end
        return source(node)
    end
end


-- Build tag descriptor node with dependency hierarchy
-- @element (required string): name of the HTML tag element you want to create
-- @attributes (optional table): attributes of that HTML tag
local function tree(element, attributes)
    local node = setmetatable({}, {__index = generate}) -- with getter-method
    if type(element) == "string" and element ~= "" then
        node.tagName = element
    end
    if type(attributes) ~= "table" then
        node.innerHTML = attributes
        return node
    end
    for key, value in pairs(attributes) do
        if type(key) == "number" or key == "innerHTML" then
            if type(value) == "table" then
                if not node.innerHTML then node.innerHTML = {} end
                if type(node.innerHTML) == "string" then node.innerHTML = node.innerHTML..source(value)
                else node.innerHTML[key] = value end
            else
                if not node.innerHTML then node.innerHTML = "" end
                if type(node.innerHTML) == "string" then node.innerHTML = node.innerHTML..value
                else node.innerHTML = source(node.innerHTML)..value end
            end
        else
            if not node.attributes then node.attributes = {} end
            node.attributes[key] = tostring(value)
        end
    end
    return node
end


local function process(element_name, element_attributes)
    return tree(element_name, element_attributes)
end


local function access(_, element)
    return function(...)
        return process(element, ...)
    end
end


-- extend built-in string module to support trimming and escaping of unsecure strings
local string_meta = getmetatable("")
string_meta.__index.trim = trim
string_meta.__index.escape = escape


return setmetatable({}, {__index = access, __call = process}) -- dom
