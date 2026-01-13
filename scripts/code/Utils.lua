local Utils = {}

--- Utility functions for the Pingouin Mod
--- @param playerController (UPlayerController) The player controller to enable the cheat manager for
--- @return (boolean) True if the cheat manager is enabled or already present, false otherwise
function Utils.EnableCheatManager(playerController)

    if not playerController.CheatManager:IsValid() then
        local CheatManagerClass = playerController.CheatClass
        if not CheatManagerClass:IsValid() then
            print("[PingouinMod] Controller:CheatClass is nullptr, using default CheatClass instead\n")
            CheatManagerClass = StaticFindObject("/Script/Engine.CheatManager") --[[@as UClass]]
        end

        if not CheatManagerClass:IsValid() then
            print("[PingouinMod] Couldn't find default CheatClass, therefore, could not enable Cheat Manager\n")
            return false
        end

        local CreatedCheatManager = StaticConstructObject(CheatManagerClass, playerController)
        if CreatedCheatManager:IsValid() then
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
    if DebugCameraControllerCache:IsValid() then return DebugCameraControllerCache end
    for _, Controller in ipairs(FindAllOf("DebugCameraController") or {}) do
        if Controller:IsValid() and (Controller.IsPlayerController and Controller:IsPlayerController() or Controller:IsLocalPlayerController()) then
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
    if not KsmMath:IsValid() then print("[PingouinMod] KismetMathLibrary not valid\n") return Position end
    
    local AddValue = KsmMath:Multiply_VectorInt(KsmMath:GetForwardVector(Rotation), distance)
    local EndVector = KsmMath:Add_VectorVector(Position, AddValue)
    return EndVector
end


--- Computes the forward vector from pitch and yaw angles.
-- @param Rotation (table) A table with Pitch, Yaw, Roll fields
-- @return (table) A table representing the forward vector with X, Y, Z fields
function Utils.GetForwardVector(Rotation)
    local KsmMath = UEHelpers:GetKismetMathLibrary()
    if not KsmMath:IsValid() then print("[PingouinMod] KismetMathLibrary not valid\n") return {X=0, Y=0, Z=0} end
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