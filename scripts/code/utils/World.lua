local Constants = require("code/Constants")
local Types = require("code/utils/Types")
local Math = require("code/utils/Math")
local Entity = require("code/utils/Entity")
local World = {}

-- Variables 

local TRACE_CHANNELS = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
}


--- Finds the first blocking surface below a world position.
-- @param Actor (AActor) The actor ignored by the trace
-- @param Position (FVector) The center of the vertical trace
-- @return (FVector|nil) The impact point, or nil when no surface is hit
function World.FindSurfaceBelow(Actor, Position)
    local _, hitResult, wasHit = World.PerformRaycast(
        Position,
        Actor,
        nil,
        {X = 0, Y = 0, Z = -1},
        nil,
        Constants.TRACE_DISTANCE,
        1,
        false,
        {Actor},
        true,
        false,
        0.0,
        {R = 0, G = 0, B = 0, A = 0},
        {R = 0, G = 0, B = 0, A = 0}
    )
    if not wasHit or not hitResult then return nil end
    return Types.UnwrapValue(hitResult.ImpactPoint or hitResult.Location)
end

-- TODO : Rework the following function since it seems to be inconsistent on the ground placement
--- Moves an actor so the bottom of its bounds touches a surface point.
-- @param Actor (AActor) The actor to move
-- @param MeshComponent (UStaticMeshComponent) The mesh component used for bounds
-- @param MeshAsset (UStaticMesh) The mesh asset used as a bounds fallback
-- @param SurfacePoint (FVector|nil) The target surface point
-- @return (nil) This function does not return a value
function World.PlaceActorOnSurface(Actor, MeshComponent, MeshAsset, SurfacePoint)
    if not SurfacePoint then return end
    local actorLocation = Actor:K2_GetActorLocation()
    local surfaceZ = Types.ReadVectorComponent(SurfacePoint, "Z")
    local actorX = Types.ReadVectorComponent(actorLocation, "X")
    local actorY = Types.ReadVectorComponent(actorLocation, "Y")
    local actorZ = Types.ReadVectorComponent(actorLocation, "Z")
    if not surfaceZ or not actorX or not actorY or not actorZ then return end

    local boundsSuccess, minBounds, maxBounds = pcall(function() return MeshComponent:GetLocalBounds() end)
    local localBounds = boundsSuccess and minBounds and maxBounds
    if (not boundsSuccess or not minBounds or not maxBounds) and MeshAsset then
        boundsSuccess, minBounds, maxBounds = pcall(function() return MeshAsset:GetLocalBounds() end)
        localBounds = boundsSuccess and minBounds and maxBounds
    end
    if not boundsSuccess or not minBounds or not maxBounds then
        local KismetSystemLibrary = UEHelpers:GetKismetSystemLibrary()
        local returnedSuccess, returnedOrigin, returnedExtent = pcall(function()
            return KismetSystemLibrary:GetComponentBounds(MeshComponent)
        end)
        if returnedSuccess and returnedOrigin and returnedExtent then
            minBounds, maxBounds, boundsSuccess, localBounds = returnedOrigin, returnedExtent, true, false
        else
            local originOutput, extentOutput, radiusOutput = {}, {}, {}
            local outputSuccess = pcall(function()
                KismetSystemLibrary:GetComponentBounds(MeshComponent, originOutput, extentOutput, radiusOutput)
            end)
            if outputSuccess then
                minBounds, maxBounds, boundsSuccess, localBounds = originOutput, extentOutput, true, false
            end
        end
    end
    if not boundsSuccess or not minBounds or not maxBounds then return end

    local minZ = Types.ReadVectorComponent(minBounds, "Z")
    local extentZ = Types.ReadVectorComponent(maxBounds, "Z")
    if not localBounds and extentZ then minZ = minZ - extentZ end
    if not minZ then return end

    local meshBottom = localBounds and actorZ + minZ or minZ - (extentZ or 0)
    local verticalOffset = surfaceZ - meshBottom
    local componentLocationSuccess, componentLocation = pcall(function() return MeshComponent:K2_GetComponentLocation() end)
    if not componentLocationSuccess then
        componentLocationSuccess, componentLocation = pcall(function() return MeshComponent:GetComponentLocation() end)
    end
    local componentX = componentLocationSuccess and Types.ReadVectorComponent(componentLocation, "X") or actorX
    local componentY = componentLocationSuccess and Types.ReadVectorComponent(componentLocation, "Y") or actorY
    local componentZ = componentLocationSuccess and Types.ReadVectorComponent(componentLocation, "Z") or actorZ
    if not componentX or not componentY or not componentZ then return end

    local targetLocation = {X = componentX, Y = componentY, Z = componentZ + verticalOffset}
    local moveSuccess, moveResult = pcall(function()
        return MeshComponent:K2_SetWorldLocation(targetLocation, false, {}, true)
    end)
    if not moveSuccess or moveResult == false then
        pcall(function() Actor:K2_SetActorLocation(targetLocation, false, {}, true) end)
    end
end

--- Reads the location and rotation from a camera manager.
-- @param camera (APlayerCameraManager) The camera manager to inspect
-- @return (FVector|nil, FRotator|nil) Camera location and rotation
local function getCameraData(camera)
    if not Types.IsValidObject(camera) then return nil, nil end
    local locationSuccess, location = pcall(function() return camera:GetCameraLocation() end)
    local rotationSuccess, rotation = pcall(function() return camera:GetCameraRotation() end)
    if not locationSuccess or not rotationSuccess then return nil, nil end
    return Types.ReadVector(location), rotation
end

--- Extracts the object represented by a line trace hit result.
-- @param hitResult (FHitResult) The Unreal hit result
-- @return (UObject|nil) The hit object, actor, or component
local function getHitObject(hitResult)
    local success, handle = pcall(function()
        local handle = Types.UnwrapValue(hitResult.HitObjectHandle)
        return handle and Types.UnwrapValue(handle.ReferenceObject)
    end)
    if success and handle then
        local referenceSuccess, object = pcall(function() return handle:Get() end)
        if referenceSuccess and object then return object end
    end
    local actorSuccess, actor = pcall(function() return Types.UnwrapValue(hitResult.Actor) end)
    if actorSuccess and actor then return actor end
    local componentSuccess, component = pcall(function() return Types.UnwrapValue(hitResult.Component) end)
    return componentSuccess and component or nil
end

--- Performs a configurable line trace.
-- @param Position (FVector|nil) Ray origin; camera or pawn location is used when nil
-- @param Pawn (APawn|nil) Pawn used as the default self actor and fallback origin
-- @param Camera (APlayerCameraManager|nil) Camera used as the default origin and direction
-- @param Direction (FVector|nil) Normalized ray direction; camera or pawn rotation is used when nil
-- @param Rotation (FRotator|nil) Rotation used to derive the ray direction
-- @param Length (number|nil) Ray length, default 50000
-- @param TraceChannel (number|nil) 1 WorldStatic, 2 WorldDynamic, 3 Pawn, 4 Visibility, 5 Camera
-- @param TraceComplex (boolean|nil) Whether to use complex collision, default true
-- @param ActorsToIgnore (table|nil) Actors excluded from the trace
-- @param IgnoreSelf (boolean|nil) Whether to ignore Pawn, default true
-- @param DrawDebug (boolean|number|nil) Debug mode: false/0 none, true/1 one frame, 2 duration, 3 persistent
-- @param DrawTime (number|nil) Duration used by debug drawing
-- @param TraceColor (FLinearColor|table|nil) Debug color before a hit
-- @param TraceHitColor (FLinearColor|table|nil) Debug color after a hit
-- @return (UObject|nil, FHitResult|nil, boolean) Hit object, result, and success
function World.PerformRaycast(Position, Pawn, Camera, Direction, Rotation, Length, TraceChannel, TraceComplex, ActorsToIgnore, IgnoreSelf, DrawDebug, DrawTime, TraceColor, TraceHitColor)
    -- UE4SS can throw when a library is unavailable during world loading, so
    -- failure to acquire it is reported as an unsuccessful trace.
    local librarySuccess, KismetSystemLibrary = pcall(function() return UEHelpers:GetKismetSystemLibrary() end)
    if not librarySuccess or not Types.IsValidObject(KismetSystemLibrary) then return nil, nil, false end

    -- Explicit Pawn and Camera values take precedence. If it fails, use the local player as the fallback source
    local PlayerController = Entity.GetPlayerController()
    if not Types.IsValidObject(Pawn) and Types.IsValidObject(PlayerController) then
        Pawn = Types.UnwrapValue(PlayerController.Pawn)
    end

    if not Types.IsValidObject(Camera) and Types.IsValidObject(PlayerController) then
        Camera = Types.UnwrapValue(PlayerController.PlayerCameraManager)
    end

    -- Resolve the origin and orientation independently. This allows caller to combine a custom Position with the current camera rotation.
    -- Origin priority is Position, then Camera location, then Pawn location.
    local StartVector = Types.ReadVector(Position)
    if Camera then
        local cameraLocation, cameraRotation = getCameraData(Camera)
        StartVector = StartVector or cameraLocation
        Rotation = Rotation or cameraRotation
    end
    if not StartVector and Pawn then
        StartVector = Entity.GetActorLocation(Pawn)
        if not Rotation then
            pcall(function() Rotation = Pawn:K2_GetActorRotation() end)
        end
    end
    if not StartVector then return nil, nil, false end

    -- Direction is preferred when supplied. A Rotation is only converted to a forward vector as a fallback, first from the camera and then from Pawn.
    local RayDirection = Types.ReadVector(Direction)
    if not RayDirection and Rotation then RayDirection = Math.GetForwardVector(Rotation) end
    RayDirection = Types.ReadVector(RayDirection)
    if not RayDirection then return nil, nil, false end

    -- Keep the endpoint calculation local so the input origin and direction are never mutated before the native trace call.
    local traceLength = tonumber(Length) or 50000.0
    if traceLength <= 0 then return nil, nil, false end
    local EndVector = {
        X = StartVector.X + RayDirection.X * traceLength,
        Y = StartVector.Y + RayDirection.Y * traceLength,
        Z = StartVector.Z + RayDirection.Z * traceLength,
    }

    -- Remove invalid entries before crossing the UE4SS boundary. IgnoreSelf is applied both to this list and to LineTraceSingle's native flag.
    local actorsToIgnore = {}
    if type(ActorsToIgnore) == "table" then
        for _, actor in ipairs(ActorsToIgnore) do
            if Types.IsValidObject(actor) then table.insert(actorsToIgnore, actor) end
        end
    end
    if IgnoreSelf ~= false and Types.IsValidObject(Pawn) then
        local alreadyIgnored = false
        for _, actor in ipairs(actorsToIgnore) do
            if actor == Pawn then alreadyIgnored = true break end
        end
        if not alreadyIgnored then table.insert(actorsToIgnore, Pawn) end
    end

    local traceChannel = TRACE_CHANNELS[tonumber(TraceChannel) or 4]
    if traceChannel == nil then traceChannel = TRACE_CHANNELS[4] end

    -- Draw debug related stuff
    local drawDebug = DrawDebug
    if type(drawDebug) == "boolean" then drawDebug = drawDebug and 1 or 0 end
    drawDebug = tonumber(drawDebug) or 0
    local traceColor = TraceColor or {R = 0, G = 255, B = 0, A = 255}
    local traceHitColor = TraceHitColor or {R = 255, G = 0, B = 0, A = 255}

    -- The native call is protected because invalid UE objects can throw errors and fuck the whole trace (not happend one nor twice. SEVERAL TIMES)
    local hitResult = {}
    local success, wasHit = pcall(function()
        return KismetSystemLibrary:LineTraceSingle(
            Pawn, StartVector, EndVector, traceChannel, TraceComplex ~= false,
            actorsToIgnore, drawDebug, hitResult, IgnoreSelf ~= false, traceColor, traceHitColor,
            tonumber(DrawTime) or 0.0
        )
    end)
    if not success then return nil, hitResult, false end
    wasHit = Types.UnwrapValue(wasHit) == true
    return wasHit and getHitObject(hitResult) or nil, hitResult, wasHit
end


return World