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

local function IsValidObject(object)
    return object and object:IsValid()
end

local function CacheShortName(shortName, assetPath)
    shortNameMap[shortName] = assetPath
    LIP.saveWrapper({
        ShortNaming = {
            [shortName] = assetPath,
        },
    })
    return assetPath
end

local function FindBlueprintPath(shortName)
    for _, basePath in ipairs(probableBlueprintPaths) do
        local candidatePath = ShortNaming.ConstructName(basePath, shortName)
        local foundObject = StaticFindObject(candidatePath)
        if not IsValidObject(foundObject) then
            foundObject = LoadAsset(candidatePath)
        end
        if IsValidObject(foundObject) then return candidatePath end
    end
    return nil
end

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

function ShortNaming.PopulateShortNamesFromFile(filePath)
    local data = LIP.loadWrapper();

    if data.ShortNaming == nil then print("[PingouinMod] No ShortNaming section found in config file: " .. filePath .. "\n") return end

    for shortName, classPath in pairs(data.ShortNaming) do
        shortName = string.lower(shortName)
        shortNameMap[shortName] = classPath
    end

    print("[PingouinMod] Short naming map populated from file: " .. filePath .. "\n")
end

function ShortNaming.ConstructName(path, name)
    return path .. name .. "." .. name .. "_C"
end

-- Populate the short naming map at script load
ShortNaming.PopulateShortNamesFromFile(INIPATH)

return ShortNaming

-- TODO : Test that LIP.saveWrapper works correctly and does not overwrite existing entries

