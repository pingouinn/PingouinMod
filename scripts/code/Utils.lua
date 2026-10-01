local Utils = {}

function Utils.IsValidObject(object)
    if not object then return false end
    local success, valid = pcall(function() return object:IsValid() end)
    return success and valid == true
end

function Utils.NormalizeVector(value, namedKeys)
    if type(value) ~= "table" then return nil end

    local first = value[namedKeys[1]]
    local second = value[namedKeys[2]]
    local third = value[namedKeys[3]]
    if first == nil then
        first = value[1]
        second = value[2]
        third = value[3]
    end

    first = tonumber(first)
    second = tonumber(second)
    third = tonumber(third)
    if first == nil or second == nil or third == nil then return nil end

    return {
        [namedKeys[1]] = first,
        [namedKeys[2]] = second,
        [namedKeys[3]] = third,
    }
end

--- Enables the cheat manager for a given player controller, constructing it if necessary.
--- @param playerController (UPlayerController) The player controller to enable the cheat manager for
--- @return (boolean) True if the cheat manager is enabled or already present, false otherwise
function Utils.EnableCheatManager(playerController)
    if not Utils.IsValidObject(playerController) then return false end

    if not Utils.IsValidObject(playerController.CheatManager) then
        local CheatManagerClass = playerController.CheatClass
        if not Utils.IsValidObject(CheatManagerClass) then
            print("[PingouinMod] Controller:CheatClass is nullptr, using default CheatClass instead\n")
            CheatManagerClass = StaticFindObject("/Script/Engine.CheatManager") --[[@as UClass]]
        end

        if not Utils.IsValidObject(CheatManagerClass) then
            print("[PingouinMod] Couldn't find default CheatClass, therefore, could not enable Cheat Manager\n")
            return false
        end

        local CreatedCheatManager = StaticConstructObject(CheatManagerClass, playerController)
        if Utils.IsValidObject(CreatedCheatManager) then
            print(string.format("[PingouinMod] Constructed CheatManager [0x%X] | Success\n", CreatedCheatManager:GetAddress()))
            playerController.CheatManager = CreatedCheatManager
        else
            print("[PingouinMod] Was unable to construct CheatManager, therefore, could not enable Cheat Manager\n")
            return false
        end
    end

    return true
end

--- Retrieves the Debug Camera Controller for the local player.
--- @return (UPlayerController) The Debug Camera Controller object
local DebugCameraControllerCache = CreateInvalidObject()
function Utils.GetDebugCameraController()
    if Utils.IsValidObject(DebugCameraControllerCache) then return DebugCameraControllerCache end
    for _, Controller in ipairs(FindAllOf("DebugCameraController") or {}) do
        if Utils.IsValidObject(Controller) and (Controller.IsPlayerController and Controller:IsPlayerController() or Controller:IsLocalPlayerController()) then
            DebugCameraControllerCache = Controller
            return DebugCameraControllerCache
        end
    end
    return UEHelpers:GetPlayerController()
end

--- Teleports the player to a specified position and rotation.
-- @param position (table) A table with X, Y, Z fields representing the current position
-- @param rotation (table) A table with Pitch, Yaw, Roll fields representing the target rotation
-- @param distance (number) Distance to offset in the direction vector
-- @return (number, number, number) The new X, Y, Z coordinates after applying the offset
function Utils.GetPositionInFront(Position, Rotation, distance)
    local KsmMath = UEHelpers:GetKismetMathLibrary()
    if not Utils.IsValidObject(KsmMath) then print("[PingouinMod] KismetMathLibrary not valid\n") return Position end
    
    local AddValue = KsmMath:Multiply_VectorFloat(KsmMath:GetForwardVector(Rotation), distance)
    local EndVector = KsmMath:Add_VectorVector(Position, AddValue)
    return EndVector
end


--- Computes the forward vector from pitch and yaw angles.
-- @param Rotation (table) A table with Pitch, Yaw, Roll fields
-- @return (table) A table representing the forward vector with X, Y, Z fields
function Utils.GetForwardVector(Rotation)
    local KsmMath = UEHelpers:GetKismetMathLibrary()
    if not Utils.IsValidObject(KsmMath) then print("[PingouinMod] KismetMathLibrary not valid\n") return {X=0, Y=0, Z=0} end
    return KsmMath:GetForwardVector(Rotation)
end

--- Checks if two locations are approximately equal within a given tolerance.
-- @param locA (table) First location with X, Y, Z fields
-- @param locB (table) Second location with X, Y, Z fields
-- @param tolerance (number) The maximum allowed difference for each coordinate
-- @return (boolean) True if locations are approximately equal, false otherwise
function Utils.CheckLocationEquality(locA, locB, tolerance)
    if locA == nil or locB == nil then return false end
    tolerance = tolerance or 0.01
    return math.abs(locA.X - locB.X) <= tolerance and
           math.abs(locA.Y - locB.Y) <= tolerance and
           math.abs(locA.Z - locB.Z) <= tolerance
end

--- Unwraps a value returned through a UE4SS remote parameter.
--- @param value (any) A direct value or a UE4SS remote parameter
--- @return (any) The unwrapped value, or the original value when unchanged
function Utils.UnwrapValue(value)
    if not value then return nil end

    local success, unwrappedValue = pcall(function() return value:get() end)
    if success and unwrappedValue and unwrappedValue ~= value then return unwrappedValue end
    return value
end

--- Reads a numeric value returned directly or wrapped by UE4SS.
--- @param value (any) A number or UE4SS numeric parameter
--- @return (number|nil) The numeric value, or nil when unavailable
function Utils.ReadNumber(value)
    value = Utils.UnwrapValue(value)
    if type(value) == "number" then return value end
    if not value then return nil end
    return nil
end

--- Reads one component from a vector returned by UE4SS.
--- @param vector (FVector|UScriptStruct) The vector to inspect
--- @param component (string) The component name, such as X, Y, or Z
--- @return (number|nil) The component value, or nil when unavailable
function Utils.ReadVectorComponent(vector, component)
    vector = Utils.UnwrapValue(vector)
    if not vector then return nil end

    local success, value = pcall(function() return vector[component] end)
    if not success then return nil end
    return Utils.ReadNumber(value)
end

--- Resolves a StaticMesh reference from an Unreal asset path.
--- @param assetPath (string) The full Unreal asset path
--- @param fallbackAsset (UObject) The asset returned when typed resolution fails
--- @return (UStaticMesh|UObject|nil) The resolved mesh reference
function Utils.ResolveStaticMesh(assetPath, fallbackAsset)
    local packagePath = string.match(assetPath, "^(.*)%.[^%.]+$") or assetPath
    local objectName = string.match(assetPath, "%.([^%.]+)$") or string.match(assetPath, "/([^/]+)$")
    local staticMeshClass = StaticFindObject(Constants.STATIC_MESH_CLASS_PATH)

    if Utils.IsValidObject(staticMeshClass) then
        for _, objectPath in ipairs({assetPath, packagePath}) do
            local success, typedAsset = pcall(function()
                return StaticFindObject(staticMeshClass, nil, objectPath, true)
            end)
            if success and Utils.IsValidObject(typedAsset) then return typedAsset end
        end
    end

    if objectName then
        local success, typedAsset = pcall(function()
            return FindObject("StaticMesh", objectName, 0, 0)
        end)
        if success and Utils.IsValidObject(typedAsset) then return typedAsset end
    end

    local packageAsset = LoadAsset(packagePath)
    if Utils.IsValidObject(packageAsset) then return packageAsset end
    return fallbackAsset
end

--- Finds the first blocking surface below a world position.
--- @param Actor (AActor) The actor ignored by the trace
--- @param Position (FVector) The center of the vertical trace
--- @return (FVector|nil) The impact point, or nil when no surface is hit
function Utils.FindSurfaceBelow(Actor, Position)
    local KismetSystemLibrary = UEHelpers:GetKismetSystemLibrary()
    if not Utils.IsValidObject(KismetSystemLibrary) then return nil end

    -- Start at the spawn point so overhead roofs are not selected first.
    local Start = {X = Position.X, Y = Position.Y, Z = Position.Z}
    local End = {X = Position.X, Y = Position.Y, Z = Position.Z - Constants.TRACE_DISTANCE}
    local HitResult = {}
    local TraceColor = {R = 0, G = 0, B = 0, A = 0}
    local WasHit = KismetSystemLibrary:LineTraceSingle(
        Actor,
        Start,
        End,
        0,
        false,
        {Actor},
        0,
        HitResult,
        true,
        TraceColor,
        TraceColor,
        0.0
    )

    if not WasHit then return nil end

    return Utils.UnwrapValue(HitResult.ImpactPoint or HitResult.Location)
end

--- Moves an actor so the bottom of its bounds touches a surface point.
--- @param Actor (AActor) The actor to move
--- @param MeshComponent (UStaticMeshComponent) The mesh component used for bounds
--- @param MeshAsset (UStaticMesh) The mesh asset used as a bounds fallback
--- @param SurfacePoint (FVector|nil) The target surface point
--- @return (nil) This function does not return a value
function Utils.PlaceActorOnSurface(Actor, MeshComponent, MeshAsset, SurfacePoint)
    if not SurfacePoint then return end

    local actorLocation = Actor:K2_GetActorLocation()
    local surfaceZ = Utils.ReadVectorComponent(SurfacePoint, "Z")
    local actorX = Utils.ReadVectorComponent(actorLocation, "X")
    local actorY = Utils.ReadVectorComponent(actorLocation, "Y")
    local actorZ = Utils.ReadVectorComponent(actorLocation, "Z")
    if not surfaceZ or not actorX or not actorY or not actorZ then return end

    -- Local bounds avoid the unreliable component Bounds property.
    local boundsSuccess, minBounds, maxBounds = pcall(function()
        return MeshComponent:GetLocalBounds()
    end)
    local localBounds = boundsSuccess and minBounds and maxBounds
    if (not boundsSuccess or not minBounds or not maxBounds) and MeshAsset then
        boundsSuccess, minBounds, maxBounds = pcall(function()
            return MeshAsset:GetLocalBounds()
        end)
        localBounds = boundsSuccess and minBounds and maxBounds
    end
    if not boundsSuccess or not minBounds or not maxBounds then
        -- KismetSystemLibrary supports both common UE4SS out-parameter styles.
        local KismetSystemLibrary = UEHelpers:GetKismetSystemLibrary()
        local returnedSuccess, returnedOrigin, returnedExtent = pcall(function()
            return KismetSystemLibrary:GetComponentBounds(MeshComponent)
        end)
        if returnedSuccess and returnedOrigin and returnedExtent then
            minBounds = returnedOrigin
            maxBounds = returnedExtent
            boundsSuccess = true
            localBounds = false
        else
            local originOutput = {}
            local extentOutput = {}
            local radiusOutput = {}
            local outputSuccess = pcall(function()
                KismetSystemLibrary:GetComponentBounds(MeshComponent, originOutput, extentOutput, radiusOutput)
            end)
            if outputSuccess then
                minBounds = originOutput
                maxBounds = extentOutput
                boundsSuccess = true
                localBounds = false
            end
        end
    end
    if not boundsSuccess or not minBounds or not maxBounds then return end

    local minZ = Utils.ReadVectorComponent(minBounds, "Z")
    local extentZ = Utils.ReadVectorComponent(maxBounds, "Z")
    if not localBounds and extentZ then minZ = minZ - extentZ end
    if not minZ then return end

    local meshBottom = minZ
    if localBounds then
        meshBottom = actorZ + minZ
    elseif extentZ then
        meshBottom = minZ - extentZ
    end

    local verticalOffset = surfaceZ - meshBottom
    local componentLocationSuccess, componentLocation = pcall(function()
        return MeshComponent:K2_GetComponentLocation()
    end)
    if not componentLocationSuccess then
        componentLocationSuccess, componentLocation = pcall(function()
            return MeshComponent:GetComponentLocation()
        end)
    end

    local componentX = componentLocationSuccess and Utils.ReadVectorComponent(componentLocation, "X") or actorX
    local componentY = componentLocationSuccess and Utils.ReadVectorComponent(componentLocation, "Y") or actorY
    local componentZ = componentLocationSuccess and Utils.ReadVectorComponent(componentLocation, "Z") or actorZ
    if not componentX or not componentY or not componentZ then return end

    local targetLocation = {
        X = componentX,
        Y = componentY,
        Z = componentZ + verticalOffset,
    }
    local moveSuccess, moveResult = pcall(function()
        return MeshComponent:K2_SetWorldLocation(targetLocation, false, {}, true)
    end)
    if not moveSuccess or moveResult == false then
        moveSuccess, moveResult = pcall(function()
            return Actor:K2_SetActorLocation(targetLocation, false, {}, true)
        end)
    end
end

--- Corrects the path separators in a given path string.
-- @param path (string) The path with \
-- @return (string) The cleaned path with /
function Utils.SanitizePath(path)
    if type(path) ~= "string" then return nil end
    return (path:gsub("\\", "/"))
end

--- Retrieves the mod folder path from a script's full path.
-- @param scriptFullPath (string) The full path of the script
-- @return (string) The mod folder path
function Utils.GetModFolder(scriptFullPath)
    return scriptFullPath:match("^(.*)/PingouinMod/") or ""
end

--- Dynamically requires a UE4SS dump file, patching it to use global variables, because it overlaps the 200 local limit.
-- @param  filePath (string) The file path to the UE4SS dump Lua file
-- @return (table) The environment table containing the dumped variables, or nil and an error
function Utils.RequireUE4SSDump(filePath)
    local f = io.open(filePath, "rb")
    if not f then return nil, "[PingouinMod] File not found: " .. filePath end
    
    local content = f:read("*a") -- Tout lire d'un coup
    f:close()

    if type(content) ~= "string" then
        return nil, "[PingouinMod] Failed to read file: " .. tostring(filePath)
    end

    -- Modifies the content to remove 'local' declarations
    local patched_content = content:gsub("local ", "") 

    -- Create a new environment table
    local env = {} 
    
    -- Connect the default global environment so that print, pairs, etc. work
    setmetatable(env, { __index = _G }) 

    local chunk, err = load(patched_content, filePath, "t", env)
    if not chunk then 
        return nil, "Erreur de compilation : " .. tostring(err) 
    end
    
    -- Apply the environment and execute
    chunk() 
    
    return env
end

return Utils