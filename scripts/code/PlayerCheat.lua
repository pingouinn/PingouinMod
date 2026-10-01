local PlayerCheat = {}

-- State variables

PlayerCheat.isPlayerCheating = false

-- Backup of player states and loop handle
local movementLoopHandle
local savedPlayerState

function PlayerCheat.TogglePlayerCheatMode()
    -- TODO : Signature may change based on the actual player object class --> Find more robust way to get the player object
    local firstPlayerController = UEHelpers:GetPlayerController()
    local player = firstPlayerController.Pawn
    if not player:IsValid() then print("PlayerAbilities : Player object is not valid\n") return end
    local charMoveComp = player.CharacterMovement 
    if not charMoveComp:IsValid() then return end

    PlayerCheat.isPlayerCheating = not PlayerCheat.isPlayerCheating
    if PlayerCheat.isPlayerCheating then
        print("Enable cheat mode: grant player special abilities\n")

        savedPlayerState = {
            player = player,
            movementComponent = charMoveComp,
            bCanBeDamaged = player.bCanBeDamaged,
            jumpZVelocity = charMoveComp.JumpZVelocity,
            maxStepHeight = charMoveComp.MaxStepHeight,
            walkableFloorAngle = charMoveComp.WalkableFloorAngle,
            airControl = charMoveComp.AirControl,
            maxWalkSpeed = charMoveComp.MaxWalkSpeed,
        }
  
	    -- Player related 
        player.bCanBeDamaged = false

        -- Movement related
        charMoveComp.JumpZVelocity = 2000.0
        charMoveComp.MaxStepHeight = 2.0
        charMoveComp.WalkableFloorAngle = 80.0
        charMoveComp.AirControl = 1.0

        -- Walking speed can be erased by the game if player sprints, so we need to enforce it in a loop
        movementLoopHandle = LoopInGameThreadWithDelay(50, function()
            if charMoveComp.MaxWalkSpeed == 930.0 then
                charMoveComp.MaxWalkSpeed = 2500.0
            else 
                charMoveComp.MaxWalkSpeed = 2000.0
            end
        end)

    else
        print("Disable cheat mode: remove player special abilities\n")

        if movementLoopHandle then
            CancelDelayedAction(movementLoopHandle)
            movementLoopHandle = nil
        end

        if savedPlayerState and savedPlayerState.player:IsValid() and savedPlayerState.movementComponent:IsValid() then
            savedPlayerState.player.bCanBeDamaged = savedPlayerState.bCanBeDamaged
            savedPlayerState.movementComponent.JumpZVelocity = savedPlayerState.jumpZVelocity
            savedPlayerState.movementComponent.MaxStepHeight = savedPlayerState.maxStepHeight
            savedPlayerState.movementComponent.WalkableFloorAngle = savedPlayerState.walkableFloorAngle
            savedPlayerState.movementComponent.AirControl = savedPlayerState.airControl
            savedPlayerState.movementComponent.MaxWalkSpeed = savedPlayerState.maxWalkSpeed
        end

        savedPlayerState = nil
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