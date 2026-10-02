local Constants = require("code/Constants")
local Types = require("code/utils/Types")
local World = {}

--- Finds the first blocking surface below a world position.
-- @param Actor (AActor) The actor ignored by the trace
-- @param Position (FVector) The center of the vertical trace
-- @return (FVector|nil) The impact point, or nil when no surface is hit
function World.FindSurfaceBelow(Actor, Position)
    local KismetSystemLibrary = UEHelpers:GetKismetSystemLibrary()
    if not Types.IsValidObject(KismetSystemLibrary) then return nil end
    local Start = {X = Position.X, Y = Position.Y, Z = Position.Z}
    local End = {X = Position.X, Y = Position.Y, Z = Position.Z - Constants.TRACE_DISTANCE}
    local HitResult = {}
    local TraceColor = {R = 0, G = 0, B = 0, A = 0}
    local WasHit = KismetSystemLibrary:LineTraceSingle(Actor, Start, End, 0, false, {Actor}, 0, HitResult, true, TraceColor, TraceColor, 0.0)
    if not WasHit then return nil end
    return Types.UnwrapValue(HitResult.ImpactPoint or HitResult.Location)
end

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

return World