local Types = require("code/utils/Types")
local Entity = {}
local DebugCameraControllerCache = CreateInvalidObject()

--- Checks whether a controller belongs to the debug camera system.
-- @param controller (UPlayerController) The controller to inspect
-- @return (boolean) True when the controller is a debug camera controller
local function IsDebugCameraController(controller)
    if not Types.IsValidObject(controller) then return false end
    local success, fullName = pcall(function() return controller:GetFullName() end)
    return success and string.find(fullName, "DebugCameraController", 1, true) ~= nil
end

--- Checks if a given player controller or character is currently in a vehicle.
-- @param playerControllerOrCharacter (UPlayerController|ACharacter) The player controller or character to check
-- @return (boolean) True if the player is in a vehicle, false otherwise
function Entity.IsVehiclePawn(playerControllerOrCharacter)
    if not playerControllerOrCharacter then return false end
    local character = playerControllerOrCharacter.LocalCharacter or playerControllerOrCharacter
    if not Types.IsValidObject(character) then return false end
    return Types.IsValidObject(character.InVehicle) or character.bVehicleDriver == true
end

--- Retrieves the local player controller, ensuring it is valid and not a debug camera controller.
-- @return (UPlayerController|nil) The local player controller, or nil if not found
function Entity.GetPlayerController()
    local success, currentController = pcall(function() return UEHelpers:GetPlayerController() end)
    if success and Types.IsValidObject(currentController) and not IsDebugCameraController(currentController) then return currentController end
    for _, controller in ipairs(FindAllOf("PlayerController") or {}) do
        local isLocalSuccess, isLocal = pcall(function() return controller:IsLocalPlayerController() end)
        if Types.IsValidObject(controller) and not IsDebugCameraController(controller)
            and isLocalSuccess and isLocal and Types.IsValidObject(controller.Pawn) then return controller end
    end
    return nil
end

--- Gets the local player pawn, ensuring it is valid.
-- @return (APawn|nil) The local player pawn, or nil if not found
function Entity.GetPlayer()
    local success, player = pcall(function() return UEHelpers:GetPlayer() end)
    if success and Types.IsValidObject(player) then return player end
    local playerController = Entity.GetPlayerController()
    if playerController then return playerController.Pawn end
    return nil
end

--- Retrieves an actor's world location using the available Unreal accessor.
-- @param actor (AActor) The actor whose location should be read
-- @return (FVector|nil) The normalized world location, or nil when unavailable
function Entity.GetActorLocation(actor)
    if not Types.IsValidObject(actor) then return nil end
    local success, location = pcall(function() return actor:K2_GetActorLocation() end)
    if not success then
        success, location = pcall(function() return actor:GetActorLocation() end)
    end
    return success and Types.ReadVector(location) or nil
end

--- Retrieves an object's name using the most specific available Unreal accessor.
-- @param object (UObject) The object to inspect
-- @return (string|nil) The object name, or nil when unavailable
function Entity.GetObjectName(object)
    if not object then return nil end

    local success, name = pcall(function()
        if object.GetName then return object:GetName() end
        if object.GetFullName then return object:GetFullName() end
    end)

    return success and name and tostring(name) or nil
end

--- Checks whether an object's name matches an expected name, allowing Unreal numeric suffixes.
-- @param object (UObject) The object to inspect
-- @param expectedName (string) The expected object name
-- @return (boolean) True when the object name matches
function Entity.HasObjectName(object, expectedName)
    local name = Entity.GetObjectName(object)
    if not name or not expectedName then return false end

    name = string.lower(name)
    expectedName = string.lower(expectedName)
    return name == expectedName or string.match(name, "^" .. expectedName .. "_%d+$") ~= nil
end

--- Enables the cheat manager for a given player controller, constructing it if necessary.
--- @param playerController (UPlayerController) The player controller to enable the cheat manager for
--- @return (boolean) True if the cheat manager is enabled or already present, false otherwise
function Entity.EnableCheatManager(playerController)
    if not Types.IsValidObject(playerController) then return false end
    if not Types.IsValidObject(playerController.CheatManager) then
        local CheatManagerClass = playerController.CheatClass
        if not Types.IsValidObject(CheatManagerClass) then
            print("[PingouinMod] Controller:CheatClass is nullptr, using default CheatClass instead\n")
            CheatManagerClass = StaticFindObject("/Script/Engine.CheatManager")
        end
        if not Types.IsValidObject(CheatManagerClass) then
            print("[PingouinMod] Couldn't find default CheatClass, therefore, could not enable Cheat Manager\n")
            return false
        end
        local CreatedCheatManager = StaticConstructObject(CheatManagerClass, playerController)
        if Types.IsValidObject(CreatedCheatManager) then
            print(string.format("[PingouinMod] Constructed CheatManager [0x%X] | Success\n", CreatedCheatManager:GetAddress()))
            playerController.CheatManager = CreatedCheatManager
        else
            print("[PingouinMod] Was unable to construct CheatManager, therefore, could not enable Cheat Manager\n")
            return false
        end
    end
    return true
end

--- Resets the cached Debug Camera Controller, forcing a re-evaluation on the next retrieval.
function Entity.ResetDebugCameraControllerCache()
    DebugCameraControllerCache = CreateInvalidObject()
end

--- Gets the Debug Camera Controller for the local player, caching it for future calls.
-- @return (UPlayerController) The Debug Camera Controller object
function Entity.GetDebugCameraController()
    if Types.IsValidObject(DebugCameraControllerCache) then return DebugCameraControllerCache end
    for _, Controller in ipairs(FindAllOf("DebugCameraController") or {}) do
        if Types.IsValidObject(Controller) and (Controller.IsPlayerController and Controller:IsPlayerController() or Controller:IsLocalPlayerController()) then
            DebugCameraControllerCache = Controller
            return DebugCameraControllerCache
        end
    end
    return UEHelpers:GetPlayerController()
end

--- Resolves a StaticMesh reference from an Unreal asset path.
-- @param assetPath (string) The full Unreal asset path
-- @param fallbackAsset (UObject) The asset returned when typed resolution fails
-- @return (UStaticMesh|UObject|nil) The resolved mesh reference
function Entity.ResolveStaticMesh(assetPath, fallbackAsset)
    local packagePath = string.match(assetPath, "^(.*)%.[^%.]+$") or assetPath
    local objectName = string.match(assetPath, "%.([^%.]+)$") or string.match(assetPath, "/([^/]+)$")
    local staticMeshClass = StaticFindObject(Constants.STATIC_MESH_CLASS_PATH)
    if Types.IsValidObject(staticMeshClass) then
        for _, objectPath in ipairs({assetPath, packagePath}) do
            local success, typedAsset = pcall(function() return StaticFindObject(staticMeshClass, nil, objectPath, true) end)
            if success and Types.IsValidObject(typedAsset) then return typedAsset end
        end
    end
    if objectName then
        local success, typedAsset = pcall(function() return FindObject("StaticMesh", objectName, 0, 0) end)
        if success and Types.IsValidObject(typedAsset) then return typedAsset end
    end
    local packageAsset = LoadAsset(packagePath)
    if Types.IsValidObject(packageAsset) then return packageAsset end
    return fallbackAsset
end

--- Generates a unique key for an entity based on its address or full name.
-- @param entity (AActor|UObject) The entity to generate a key for
-- @return (string|nil) A unique string key for the entity, or nil if the entity is invalid
function Entity.GetEntityKey(entity)
    if not Utils.IsValidObject(entity) then return nil end
    if entity.GetAddress then
        return tostring(entity:GetAddress())
    end
    if entity.GetFullName then
        return entity:GetFullName()
    end
    return tostring(entity)
end

--- Retrieves the top-level entity for a given entity, considering ownership and attachment.
-- @param entity (AActor|UObject) The entity to inspect
-- @return (AActor|UObject) The top-level entity, or the original entity if no higher level is found
function Entity.GetTopLevelEntity(entity)
    if not Utils.IsValidObject(entity) then return entity end

    local current = entity
    local visited = {}

    while Utils.IsValidObject(current) and not visited[current] do
        visited[current] = true
        local parent = nil

        if current.GetOwner then
            local success, owner = pcall(function() return current:GetOwner() end)
            if success and Utils.IsValidObject(owner) then parent = owner end
        end

        if not parent and current.GetAttachParentActor then
            local success, parentActor = pcall(function() return current:GetAttachParentActor() end)
            if success and Utils.IsValidObject(parentActor) then parent = parentActor end
        end

        if not parent then break end
        current = parent
    end

    return current
end

--- Disables collision for a given entity, attempting multiple methods to ensure collision is turned off.
-- @param entity (AActor|UObject) The entity to disable collision for
-- @return (boolean) True if collision was successfully disabled, false otherwise
function Entity.DisableEntityCollision(entity)
    local disabled = false

    if not Utils.IsValidObject(entity) then
        print("[PingouinMod] Invalid entity provided for collision disable.\n")
        return disabled
    end

    pcall(function()
        if entity.SetActorEnableCollision then
            entity:SetActorEnableCollision(false)
            disabled = true
            print("[PingouinMod] Collision disabled via SetActorEnableCollision.\n")
        end
    end)

    if not disabled then
        pcall(function()
            if entity.SetCollisionEnabled then
                -- 0 = ECollisionEnabled::NoCollision
                entity:SetCollisionEnabled(0)
                disabled = true
                print("[PingouinMod] Collision disabled via SetCollisionEnabled(0).\n")
            end
        end)
    end

    if not disabled then
        print("[PingouinMod] Could not disable collision on this entity.\n")
    end

    return disabled
end

return Entity