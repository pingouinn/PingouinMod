-- This part implements short naming for function calls
local ShortNaming = {}

local INIPATH = SCRIPT_DIR .. "config.ini"
local shortNameMap = {}

-- Ordered Blueprint folders used only as a last-resort convenience lookup.
local probableBlueprintPaths = {
    "/Game/Wildfire/Blueprints/Core/Characters/",
    "/Game/Wildfire/Blueprints/Core/Characters/Civilians/",
    "/Game/Wildfire/Blueprints/Core/Characters/Firefighters/",
    "/Game/Wildfire/Blueprints/Core/Vehicles/",
    "/Game/Wildfire/Blueprints/Core/Vehicles/CCF/",
    "/Game/Wildfire/Blueprints/Core/Vehicles/Helicopter_EC145/",
    "/Game/Wildfire/Blueprints/Core/Items/",
    "/Game/Wildfire/Blueprints/Core/Items/BackpackPump/",
    "/Game/Wildfire/Blueprints/Core/Items/Chainsaw/",
    "/Game/Wildfire/Blueprints/Core/Items/DripTorch/",
    "/Game/Wildfire/Blueprints/Core/Items/EscapeMask/",
    "/Game/Wildfire/Blueprints/Core/Items/FireHose/",
    "/Game/Wildfire/Blueprints/Core/Items/Flamethrower/",
    "/Game/Wildfire/Blueprints/Core/Items/FrameBackpack/",
    "/Game/Wildfire/Blueprints/Core/Items/Heal/",
    "/Game/Wildfire/Blueprints/Core/Items/MedBackpack/",
    "/Game/Wildfire/Blueprints/Core/Items/Pump/",
    "/Game/Wildfire/Blueprints/Core/Items/Rake/",
    "/Game/Wildfire/Blueprints/Core/Items/WaterShield/",
    "/Game/Wildfire/Blueprints/Core/Items/Winch/",
    "/Game/Wildfire/Blueprints/Core/Connectors/",
}

-- Caches a short name and its corresponding asset path in the short naming map and saves it to the config file.
-- @param shortName (string) The short name to cache.
-- @param assetPath (string) The full asset path corresponding to the short name.
-- @return (string) The asset path that was cached.
local function CacheShortName(shortName, assetPath)
    shortNameMap[shortName] = assetPath
    LIP.saveWrapper({
        ShortNaming = {
            [shortName] = assetPath,
        },
    })
    return assetPath
end

--- Attempts to find the full asset path for a given short name by searching through probable blueprint paths.
-- @param shortName (string) The short name to search for.
-- @return (string or nil) The full asset path if found, or nil if not found.
local function FindBlueprintPath(shortName)
    for _, basePath in ipairs(probableBlueprintPaths) do
        local candidatePath = ShortNaming.ConstructName(basePath, shortName)
        local foundObject = StaticFindObject(candidatePath)
        if not Utils.IsValidObject(foundObject) then
            foundObject = LoadAsset(candidatePath)
        end
        if Utils.IsValidObject(foundObject) then return candidatePath end
    end
    return nil
end

--- Handles short naming for actor class paths. If the provided name is already a full path, it returns it as is. Otherwise, it attempts to resolve the short name to a full path using the short naming map or by searching probable blueprint paths.
-- @param ActorShortName (string) The short name or full path of the actor class.
-- @return (string or nil) The resolved full path of the actor class, or nil if not found.
function ShortNaming.HandleShortNaming(ActorShortName)
    -- If already formed as a full path, return as is
    if string.sub(ActorShortName, 1, 6) == "/Game/" then return ActorShortName end

    ActorShortName = string.lower(ActorShortName)

    -- Check in the short naming map first
    if shortNameMap[ActorShortName] then
        return shortNameMap[ActorShortName]
    end

    -- Only Blueprint candidates are guessed; meshes should use an explicit alias.
    local finalActorClassPath = FindBlueprintPath(ActorShortName)
    return finalActorClassPath and CacheShortName(ActorShortName, finalActorClassPath) or nil
end

--- Populates the short naming map from a configuration file. If the file contains a "ShortNaming" section, it reads each entry and adds it to the short naming map.
-- @param filePath (string) The path to the configuration file.
function ShortNaming.PopulateShortNamesFromFile(filePath)
    local data = LIP.loadWrapper();

    if data.ShortNaming == nil then print("[PingouinMod] No ShortNaming section found in config file: " .. filePath .. "\n") return end

    for shortName, classPath in pairs(data.ShortNaming) do
        shortName = string.lower(shortName)
        shortNameMap[shortName] = classPath
    end

    print("[PingouinMod] Short naming map populated from file: " .. filePath .. "\n")
end

--- Constructs a full asset path from a base path and a short name. This is used to generate the expected full path for a given short name.
-- @param path (string) The base path where the asset is located.
-- @param name (string) The short name of the asset.
-- @return (string) The constructed full asset path.
function ShortNaming.ConstructName(path, name)
    return path .. name .. "." .. name .. "_C"
end

-- Populate the short naming map at script load
ShortNaming.PopulateShortNamesFromFile(INIPATH)

return ShortNaming

-- TODO : Test that LIP.saveWrapper works correctly and does not overwrite existing entries

