local Teleport = {}

--- Teleports a pawn to an absolute or relative position and optionally rotates it.
-- Position and rotation accept either named components or numeric components.
-- @param posTable (table) Target position: {X, Y, Z} or {1, 2, 3}
-- @param isOffset (boolean|nil) Add the position to the pawn's current location
-- @param rotTable (table|nil) Target rotation: {Pitch, Yaw, Roll} or numeric components
-- @param verbose (boolean|nil) Print the position before and after teleportation
-- @param targetPawn (APawn|nil) Pawn to move; resolves the local player's pawn when omitted
-- @return (boolean) True when the location and optional rotation were applied successfully
function Teleport.TeleportPawn(posTable, isOffset, rotTable, verbose, targetPawn)
    if verbose == nil then verbose = true end
    if isOffset == nil then isOffset = false end
    if type(isOffset) ~= "boolean" or type(verbose) ~= "boolean" then return false end

    -- Normalize both named and indexed position formats.
    local newPos = Utils.NormalizeVector(posTable, {"X", "Y", "Z"})
    if not newPos then return false end

    local newRot
    if rotTable ~= nil then
        -- Keep rotation validation consistent with position validation.
        newRot = Utils.NormalizeVector(rotTable, {"Pitch", "Yaw", "Roll"})
        if not newRot then return false end
    end

    local pawn = targetPawn
    if pawn == nil then
        -- Resolve the real player controller when the debug camera is active.
        local firstPlayerController = Utils.GetPlayerController()
        if not Utils.IsValidObject(firstPlayerController) then return false end
        pawn = firstPlayerController.Pawn
    end
    if not Utils.IsValidObject(pawn) then return false end

    if isOffset then
        -- Read the current location only when applying a relative offset.
        local positionSuccess, rawPosition = pcall(function() return pawn:K2_GetActorLocation() end)
        if not positionSuccess then return false end
        local pos = Utils.ReadVector(rawPosition)
        if not pos.X or not pos.Y or not pos.Z then return false end
        if verbose then
            print(string.format("[PingouinMod] Player location before TP : {X=%.3f, Y=%.3f, Z=%.3f}\n", pos.X, pos.Y, pos.Z))
        end

        -- Convert the relative offset into an absolute target location.
        newPos = {X = pos.X + newPos.X , Y = pos.Y + newPos.Y,  Z = pos.Z + newPos.Z}
    elseif verbose then
        local positionSuccess, rawPosition = pcall(function() return pawn:K2_GetActorLocation() end)
        if not positionSuccess then return false end
        local pos = Utils.ReadVector(rawPosition)
        if not pos.X or not pos.Y or not pos.Z then return false end
        print(string.format("[PingouinMod] Player location before TP : {X=%.3f, Y=%.3f, Z=%.3f}\n", pos.X, pos.Y, pos.Z))
    end

    -- Move without sweeping so noclip is not blocked by collision.
    local locationSuccess, ret = pcall(function()
        return pawn:K2_SetActorLocation(newPos, false, {}, true)
    end)
    if not locationSuccess or not ret then return false end

    if newRot then
        -- Rotation is optional because noclip supplies it every frame.
        local rotationSuccess, rotationResult = pcall(function()
            pawn:K2_SetActorRotation(newRot, false)
        end)
        if not rotationSuccess or rotationResult == false then return false end
    end

    -- Noclip skips the extra readback to keep its update loop light.
    if not verbose then return true end

    -- Verify and report the final location for manual teleports.
    local newPositionSuccess, finalPos = pcall(function() return pawn:K2_GetActorLocation() end)
    if not newPositionSuccess or not finalPos then return false end
    local finalPosition = Utils.ReadVector(finalPos)
    local finalX = finalPosition and finalPosition.X
    local finalY = finalPosition and finalPosition.Y
    local finalZ = finalPosition and finalPosition.Z
    if not finalX or not finalY or not finalZ then return false end
    print(ret, string.format("[PingouinMod] Player location after TP : {X=%.3f, Y=%.3f, Z=%.3f}\n", finalX, finalY, finalZ))
    return true
end

--- Console command that teleports the local player.
-- @usage tp X Y Z [isOffset]
RegisterConsoleCommandHandler("tp", function(fullCommand, args, _)
    print("[PingouinMod] Command tp activated\n")
  
    -- Validate and convert the three required coordinates.
    if #args < 3 or #args > 4 then
        print(string.format("[PingouinMod] ERROR : Expected 3 or 4 arguments (X, Y, Z, isOffset), got %d\n", #args))
        return false
    end
    for i = 1, 3 do
        if type(args[i]) ~= "number" then 
            local res = tonumber(args[i])
            if res == nil then 
                print(string.format("[PingouinMod] ERROR : Argument %d is not a number\n", i))
                return false
            else 
                args[i] = res
            end 
        end
    end
	
    -- Parse the optional offset flag after coordinate validation.
    local isOffset = false
 	if #args == 4 then 
		isOffset = GB_StrToBool[args[4]]
        if isOffset == nil then 
            print(string.format("[PingouinMod] ERROR : Argument 4 (isOffset) is not a boolean\n"))
            return false
        end
	end 

    local pos = {args[1], args[2], args[3]}

    ExecuteInGameThread(function()
        if not Teleport.TeleportPawn(pos, isOffset) then
            print("[PingouinMod] ERROR : Teleport failed\n")
        end
    end)
    return true
end)

return Teleport