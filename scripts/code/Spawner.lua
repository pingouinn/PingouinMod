--- Spawner.lua provides functions to spawn and delete actors in front of the player, track them, and manage their lifecycle. It also registers console commands for spawning and deleting actors, as well as retrieving information about tracked actors.
-- @author PingouinTheDev

local Spawner = {}
Spawner.entitytracker = {}

--- Detect meshes by path or reflected type.
-- @param asset (UObject) The asset to check
-- @param assetPath (string) The full Unreal asset path of the mesh
-- @return (boolean) True if the asset is a static mesh, false otherwise
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
-- @param assetPath (string) The full Unreal asset path of the mesh
-- @param verbose (boolean) Whether to print debug messages
-- @return (UStaticMesh|UObject|nil) The resolved mesh reference, or nil if not found
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

--- Internal native spawn taking collisionMethod into account.
-- @param world (UWorld) The world context for spawning
-- @param spawnClass (UClass) The class of the actor to spawn
-- @param location (table) The spawn location: {X, Y, Z}
-- @param rotation (table) The spawn rotation: {Pitch, Yaw, Roll}
-- @param collisionMethod (number) ESpawnActorCollisionHandlingMethod from Constants.SpawnCollisionHandling
-- @return (AActor|nil) The spawned actor, or nil if spawning failed
local function SpawnActorInternal(world, spawnClass, location, rotation, collisionMethod)
    local GameplayStatics = UEHelpers:GetGameplayStatics()
    local transform = {
        Translation = {X = location.X, Y = location.Y, Z = location.Z},
        Rotation = {Pitch = rotation.Pitch or 0, Yaw = rotation.Yaw or 0, Roll = rotation.Roll or 0},
        Scale3D = {X = 1, Y = 1, Z = 1}
    }

    local actor = nil
    if Utils.IsValidObject(GameplayStatics) and GameplayStatics.BeginDeferredActorSpawnFromClass then
        actor = GameplayStatics:BeginDeferredActorSpawnFromClass(world, spawnClass, transform, collisionMethod, nil, nil)
        if Utils.IsValidObject(actor) then
            Utils.SetActorSpawnCollisionMethod(actor, collisionMethod)
            GameplayStatics:FinishSpawningActor(actor, transform, false)
        end
    else
        actor = world:SpawnActor(spawnClass, location, rotation)
        if Utils.IsValidObject(actor) then
            Utils.SetActorSpawnCollisionMethod(actor, collisionMethod)
        end
    end

    if Utils.IsValidObject(actor) then
        Utils.TryCall("Set actor rotation", function()
            actor:K2_SetActorRotation({
                Pitch = rotation.Pitch or 0,
                Yaw = rotation.Yaw or 0,
                Roll = rotation.Roll or 0
            }, false)
        end)
    end

    return actor
end

--- Spawns an actor of the specified class in front of the player.
-- @param actorName (string) The full Unreal asset path of the actor class or the ShortName of the actor
-- @param distInFront (number|nil) The distance in front of the player to spawn the actor
-- @param verbose (boolean|nil) Whether to print debug messages
-- @param collisionMethod (number|nil) ESpawnActorCollisionHandlingMethod from Constants.SpawnCollisionHandling
-- @return (AActor|nil) The spawned actor, or nil if spawning failed
function Spawner.SpawnActor(actorName, distInFront, verbose, collisionMethod)
    local ActorClassPath = ShortNaming.HandleShortNaming(tostring(actorName))
    if ActorClassPath == nil then 
        print(string.format("[PingouinMod] ERROR: Could not resolve class name: %s\n", actorName)) 
        return nil 
    end
    verbose = verbose or false
    collisionMethod = collisionMethod or Constants.SpawnCollisionHandling.AdjustIfPossibleButAlwaysSpawn
    print("[PingouinMod] Spawning actor of class : " .. ActorClassPath .. "\n")
    local spawnedComponents = {}

    local loadedAsset = LoadAssetWithRetries(ActorClassPath, verbose)
    if not loadedAsset then
        print("[PingouinMod] ERROR: Failed to load asset after multiple attempts.\n")
        return nil
    end

    local player = Utils.GetPlayer()
    if not Utils.IsValidObject(player) then 
        print("[PingouinMod] ERROR: Could not get local player.\n") 
        return nil 
    end

    local targetDist = (type(distInFront) == "number" and distInFront > 0) and distInFront or 500.0
    local playerLoc = player:K2_GetActorLocation()
    local playerRot = player:K2_GetActorRotation()

    local newPos = Utils.GetPositionInFront and Utils.GetPositionInFront(playerLoc, playerRot, targetDist)
    if not newPos then
        local forwardVector = player:GetActorForwardVector()
        newPos = {
            X = playerLoc.X + (forwardVector.X * targetDist),
            Y = playerLoc.Y + (forwardVector.Y * targetDist),
            Z = playerLoc.Z + (forwardVector.Z * targetDist)
        }
    end

    if verbose then 
        print(string.format("[PingouinMod] Target position: X=%.2f Y=%.2f Z=%.2f (Dist: %.1f)\n", newPos.X, newPos.Y, newPos.Z, targetDist)) 
    end

    local world = UEHelpers:GetWorld()
    local spawnClass = loadedAsset
    local isStaticMesh = IsStaticMeshAsset(loadedAsset, ActorClassPath)

    if isStaticMesh then
        loadedAsset = Utils.ResolveStaticMesh(ActorClassPath, loadedAsset)
        spawnClass = LoadAssetWithRetries(Constants.STATIC_MESH_ACTOR_CLASS_PATH, verbose)
        if not spawnClass then
            print("[PingouinMod] ERROR: Could not load StaticMeshActor class.\n")
            return nil
        end
    else
        if spawnClass.GeneratedClass and Utils.IsValidObject(spawnClass.GeneratedClass) then
            spawnClass = spawnClass.GeneratedClass
        end
    end

    local spawnRot = {Pitch = 0, Yaw = (playerRot and playerRot.Yaw) or 0, Roll = 0}
    local Actor = SpawnActorInternal(world, spawnClass, newPos, spawnRot, collisionMethod)

    if not Utils.IsValidObject(Actor) then
        print("[PingouinMod] ERROR: Failed to instantiate actor (rejected by engine or collision rules).\n")
        return nil
    end

    if isStaticMesh then
        local componentClass = LoadAssetWithRetries(Constants.STATIC_MESH_COMPONENT_CLASS_PATH, verbose)
        if not componentClass then
            print("[PingouinMod] ERROR: Could not load StaticMeshComponent class.\n")
            Actor:K2_DestroyActor()
            return nil
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
            return nil
        end

        local setSuccess, setResult = Utils.TryCall("Assign static mesh", function()
            return meshComponent:SetStaticMesh(loadedAsset)
        end)
        local propertyAssigned = setSuccess and setResult == true
        if not setSuccess or setResult == false then
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
            return nil
        end

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

    AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
    if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:AddActor(Actor) end
    print("[PingouinMod] Actor registered to AWF Spawned Assets Manager.\n")
    
    Spawner.entitytracker[Actor] = {
        classPath = ActorClassPath,
        spawnTime = os.time(),
        createdAt = os.clock(),
        address = Actor:GetAddress(),
        className = Actor.ClassName,
        registeredDeletion = false,
        components = spawnedComponents,
    }

    return Actor
end

--- Deletes an actor and cleans up its tracking.
-- @param Actor (AActor) The actor to delete
-- @param verbose (boolean|nil) Whether to print debug messages
-- @return (boolean) True if the actor was successfully deleted, false otherwise
function Spawner.DeleteActor(Actor, verbose)
    verbose = verbose or false
    if not Utils.IsValidObject(Actor) then print("[PingouinMod] ERROR: Attempted to delete an invalid actor.\n") return end
    if verbose then print(string.format("[PingouinMod] Deleting actor [0x%X] of class: %s\n", Actor:GetAddress(), Actor.ClassName)) end

    AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
    if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:RemoveActor(Actor) end
    if verbose then print("[PingouinMod] Actor unregistered from AWF Spawned Assets Manager.\n") end

    local localTrackingSave = Spawner.entitytracker[Actor]
    Spawner.entitytracker[Actor] = nil
    if verbose then print("[PingouinMod] Actor removed from local entity tracker.\n") end

    local success = false
    Actor:K2_DestroyActor()
    if not Utils.IsValidObject(Actor) then
        if verbose then print("[PingouinMod] Actor successfully destroyed.\n") end
        success = true
    else
        print("[PingouinMod] ERROR: Failed to destroy actor.\n")
        AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
        if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:AddActor(Actor) end
        Spawner.entitytracker[Actor] = localTrackingSave
        if verbose then print("[PingouinMod] Actor tracking restored due to destruction failure.\n") end
    end

    return success
end

--- Retrieves all currently tracked actors from the entity tracker.
-- @return (table) A list of all tracked actors
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
    local now = os.clock()
    local GRACE_PERIOD = 2.0

    for actor, infos in pairs(Spawner.entitytracker) do
        local age = infos.createdAt and (now - infos.createdAt) or math.huge

        if not Utils.IsValidObject(actor) then
            if age >= GRACE_PERIOD then
                print(string.format("[PingouinMod] Garbage collecting invalid actor [0x%X] of class %s\n", infos.address, infos.className))
                Spawner.entitytracker[actor] = nil
            end
        elseif infos.registeredDeletion then
            Spawner.DeleteActor(actor, false)
        end
    end
    return false
end

--- Registers console command "Spawn" that allows the player to spawn an actor of a specified class in front of them.
-- @usage Spawn <ClassName> [distInFront] [verbose] [collisionMethod]
RegisterConsoleCommandHandler("Spawn", function(fullCommand, args, _)
    if #args < 1 then 
        print("[PingouinMod] Usage: Spawn <ClassName> [distInFront] [verbose] [collisionMethod]\n") 
        return false 
    end
    
    local distInFront = nil
    local verbose = false
    local collisionMethod = nil

    if #args >= 2 then
        local num = tonumber(args[2])
        if num then
            distInFront = num
            if #args >= 3 then verbose = GB_StrToBool[args[3]] or false end
            if #args >= 4 then collisionMethod = tonumber(args[4]) end
        else
            verbose = GB_StrToBool[args[2]] or false
            if #args >= 3 then collisionMethod = tonumber(args[3]) end
        end
    end

    ExecuteInGameThread(function()
        Spawner.SpawnActor(args[1], distInFront, verbose, collisionMethod)
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
    for i, v in pairs(allSpawnedActors) do print(i, v) end
    return false
end)

RegisterConsoleCommandHandler("GetInfosInternal", function(fullCommand, args, _)
    for actor, infos in pairs(Spawner.entitytracker) do
        print(string.format("Actor [0x%X] of class %s spawned at %s (Persistent: %s)\n", infos.address, infos.className, os.date("%Y-%m-%d %H:%M:%S", infos.spawnTime), tostring(infos.registeredDeletion)))
    end
    return false
end)

GCScheduler.RegisterGC(Spawner.GC, 0.5, false)

return Spawner