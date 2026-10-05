local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")

local Spacer = {}
Spacer.__index = Spacer

local SpacerClass = nil

--- Resolves and caches the native UMG spacer class.
-- @return (UClass|nil) The spacer class.
local function GetClass()
    if not Utils.IsValidObject(SpacerClass) then
        SpacerClass = StaticFindObject(Config.Paths.spacerClass)
    end
    return SpacerClass
end

--- Creates a native UMG spacer widget.
-- @param outer (UWidget|nil) Memory owner for the new widget.
-- @return (table|nil) Spacer wrapper, or nil when creation fails.
function Spacer.Create(outer)
    Core.Init()
    local cls = GetClass()
    if not Utils.IsValidObject(cls) then return nil end

    if not Utils.IsValidObject(outer) then
        outer = Utils.GetPlayerController()
    end

    local instance = Utils.ConstructObject(cls, outer)

    if not Utils.IsValidObject(instance) then return nil end

    return setmetatable({ Widget = instance }, Spacer)
end

return Spacer