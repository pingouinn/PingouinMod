local Types = require("code/utils/Types")
local Player = {}

local DebugCameraControllerCache = CreateInvalidObject()

--- Checks whether a controller belongs to the debug camera system.
-- @param controller (UPlayerController) The controller to inspect
-- @return (boolean) True when the controller is a debug camera controller
local function IsDebugCameraController(controller)
    if not Types.IsValidObject(controller) then return false end
    local success, fullName = Types.TryCall("Read controller full name", function() return controller:GetFullName() end)
    return success and string.find(fullName, "DebugCameraController", 1, true) ~= nil
end

--- Resets the cached Debug Camera Controller, forcing a re-evaluation on the next retrieval.
function Player.ResetDebugCameraControllerCache()
    DebugCameraControllerCache = CreateInvalidObject()
end

--- Gets the Debug Camera Controller for the local player, caching it for future calls.
-- @return (UPlayerController) The Debug Camera Controller object
function Player.GetDebugCameraController()
    if Types.IsValidObject(DebugCameraControllerCache) then return DebugCameraControllerCache end
    for _, Controller in ipairs(FindAllOf("DebugCameraController") or {}) do
        if Types.IsValidObject(Controller) and (Controller.IsPlayerController and Controller:IsPlayerController() or Controller:IsLocalPlayerController()) then
            DebugCameraControllerCache = Controller
            return DebugCameraControllerCache
        end
    end
    return UEHelpers:GetPlayerController()
end

--- Enables the cheat manager for a given player controller, constructing it if necessary.
--- @param playerController (UPlayerController) The player controller to enable the cheat manager for
--- @return (boolean) True if the cheat manager is enabled or already present, false otherwise
function Player.EnableCheatManager(playerController)
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

--- Retrieves the local player controller, ensuring it is valid and not a debug camera controller.
-- @return (UPlayerController|nil) The local player controller, or nil if not found
function Player.GetPlayerController()
    local success, currentController = Types.TryCall("Get player controller", function() return UEHelpers:GetPlayerController() end)
    if success and Types.IsValidObject(currentController) and not IsDebugCameraController(currentController) then return currentController end
    for _, controller in ipairs(FindAllOf("PlayerController") or {}) do
        local isLocalSuccess, isLocal = Types.TryCall("Check local player controller", function() return controller:IsLocalPlayerController() end)
        if Types.IsValidObject(controller) and not IsDebugCameraController(controller)
            and isLocalSuccess and isLocal and Types.IsValidObject(controller.Pawn) then return controller end
    end
    return nil
end

--- Gets the local player pawn, ensuring it is valid.
-- @return (APawn|nil) The local player pawn, or nil if not found
function Player.GetPlayer()
    local success, player = Types.TryCall("Get player pawn", function() return UEHelpers:GetPlayer() end)
    if success and Types.IsValidObject(player) then return player end
    local playerController = Player.GetPlayerController()
    if playerController then return playerController.Pawn end
    return nil
end


return Player