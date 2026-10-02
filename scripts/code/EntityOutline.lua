EntityOutline = {}

EntityOutline.OutlinedEntities = {}

function EntityOutline.AddEntityOutline(entity)
    -- TODO : Find a way buddy

    EntityOutline.OutlinedEntities[entity] = true
end

function EntityOutline.RemoveEntityOutline(entity)
    -- TODO : Find a way buddy

    EntityOutline.OutlinedEntities[entity] = nil
end

function EntityOutline.ToggleRaycastedEntityOutline()

    local entity = Utils.PerformRaycast(nil, nil, nil, nil, nil, 50000.0, 1, false, {}, true, false, 0.0)
    if entity == nil then print("[PingouinMod] No entity hit\n") return end
    if not Utils.IsValidObject(entity) then print("[PingouinMod] Hit entity is not valid\n") return end

    if EntityOutline.OutlinedEntities[entity] then
        print("[PingouinMod] Removing outline from entity\n")
        EntityOutline.RemoveEntityOutline(entity)
        -- TODO : Remove outline
        return
    end

    print("[PingouinMod] Adding outline to entity\n")
    EntityOutline.AddEntityOutline(entity)

end

function EntityOutline.GC()
    
    -- TODO : Utility TBD

end

RegisterKeyBind(Keybinds.EntityOutline, function()
    print("[PingouinMod] Displaying raycasted entity outline\n")
    ExecuteInGameThread(function()
        EntityOutline.ToggleRaycastedEntityOutline()
    end)
end)

return EntityOutline