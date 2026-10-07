--- TextInput.lua provides a wrapper for creating and managing text input boxes in Unreal Engine's NativeUI system. It includes methods for setting and retrieving text, handling focus, customizing appearance, and managing callbacks for text changes and commit events.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")

local TextInputComponent = {}
local TextBoxClass = nil
local ActiveInputs = {}
local WatcherActive = false

--- Retrieves the native UClass for EditableTextBox.
-- @return (UClass|nil)
local function GetClass()
    if not Utils.IsValidObject(TextBoxClass) then
        TextBoxClass = StaticFindObject(Constants.NativeUI.Paths.TEXTBOX_CLASS)
    end
    return TextBoxClass
end

--- Starts the asynchronous value watcher loop if not already running.
local function EnsureWatcher()
    if WatcherActive then return end
    WatcherActive = true

    -- Same as Slider, but for text input boxes. We use a watcher loop to detect text changes because we couldn't find a reliable event hook for text change events.
    LoopAsync(100, function()
        local count = 0

        for address, inputObject in pairs(ActiveInputs) do
            if inputObject and Utils.IsValidObject(inputObject.Widget) then
                count = count + 1
                
                local widget = inputObject.Widget
                -- Check if the input box currently has keyboard focus and update the last focused input reference.
                if widget:HasKeyboardFocus() then
                    Core.LastFocusedInput = inputObject
                end

                local currentText = inputObject:GetText()
                if currentText ~= inputObject.LastText then
                    inputObject.LastText = currentText
                    inputObject.Text = currentText
                    if inputObject.OnChangeCallback then
                        inputObject.OnChangeCallback(currentText, inputObject)
                    end
                end
            else
                ActiveInputs[address] = nil
            end
        end

        if count == 0 then
            WatcherActive = false
            return true
        end

        return false
    end)
end

--- Updates the background color of a specific brush in the widget's style.
-- @param widget (UWidget) The native UMG widget.
-- @param brushName (string) The name of the brush property to update (e.g., "BackgroundImageNormal").
-- @param color (table) A table representing the color with fields R, G, B, A (values between 0.0 and 1.0).
local function UpdateStyleBrush(widget, brushName, color)
    if not Utils.IsValidObject(widget) or not widget.WidgetStyle or not color then return end

    local style = widget.WidgetStyle
    local brush = style[brushName]
    if not brush then return end

    brush.TintColor = {
        SpecifiedColor = color,
        ColorUseRule = 0 -- UseColor_Specified
    }

    widget.WidgetStyle = style

    if widget.InvalidateLayoutAndVolatility then
        Utils.TryCall("Invalidate Layout and Volatility InputText", function() widget:InvalidateLayoutAndVolatility() end)
    end
end

--- Creates a text input box component.
-- @param placeholder (string|nil) Hint text when empty.
-- @param initialText (string|nil) Default text inside the box.
-- @param onCommit (function|nil) Callback fn(text, commitMethod, inputObject) on Enter or focus lost.
-- @param onChange (function|nil) Callback fn(text, inputObject) on text change.
-- @param textColor (table|nil) Optional color table { R, G, B, A } for text color.
-- @return (table|nil) TextInput wrapper object.
function TextInputComponent.Create(placeholder, initialText, onCommit, onChange, textColor)
    Core.Init()
    local PC = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not PC or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = StaticConstructObject(widgetClass, PC)
    if not Utils.IsValidObject(instance) then return nil end

    Core.RegisterFocusableInput(instance)

    local initial = tostring(initialText or "")
    local hint = tostring(placeholder or "")

    Utils.TryCall("Configure text input defaults", function()
        instance:SetText(Utils.ToFText(initial))
        instance:SetHintText(Utils.ToFText(hint))

        local textColor = textColor or { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }

        -- 0 = ESlateColorStylingMode::UseColor_Specified
        local slateWhite = {
            SpecifiedColor = textColor,
            ColorUseRule = 0
        }

        -- NAtive UMG method for setting foreground color, but not always present. Fallback to direct property assignment.
        if instance.SetForegroundColor then
            instance:SetForegroundColor(slateWhite)
        else
            instance.ForegroundColor = slateWhite
        end

        if instance.WidgetStyle then
            local style = instance.WidgetStyle

            local darkGray = { R = 0.25, G = 0.25, B = 0.25, A = 1.0 }
            local hoverGray = { R = 0.35, G = 0.35, B = 0.35, A = 1.0 }
            local rescueYellow = { R = 1.0, G = 0.6172, B = 0.0123, A = 0.3 }

            if style.BackgroundImageNormal then
                style.BackgroundImageNormal.TintColor.SpecifiedColor = darkGray
            end
            if style.BackgroundImageHovered then
                style.BackgroundImageHovered.TintColor.SpecifiedColor = hoverGray
            end
            if style.BackgroundImageFocused then
                style.BackgroundImageFocused.TintColor.SpecifiedColor = rescueYellow
            end

            if style.TextStyle and style.TextStyle.ColorAndOpacity then
                style.TextStyle.ColorAndOpacity.SpecifiedColor = textColor
                style.TextStyle.ColorAndOpacity.ColorUseRule = 0
            end

            -- Using Afacad font
            local fontObj = StaticFindObject(Constants.NativeUI.Paths.FONT_AFACAD)
            if not fontObj then
                fontObj = UObject.Load(Constants.NativeUI.Paths.FONT_AFACAD)
            end

            if fontObj and style.TextStyle and style.TextStyle.Font then
                style.TextStyle.Font.FontObject = fontObj
                style.TextStyle.Font.Size = 15.0
            end
        end
    end, not DEBUG_MODE)

    local inputObject = {
        Widget = instance,
        Text = initial,
        LastText = initial,
        HintText = hint,
        OnCommitCallback = onCommit,
        OnChangeCallback = onChange,
    }

    if instance.GetAddress then
        ActiveInputs[tostring(instance:GetAddress())] = inputObject
    end

    EnsureWatcher()

    --- Sets the text inside the input box and updates the internal state.
    -- @param newText (string) The new text to set in the input box.
    function inputObject:SetText(newText)
        self.Text = tostring(newText or "")
        self.LastText = self.Text
        if Utils.IsValidObject(self.Widget) and self.Widget.SetText then
            self.Widget:SetText(Utils.ToFText(self.Text))
        end
    end

    --- Retrieves the current text from the input box, updating the internal state if necessary.
    -- @return (string) The current text in the input box.
    function inputObject:GetText()
        if Utils.IsValidObject(self.Widget) and self.Widget.GetText then
            local ftext = self.Widget:GetText()
            self.Text = Utils.GetFTextString(ftext)
        end
        return self.Text
    end

    --- Clears the text input box.
    function inputObject:Clear()
        self:SetText("")
    end

    --- Sets the hint text for the input box.
    -- @param newHint (string) The new hint text to display when the input is empty.
    function inputObject:SetHintText(newHint)
        self.HintText = tostring(newHint or "")
        if Utils.IsValidObject(self.Widget) and self.Widget.SetHintText then
            self.Widget:SetHintText(Utils.ToFText(self.HintText))
        end
    end

    --- Sets the background color of the input box when not hovered or focused.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }
    function inputObject:SetBackgroundColorNormal(color)
        UpdateStyleBrush(self.Widget, "BackgroundImageNormal", color)
    end

    --- Sets the background color of the input box when hovered.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }
    function inputObject:SetBackgroundColorHovered(color)
        UpdateStyleBrush(self.Widget, "BackgroundImageHovered", color)
    end

    --- Sets the background color of the input box when it is focused.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }
    function inputObject:SetBackgroundColorFocused(color)
        UpdateStyleBrush(self.Widget, "BackgroundImageFocused", color)
    end

    --- Sets the text color inside the input box. 
    -- WARNING : Slate does not expose a direct method to refresh the text color, so this method will not do anything unless you're lucky and slate decides to reinstanciate or interrogate the widget. 
    -- This is a known limitation of Unreal Engine's UMG system, use color in the constructor instead.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }
    function inputObject:SetTextColor(color)
        if not Utils.IsValidObject(self.Widget) or not color then return end

        self.TextColor = color

        if self.Widget.WidgetStyle and self.Widget.WidgetStyle.TextStyle then
            local textStyle = self.Widget.WidgetStyle.TextStyle
            if textStyle.ColorAndOpacity then
                textStyle.ColorAndOpacity.SpecifiedColor = color
                textStyle.ColorAndOpacity.ColorUseRule = 0
            end
            self.Widget.WidgetStyle = self.Widget.WidgetStyle
        end
    end

    --- Changes the font asset used by the input box.
    -- @param fontAssetPathOrObject (string|UObject) Path to the font asset or the UFont object itself.
    -- @param size (number|nil) Optional size to apply alongside the font.
    function inputObject:SetFont(fontAssetPathOrObject, size)
        if not Utils.IsValidObject(self.Widget) then return end

        local fontObj = fontAssetPathOrObject
        if type(fontAssetPathOrObject) == "string" then
            fontObj = StaticFindObject(fontAssetPathOrObject) or UObject.Load(fontAssetPathOrObject)
        end

        if not Utils.IsValidObject(fontObj) then return end

        local fontStruct = self.Widget.WidgetStyle and self.Widget.WidgetStyle.TextStyle and self.Widget.WidgetStyle.TextStyle.Font
        if fontStruct then
            fontStruct.FontObject = fontObj
            if size then
                fontStruct.Size = tonumber(size) or fontStruct.Size
            end
        end
    end

    --- Sets the text font size.
    -- @param size (number) Size in points (e.g. 14.0, 16.0)
    function inputObject:SetFontSize(size)
        local s = tonumber(size)
        if not s or not Utils.IsValidObject(self.Widget) then return end

        if self.Widget.WidgetStyle and self.Widget.WidgetStyle.TextStyle and self.Widget.WidgetStyle.TextStyle.Font then
            self.Widget.WidgetStyle.TextStyle.Font.Size = s
        end
    end

    --- Sets the input box to an error state, changing its background colors to indicate an error.
    -- @param isError (boolean) Whether to enable or disable the error state.
    function inputObject:SetErrorState(isError)
        if isError then
            if not self.savedColors and Utils.IsValidObject(self.Widget) and self.Widget.WidgetStyle then
                local style = self.Widget.WidgetStyle
                self.savedColors = {
                    normal = style.BackgroundImageNormal and style.BackgroundImageNormal.TintColor.SpecifiedColor,
                    focused = style.BackgroundImageFocused and style.BackgroundImageFocused.TintColor.SpecifiedColor
                }
            end
            self:SetBackgroundColorNormal({ R = 0.5, G = 0.05, B = 0.05, A = 1.0 })
            self:SetBackgroundColorFocused({ R = 0.8, G = 0.1, B = 0.1, A = 1.0 })
        else
            if self.savedColors then
                if self.savedColors.normal then self:SetBackgroundColorNormal(self.savedColors.normal) end
                if self.savedColors.focused then self:SetBackgroundColorFocused(self.savedColors.focused) end
                self.savedColors = nil
            else 
                self:SetBackgroundColorNormal({ R = 0.25, G = 0.25, B = 0.25, A = 1.0 })
                self:SetBackgroundColorFocused({ R = 1.0, G = 0.6172, B = 0.0123, A = 0.3 })
            end
        end
    end

    --- Sets whether the input box is read-only, preventing user edits.
    -- @param isReadOnly (boolean) Whether to make the input box read-only.
    function inputObject:SetReadOnly(isReadOnly)
        if Utils.IsValidObject(self.Widget) and self.Widget.SetIsReadOnly then
            self.Widget:SetIsReadOnly(isReadOnly == true)
            self.isReadOnly = isReadOnly == true
        end
    end

    --- Checks if the input box is currently read-only.
    -- @return (boolean) True if the input box is read-only, false otherwise.
    function inputObject:GetIsReadOnly()
        return self.isReadOnly == true
    end

    --- Toggles password masking mode.
    -- @param isPassword (boolean)
    function inputObject:SetIsPassword(isPassword)
        if Utils.IsValidObject(self.Widget) and self.Widget.SetIsPassword then
            self.Widget:SetIsPassword(isPassword == true)
            self.isPassword = isPassword == true
        end
    end

    --- Checks if the input box is currently in password mode.
    -- @return (boolean) True if the input box is in password mode, false otherwise.
    function inputObject:GetIsPassword()
        return self.isPassword == true
    end

    --- Sets the visibility of the input box widget.
    -- @param visibility (number) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    -- @see NativeUIVisibilityConstants
    function inputObject:SetVisibility(visibility)
        if Utils.IsValidObject(self.Widget) and self.Widget.SetVisibility then
            self.Widget:SetVisibility(visibility)
        end
    end

    --- Retrieves the current widget visibility.
    -- @return (number|nil) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    -- @see NativeUIVisibilityConstants
    function inputObject:GetVisibility()
        if not Utils.IsValidObject(self.Widget) or not self.Widget.GetVisibility then return nil end
        local ok, vis = Utils.TryCall("TextInput GetVisibility", function() return self.Widget:GetVisibility() end)
        if ok then return vis end
        return nil
    end

    --- Set keyboard focus to this input box, allowing the user to type into it.
    function inputObject:SetKeyboardFocus()
        if Utils.IsValidObject(self.Widget) and self.Widget.SetKeyboardFocus then
            self.Widget:SetKeyboardFocus()
            Core.LastFocusedInput = self
        end
    end

    --- Checks if this input box currently has keyboard focus.
    -- @return (boolean) True if the input box has focus, false otherwise.
    function inputObject:HasFocus()
        if not Utils.IsValidObject(self.Widget) then return false end
        return self.Widget.HasKeyboardFocus and self.Widget:HasKeyboardFocus() or false
    end

    return inputObject
end

--- Removes invalid widgets from the callback registry.
function TextInputComponent.GC()
    for address, inputObject in pairs(ActiveInputs) do
        if not inputObject or not Utils.IsValidObject(inputObject.Widget) then
            Core.UnregisterFocusableInput(inputObject and inputObject.Widget)
            ActiveInputs[address] = nil
        end
    end
end

GCScheduler.RegisterGC(TextInputComponent.GC, 10.0, true)

return TextInputComponent