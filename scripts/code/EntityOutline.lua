EntityOutline = {}

EntityOutline.OutlinedEntities = {}
local Spawner = require("code/Spawner")

--- Enables or disables custom depth rendering on a component, optionally setting a stencil value.
-- @param comp (UActorComponent) The component to modify
-- @param bEnabled (boolean) Whether to enable or disable custom depth rendering
-- @param stencilValue (number) The stencil value to use for custom depth rendering
local function EnableCustomDepthOnComponent(comp, bEnabled, stencilValue)
    if not Utils.IsValidObject(comp) then return end

    if comp.SetRenderCustomDepth then
        local success, errorMessage = pcall(function()
            comp:SetRenderCustomDepth(bEnabled)
            if bEnabled and stencilValue ~= nil and comp.SetCustomDepthStencilValue then
                comp:SetCustomDepthStencilValue(stencilValue)
            end
        end)
        if not success then
            print(string.format("[PingouinMod] Failed to update custom depth on component: %s\n", tostring(errorMessage)))
        end
    end
end

--- Enables or disables custom depth rendering on a component and its attached children.
-- @param comp (UActorComponent) The component to modify
-- @param bEnabled (boolean) Whether to enable or disable custom depth rendering
-- @param stencilValue (number) The stencil value to use for custom depth rendering
local function ProcessComponentHierarchy(comp, bEnabled, stencilValue, visited)
    if not Utils.IsValidObject(comp) then return end
    if visited[comp] then return end
    visited[comp] = true

    EnableCustomDepthOnComponent(comp, bEnabled, stencilValue)

    if comp.AttachChildren then
        local children = comp.AttachChildren
        if children.ForEach then
            children:ForEach(function(index, child)
                ProcessComponentHierarchy(child, bEnabled, stencilValue, visited)
            end)
        elseif type(children) == "table" then
            for _, child in ipairs(children) do
                ProcessComponentHierarchy(child, bEnabled, stencilValue, visited)
            end
        end
    end
end

--- Applies or removes an outline effect on an entity by enabling or disabling custom depth rendering on its components and attached children.
-- @param entity (AActor) The entity to modify
-- @param bEnabled (boolean) Whether to enable or disable the outline effect
-- @param stencilValue (number) The stencil value to use for the outline effect
local function ApplyCustomDepthToActor(actor, bEnabled, stencilValue, visited)
    if not Utils.IsValidObject(actor) then return end
    if visited[actor] then return end
    visited[actor] = true

    local entityInfo = Spawner.entitytracker[actor]
    if entityInfo and entityInfo.components then
        for _, component in ipairs(entityInfo.components) do
            ProcessComponentHierarchy(component, bEnabled, stencilValue, visited)
        end
    end

    -- If the actor has a root component, we process it and its hierarchy
    if actor.RootComponent and Utils.IsValidObject(actor.RootComponent) then
        ProcessComponentHierarchy(actor.RootComponent, bEnabled, stencilValue, visited)
    end

    -- We also check for attached child actors and apply the same logic recursively
    if actor.Children then
        local childrenActors = actor.Children
        if childrenActors.ForEach then
            childrenActors:ForEach(function(index, childActor)
                ApplyCustomDepthToActor(childActor, bEnabled, stencilValue, visited)
            end)
        elseif type(childrenActors) == "table" then
            for _, childActor in ipairs(childrenActors) do
                ApplyCustomDepthToActor(childActor, bEnabled, stencilValue, visited)
            end
        end
    end
end

--- Adds or removes an outline effect on a whole entity by enabling or disabling custom depth rendering.
-- @param entity (AActor) The entity to modify
-- @param bEnabled (boolean) Whether to enable or disable the outline
-- @param stencilValue (number) The stencil value to use for the outline
local function SetEntityCustomDepth(entity, bEnabled, stencilValue)
    local visited = {}

    -- A trace can return the mesh component itself instead of its actor.
    -- Process it before resolving the top-level actor.
    if entity.SetRenderCustomDepth then
        ProcessComponentHierarchy(entity, bEnabled, stencilValue, visited)
    end

    local topEntity = Utils.GetTopLevelEntity(entity)
    ApplyCustomDepthToActor(topEntity, bEnabled, stencilValue, visited)
end

--- Adds an outline effect to an entity.
-- @param entity (AActor) The entity to add an outline to
-- @param stencilValue (number) The stencil value to use for the outline
function EntityOutline.AddEntityOutline(entity, stencilValue)
    local topEntity = Utils.GetTopLevelEntity(entity)
    local key = Utils.GetEntityKey(topEntity)
    if not key then return end

    stencilValue = stencilValue or 0
    SetEntityCustomDepth(entity, true, stencilValue)

    -- We store the entity in the outlined entities table to keep track of it for future reference or removal.
    EntityOutline.OutlinedEntities[key] = topEntity
end

--- Removes the outline effect from an entity.
-- @param entity (AActor) The entity to remove the outline from
function EntityOutline.RemoveEntityOutline(entity)
    local topEntity = Utils.GetTopLevelEntity(entity)
    local key = Utils.GetEntityKey(topEntity)
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

    local topEntity = Utils.GetTopLevelEntity(entity)
    local key = Utils.GetEntityKey(topEntity)
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