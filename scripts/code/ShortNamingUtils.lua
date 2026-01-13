-- This part implements short naming for function calls
local ShortNaming = {}

local INIPATH = SCRIPT_DIR .. "config.ini"
local shortNameMap = {}
local probablePaths = {
    ["/Game/Wildfire/Blueprints/Core/Characters/"] = {
        "Civilians/",
        "Firefighters/",
        "Stretcher/",
    },
    ["/Game/Wildfire/Blueprints/Core/Vehicles/"] = {
        "CCF/",
        "Helicopter_EC145/",
    },
    ["/Game/Wildfire/Blueprints/Core/Items/"] = {
        "BackpackPump/",
        "Chainsaw/",
        "DripTorch/",
        "EscapeMask/",
        "FireHose/",
        "Flamethrower/",
        "FrameBackpack/",
        "Heal/",
        "MedBackpack/",
        "Pump/",
        "Rake/",
        "WaterShield/",
        "Winch/",
    },
    ["/Game/Wildfire/Blueprints/Core/Connectors/"] = {},
}

function ShortNaming.HandleShortNaming(ActorShortName)
    -- If already formed as a full path, return as is
    if string.sub(ActorShortName, 1, 6) == "/Game/" then return ActorShortName end

    -- Check in the short naming map first
    if shortNameMap[ActorShortName] then
        return shortNameMap[ActorShortName]
    end

    local finalActorClassPath = nil
    -- If not found in the map, we search in probable paths
    for basePath, subPaths in pairs(probablePaths) do
        -- First check in the base path
        local constructedName = ShortNaming.ConstructName(basePath, ActorShortName)
        LoadAsset(constructedName)
        local foundObject = StaticFindObject(constructedName)
        if foundObject and foundObject:IsValid() then
            finalActorClassPath = constructedName

            -- Adds the entry to the short naming map for faster future access
            LIP.saveWrapper({
                ShortNaming = {
                    [ActorShortName] = finalActorClassPath
                }
            })
            break
        end

        -- Then check in subpaths
        for _, subPath in ipairs(subPaths) do
            constructedName = ShortNaming.ConstructName(basePath .. subPath, ActorShortName)
            LoadAsset(constructedName)
            foundObject = StaticFindObject(constructedName)
            if foundObject and foundObject:IsValid() then
                finalActorClassPath = constructedName

                -- Adds the entry to the short naming map for faster future access
                LIP.saveWrapper({
                    ShortNaming = {
                        [ActorShortName] = finalActorClassPath
                    }
                })
                break
            end
        end

        if finalActorClassPath then
            break
        end
    end

    return finalActorClassPath
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

