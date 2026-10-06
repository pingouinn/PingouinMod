--- Utils.lua is a utility module that aggregates various utility functions from different modules, including Types, Math, Entity, World, Path, and Player. It provides a single interface for accessing these utilities.
-- @author PingouinTheDev

local Types = require("code/utils/Types")
local Math = require("code/utils/Math")
local Entity = require("code/utils/Entity")
local World = require("code/utils/World")
local Path = require("code/utils/Path")
local Player = require("code/utils/Player")

local Utils = {}
for _, module in ipairs({Types, Math, Entity, World, Path, Player}) do
    for name, value in pairs(module) do
        Utils[name] = value
    end
end

return Utils