local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")
local StyleHelper = require("code/NativeUI/Style/StyleUtils")

local ButtonComponent = {}
local ButtonClass = nil
local ActiveButtons = {}
local HookInstalled = false

-- Retrieves the UClass for the button widget.
-- @return (UClass|nil) The button widget class.
local function GetClass()
    if not Utils.IsValidObject(ButtonClass) then
        ButtonClass = StaticFindObject(Config.Paths.buttonClass)
    end
    return ButtonClass
end

-- Ensures that the button click hook is installed to handle button click events.
local function EnsureHook()
    if HookInstalled then return end
    HookInstalled = Core.RegisterButtonClickHandler(function(clickedWidget)
        if not clickedWidget.GetAddress then return end
        local buttonObject = ActiveButtons[tostring(clickedWidget:GetAddress())]
        if buttonObject and buttonObject.OnClickCallback then
            buttonObject.OnClickCallback(buttonObject)
        end
    end)
end

--- Applies a button style to the given widget instance.
-- @param instance (UUserWidget) Widget instance to style.
-- @param stylePath (string|UObject) Style identifier, asset path, or style object.
local function ApplyButtonStyle(instance, stylePath)
    local styleClass = StyleHelper.ResolveStyle("Button", stylePath)
    if not styleClass then return end

    pcall(function() instance:SetStyle(styleClass) end)

    local ok, cdo = pcall(function() return styleClass:GetDefaultObject() end)
    if not ok or not Utils.IsValidObject(cdo) then return end

    if cdo.NormalTextStyle and Utils.IsValidObject(instance.BTNText) then
        pcall(function()
            instance.BTNText.Style = cdo.NormalTextStyle
            if instance.BTNText.SetStyle then instance.BTNText:SetStyle(cdo.NormalTextStyle) end
        end)
    end

    if cdo.NormalBase and cdo.NormalBase.TintColor and instance.SetColorAndOpacity then
        pcall(function() instance:SetColorAndOpacity(cdo.NormalBase.TintColor.SpecifiedColor) end)
    end
end

--- Creates a styled button component.
-- @param initialText (string|nil) Initial button text.
-- @param onClick (function|nil) Callback invoked with the button wrapper.
-- @param stylePath (string|nil) Style identifier or asset path.
-- @return (table|nil) Button wrapper, or nil when creation fails.
function ButtonComponent.Create(initialText, onClick, stylePath)
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(instance) then return nil end

    instance:SetVisibility(0)
    instance.bIsFocusable = true
    EnsureHook()

    local buttonObject = {
        Widget = instance,
        Text = initialText or "Action",
        OnClickCallback = onClick
    }

    if instance.GetAddress then
        ActiveButtons[tostring(instance:GetAddress())] = buttonObject
    end

    --- Updates the button text.
    -- @param value (any) New button text.
    function buttonObject:SetText(value)
        self.Text = tostring(value or "")
        local ftext = Utils.ToFText(self.Text)

        pcall(function() instance.Text = ftext end)
        pcall(function()
            if instance.SetText then instance:SetText(ftext) end
        end)
        pcall(function()
            if Utils.IsValidObject(instance.BTNText) then
                instance.BTNText:SetText(ftext)
            end
        end)
    end

    --- Applies a button style.
    -- @param stylePath (string|nil) Style identifier or asset path.
    function buttonObject:SetStyle(stylePath)
        ApplyButtonStyle(self.Widget, stylePath)
    end

    --- Refreshes the native widget from the wrapper state.
    function buttonObject:Refresh()
        self:SetText(self.Text)
    end

    buttonObject:SetStyle(stylePath)
    buttonObject:SetText(buttonObject.Text)

    return buttonObject
end

--- Removes invalid widgets from the button callback registry.
function ButtonComponent.GC()
    for address, buttonObject in pairs(ActiveButtons) do
        if not buttonObject or not Utils.IsValidObject(buttonObject.Widget) then
            ActiveButtons[address] = nil
        end
    end
end

GCScheduler.RegisterGC(ButtonComponent.GC, 10.0, true)

return ButtonComponent