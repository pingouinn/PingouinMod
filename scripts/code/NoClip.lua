local NoClip = {}

-- State Variables
NoClip.noClipEnabled = false
local lastPos = {X = 0.0, Y = 0.0, Z = 0.0}
local activePlayerController
local activePawn
local activePawnState
local activationRetryScheduled = false
local activationRetryCount = 0
local MAX_ACTIVATION_RETRIES = 20

-- TODO : Player Pawn not really pinnd on the camera, a bit under and dont know why
-- TODO : Still feels laggy / jittery. Core functionality is working, but may need to be optimized further.
-- Hint : maybe get rid of the teleport function or lighten it. Interpolation ? 

--- Retries noclip activation while the game is replacing its player controller.
local function ScheduleActivationRetry()
    if activationRetryScheduled then return end
    if activationRetryCount >= MAX_ACTIVATION_RETRIES then
        print("[PingouinMod] NoClip activation timed out while waiting for the player controller\n")
        activationRetryCount = 0
        return
    end

    activationRetryScheduled = true
    activationRetryCount = activationRetryCount + 1
    ExecuteWithDelay(250, function()
        activationRetryScheduled = false
        if not NoClip.noClipEnabled then NoClip.ToggleNoClip() end
    end)
end

--- Saves the pawn state and disables damage, collision, and gravity for noclip.
-- @param pawn (APawn) Pawn whose state should be captured and disabled
-- @return (table|nil) Saved pawn state, or nil when the pawn is invalid
local function CaptureAndDisablePawn(pawn)
    if not Utils.IsValidObject(pawn) then return nil end

    local state = {
        pawn = pawn,
        canBeDamaged = pawn.bCanBeDamaged,
        collision = pawn.bActorEnableCollision,
        simGravityDisabled = pawn.bSimGravityDisabled,
        replicatedGravityDirection = pawn.ReplicatedGravityDirection,
        children = {},
    }
    pawn.bCanBeDamaged = false
    pawn.bActorEnableCollision = false
    pawn.bSimGravityDisabled = true
    pawn.ReplicatedGravityDirection = {X = 0.0, Y = 0.0, Z = 0.0}

    for i = 1, #(pawn.Children or {}) do
        local attachedActor = pawn.Children[i]
        if Utils.IsValidObject(attachedActor) then
            state.children[attachedActor] = attachedActor.bActorEnableCollision
            attachedActor.bActorEnableCollision = false
        end
    end
    return state
end

--- Restores the pawn and attached actors to their pre-noclip state.
-- @param state (table|nil) State returned by CaptureAndDisablePawn
local function RestorePawnState(state)
    if not state or not Utils.IsValidObject(state.pawn) then return end

    state.pawn.bCanBeDamaged = state.canBeDamaged
    state.pawn.bActorEnableCollision = state.collision
    state.pawn.bSimGravityDisabled = state.simGravityDisabled
    state.pawn.ReplicatedGravityDirection = state.replicatedGravityDirection
    for attachedActor, collision in pairs(state.children) do
        if Utils.IsValidObject(attachedActor) then attachedActor.bActorEnableCollision = collision end
    end
end

--- Toggles debug-camera noclip for the local player's current pawn.
function NoClip.ToggleNoClip()
    if NoClip.noClipEnabled then
        print("[PingouinMod] Toggle NoClip mode OFF\n")

        local debugCameraDisabled = false
        if Utils.IsValidObject(activePlayerController) and Utils.IsValidObject(activePlayerController.CheatManager) then
            local disableSuccess = Utils.TryCall("Disable debug camera", function()
                activePlayerController.CheatManager:DisableDebugCamera()
            end)
            debugCameraDisabled = disableSuccess
        end

        if not debugCameraDisabled then
            local debugCamController = Utils.GetDebugCameraController()
            if Utils.IsValidObject(debugCamController) then
                Utils.EnableCheatManager(debugCamController)
                debugCameraDisabled = Utils.TryCall("Disable fallback debug camera", function()
                    debugCamController.CheatManager:DisableDebugCamera()
                end)
            end
        end
        Utils.ResetDebugCameraControllerCache()

        RestorePawnState(activePawnState)

        activePawn = nil
        activePlayerController = nil
        activePawnState = nil
        NoClip.noClipEnabled = false
        return
    end

    -- Ensure CheatManager is enabled on the PlayerController
    local playerController = Utils.GetPlayerController()
    if not Utils.IsValidObject(playerController) then
        ScheduleActivationRetry()
        return
    end
    local cheatManagerSuccess, cheatManagerEnabled = Utils.TryCall("Enable cheat manager", function()
        return Utils.EnableCheatManager(playerController)
    end)
    if not cheatManagerSuccess or not cheatManagerEnabled then
        ScheduleActivationRetry()
        return
    end

    -- Get the controlled pawn and ensure it's valid
    local pawn = playerController.Pawn
    if not pawn or not Utils.IsValidObject(pawn) then
        local player = Utils.GetPlayer()
        if player and Utils.IsValidObject(player) then pawn = player end
    end
    if not pawn or not Utils.IsValidObject(pawn) then
        ScheduleActivationRetry()
        return
    end

    activationRetryCount = 0

    activePlayerController = playerController
    activePawn = pawn
    activePawnState = CaptureAndDisablePawn(pawn)
    if not activePawnState then
        activePlayerController = nil
        activePawn = nil
        return
    end

    -- Gets the player object to check if in vehicle
    local isVeh = Utils.IsVehiclePawn(playerController)

    print("[PingouinMod] Toggle NoClip mode ON\n")
    lastPos = {X = 0.0, Y = 0.0, Z = 0.0}
    Utils.TryCall("Enable debug camera", function() playerController.CheatManager:EnableDebugCamera() end)

    ExecuteWithDelay(250, function()
            LoopAsync(16, function()
                if not NoClip.noClipEnabled then return true end -- Exit the loop if noClip is disabled

                local pawnSuccess, currentPawn = Utils.TryCall("Read active pawn", function() return activePlayerController.Pawn end)
                if not pawnSuccess then currentPawn = nil end
                if Utils.IsValidObject(currentPawn) and currentPawn ~= activePawn then
                    RestorePawnState(activePawnState)
                    activePawn = currentPawn
                    activePawnState = CaptureAndDisablePawn(currentPawn)
                    isVeh = Utils.IsVehiclePawn(activePlayerController)
                end
                if not Utils.IsValidObject(activePawn) or not activePawnState then return false end

                local debugCamController = Utils.GetDebugCameraController()
                if not Utils.IsValidObject(debugCamController) then return false end

                -- Teleports the player to the debug camera position
                local cam = debugCamController.PlayerCameraManager
                if not Utils.IsValidObject(cam) then return false end
                
                -- Offsets the cam position to place pawn in front of camera
                local distance = 200.0
                if isVeh then distance = 500.0 end
                local newPos = Utils.GetPositionInFront(cam:GetCameraLocation(), cam:GetCameraRotation(), distance)
                if not Utils.CheckLocationEquality(lastPos, newPos, 1.0) then

                    -- Keep the pawn at the camera's vertical level; the camera pitch already affects Z.
                    local newVectorCorrected = {
                        X = newPos.X,
                        Y = newPos.Y,
                        Z = newPos.Z,
                    }
                    
                    local teleported = Teleport.TeleportPawn(newVectorCorrected, false, cam:GetCameraRotation(), false, activePawn)
                    if teleported then lastPos = newPos end
                end

                return false -- Loops forever
            end)
    end)
    NoClip.noClipEnabled = true
end

-- Enable CheatManager on PlayerController creation
NotifyOnNewObject("/Script/Engine.PlayerController", function(PlayerController)
    Utils.EnableCheatManager(PlayerController)
    return false
end)

-- Noclip keybind
RegisterKeyBind(Keybinds.NoClip, function()
    ExecuteInGameThread(function()
        NoClip.ToggleNoClip()
    end)
end)

return NoClip