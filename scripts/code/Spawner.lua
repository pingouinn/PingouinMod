local Spawner = {}

Spawner.entitytracker = {}

function Spawner.SpawnActor(ActorClassPath, verbose)
    verbose = verbose or false
    print("[PingouinMod] Spawning actor of class : " .. ActorClassPath .. "\n")

    -- We try a FindObject first to see if the asset is already loaded, else we load it
    local maxRetries = 5
    ::retry::
    local LoadedAssetClass = StaticFindObject(ActorClassPath) --[[@as UClass]]
    if not LoadedAssetClass:IsValid() then
        if verbose then print("[PingouinMod] Asset class not loaded yet, attempting to load it...\n") end
        LoadedAssetClass = LoadAsset(ActorClassPath) --[[@as UClass]]
        if not LoadedAssetClass:IsValid() then
            maxRetries = maxRetries - 1
            if maxRetries > 0 then
                if verbose then print(string.format("[PingouinMod] Failed to load asset class, retrying... (%d retries left)\n", maxRetries)) end
                goto retry
            else
                print("[PingouinMod] ERROR: Failed to load asset class after multiple attempts.\n")
                return
            end
        end
    end

    if verbose then print(string.format("[PingouinMod] Successfully loaded asset class [0x%X] of class: %s\n", LoadedAssetClass:GetAddress(), LoadedAssetClass.ClassName)) end
    local player = UEHelpers:GetPlayer()
    if not player:IsValid() then print("[PingouinMod] ERROR: Could not get local player.\n") return end

    -- Spawn the actor in front of the player
    local newPos = Utils.GetPositionInFront(player:K2_GetActorLocation(), player:K2_GetActorRotation(), 500) -- TODO : Make it dynamic or config based (its to avoid vehicles spawning inside the player currently)
    if verbose then print(string.format("[PingouinMod] Spawning at position: X=%.2f Y=%.2f Z=%.2f\n", newPos.X, newPos.Y, newPos.Z)) end

    local world = UEHelpers:GetWorld()
    local Actor = world:SpawnActor(LoadedAssetClass, newPos, {Pitch = 0, Yaw = 0, Roll = 0})
    if not Actor:IsValid() then print("[PingouinMod] Failed to spawn actor.\n") return end
    
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
    }

    return Actor
end

function Spawner.DeleteActor(Actor, verbose)
    verbose = verbose or false
    if not Actor:IsValid() then print("[PingouinMod] ERROR: Attempted to delete an invalid actor.\n") return end
    if verbose then print(string.format("[PingouinMod] Deleting actor [0x%X] of class: %s\n", Actor:GetAddress(), Actor.ClassName)) end

    -- Remove from Game Manager tracking
    AWFSpawnedAssetsManager = WildFire.AWFSpawnedAssetsManager
    if AWFSpawnedAssetsManager then AWFSpawnedAssetsManager:RemoveActor(Actor) end
    if verbose then print("[PingouinMod] Actor unregistered from AWF Spawned Assets Manager.\n") end

    -- Remove from local tracking
    local localTrackingSave = Spawner.entitytracker[Actor]
    Spawner.entitytracker[Actor] = nil
    if verbose then print("[PingouinMod] Actor removed from local entity tracker.\n") end


    -- Destroy the actor
    Actor:K2_DestroyActor()
    if not Actor:IsValid() then 
        if verbose then print("[PingouinMod] Actor successfully destroyed.\n") end
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

function Spawner.GC()
    for actor, infos in pairs(Spawner.entitytracker) do
        if not actor:IsValid() then
            print(string.format("[PingouinMod] Garbage collecting invalid actor [0x%X] of class %s\n", infos.address, infos.className))
            Spawner.entitytracker[actor] = nil
        elseif infos.registeredDeletion then
            Spawner.DeleteActor(actor, false)
        end
    end
    return false
end


RegisterConsoleCommandHandler("Spawn", function(fullCommand, args, _)
    print("[PingouinMod] Command Spawn activated\n")
    if #args < 1 then print("[PingouinMod] ERROR: No class name provided. Usage: Spawn <ClassName checkColAtSpawn verbose>\n") return false end
    local verbose
    if #args > 1 then verbose = GB_StrToBool[args[3]] end


    -- Handle short naming if needed
    local className = ShortNaming.HandleShortNaming(string.lower(args[1]))
    if className == nil then print(string.format("[PingouinMod] ERROR: Could not resolve class name for short name: %s\n", args[1])) return false end

    ExecuteInGameThread(function()
        Spawner.SpawnActor(className, verbose)
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

-- Periodic GC to clean up invalid actors from the tracker
LoopAsync(500, function()
    Spawner.GC()
end)

return Spawner