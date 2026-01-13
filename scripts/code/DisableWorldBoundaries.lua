WorldBoundaries = {}

function WorldBoundaries.ToggleWorldBoundaries()
    local player = UEHelpers:GetPlayer()
    if not player or not player:IsValid() then print("[PingouinMod] Player is not valid\n") return end

    -- TODO : Find a way buddy --> Will need entity outline before that


end

-- World boundaries keybind
RegisterKeyBind(Key.F5, function()
    print("[PingouinMod] Toggling world boundaries\n")
    ExecuteInGameThread(function()
        WorldBoundaries.ToggleWorldBoundaries()
    end)
end)

return WorldBoundaries