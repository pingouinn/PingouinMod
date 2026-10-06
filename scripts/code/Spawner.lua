--- Spawner.lua provides functions to spawn and delete actors in front of the player, track them, and manage their lifecycle. It also registers console commands for spawning and deleting actors, as well as retrieving information about tracked actors.
-- @author PingouinTheDev

local Spawner = {}

Spawner.entitytracker = {}

--- Detect meshes by path or reflected type.
-- @param asset (UObject) The asset to inspect
-- @param assetPath (string) The full Unreal asset path
-- @return (boolean) True when the asset is a StaticMesh
local function IsStaticMeshAsset(asset, assetPath)
    if not Utils.IsValidObject(asset) then return false end

    local normalizedPath = string.lower(tostring(assetPath or ""))
    if string.find(normalizedPath, "/staticmeshes/", 1, true) then return true end

    local success, isStaticMesh = Utils.TryCall("Check static mesh asset", function()
        return asset:IsA(Constants.STATIC_MESH_CLASS_PATH)
    end)
    return success and isStaticMesh == true
end

--- Resolve a typed mesh reference before passing it to SetStaticMesh. Asset loading can be asynchronous, so retry a few times.
-- @param assetPath (string) The full Unreal asset path
-- @param verbose (boolean) Whether to print debug messages
-- @return (UStaticMesh|nil) The resolved mesh reference, or nil if not found
local function LoadAssetWithRetries(assetPath, verbose)
    local maxRetries = 5
    local loadedAsset

    repeat
        loadedAsset = StaticFindObject(assetPath)
        if not Utils.IsValidObject(loadedAsset) then
            if verbose then print("[PingouinMod] Asset not loaded yet, attempting to load it...\n") end
            loadedAsset = LoadAsset(assetPath)
        end

        if Utils.IsValidObject(loadedAsset) then return loadedAsset end
        maxRetries = maxRetries - 1
        if verbose and maxRetries > 0 then
            print(string.format("[PingouinMod] Failed to load asset, retrying... (%d retries left)\n", maxRetries))
        end
    until maxRetries == 0

    return nil
end

--- Spawns an actor of the specified class in front of the player.
-- @param ActorClassPath (string) The full Unreal asset path of the actor class
-- @param distInFront (number) The distance in front of the player to spawn the actor
-- @param verbose (boolean) Whether to print debug messages
-- @return (AActor|nil) The spawned actor, or nil if spawning failed
function Spawner.SpawnActor(ActorClassPath, distInFront, verbose)
    verbose = verbose or false
    print("[PingouinMod] Spawning actor of class : " .. ActorClassPath .. "\n")
    local spawnedComponents = {}

    local loadedAsset = LoadAssetWithRetries(ActorClassPath, verbose)
    if not loadedAsset then
        print("[PingouinMod] ERROR: Failed to load asset after multiple attempts.\n")
        return
    end

    local player = Utils.GetPlayer()
    if not Utils.IsValidObject(player) then print("[PingouinMod] ERROR: Could not get local player.\n") return end

    -- Spawn the actor in front of the player
    local newPos = Utils.GetPositionInFront(player:K2_GetActorLocation(), player:K2_GetActorRotation(), distInFront or 50.0) 
    if verbose then print(string.format("[PingouinMod] Spawning at position: X=%.2f Y=%.2f Z=%.2f\n", newPos.X, newPos.Y, newPos.Z)) end

    local world = UEHelpers:GetWorld()
    local spawnClass = loadedAsset
    local isStaticMesh = IsStaticMeshAsset(loadedAsset, ActorClassPath)
    if isStaticMesh then
        -- StaticMesh assets need a native actor wrapper before spawning.
        loadedAsset = Utils.ResolveStaticMesh(ActorClassPath, loadedAsset)
        spawnClass = LoadAssetWithRetries(Constants.STATIC_MESH_ACTOR_CLASS_PATH, verbose)
        if not spawnClass then
            print("[PingouinMod] ERROR: Could not load StaticMeshActor class.\n")
            return
        end
    end

    local Actor = world:SpawnActor(spawnClass, newPos, {Pitch = 0, Yaw = 0, Roll = 0})
    if not Utils.IsValidObject(Actor) then
        print("[PingouinMod] Failed to spawn actor.\n")
        return
    end

    if isStaticMesh then
        -- Create an instance component, then assign the mesh.
        local componentClass = LoadAssetWithRetries(Constants.STATIC_MESH_COMPONENT_CLASS_PATH, verbose)
        if not componentClass then
            print("[PingouinMod] ERROR: Could not load StaticMeshComponent class.\n")
            Actor:K2_DestroyActor()
            return
        end

        local addSuccess, meshComponent = Utils.TryCall("Create static mesh component", function()
            return Actor:AddComponentByClass(componentClass, false, {
                Translation = {X = 0, Y = 0, Z = 0},
                Rotation = {Pitch = 0, Yaw = 0, Roll = 0},
                Scale3D = {X = 1, Y = 1, Z = 1},
            }, false)
        end)
        if not addSuccess or not Utils.IsValidObject(meshComponent) then
            print("[PingouinMod] ERROR: Could not create StaticMeshComponent.\n")
            Actor:K2_DestroyActor()
            return
        end

        local setSuccess, setResult = Utils.TryCall("Assign static mesh", function()
            return meshComponent:SetStaticMesh(loadedAsset)
        end)
        local propertyAssigned = setSuccess and setResult == true
        if not setSuccess or setResult == false then
            -- Some UE4SS versions require direct property assignment.
            local propertySuccess, propertyMesh = Utils.TryCall("Assign static mesh property", function()
                meshComponent.StaticMesh = loadedAsset
                return meshComponent.StaticMesh
            end)
            local propertyValid = false
            if propertySuccess and propertyMesh then
                local validSuccess, validResult = Utils.TryCall("Validate assigned static mesh", function()
                    return Utils.IsValidObject(propertyMesh)
                end)
                propertyValid = validSuccess and validResult == true
            end
            propertyAssigned = propertyValid
        end

        if not propertyAssigned then
            print("[PingouinMod] ERROR: Could not assign StaticMesh.\n")
            Actor:K2_DestroyActor()
            return
        end

        -- Refresh registration and rendering after changing the mesh.
        local registerSuccess, registerResult = Utils.TryCall("Register static mesh component", function() return meshComponent:RegisterComponentWithWorld(world) end)
        if not registerSuccess or registerResult == false then
            Utils.TryCall("Register static mesh component fallback", function() meshComponent:RegisterComponent() end)
        end
        Utils.TryCall("Show spawned actor", function() Actor:SetActorHiddenInGame(false) end)
        Utils.TryCall("Show spawned mesh component", function() meshComponent:SetVisibility(true, true) end)
        Utils.TryCall("Refresh spawned mesh render state", function() meshComponent:MarkRenderStateDirty() end)
        table.insert(spawnedComponents, meshComponent)
    end
    
    if verbose then print(string.format("[PingouinMod] Successfully spawned actor [0x%X] of class: %s\n", Actor:GetAddress(), Actor.ClassName)) end

    -- Add asset to the Game Manager for tracking 
    -- ### Unsure of the utility and behavior of it for now
    AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
    if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:AddActor(Actor) end
    print("[PingouinMod] Actor registered to AWF Spawned Assets Manager.\n")
    
    -- Track spawned entity for further manipulation / deletion if needed 
    Spawner.entitytracker[Actor] = {
        classPath = ActorClassPath,
        spawnTime = os.time(),
        address = Actor:GetAddress(),
        className = Actor.ClassName, 
        registeredDeletion = false,
        components = spawnedComponents,
    }

    return Actor
end

--- Deletes an actor and cleans up its tracking.
-- @param Actor (AActor) The actor to delete
-- @param verbose (boolean) Whether to print debug messages
function Spawner.DeleteActor(Actor, verbose)
    verbose = verbose or false
    if not Utils.IsValidObject(Actor) then print("[PingouinMod] ERROR: Attempted to delete an invalid actor.\n") return end
    if verbose then print(string.format("[PingouinMod] Deleting actor [0x%X] of class: %s\n", Actor:GetAddress(), Actor.ClassName)) end

    -- Remove from Game Manager tracking
    AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
    if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:RemoveActor(Actor) end
    if verbose then print("[PingouinMod] Actor unregistered from AWF Spawned Assets Manager.\n") end

    -- Remove from local tracking
    local localTrackingSave = Spawner.entitytracker[Actor]
    Spawner.entitytracker[Actor] = nil
    if verbose then print("[PingouinMod] Actor removed from local entity tracker.\n") end


    local success = false
    -- Destroy the actor
    Actor:K2_DestroyActor()
    if not Utils.IsValidObject(Actor) then
        if verbose then print("[PingouinMod] Actor successfully destroyed.\n") end
        success = true
    else
        print("[PingouinMod] ERROR: Failed to destroy actor.\n")

        -- Restore tracking on failure
        AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
        if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:AddActor(Actor) end

        Spawner.entitytracker[Actor] = localTrackingSave
        if verbose then print("[PingouinMod] Actor tracking restored due to destruction failure.\n") end
    end

    return success
end

--- Retrieves all currently tracked actors from the entity tracker.
-- @return (table) A list of all valid tracked actors
function Spawner.GetAllTrackedActors()
    local trackedActors = {}
    for actor, _ in pairs(Spawner.entitytracker) do
        if Utils.IsValidObject(actor) then
            table.insert(trackedActors, actor)
        end
    end
    return trackedActors
end

--- Performs garbage collection on the entity tracker, removing invalid actors.
-- @return (boolean) Always returns false to indicate the GC process is complete
function Spawner.GC()
    for actor, infos in pairs(Spawner.entitytracker) do
        if not Utils.IsValidObject(actor) then
            print(string.format("[PingouinMod] Garbage collecting invalid actor [0x%X] of class %s\n", infos.address, infos.className))
            Spawner.entitytracker[actor] = nil
        elseif infos.registeredDeletion then
            Spawner.DeleteActor(actor, false)
        end
    end
    return false
end

--- Registers a console command "Spawn" that allows the player to spawn an actor of a specified class in front of them. The command takes the class name, an optional distance in front, and an optional verbosity flag.
-- @usage Spawn <ClassName> [distInFront] [verbose]
RegisterConsoleCommandHandler("Spawn", function(fullCommand, args, _)
    print("[PingouinMod] Command Spawn activated\n")
    if #args < 1 then print("[PingouinMod] ERROR: No class name provided. Usage: Spawn <ClassName distInFront verbose>\n") return false end

    -- Handle short naming if needed
    local className = ShortNaming.HandleShortNaming(args[1])
    if className == nil then print(string.format("[PingouinMod] ERROR: Could not resolve class name for short name: %s\n", args[1])) return false end
    
    local distInFront
    if #args > 1 then distInFront = tonumber(args[2]) end

    local verbose
    if #args > 2 then verbose = GB_StrToBool[args[3]] end

    ExecuteInGameThread(function()
        Spawner.SpawnActor(className, distInFront, verbose)
    end)
    return true
end)

-- DEBUG COMMANDS
RegisterConsoleCommandHandler("DeleteAll", function(fullCommand, args, _)
    for actor, _ in pairs(Spawner.entitytracker) do
        Spawner.DeleteActor(actor, true)
    end
    return true
end)

RegisterConsoleCommandHandler("GetInfosAWF", function(fullCommand, args, _)
    local allSpawnedActors = WildFire.AWFSpawnedAssetsManager:GetAllSpawnedActors()
    if not allSpawnedActors then print("[PingouinMod] No spawned actors found in AWF Spawned Assets Manager.\n") return false end
    
    for i, v in pairs(allSpawnedActors) do
        print(i, v)
    end
    return false
end)

RegisterConsoleCommandHandler("GetInfosInternal", function(fullCommand, args, _)
    for actor, infos in pairs(Spawner.entitytracker) do
        print(string.format("Actor [0x%X] of class %s spawned at %s (Persistent: %s)\n", infos.address, infos.className, os.date("%Y-%m-%d %H:%M:%S", infos.spawnTime), tostring(infos.registeredDeletion)))
    end
    return false
end)

-- Periodic GC to clean up invalid actors from the tracker.
GCScheduler.RegisterGC(Spawner.GC, 0.5, false)

return Spawner