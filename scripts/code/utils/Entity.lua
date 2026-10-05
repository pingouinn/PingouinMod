local Types = require("code/utils/Types")
local Entity = {}

--- Checks if a given player controller or character is currently in a vehicle.
-- @param playerControllerOrCharacter (UPlayerController|ACharacter) The player controller or character to check
-- @return (boolean) True if the player is in a vehicle, false otherwise
function Entity.IsVehiclePawn(playerControllerOrCharacter)
    if not playerControllerOrCharacter then return false end
    local character = playerControllerOrCharacter.LocalCharacter or playerControllerOrCharacter
    if not Types.IsValidObject(character) then return false end
    return Types.IsValidObject(character.InVehicle) or character.bVehicleDriver == true
end

--- Retrieves an actor's world location using the available Unreal accessor.
-- @param actor (AActor) The actor whose location should be read
-- @return (FVector|nil) The normalized world location, or nil when unavailable
function Entity.GetActorLocation(actor)
    if not Types.IsValidObject(actor) then return nil end
    local success, location = Types.TryCall("Read actor location", function() return actor:K2_GetActorLocation() end)
    if not success then
        success, location = Types.TryCall("Read actor location fallback", function() return actor:GetActorLocation() end)
    end
    return success and Types.ReadVector(location) or nil
end

--- Retrieves an object's name using the most specific available Unreal accessor.
-- @param object (UObject) The object to inspect
-- @return (string|nil) The object name, or nil when unavailable
function Entity.GetObjectName(object)
    if not object then return nil end

    local success, name = Types.TryCall("Read object name", function()
        if object.GetName then  return object:GetName() end
    end)

    if not success or not name then
        success, name = Types.TryCall("Read object full name", function()
            if object.GetFullName then return object:GetFullName() end
        end)
    end

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
            local success, typedAsset = Types.TryCall("Find typed static mesh", function() return StaticFindObject(staticMeshClass, nil, objectPath, true) end)
            if success and Types.IsValidObject(typedAsset) then return typedAsset end
        end
    end
    if objectName then
        local success, typedAsset = Types.TryCall("Find static mesh object", function() return FindObject("StaticMesh", objectName, 0, 0) end)
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
            local success, owner = Types.TryCall("Read entity owner", function() return current:GetOwner() end)
            if success and Utils.IsValidObject(owner) then parent = owner end
        end

        if not parent and current.GetAttachParentActor then
            local success, parentActor = Types.TryCall("Read attached parent actor", function() return current:GetAttachParentActor() end)
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

    Types.TryCall("Disable actor collision", function()
        if entity.SetActorEnableCollision then
            entity:SetActorEnableCollision(false)
            disabled = true
            print("[PingouinMod] Collision disabled via SetActorEnableCollision.\n")
        end
    end)

    if not disabled then
        Types.TryCall("Disable component collision", function()
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