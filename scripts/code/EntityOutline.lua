--- EntityOutline.lua provides functions to add and remove outline effects on entities by enabling or disabling custom depth rendering on their components. It also manages a table of outlined entities and registers a keybind for toggling outlines on the entity under the player's crosshair.
-- @author PingouinTheDev

EntityOutline = {}

EntityOutline.OutlinedEntities = {}
local Spawner = require("code/Spawner")

--- Checks if an error message indicates an unsupported custom depth error.
-- @param errorMessage (string) The error message to check
-- @return (boolean) True if the error message indicates an unsupported custom depth error, false otherwise
local function IsUnsupportedCustomDepthError(errorMessage)
    return string.find(tostring(errorMessage), "TrivialObject", 1, true) ~= nil
end

--- Checks if a component is a valid renderable mesh.
-- @param comp (UActorComponent) The component to check
-- @return (boolean) True if it's a mesh component, false otherwise
local function IsMeshComponent(comp)
    if not Utils.IsValidObject(comp) then return false end
    
    -- Filter out collision boxes, particles, cameras and logic components
    local className = tostring(comp.ClassName or "")
    if string.find(className, "MeshComponent", 1, true) then return true end
    
    -- Fallback check on standard mesh properties
    if comp.StaticMesh ~= nil or comp.SkeletalMesh ~= nil then return true end
    
    return false
end

--- Enables or disables custom depth rendering on a component, optionally setting a stencil value.
-- @param comp (UActorComponent) The component to modify
-- @param bEnabled (boolean) Whether to enable or disable custom depth rendering
-- @param stencilValue (number) The stencil value to use for custom depth rendering
local function EnableCustomDepthOnComponent(comp, bEnabled, stencilValue)
    comp = Utils.UnwrapValue(comp)
    if not Utils.IsValidObject(comp) then return end

    -- Filter non renderable components (e.g., collision boxes, particles, cameras, logic components)
    local canRender = false
    Utils.TryCall("Check render component", function()
        canRender = (comp.bRenderInMainPass == true) or (comp.bCastShadow == true)
    end)
    if not canRender then return end

    local success, errorMessage = Utils.TryCall("Update custom depth", function()
        -- in UE4SS, UFunctions are "userdata"
        local fn = comp.SetRenderCustomDepth
        if fn ~= nil and (type(fn) == "userdata" or type(fn) == "function") then
            comp:SetRenderCustomDepth(bEnabled)
            if bEnabled and stencilValue ~= nil and comp.SetCustomDepthStencilValue ~= nil then
                comp:SetCustomDepthStencilValue(stencilValue)
            end
        end
    end)

    if not success and not IsUnsupportedCustomDepthError(errorMessage) then
        print(string.format("[PingouinMod] Failed to update custom depth on component: %s\n", tostring(errorMessage)))
    end
end

--- Enables or disables custom depth rendering on a component and its attached children.
-- @param comp (UActorComponent) The component to modify
-- @param bEnabled (boolean) Whether to enable or disable custom depth rendering
-- @param stencilValue (number) The stencil value to use for custom depth rendering
local function ProcessComponentHierarchy(comp, bEnabled, stencilValue, visited)
    comp = Utils.UnwrapValue(comp)
    if not Utils.IsValidObject(comp) then return end
    if visited[comp] then return end
    visited[comp] = true

    EnableCustomDepthOnComponent(comp, bEnabled, stencilValue)

    if comp.AttachChildren then
        local children = comp.AttachChildren
        local count = 0
        local okCount = Utils.TryCall("Get attach children count", function()
            count = #children
        end)

        if okCount and count > 0 then
            for i = 1, count do
                local child = nil
                local ok = Utils.TryCall("Get attach child", function()
                    child = children[i]
                end)
                if ok and child then
                    local success, unwrappedChild = Utils.TryCall("Unwrap attached component", function()
                        return Utils.UnwrapValue(child)
                    end)
                    if unwrappedChild then
                        ProcessComponentHierarchy(unwrappedChild, bEnabled, stencilValue, visited)
                    end
                end
            end
        end
    end
end

--- Applies or removes an outline effect on an entity by enabling or disabling custom depth rendering on its components and attached children.
-- @param entity (AActor) The entity to modify
-- @param bEnabled (boolean) Whether to enable or disable the outline effect
-- @param stencilValue (number) The stencil value to use for the outline effect
local function ApplyCustomDepthToActor(actor, bEnabled, stencilValue, visited)
    actor = Utils.UnwrapValue(actor)
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
        local count = 0
        local okCount = Utils.TryCall("Get children actors count", function()
            count = #childrenActors
        end)

        if okCount and count > 0 then
            for i = 1, count do
                local childActor = nil
                local ok = Utils.TryCall("Get child actor", function()
                    childActor = childrenActors[i]
                end)
                if ok and childActor then
                    local success, unwrappedChild = Utils.TryCall("Unwrap child actor", function()
                        return Utils.UnwrapValue(childActor)
                    end)
                    if unwrappedChild then
                        ProcessComponentHierarchy(unwrappedChild, bEnabled, stencilValue, visited)
                    end
                end
            end
        end
    end
end

--- Adds or removes an outline effect on a whole entity by enabling or disabling custom depth rendering.
-- @param entity (AActor) The entity to modify
-- @param bEnabled (boolean) Whether to enable or disable the outline
-- @param stencilValue (number) The stencil value to use for the outline
local function SetEntityCustomDepth(entity, bEnabled, stencilValue)
    entity = Utils.UnwrapValue(entity)
    local visited = {}
    local topEntity = Utils.GetTopLevelEntity(entity)

    -- Resolve the logical actor first, then traverse all of its components and children.
    ApplyCustomDepthToActor(topEntity, bEnabled, stencilValue, visited)

    -- Process a standalone hit component only when the actor traversal did not cover it.
    if entity ~= topEntity and entity.SetRenderCustomDepth then
        ProcessComponentHierarchy(entity, bEnabled, stencilValue, visited)
    end
end

--- Adds an outline effect to an entity.
-- @param entity (AActor) The entity to add an outline to
-- @param stencilValue (number) The stencil value to use for the outline
function EntityOutline.AddEntityOutline(entity, stencilValue, key)
    local topEntity = Utils.GetTopLevelEntity(entity)

    if not key then
        key = Utils.GetEntityKey(topEntity)
        if not key then return end
    end

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
    EntityOutline.AddEntityOutline(entity, stencilValue or 0, key)
end

--- Returns the table of currently outlined entities.
-- @return (table) A table containing the currently outlined entities, indexed by their unique keys
function EntityOutline.GetOutlinedEntities()
    return EntityOutline.OutlinedEntities
end

--- Clears all outlines from entities and resets the outlined entities table.
function EntityOutline.ClearAllOutlines()
    for key, entity in pairs(EntityOutline.OutlinedEntities) do
        if Utils.IsValidObject(entity) then
            SetEntityCustomDepth(entity, false, 0)
        end
        EntityOutline.OutlinedEntities[key] = nil
    end
end

--- Performs garbage collection on the outlined entities.
function EntityOutline.GC()
    for key, entity in pairs(EntityOutline.OutlinedEntities) do
        if not Utils.IsValidObject(entity) then
            EntityOutline.OutlinedEntities[key] = nil
        end
    end
end

GCScheduler.RegisterGC(EntityOutline.GC, 5.0, true)

RegisterKeyBind(Keybinds.EntityOutline, function()
    print("[PingouinMod] Displaying raycasted entity outline\n")
    ExecuteInGameThread(function()
        EntityOutline.ToggleRaycastedEntityOutline()
    end)
end)

return EntityOutline