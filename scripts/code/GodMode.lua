local GodMode = {}

-- State variables

GodMode.isPlayerInGodMode = false

-- Backup of player states and loop handle
local savedPlayerState

-- TODO : Need to implement other godmode features

function GodMode.ToggleGodMode(player, forceState)
    if not player then
        -- TODO : Signature may change based on the actual player object class --> Find more robust way to get the player object
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