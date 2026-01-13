local Teleport = {}

function Teleport.TeleportPlayer(posTable, isOffset, rotTable, verbose)
    -- Avoid errors with incorrect tables
    if verbose == nil then verbose = true end

	if #posTable ~= 3 and posTable.X == nil or posTable == nil then return end

    local firstPlayerController = UEHelpers:GetPlayerController()
    if not firstPlayerController:IsValid() then return end
    local pawn = firstPlayerController.Pawn
    if not pawn:IsValid() then print("[PingouinMod] Teleport Player object is not valid\n") return end

    local pos = pawn:K2_GetActorLocation()
    local newPos

	--Detects table format to handle raw inputs or game like structure
	if posTable.X == nil  then 
   		newPos = {X = posTable[1], Y = posTable[2],  Z = posTable[3]}
    else 
		newPos = posTable
	end

    -- Handle offset if specified and teleport
    if verbose then print(string.format("[PingouinMod] Player location before TP : {X=%.3f, Y=%.3f, Z=%.3f}\n", pos.X, pos.Y, pos.Z)) end
   	if isOffset then 
        newPos = {X = pos.X + newPos.X , Y = pos.Y + newPos.Y,  Z = pos.Z + newPos.Z}
    end
	local ret = pawn:K2_SetActorLocation(newPos, false, {}, true)

    -- Handle rotation if provided
    if rotTable ~= nil then
        local newRot
        if rotTable.Pitch == nil  then 
            newRot = {Pitch = rotTable[1], Yaw = rotTable[2], Roll = rotTable[3]}
        else 
            newRot = rotTable
        end
        pawn:K2_SetActorRotation(newRot, false)
    end

    -- Print new position
    pos = pawn:K2_GetActorLocation()
    if verbose then print(ret, string.format("[PingouinMod] Player location after TP : {X=%.3f, Y=%.3f, Z=%.3f}\n", pos.X, pos.Y, pos.Z)) end
end

-- TODO : Implement Teleport:TeleportActor(self, posTable, isOffset, rotTable, verbose) avec self

-- Teleport player command
RegisterConsoleCommandHandler("pos", function(fullCommand, args, _)
    print("[PingouinMod] Command pos activated\n")
  
	-- Error detection on args and conversion to numbers
    if #args < 3 then print(string.format("[PingouinMod] ERROR : Too few arguments, got %.1f, expected 4 (X , Y, Z, isOffset)\n", pos.X, pos.Y, pos.Z)) return end
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
        Teleport.TeleportPlayer(pos, isOffset)
    end)
    return true
end)

return Teleport