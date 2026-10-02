EntityOutline = {}

EntityOutline.OutlinedEntities = {}

--- Adds or removes an outline effect on an entity by enabling or disabling custom depth rendering.
-- @param entity (AActor) The entity to modify
-- @param bEnabled (boolean) Whether to enable or disable the outline
-- @param stencilValue (number) The stencil value to use for the outline
local function SetEntityCustomDepth(entity, bEnabled, stencilValue)
    if not Utils.IsValidObject(entity) then return end

    -- If the entity has a SetRenderCustomDepth method, use it directly
    if entity.SetRenderCustomDepth then
        entity:SetRenderCustomDepth(bEnabled)
        if bEnabled and stencilValue ~= nil then
            entity:SetCustomDepthStencilValue(stencilValue)
        end
        return
    end

    -- If the entity doesn't have a SetRenderCustomDepth method, attempt to find its mesh component and apply the outline effect on it
    local meshClass = StaticFindObject("/Script/Engine.MeshComponent")
    if not meshClass then
        meshClass = StaticFindObject("/Script/Engine.PrimitiveComponent")
    end

    if meshClass and entity.GetComponentsByClass then
        local components = entity:GetComponentsByClass(meshClass)
        if components then
            -- If the components collection has a ForEach method, use it; otherwise, iterate over the table.
            if components.ForEach then
                components:ForEach(function(index, comp)
                    if Utils.IsValidObject(comp) and comp.SetRenderCustomDepth then
                        comp:SetRenderCustomDepth(bEnabled)
                        if bEnabled and stencilValue ~= nil then
                            comp:SetCustomDepthStencilValue(stencilValue)
                        end
                    end
                end)
            elseif type(components) == "table" then
                for _, comp in ipairs(components) do
                    if Utils.IsValidObject(comp) and comp.SetRenderCustomDepth then
                        comp:SetRenderCustomDepth(bEnabled)
                        if bEnabled and stencilValue ~= nil then
                            comp:SetCustomDepthStencilValue(stencilValue)
                        end
                    end
                end
            end
        end
    end
end

-- Adds an outline effect to an entity.
-- @param entity (AActor) The entity to add an outline to
-- @param stencilValue (number) The stencil value to use for the outline
function EntityOutline.AddEntityOutline(entity, stencilValue)
    local key = Utils.GetEntityKey(entity)
    if not key then return end

    stencilValue = stencilValue or 0
    SetEntityCustomDepth(entity, true, stencilValue)

    -- On stocke l'entité sous sa clé unique
    EntityOutline.OutlinedEntities[key] = entity
end

--- Removes the outline effect from an entity.
-- @param entity (AActor) The entity to remove the outline from
function EntityOutline.RemoveEntityOutline(entity)
    local key = Utils.GetEntityKey(entity)
    if not key then return end

    SetEntityCustomDepth(entity, false, 0)

    EntityOutline.OutlinedEntities[key] = nil
end

--- Toggles the outline effect on the entity currently under the player's crosshair.
-- @param stencilValue (number) The stencil value to use for the outline
function EntityOutline.ToggleRaycastedEntityOutline(stencilValue)
    local entity = Utils.PerformRaycast(nil, nil, nil, nil, nil, 50000.0, 1, false, {}, true, false, 0.0)
    if entity == nil then 
        print("[PingouinMod] No entity hit\n") 
        return 
    end
    if not Utils.IsValidObject(entity) then 
        print("[PingouinMod] Hit entity is not valid\n") 
        return 
    end

    local key = Utils.GetEntityKey(entity)
    if not key then return end

    if EntityOutline.OutlinedEntities[key] then
        print("[PingouinMod] Removing outline from entity\n")
        EntityOutline.RemoveEntityOutline(entity)
        return
    end

    print("[PingouinMod] Adding outline to entity\n")
    EntityOutline.AddEntityOutline(entity, stencilValue or 0)
end

--- Performs garbage collection on the outlined entities.
function EntityOutline.GC()
    for key, entity in pairs(EntityOutline.OutlinedEntities) do
        if not Utils.IsValidObject(entity) then
            EntityOutline.OutlinedEntities[key] = nil
        end
    end
end

RegisterKeyBind(Keybinds.EntityOutline, function()
    print("[PingouinMod] Displaying raycasted entity outline\n")
    ExecuteInGameThread(function()
        EntityOutline.ToggleRaycastedEntityOutline()
    end)
end)

return EntityOutline