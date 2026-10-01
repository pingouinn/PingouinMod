EntityOutline = {}

EntityOutline.OutlinedEntities = {}

-- Imports the kismet libraries for in game functions
local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local function ValidateKsmLibs()
    if not Utils.IsValidObject(GetKismetSystemLibrary()) then print("KismetSystemLibrary not valid\n") return false end
    if not Utils.IsValidObject(GetKismetMathLibrary()) then print("KismetMathLibrary not valid\n") return false end
    return true
end

-- Completely stolen from LineTraceMod
function EntityOutline.PerformRaycast()
    if not ValidateKsmLibs() then return end
    local PlayerController = GetPlayerController()
    local PlayerPawn = PlayerController.Pawn
    local CameraManager = PlayerController.PlayerCameraManager
    local EndVector = Utils.GetPositionInFront(CameraManager:GetCameraLocation(), CameraManager:GetCameraRotation(), 50000.0)
    local TraceColor = {
        ["R"] = 0,
        ["G"] = 0,
        ["B"] = 0,
        ["A"] = 0,
    }
    local TraceHitColor = TraceColor
    local EDrawDebugTrace_Type_None = 0
    local ETraceTypeQuery_TraceTypeQuery1 = 0
    local ActorsToIgnore = {}

    print("[PingouinMod] Doing Raycast\n")
    local HitResult = {}
    local WasHit = GetKismetSystemLibrary():LineTraceSingle(
        PlayerPawn,
        StartVector,
        EndVector,
        ETraceTypeQuery_TraceTypeQuery1,
        false,
        ActorsToIgnore,
        EDrawDebugTrace_Type_None,
        HitResult,
        true,
        TraceColor,
        TraceHitColor,
        0.0
    )

    if WasHit then
        return HitResult.HitObjectHandle.ReferenceObject:Get()
    else
        print("[PingouinMod] Nothing hit.\n")
        return nil
    end
end

function EntityOutline.AddEntityOutline(entity)
    -- TODO : Find a way buddy

    EntityOutline.OutlinedEntities[entity] = true
end

function EntityOutline.RemoveEntityOutline(entity)
    -- TODO : Find a way buddy

    EntityOutline.OutlinedEntities[entity] = nil
end

function EntityOutline.ToggleEntityOutline()

    local entity = EntityOutline.PerformRaycast()
    if entity == nil then return end
    if not Utils.IsValidObject(entity) then print("[PingouinMod] Hit entity is not valid\n") return end

    if EntityOutline.OutlinedEntities[entity] then
        print("[PingouinMod] Removing outline from entity\n")
        -- TODO : Remove outline
        return
    end

    print("[PingouinMod] Adding outline to entity\n")
    EntityOutline.AddEntityOutline(entity)

end

function EntityOutline.GC()
    
    -- TODO : Utility TBD

end


RegisterKeyBind(Keybinds.EntityOutline, function()
    print("[PingouinMod] Displaying entity outline\n")
    ExecuteInGameThread(function()
        EntityOutline.ToggleEntityOutline()
    end)
end)

return EntityOutline