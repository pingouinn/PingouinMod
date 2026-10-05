local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")
local StyleHelper = require("code/NativeUI/Style/StyleUtils")

local SwitchComponent = {}
local SwitchClass = nil
local ActiveSwitches = {}
local HookInstalled = false

-- Retrieves the UClass for the switch widget.
-- @return (UClass|nil) The switch widget class.
local function GetClass()
    if not Utils.IsValidObject(SwitchClass) then
        SwitchClass = StaticFindObject(Config.Paths.switchClass)
    end
    return SwitchClass
end

-- Ensures that the switch click hook is installed to handle switch toggle events.
local function EnsureHook()
    if HookInstalled then return end
    HookInstalled = Core.RegisterButtonClickHandler(function(clickedWidget)
        if not clickedWidget.GetAddress then return end
        local switchObject = ActiveSwitches[tostring(clickedWidget:GetAddress())]
        if switchObject then switchObject:Toggle() end
    end)
end

--- Applies a switch style to the given widget instance.
-- @param instance (UUserWidget) Widget instance to style.
-- @param stylePath (string|UObject) Style identifier, asset path, or style object.
local function ApplySwitchStyle(instance, stylePath)
    local styleObj = StyleHelper.ResolveStyle("Switch", stylePath)
    if not styleObj then return end

    pcall(function()
        local targetButton = Utils.IsValidObject(instance.WBP_ButtonBase) and instance.WBP_ButtonBase or instance
        targetButton.Style = styleObj
        if targetButton.SetStyle then
            targetButton:SetStyle(styleObj)
        end
    end)
end

--- Creates a switch component.
-- @param initialState (boolean|nil) Initial checked state.
-- @param onToggle (function|nil) Callback invoked with the new state and wrapper.
-- @param stylePath (string|nil) Style identifier or asset path.
-- @return (table|nil) Switch wrapper, or nil when creation fails.
function SwitchComponent.Create(initialState, onToggle, stylePath)
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(instance) then return nil end

    instance:SetVisibility(0)
    EnsureHook()

    local switchObject = {
        Widget = instance,
        IsChecked = initialState or false,
        OnToggleCallback = onToggle
    }

    local targetButton = Utils.IsValidObject(instance.WBP_ButtonBase) and instance.WBP_ButtonBase or instance
    if targetButton.GetAddress then
        ActiveSwitches[tostring(targetButton:GetAddress())] = switchObject
    end

    --- Sets the checked state.
    -- @param state (boolean) New checked state.
    function switchObject:SetState(state)
        self.IsChecked = state and true or false
        pcall(function()
            if self.Widget.SetCheckedState then
                self.Widget:SetCheckedState(self.IsChecked)
            elseif self.Widget.SetIsChecked then
                self.Widget:SetIsChecked(self.IsChecked)
            end
        end)
    end

    --- Applies a switch style.
    -- @param stylePath (string|nil) Style identifier or asset path.
    function switchObject:SetStyle(stylePath)
        ApplySwitchStyle(self.Widget, stylePath)
    end

    --- Refreshes the native widget from the wrapper state.
    function switchObject:Refresh()
        self:SetState(self.IsChecked)
    end

    --- Toggles the checked state and invokes the callback.
    function switchObject:Toggle()
        self:SetState(not self.IsChecked)
        if self.OnToggleCallback then
            self.OnToggleCallback(self.IsChecked, self)
        end
    end

    switchObject:SetStyle(stylePath)
    switchObject:SetState(switchObject.IsChecked)

    return switchObject
end

--- Removes invalid widgets from the switch callback registry.
function SwitchComponent.GC()
    for address, switchObject in pairs(ActiveSwitches) do
        if not switchObject or not Utils.IsValidObject(switchObject.Widget) then
            ActiveSwitches[address] = nil
        end
    end
end

GCScheduler.RegisterGC(SwitchComponent.GC, 10.0, true)

return SwitchComponent