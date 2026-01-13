BarrierOpener = {}

local stop = false -- TODO :  Temp shitty fix to prevent multiple openings

-- Opens all barriers in the level by detecting then when near the player

function BarrierOpener.OpenBarriers()
    local player = UEHelpers:GetPlayer()
    if not player or not player:IsValid() then print("[PingouinMod] Player is not valid\n") return end

    if not player.bVehicleDriver then return end 

    local playerPos = player:K2_GetActorLocation()

    local barriers = FindAllOf("BP_Gate_C")
    if not barriers then print("[PingouinMod] No barriers found in the level\n") return end

    for _, barrier in ipairs(barriers) do
        if barrier:IsValid() then
            local barrierPos = barrier:K2_GetActorLocation()
            local distance = math.sqrt((playerPos.X - barrierPos.X)^2 + (playerPos.Y - barrierPos.Y)^2 + (playerPos.Z - barrierPos.Z)^2)
            if distance <= 1500.0 then -- Open barriers within 1000 units
                local WFDoor = barrier.WFDoor
                if WFDoor:IsValid() and not stop then
                    WFDoor:StartOpeningDoorServer(WFDoor.OpeningCurve, WFDoor.DoorMovingSpeedRate)
                    stop = true
                end
            end
        end
    end
end

LoopAsync(1000, function()
    BarrierOpener.OpenBarriers()
end)

-- TODO : If not found barriers X times, stop searching and wait till another level load


return BarrierOpener