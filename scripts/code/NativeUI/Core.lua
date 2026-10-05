local Core = {}
local Config = require("code/NativeUI/Config")

-- Global state for the NativeUI core
local state = rawget(_G, "__PingouinNativeUICoreState")
if not state then
    state = {
        umgLib = nil,
        buttonClickHandlers = {},
        buttonClickHookInstalled = false
    }
    rawset(_G, "__PingouinNativeUICoreState", state)
end

Core.UMG_Lib = nil

--- Initializes the cached Unreal UI libraries used by NativeUI.
-- @return (boolean) True when both required libraries are available.
function Core.Init()
    if not Utils.IsValidObject(state.umgLib) then
        state.umgLib = StaticFindObject(Config.Paths.widgetLibrary)
    end
    Core.UMG_Lib = state.umgLib
    return Utils.IsValidObject(Core.UMG_Lib)
end

--- Registers a callback for CommonUI button clicks and installs the native hook once.
-- @param handler (function) Callback receiving the clicked widget.
-- @return (boolean) True when the handler was registered.
function Core.RegisterButtonClickHandler(handler)
    if type(handler) ~= "function" then return false end
    for _, registeredHandler in ipairs(state.buttonClickHandlers) do
        if registeredHandler == handler then return true end
    end
    table.insert(state.buttonClickHandlers, handler)

    if not state.buttonClickHookInstalled and StaticFindObject(Config.Paths.buttonClickFunction) then
        RegisterHook(Config.Paths.buttonClickFunction, function(context)
            local clickedWidget = context:get()
            if not Utils.IsValidObject(clickedWidget) then return end
            for _, callback in ipairs(state.buttonClickHandlers) do
                callback(clickedWidget)
            end
        end)
        state.buttonClickHookInstalled = true
    end
    return state.buttonClickHookInstalled
end

-- Debug console command to list all active UserWidget classes in memory
RegisterConsoleCommandHandler("ScrapWidgets", function(fullCommand, args, _)
    print("[PingouinMod] Searching memory loaded widgets...\n")
    local widgets = FindAllOf("UserWidget")
    if widgets then
        local seen = {}
        for _, w in ipairs(widgets) do
            local className = Utils.GetObjectName(w:GetClass())
            if className and not seen[className] then
                seen[className] = true
                print("Found class: " .. className .. "\n")
            end
        end
    else
        print("No active UserWidget found.\n")
    end
    print("[PingouinMod] End of search.\n")
    return false
end)

return Core