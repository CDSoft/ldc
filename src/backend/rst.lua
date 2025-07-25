--[[
This file is part of ldc.

ldc is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ldc is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with ldc.  If not, see <https://www.gnu.org/licenses/>.

For further information about ldc you can visit
http://codeberg.org/cdsoft/ldc
]]

--@LIB=backend.rst

local backend = {}

local parser = require "parser"
local utils = require "utils"

local gen_const, gen_custom

local function gen_rst(ast, namespace)
    local s = parser.prelude(ast, "rst") or ""
    parser.leaves(ast, function(path, x, t)
        local name = utils.upper_snake_case(namespace, path)
        local val = gen_const(x, t)
        if val ~= nil then
            s = s .. ".. |" .. name .. "| replace:: " .. val .. "\n\n"
        end
    end)
    return s
end

gen_const = function(x, t)
    if t.kind == "uint" then return tostring(x) end
    if t.kind == "int" then return tostring(x) end
    if t.kind == "bool" then return tostring(x) end
    if t.kind == "double" then return tostring(x) end
    if t.kind == "str" then return tostring(x) end
    if t.kind == "custom" then return gen_custom(x, t) end
    error("Unknown value: " .. utils.dump(t))
end

gen_custom = function(x, t)
    local defs = t.definitions.sh
    if defs then
        return (defs.v or "%s"):format(x[1])
    end
end

function backend.compile(output, ast, namespace)
    return {
        {"rst", gen_rst(ast, namespace)},
    }
end

return backend
