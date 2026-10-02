WorldBoundaries = {}

local BOUNDARY_ACTOR_CLASSES = {
    "BP_PCGSplineFence_C", -- TODO : This deletes all the fences, maybe we can add a way to check only for the blocking ones
}

--- Disables all BlockingVolume actors in the world to remove world boundaries.
--- Also deletes specific actors that are known to enforce world boundaries, such as "BP_PCGSplineFence_C".
function WorldBoundaries.DisableAllBlockingVolumes()
    ExecuteInGameThread(function()
        local volumes = FindAllOf("BlockingVolume")
        local count = 0
        if volumes then
            for _, volume in ipairs(volumes) do
                if volume:IsValid() then
                    volume:SetActorEnableCollision(false)
                    count = count + 1
                end
            end
        end

        -- Delete specific actors that enforce world boundaries
        for _, className in ipairs(BOUNDARY_ACTOR_CLASSES) do
            local actors = FindAllOf(className)
            if actors then
                for _, actor in ipairs(actors) do
                    if actor:IsValid() then
                        local actorName = actor:GetFullName()
                        
                        -- Méthode officielle Unreal Engine pour détruire un AActor
                        if actor.K2_DestroyActor then
                            actor:K2_DestroyActor()
                            print(string.format("[PingouinMod] Destroyed actor of class %s: %s\n", className, actorName))
                        else
                            -- Solution de repli si K2_DestroyActor n'est pas exposé
                            actor:SetActorEnableCollision(false)
                            actor:SetActorHiddenInGame(true)
                            print(string.format("[PingouinMod] Disabled & hid actor of class %s: %s\n", className, actorName))
                        end
                    end
                end
            end
        end

        print(string.format("[PingouinMod] Deactivated collision on %d BlockingVolume(s).\n", count))
    end)
end

-- World boundaries keybind
RegisterKeyBind(Keybinds.WorldBoundaries, function()
    print("[PingouinMod] Disabling world boundaries\n")
    WorldBoundaries.DisableAllBlockingVolumes()
end)

return WorldBoundaries