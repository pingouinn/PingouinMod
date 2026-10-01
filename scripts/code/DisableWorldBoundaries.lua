WorldBoundaries = {}

function WorldBoundaries.ToggleWorldBoundaries()
    local player = Utils.GetPlayer()
    if not Utils.IsValidObject(player) then print("[PingouinMod] Player is not valid\n") return end

    -- TODO : Find a way buddy --> Will need entity outline before that


end

-- World boundaries keybind
RegisterKeyBind(Keybinds.WorldBoundaries, function()
    print("[PingouinMod] Toggling world boundaries\n")
    ExecuteInGameThread(function()
        WorldBoundaries.ToggleWorldBoundaries()
    end)
end)

return WorldBoundaries