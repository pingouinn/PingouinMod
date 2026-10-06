--- GodMode.lua provides a function to toggle god mode for the local player, granting invincibility and other special abilities. It also registers a keybind and console command for toggling god mode.
-- @author PingouinTheDev

local GodMode = {}

-- State variables

GodMode.isPlayerInGodMode = false

-- Backup of player states and loop handle
local savedPlayerState

-- TODO : Need to implement other godmode features

--- Toggles the god mode state for the player.
-- @param player (AActor) The player actor to toggle god mode for. If nil, the function will attempt to retrieve the player actor.
-- @param forceState (boolean) If provided, forces the god mode state to the specified value (true for enabled, false for disabled). If nil, the function will toggle the current state.
function GodMode.ToggleGodMode(player, forceState)
    if not player then
        local firstPlayerController = Utils.GetPlayerController()
        if not Utils.IsValidObject(firstPlayerController) then print("GodMode : Player controller is not valid\n") return end
        player = firstPlayerController.Pawn
    end

    -- If forceState is provided, set the god mode state to that value, otherwise toggle the current state
    if forceState ~= nil then GodMode.isPlayerInGodMode = forceState
    else GodMode.isPlayerInGodMode = not GodMode.isPlayerInGodMode
    end

    -- Apply the god mode state to the player
    if GodMode.isPlayerInGodMode then
        print("Plyr in God Mode")
        savedPlayerState = {
            player = player,
            maxZVelocityBeforeDeath = player.MaxZVelocityBeforeDeath,
        }

        player.MaxZVelocityBeforeDeath = 100000.0
    else
        print("Plyr out of God Mode")

        if savedPlayerState and Utils.IsValidObject(savedPlayerState.player) then
            savedPlayerState.player.MaxZVelocityBeforeDeath = savedPlayerState.maxZVelocityBeforeDeath
        end
        savedPlayerState = nil
    end
end

-- Player god mode toggle
RegisterKeyBind(Keybinds.GodMode, function()
    ExecuteInGameThread(function()
        GodMode.ToggleGodMode()
    end)
end)

RegisterConsoleCommandHandler("GodMode", function()
    ExecuteInGameThread(function()
        GodMode.ToggleGodMode()
    end)
    return true
end)

return GodMode