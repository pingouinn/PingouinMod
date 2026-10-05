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
elseif state.buttonClickHandlers[1] then
    state.buttonClickHandlers = {}
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

--- Registers a named callback for CommonUI button clicks.
-- @param handlerKey (string) Stable callback identifier used across reloads.
-- @param handler (function) Callback receiving the clicked widget.
-- @return (boolean) True when the handler was registered.
function Core.RegisterButtonClickHandler(handlerKey, handler)
    if type(handlerKey) ~= "string" or type(handler) ~= "function" then return false end
    state.buttonClickHandlers[handlerKey] = handler

    if not state.buttonClickHookInstalled and StaticFindObject(Config.Paths.buttonClickFunction) then
        RegisterHook(Config.Paths.buttonClickFunction, function(context)
            local clickedWidget = context:get()
            if not Utils.IsValidObject(clickedWidget) then return end
            for _, callback in pairs(state.buttonClickHandlers) do
                callback(clickedWidget)
            end
        end)
        state.buttonClickHookInstalled = true
    end
    return state.buttonClickHookInstalled
end

return Core