CollisionDeactivator = {}

-- TODO : When collision deactivated, the entity should be added to a list of entities with disabled collision
-- TODO : Find a way to detect back via raycast disabled collision entities

--- Toggles the collision of the element in front of the player.
-- @param verbose (boolean) If true, prints detailed information about the hit entity and its resolved target.
function CollisionDeactivator.ToggleElementCollisionInFront(verbose)
    local player = Utils.GetPlayer()
    if not Utils.IsValidObject(player) then 
        print("[PingouinMod] Player is not valid\n") 
        return 
    end

    local hitEntity = Utils.PerformRaycast(player, nil, nil, nil, nil, 50000.0, 2, false, {}, true, false, 0.0)
    if not hitEntity then 
        print("[PingouinMod] No hit returned from raycast\n") 
        return 
    end

    if verbose then 
        print(string.format("[PingouinMod] Hit raw entity: %s\n", tostring(hitEntity)))
    end

    local resolvedTarget = nil

    -- Secure extraction of the Actor or Component from the hit result
    pcall(function()
        if hitEntity.Actor then
            local a = hitEntity.Actor
            resolvedTarget = (type(a) == "userdata" and a.get and a:get()) or a
        end
    end)

    if not resolvedTarget then
        pcall(function()
            if hitEntity.Component then
                local c = hitEntity.Component
                resolvedTarget = (type(c) == "userdata" and c.get and c:get()) or c
            end
        end)
    end

    if not resolvedTarget then
        resolvedTarget = hitEntity
    end

    -- If the resolved target is a component, we attempt to get its owner actor
    pcall(function()
        if resolvedTarget and resolvedTarget.GetOwner then
            local owner = resolvedTarget:GetOwner()
            if owner and owner:IsValid() then
                resolvedTarget = owner
            end
        end
    end)

    if verbose then 
        -- Extract the name of the resolved target for logging purposes
        local entityName = "Unknown"
        local nameRetrieved = false

        pcall(function()
            if resolvedTarget and resolvedTarget.GetFullName then
                entityName = resolvedTarget:GetFullName()
                nameRetrieved = true
            end
        end)

        if not nameRetrieved then
            pcall(function()
                if resolvedTarget and resolvedTarget.GetName then
                    entityName = resolvedTarget:GetName()
                    nameRetrieved = true
                end
            end)
        end

        if not nameRetrieved then
            entityName = tostring(resolvedTarget)
        end

        print(string.format("[PingouinMod] Hit resolved: %s\n", entityName))
    end

    -- Disable collision on the resolved target, if possible
    Utils.DisableEntityCollision(resolvedTarget)
end

-- Collision keybind 
RegisterKeyBind(Keybinds.Collision, function()
    print("[PingouinMod] Disabling entity collision\n")
    CollisionDeactivator.ToggleElementCollisionInFront()
end)

return CollisionDeactivator
