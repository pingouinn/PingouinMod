--- Core.lua is a module that provides core functionality for the NativeUI system in Unreal Engine. It manages the initialization of required libraries, registration of button click handlers, and handling of focusable input widgets. The module maintains global state to ensure consistent behavior across reloads and provides utility functions for committing focused inputs and checking input focus status.
-- @author PingouinTheDev

local Core = {}
local Constants = require("code/Constants")

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
Core.FocusableInputs = {}
Core.LastFocusedInput = nil

--- Initializes the cached Unreal UI libraries used by NativeUI.
-- @return (boolean) True when both required libraries are available.
function Core.Init()
    if not Utils.IsValidObject(state.umgLib) then
        state.umgLib = StaticFindObject(Constants.NativeUI.Paths.WIDGET_LIBRARY)
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

    if not state.buttonClickHookInstalled and StaticFindObject(Constants.NativeUI.Paths.BUTTON_CLICK_FUNCTION) then
        RegisterHook(Constants.NativeUI.Paths.BUTTON_CLICK_FUNCTION, function(context)
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

--- Registers an input widget that consumes keyboard focus.
-- @param widget (UWidget) The native Slate/UMG widget.
function Core.RegisterFocusableInput(widget)
    if not Utils.IsValidObject(widget) or not widget.GetAddress then return end
    Core.FocusableInputs[tostring(widget:GetAddress())] = widget
end

--- Unregisters an input widget when destroyed.
-- @param widget (UWidget)
function Core.UnregisterFocusableInput(widget)
    if not widget or not widget.GetAddress then return end
    Core.FocusableInputs[tostring(widget:GetAddress())] = nil
end

--- Checks if any registered text/editable input currently has keyboard focus.
-- @return (boolean)
function Core.IsAnyInputFocused()
    for address, widget in pairs(Core.FocusableInputs) do
        if Utils.IsValidObject(widget) then
            if widget:HasKeyboardFocus() then
                return true
            end
        else
            Core.FocusableInputs[address] = nil
        end
    end
    return false
end

--- Commits the currently focused text input, if any.
function Core.CommitFocusedInput()
    for _, inputObject in pairs(Core.FocusableInputs) do
        if Utils.IsValidObject(inputObject.Widget) and inputObject.Widget:HasKeyboardFocus() then
            -- Commit the text input and invoke the OnCommit callback
            local text = inputObject:GetText()
            inputObject.Text = text

            if inputObject.OnCommitCallback then
                inputObject.OnCommitCallback(text, "OnEnter", inputObject)
            end
            return true
        end
    end

    if Core.LastFocusedInput and Utils.IsValidObject(Core.LastFocusedInput.Widget) then
        local target = Core.LastFocusedInput
        local text = target:GetText()
        target.Text = text
        if target.OnCommitCallback then
            target.OnCommitCallback(text, "OnEnter", target)
        end
        Core.LastFocusedInput = nil
        return true
    end

    return false
end

RegisterKeyBind(Key.RETURN, function()
    if Core.IsAnyInputFocused() then
        Core.CommitFocusedInput()
    end
end)

return Core