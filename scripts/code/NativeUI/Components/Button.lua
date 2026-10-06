--- Button.lua provides a wrapper for creating and managing button components in Unreal Engine's NativeUI system.
-- It includes methods for setting button text, applying styles, handling click events, and managing active button instances.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")
local StyleHelper = require("code/NativeUI/Style/StyleUtils")

local ButtonComponent = {}
local ButtonClass = nil
local ActiveButtons = {}
local HookInstalled = false

--- Retrieves the UClass for the button widget.
-- @return (UClass|nil) The button widget class.
local function GetClass()
    if not Utils.IsValidObject(ButtonClass) then
        ButtonClass = StaticFindObject(Constants.NativeUI.Paths.BUTTON_CLASS)
    end
    return ButtonClass
end

--- Ensures that the button click hook is installed to handle button click events.
local function EnsureHook()
    if HookInstalled then return end
    HookInstalled = Core.RegisterButtonClickHandler("button", function(clickedWidget)
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

    Utils.TryCall("Apply button style", function() instance:SetStyle(styleClass) end)

    local ok, cdo = Utils.TryCall("Read button style defaults", function()
        return styleClass:GetDefaultObject()
    end, not DEBUG_MODE)
    if not ok or not Utils.IsValidObject(cdo) then return end

    if cdo.NormalTextStyle and Utils.IsValidObject(instance.BTNText) then
        Utils.TryCall("Apply button text style", function()
            instance.BTNText.Style = cdo.NormalTextStyle
            if instance.BTNText.SetStyle then instance.BTNText:SetStyle(cdo.NormalTextStyle) end
        end)
    end

    if cdo.NormalBase and cdo.NormalBase.TintColor and instance.SetColorAndOpacity then
        Utils.TryCall("Apply button color", function()
            instance:SetColorAndOpacity(cdo.NormalBase.TintColor.SpecifiedColor)
        end)
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

    Utils.TryCall("Show button widget", function() instance:SetVisibility(Constants.NativeUI.Visibility.VISIBLE) end)
    instance.bIsFocusable = true
    EnsureHook()

    local buttonObject = {
        Widget = instance,
        Text = initialText or "Action",
        OnClickCallback = onClick,
        isEnabled = true
    }

    if instance.GetAddress then
        ActiveButtons[tostring(instance:GetAddress())] = buttonObject
    end

    --- Updates the button text.
    -- @param value (any) New button text.
    function buttonObject:SetText(value)
        self.Text = tostring(value or "")
        local ftext = Utils.ToFText(self.Text)

        Utils.TryCall("Set button text property", function() instance.Text = ftext end)
        Utils.TryCall("Set button text", function()
            if instance.SetText then instance:SetText(ftext) end
        end)
        Utils.TryCall("Set button label", function()
            if Utils.IsValidObject(instance.BTNText) then
                instance.BTNText:SetText(ftext)
            end
        end)
    end

    --- Retrieves the current text from the button.
    -- @return (string) Current button label.
    function buttonObject:GetText()
        if Utils.IsValidObject(self.Widget) then
            if Utils.IsValidObject(self.Widget.BTNText) and self.Widget.BTNText.GetText then
                return Utils.GetFTextString(self.Widget.BTNText:GetText())
            elseif self.Widget.GetText then
                return Utils.GetFTextString(self.Widget:GetText())
            end
        end
        return self.Text
    end

    --- Applies a button style preset.
    -- @param path (string|nil) Style identifier or asset path.
    function buttonObject:SetStyle(path)
        ApplyButtonStyle(self.Widget, path)
    end

    --- Simulates a programmatic click on the button.
    function buttonObject:Click()
        if self.OnClickCallback then
            self.OnClickCallback(self)
        end
    end

    --- Enables or disables the button interactivity.
    -- @param isEnabled (boolean) Whether the button should be interactive.
    function buttonObject:SetEnabled(isEnabled)
        self.isEnabled = isEnabled == true
        if Utils.IsValidObject(self.Widget) and self.Widget.SetIsEnabled then
            self.Widget:SetIsEnabled(self.isEnabled)
        end
    end

    --- Checks if the button is currently enabled.
    -- @return (boolean) True if enabled, false otherwise.
    function buttonObject:GetIsEnabled()
        return self.isEnabled == true
    end

    --- Sets the global tint color of the button widget.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }.
    function buttonObject:SetColor(color)
        if not Utils.IsValidObject(self.Widget) or not color then return end

        local linearColor = {
            R = color.R or 1.0,
            G = color.G or 1.0,
            B = color.B or 1.0,
            A = color.A or 1.0
        }

        if self.Widget.SetColorAndOpacity then
            Utils.TryCall("Button set color",function() self.Widget:SetColorAndOpacity(linearColor) end)
        end

        if self.Widget.NormalBase and self.Widget.NormalBase.TintColor then
            local tint = self.Widget.NormalBase.TintColor
            if tint.SpecifiedColor then
                tint.SpecifiedColor.R = linearColor.R
                tint.SpecifiedColor.G = linearColor.G
                tint.SpecifiedColor.B = linearColor.B
                tint.SpecifiedColor.A = linearColor.A
            end
            Utils.TryCall("Button set tint color",function() tint.ColorUseRule = 0 end)
        end
    end

    --- Sets the text color of the button label.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }.
    function buttonObject:SetTextColor(color)
        if not Utils.IsValidObject(self.Widget) or not color then return end

        local slateColor = {
            SpecifiedColor = color,
            ColorUseRule = 0 -- UseColor_Specified
        }

        if Utils.IsValidObject(self.Widget.BTNText) and self.Widget.BTNText.SetColorAndOpacity then
            self.Widget.BTNText:SetColorAndOpacity(slateColor)
        elseif self.Widget.SetForegroundColor then
            self.Widget:SetForegroundColor(slateColor)
        end
    end

    --- Sets the font size of the button label.
    -- @param size (number) Size in points.
    function buttonObject:SetFontSize(size)
        local s = tonumber(size)
        if not s or not Utils.IsValidObject(self.Widget) then return end

        if Utils.IsValidObject(self.Widget.BTNText) and self.Widget.BTNText.Font then
            self.Widget.BTNText.Font.Size = s
            if self.Widget.BTNText.SetFont then
                self.Widget.BTNText:SetFont(self.Widget.BTNText.Font)
            end
        end
    end

    --- Sets the font asset used by the button label.
    -- @param fontAssetPathOrObject (string|UObject) Path to the font asset or the UFont object itself.
    -- @param size (number|nil) Optional font size in points.
    function buttonObject:SetFont(fontAssetPathOrObject, size)
        if not Utils.IsValidObject(self.Widget) then return end

        local fontObj = fontAssetPathOrObject
        if type(fontAssetPathOrObject) == "string" then
            fontObj = StaticFindObject(fontAssetPathOrObject) or UObject.Load(fontAssetPathOrObject)
        end
        if not Utils.IsValidObject(fontObj) then return end

        if Utils.IsValidObject(self.Widget.BTNText) and self.Widget.BTNText.Font then
            self.Widget.BTNText.Font.FontObject = fontObj
            if size then
                self.Widget.BTNText.Font.Size = tonumber(size) or self.Widget.BTNText.Font.Size
            end
            if self.Widget.BTNText.SetFont then
                self.Widget.BTNText:SetFont(self.Widget.BTNText.Font)
            end
        end
    end

    --- Sets the tooltip text shown when hovering the button.
    -- @param tooltip (string) Tooltip text.
    function buttonObject:SetToolTipText(tooltip)
        if Utils.IsValidObject(self.Widget) and self.Widget.SetToolTipText then
            self.Widget:SetToolTipText(Utils.ToFText(tostring(tooltip or "")))
        end
    end

    --- Retrieves the current tooltip text of the button.
    -- @return (string) Current tooltip text.
    function buttonObject:GetToolTipText()
        if Utils.IsValidObject(self.Widget) and self.Widget.GetToolTipText then
            return Utils.GetFTextString(self.Widget:GetToolTipText())
        end
        return ""
    end

    --- Unsets the tooltip text, removing any tooltip from the button.
    function buttonObject:UnsetToolTipText()
        self:SetToolTipText("")
    end

    --- Sets the visibility of the button widget.
    -- @param visibility (number) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    -- @see NativeUIVisibilityConstants
    function buttonObject:SetVisibility(visibility)
        if Utils.IsValidObject(self.Widget) and self.Widget.SetVisibility then
            self.Widget:SetVisibility(visibility)
        end
    end

    --- Retrieves the current widget visibility.
    -- @return (number|nil) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    function buttonObject:GetVisibility()
        if not Utils.IsValidObject(self.Widget) or not self.Widget.GetVisibility then return nil end
        local ok, vis = Utils.TryCall("Button GetVisibility", function() return self.Widget:GetVisibility() end)
        if ok then return vis end
        return nil
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