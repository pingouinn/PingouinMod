local NoClip = {}

NoClip.noClipEnabled = false
local lastPos = {X = 0.0, Y = 0.0, Z = 0.0}

-- TODO : Start cam pos to player pos when enabling noclip ?
-- TODO : Some crashes with the noclip ; Needs testing
-- TODO : Fix truck noclip (very buggy -> still collides ?)
-- TODO : Fix truck damage after noclip 
-- TODO : Fix vehicle doors detaching

function NoClip.ToggleNoClip()
    -- Ensure CheatManager is enabled on the PlayerController
    local playerController = UEHelpers:GetPlayerController()
    if not playerController:IsValid() then print("[PingouinMod] PlayerController is not valid\n") return end
    if not Utils.EnableCheatManager(playerController) then return end

    -- Get the controlled pawn and ensure it's valid
    local pawn = playerController.Pawn
    if not pawn:IsValid() then print("[PingouinMod] NoClip Player object is not valid\n") return end

    -- Gets the player object to check if in vehicle
    local player = playerController.LocalCharacter
    local isVeh = false
    if player:IsValid() then 
        if player.InVehicle:IsValid() or player.bVehicleDriver then isVeh = true end 
        -- TODO : Player exit veh if passenger
    else
        print("[PingouinMod] NoClip Player object is not valid. Defaulting to player pawn behavior. Can cause issues if not controlling the player pawn at the moment\n") 
    end

    if not NoClip.noClipEnabled then
        print("[PingouinMod] Toggle NoClip mode ON\n")
        pcall(function() playerController.CheatManager:EnableDebugCamera() end)

        pawn.bCanBeDamaged = false
        pawn.bActorEnableCollision = false

        -- Disable collision on all attached actors to the pawn
        for i = 1, #pawn.Children do
            local attachedActor = pawn.Children[i]
            if attachedActor:IsValid() then
                print(string.format("[PingouinMod] Disabling collision for attached actor [0x%X] of class: %s\n", attachedActor:GetAddress(), attachedActor:GetFullName()))
                attachedActor.bActorEnableCollision = false
            end
        end
        
        ExecuteWithDelay(250, function()
            LoopAsync(1, function()
                if not NoClip.noClipEnabled then return true end -- Exit the loop if noClip is disabled

                -- Flush streaming and garbage collect to reduce lag when moving the debug camera
                --###########################################################################
                -- INFO : Currently disabled as it seems to cause more issues than it solves
                --###########################################################################

                local playerController = UEHelpers:GetPlayerController()
                -- pcall(function() playerController:ClientFlushLevelStreaming() end)
                -- pcall(function() playerController:ClientForceGarbageCollection() end)

                local debugCamController = Utils.GetDebugCameraController()
                if not Utils.IsValidObject(debugCamController) then return false end
                -- pcall(function() debugCamController:ClientFlushLevelStreaming() end)
                -- pcall(function() debugCamController:ClientForceGarbageCollection() end)

                -- Teleports the player to the debug camera position
                local cam = debugCamController.PlayerCameraManager
                if not Utils.IsValidObject(cam) then return false end
                
                -- Offsets the cam position to place pawn in front of camera
                local distance = 200.0
                if isVeh then distance = 500.0 end
                local newPos = Utils.GetPositionInFront(cam:GetCameraLocation(), cam:GetCameraRotation(), distance)
                if not Utils.CheckLocationEquality(lastPos, newPos, 10.0) then

                    local zCorrection = 100.0 if isVeh then zCorrection = 200.0 end
                    local newVectorCorrected = {
                        X = newPos.X,
                        Y = newPos.Y,
                        Z = newPos.Z - zCorrection,
                    }
                    
                    Teleport.TeleportPlayer(newVectorCorrected, false, cam:GetCameraRotation(), false)
                    lastPos = newPos
                end

                return false -- Loops forever
            end)
        end)
    else
        print("[PingouinMod] Toggle NoClip mode OFF\n")

        -- Gets the final debug camera position before disabling it
        local debugCamController = Utils.GetDebugCameraController()
        -- local cam = debugCamController.PlayerCameraManager
        -- if cam:IsValid() then
        --     Teleport.TeleportPlayer(cam:GetCameraLocation(), false, cam:GetCameraRotation(), false)
        -- end

        -- Be sure that the CheatManager is enabled on the debugCam controller (which is different from the playerController) before disabling the debug camera
        Utils.EnableCheatManager(debugCamController)
        pcall(function() debugCamController.CheatManager:DisableDebugCamera() end)

        -- Restore pawn properties
        pawn.bCanBeDamaged = true
        pawn.bActorEnableCollision = true

        for i = 1, #pawn.Children do
            local attachedActor = pawn.Children[i]
            if attachedActor:IsValid() then
                attachedActor.bActorEnableCollision = true
            end
        end
        
    end
    NoClip.noClipEnabled = not NoClip.noClipEnabled
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