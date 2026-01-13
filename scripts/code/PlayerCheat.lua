local PlayerCheat = {}

PlayerCheat.isPlayerCheating = false

function PlayerCheat.TogglePlayerCheatMode()
    -- Signature may change based on the actual player object class --> Find more robust way to get the player object
    local firstPlayerController = UEHelpers:GetPlayerController()
    local player = firstPlayerController.Pawn
    if not player:IsValid() then print("Player object is not valid\n") return end
    local charMoveComp = player.CharacterMovement 
    if not charMoveComp:IsValid() then return end

    isPlayerCheating = not isPlayerCheating
    if isPlayerCheating then
        print("Enable cheat mode: grant player special abilities\n")
  
	    -- Player related 
        player.bCanBeDamaged = false

        -- Movement related
        charMoveComp.JumpZVelocity = 2000.0
        charMoveComp.MaxStepHeight = 2.0
        charMoveComp.WalkableFloorAngle = 80.0
        charMoveComp.AirControl = 1.0

        -- Walking speed can be erased by the game if player sprints, so we need to enforce it in a loop
        LoopAsync(50, function()
            if not PlayerCheat.isPlayerCheating then return true end -- Exit the loop if cheat mode is disabled
            if charMoveComp.MaxWalkSpeed == 930.0 then
                charMoveComp.MaxWalkSpeed = 2500.0
            else 
                charMoveComp.MaxWalkSpeed = 2000.0
            end
            return false -- Loops forever
        end)

    else
        print("Disable cheat mode: remove player special abilities\n")

        bCanBeDamaged = true

        charMoveComp.JumpZVelocity = 420.0
		charMoveComp.MaxStepHeight = 0.55
        charMoveComp.WalkableFloorAngle = 44.76
        charMoveComp.MaxWalkingSpeed = 600.0
        charMoveComp.AirControl = 0.05
    end
end

-- Player cheat mode toggle
RegisterKeyBind(Key.F1, function()
    ExecuteInGameThread(function()
        PlayerCheat.TogglePlayerCheatMode()
    end)
end)

RegisterConsoleCommandHandler("TogglePlayerCheat", function()
    ExecuteInGameThread(function()
        PlayerCheat.TogglePlayerCheatMode()
    end)
    return true
end)

return PlayerCheat