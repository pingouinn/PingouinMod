--- PlayerCheat.lua provides a function to toggle cheat mode for the local player, granting or removing special abilities such as god mode, increased jump count, and enhanced movement capabilities. It also registers a keybind and console command for toggling cheat mode.
-- @author PingouinTheDev

local PlayerCheat = {}

-- State variables

PlayerCheat.isPlayerCheating = false

-- Backup of player states and loop handle
local movementLoopHandle
local savedPlayerState

--- Toggles the player cheat mode state, granting or removing special abilities.
function PlayerCheat.TogglePlayerCheatMode()
    local firstPlayerController = Utils.GetPlayerController()
    local player = firstPlayerController.Pawn
    if not Utils.IsValidObject(player) then print("PlayerAbilities : Player object is not valid\n") return end
    local charMoveComp = player.CharacterMovement 
    if not Utils.IsValidObject(charMoveComp) then return end

    PlayerCheat.isPlayerCheating = not PlayerCheat.isPlayerCheating
    if PlayerCheat.isPlayerCheating then
        print("Enable cheat mode: grant player special abilities\n")

        savedPlayerState = {
            player = player,
            movementComponent = charMoveComp,
            jumpZVelocity = player.JumpZVelocity,
            jumpMaxCount = charMoveComp.JumpMaxCount,
            maxStepHeight = charMoveComp.MaxStepHeight,
            walkableFloorAngle = charMoveComp.WalkableFloorAngle,
            airControl = charMoveComp.AirControl,
            maxWalkSpeed = charMoveComp.MaxWalkSpeed,
        }
  
	    -- Player related 
        GodMode.ToggleGodMode(player, true)
        player.JumpMaxCount = 5

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

        if savedPlayerState and Utils.IsValidObject(savedPlayerState.player) and Utils.IsValidObject(savedPlayerState.movementComponent) then
            GodMode.ToggleGodMode(savedPlayerState.player, false)
            savedPlayerState.player.JumpMaxCount = savedPlayerState.jumpMaxCount
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
RegisterKeyBind(Keybinds.PlayerCheat, function()
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