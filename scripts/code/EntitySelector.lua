--- EntitySelector.lua provides functions to select and deselect entities in the game world, manage multiple selections, and perform raycasting to toggle selection of entities under the player's crosshair. It also registers a keybind for selecting entities.
-- @author PingouinTheDev

EntitySelector = {}

EntitySelector.SelectedEntities = {}
EntitySelector.MultipleSelectionAuthorised = true

-- TODO : No purpose yet, will serve as a mass move/teleport function in the future when UI is implemented.
-- TODO : Add comportment for when multiple selection is not authorised, i.e. deselect all other entities when a new one is selected.

--- Selects an entity and adds it to the selection. If the entity is already selected, this function does nothing.
-- @param entity (AActor) The entity to select
function EntitySelector.SelectEntity(entity)
    if not Utils.IsValidObject(entity) then
        print("[PingouinMod] ERROR : Attempted to select an invalid entity\n")
        return
    end

    if not EntitySelector.MultipleSelectionAuthorised then
        -- TODO : Implement a UI message, for now we just print a message and return.
        print("[PingouinMod] Multiple selection is not authorised\n")
        return
    end

    local entityKey = Utils.GetEntityKey(entity)
    EntitySelector.SelectedEntities[entityKey] = entity

    EntityOutline.AddEntityOutline(entity, 0, entityKey) -- Add outline with stencil value 0 for selected entities
end

--- Deselects an entity from the selection. If the entity is not currently selected, this function does nothing.
-- @param entity (AActor) The entity to deselect
function EntitySelector.DeselectEntity(entity)
    if not Utils.IsValidObject(entity) then
        print("[PingouinMod] ERROR : Attempted to deselect an invalid entity\n")
        return
    end

    local entityKey = Utils.GetEntityKey(entity)
    EntitySelector.SelectedEntities[entityKey] = nil

    EntityOutline.RemoveEntityOutline(entity, entityKey) -- Remove the outline for the deselected entity
end 

--- Toggles the selection of an entity under the player's crosshair. If the entity is already selected, it will be deselected; if it is not selected, it will be added to the selection.
function EntitySelector.ToggleSelectionOfRaycastedEntity()
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

    if EntitySelector.SelectedEntities[key] then
        print("[PingouinMod] Deselecting entity\n")
        EntitySelector.DeselectEntity(topEntity)
        return
    end

    EntitySelector.SelectEntity(topEntity)
end

--- Authorises or deauthorises multiple entity selection. When multiple selection is authorised, the player can select multiple entities at once; when it is deauthorised, selecting a new entity will deselect any previously selected entities.
-- @param doAuthorise (boolean) If true, multiple selection is authorised;
function EntitySelector.AuthoriseMultipleSelection(doAuthorise)
    EntitySelector.MultipleSelectionAuthorised = doAuthorise
end

--- Returns whether multiple entity selection is currently authorised.
-- @return (boolean) True if multiple selection is authorised, false otherwise
function EntitySelector.IsMultipleSelectionAuthorised()
    return EntitySelector.MultipleSelectionAuthorised
end

--- Checks if an entity is currently selected.
-- @param entity (AActor) The entity to check
-- @return (boolean) True if the entity is selected, false otherwise
function EntitySelector.IsEntitySelected(entity)
    if not Utils.IsValidObject(entity) then
        print("[PingouinMod] ERROR : Attempted to check selection of an invalid entity\n")
        return false
    end

    local entityKey = Utils.GetEntityKey(entity)
    return EntitySelector.SelectedEntities[entityKey] ~= nil
end

--- Returns the table of currently selected entities.
-- @return (table) A table containing the currently selected entities, indexed by their unique keys
function EntitySelector.GetSelectedEntities()
    return EntitySelector.SelectedEntities
end

--- Clears all selected entities from the table.
function EntitySelector.ClearSelectedEntities()
    for key, entity in pairs(EntitySelector.SelectedEntities) do
        EntitySelector.SelectedEntities[key] = nil
    end
end

--- Performs garbage collection on the selected entities.
function EntitySelector.GC()
    for key, entity in pairs(EntitySelector.SelectedEntities) do
        if not Utils.IsValidObject(entity) then
            EntitySelector.SelectedEntities[key] = nil
        end
    end
end

GCScheduler.RegisterGC(EntitySelector.GC, 5.0, true)

RegisterKeyBind(Keybinds.EntitySelector, function()
    print("[PingouinMod] Selecting entity\n")
    ExecuteInGameThread(function()
        EntitySelector.ToggleSelectionOfRaycastedEntity()
    end)
end)

return EntitySelector