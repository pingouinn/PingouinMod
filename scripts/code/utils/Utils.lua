local Types = require("code/utils/Types")
local Math = require("code/utils/Math")
local Entity = require("code/utils/Entity")
local World = require("code/utils/World")
local Path = require("code/utils/Path")

local Utils = {}
for _, module in ipairs({Types, Math, Entity, World, Path}) do
    for name, value in pairs(module) do
        Utils[name] = value
    end
end

return Utils