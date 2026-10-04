BarrierOpener = {}

-- Track each barrier independently so one opening does not block the others.
local barrierStates = {}

-- Stop polling empty levels, then resume when the next level is loaded.
local noBarrierChecks = 0
local waitingForLevel = false
local searchLoopRunning = false
local NO_BARRIER_CHECK_LIMIT = 5

-- Opens nearby barriers and optionally closes them when the player moves away.
-- @param closeWhenFar (boolean) If true, barriers will close when the player is far away.
-- @return (boolean) True if at least one barrier was found and processed, false if no barriers were found, nil if the player is not in a vehicle.
function BarrierOpener.OpenBarriers(closeWhenFar)
    local player = Utils.GetPlayer()
    if not Utils.IsValidObject(player) then return nil end

    if not Utils.IsVehiclePawn(player) then return nil end

    local playerPos = Utils.GetActorLocation(player)
    if not playerPos then return nil end

    local barriers = FindAllOf("BP_Gate_C")
    if not barriers then return false end

    local validBarrierFound = false
    for _, barrier in ipairs(barriers) do
        if Utils.IsValidObject(barrier) then
            validBarrierFound = true
            local barrierPos = Utils.GetActorLocation(barrier)
            if barrierPos then
                local distance = math.sqrt((playerPos.X - barrierPos.X)^2 + (playerPos.Y - barrierPos.Y)^2 + (playerPos.Z - barrierPos.Z)^2)
                local WFDoor = barrier.WFDoor
                if Utils.IsValidObject(WFDoor) then
                    local barrierKey = Utils.GetEntityKey(barrier)
                    local state = barrierStates[barrierKey]

                    if distance <= 1500.0 and state ~= "open" then
                        WFDoor:StartOpeningDoorServer(WFDoor.OpeningCurve, WFDoor.DoorMovingSpeedRate)
                        barrierStates[barrierKey] = "open"
                    elseif closeWhenFar and distance > 2000.0 and state ~= "closed" then
                        WFDoor:StartClosingDoorServer(WFDoor.ClosingCurve, WFDoor.DoorMovingSpeedRate)
                        barrierStates[barrierKey] = "closed"
                    end
                end
            end
        end
    end

    return validBarrierFound
end

-- Starts the barrier search loop.
local function StartBarrierSearch()
    if searchLoopRunning then return end
    searchLoopRunning = true

    -- LoopAsync stops when the callback returns true.
    LoopAsync(1000, function()
        if waitingForLevel then
            searchLoopRunning = false
            return true
        end

        local barriersFound = BarrierOpener.OpenBarriers(true)
        if barriersFound == false then
            noBarrierChecks = noBarrierChecks + 1
            if noBarrierChecks >= NO_BARRIER_CHECK_LIMIT then
                print("[PingouinMod] No barriers found, waiting for the next level load\n")
                waitingForLevel = true
                searchLoopRunning = false
                return true
            end
        elseif barriersFound == true then
            noBarrierChecks = 0
        end

        return false
    end)
end

-- A new map invalidates old object references and restarts the search loop.
RegisterLoadMapPostHook(function()
    barrierStates = {}
    noBarrierChecks = 0
    waitingForLevel = false
    StartBarrierSearch()
end)

StartBarrierSearch()

return BarrierOpener