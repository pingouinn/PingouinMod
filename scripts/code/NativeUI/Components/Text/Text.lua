--- Text.lua provides a wrapper for creating and managing text components in Unreal Engine's NativeUI system.
-- It includes methods for setting text, applying styles, typography controls.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")
local TextUtils = require("code/NativeUI/Components/Text/TextUtils")

local TextComponent = {}
local TextClass = nil

--- Retrieves the UClass for the text widget.
-- @return (UClass|nil) The text widget class.
local function GetClass()
    if not Utils.IsValidObject(TextClass) then
        TextClass = StaticFindObject(Constants.NativeUI.Paths.TEXT_CLASS)
    end
    return TextClass
end

--- Retrieves the internal UTextBlock within the widget structure.
-- @param widget (UUserWidget)
-- @return (UTextBlock|nil)
local function GetInternalTextBlock(widget)
    if not Utils.IsValidObject(widget) then return nil end

    if Utils.IsValidObject(widget.TitleText) then return widget.TitleText end
    if Utils.IsValidObject(widget.CommonTextBlock) then return widget.CommonTextBlock end
    if Utils.IsValidObject(widget.TextBlock) then return widget.TextBlock end
    if Utils.IsValidObject(widget.Text) and type(widget.Text) == "userdata" then return widget.Text end
    if Utils.IsValidObject(widget.Label) then return widget.Label end

    return nil
end

--- Creates a text component with an optional decorative line.
-- @param initialText (string|nil) Initial text.
-- @param stylePath (string|nil) Style identifier or asset path.
-- @param showLine (boolean|nil) Whether to show the widget's decorative line.
-- @return (table|nil) Text wrapper, or nil when creation fails.
function TextComponent.Create(initialText, stylePath, showLine)
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(instance) then return nil end

    Utils.TryCall("Show text widget", function() instance:SetVisibility(0) end) -- 0 = Visible
    if Utils.IsValidObject(instance.IMG_Fade) then
        local lineVis = (showLine == true) and 0 or 1 -- 0 = Visible, 1 = Collapsed
        Utils.TryCall("Set text line visibility", function()
            instance.IMG_Fade:SetVisibility(lineVis)
        end)
    end

    local textObject = {
        Widget = instance,
        Text = initialText or ""
    }

    --- Updates the text value.
    -- @param value (any) New text value.
    function textObject:SetText(value)
        self.Text = tostring(value or "")
        local ftext = Utils.ToFText(self.Text)
        TextUtils.SetText(instance, ftext)
    end

    --- Retrieves the current text.
    -- @return (string)
    function textObject:GetText()
        local tb = GetInternalTextBlock(self.Widget)
        if Utils.IsValidObject(tb) and type(tb.GetText) == "function" then
            local ok, ftext = Utils.TryCall("Get text", function() return tb:GetText() end)
            if ok and ftext then
                return Utils.GetFTextString(ftext)
            end
        end
        return self.Text
    end

    --- Applies a preset text style.
    -- @param path (string|nil) Style identifier or asset path.
    function textObject:SetStyle(path)
        TextUtils.ApplyStyle(self.Widget, path)
    end

    --- Sets the color and opacity of the text.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }.
    function textObject:SetColor(color)
        if not Utils.IsValidObject(self.Widget) or not color then return end

        local linearColor = {
            R = color.R or 1.0,
            G = color.G or 1.0,
            B = color.B or 1.0,
            A = color.A or 1.0
        }

        local slateColor = {
            SpecifiedColor = linearColor,
            ColorUseRule = 0 -- UseColor_Specified
        }

        local tb = GetInternalTextBlock(self.Widget)

        if Utils.IsValidObject(tb) then
            if tb.SetColorAndOpacity then
                local ok = Utils.TryCall("Text Set text color", function() tb:SetColorAndOpacity(slateColor) end)
                if not ok then
                    Utils.TryCall("Text Set text color (fallback)", function() tb:SetColorAndOpacity(linearColor) end)
                end
            end
        else
            if self.Widget.SetColorAndOpacity then
                Utils.TryCall("Text color & opacity", function() self.Widget:SetColorAndOpacity(linearColor) end)
            end
        end
    end

    --- Sets the text font size.
    -- @param size (number) Size in points.
    function textObject:SetFontSize(size)
        local s = tonumber(size)
        if not s or not Utils.IsValidObject(self.Widget) then return end

        local tb = GetInternalTextBlock(self.Widget)
        if not Utils.IsValidObject(tb) then return end

        -- Detach the CommonUI style to unlock manual override
        Utils.TryCall("Detach CommonUI style", function() tb.Style = nil end)

        -- Native call to UFunction SetFontSize if available
        if tb.SetFontSize then
            local ok = Utils.TryCall("CommonTextBlock SetFontSize", function() tb:SetFontSize(s) end)
            if ok then return end
        end

        -- Slate fallback if direct UFunction call fails
        if tb.Font then
            local fontStruct = tb.Font
            fontStruct.Size = s
            tb.Font = fontStruct
        end

        if tb.InvalidateLayoutAndVolatility then
            Utils.TryCall("Text Size layout and volatility", function() tb:InvalidateLayoutAndVolatility() end)
        end
    end

    --- Changes the font asset and optionally its size.
    -- @param fontAssetPathOrObject (string|UObject) Font asset path or loaded object.
    -- @param size (number|nil) Optional size in points.
    function textObject:SetFont(fontAssetPathOrObject, size)
        if not Utils.IsValidObject(self.Widget) then return end

        local fontObj = fontAssetPathOrObject
        if type(fontAssetPathOrObject) == "string" then
            fontObj = StaticFindObject(fontAssetPathOrObject) or UObject.Load(fontAssetPathOrObject)
        end
        if not Utils.IsValidObject(fontObj) then return end

        local tb = GetInternalTextBlock(self.Widget)
        if not Utils.IsValidObject(tb) then return end

        -- Detach the CommonUI style to unlock manual override
        Utils.TryCall("SetFont Detach CommonUI style", function() tb.Style = nil end)

        -- Struct mutation 
        if tb.Font then
            local fontStruct = tb.Font
            fontStruct.FontObject = fontObj
            if size then
                fontStruct.Size = tonumber(size) or fontStruct.Size
            end

            -- if direct UFunction call is available, we pass the complete Slate Font struct
            if tb.SetFont then
                local ok = Utils.TryCall("CommonTextBlock SetFont", function() tb:SetFont(fontStruct) end)
                if not ok then
                    tb.Font = fontStruct
                end
            else
                tb.Font = fontStruct
            end
        end

        -- If we get provided a font size, we call the native SetFontSize function if available
        if size and tb.SetFontSize then
            Utils.TryCall("FontSize SetFont", function() tb:SetFontSize(tonumber(size)) end)
        end

        if tb.InvalidateLayoutAndVolatility then
            Utils.TryCall("SetFont LayoutAndVolatility", function() tb:InvalidateLayoutAndVolatility() end)
        end
    end

    --- Sets text justification 
    -- @param justification (number) NativeUI.Justification.LEFT, NativeUI.Justification.CENTER, or NativeUI.Justification.RIGHT
    -- @see NativeUIJustificationConstants
    function textObject:SetJustification(justification)
        local tb = GetInternalTextBlock(self.Widget)
        if Utils.IsValidObject(tb) and tb.SetJustification then
            Utils.TryCall("Text SetJustification", function()
                tb:SetJustification(tonumber(justification) or 0)
            end)
        end
    end

    --- Toggles automatic text wrapping.
    -- @param autoWrap (boolean)
    function textObject:SetAutoWrap(autoWrap)
        local tb = GetInternalTextBlock(self.Widget)
        if Utils.IsValidObject(tb) and tb.SetAutoWrapText then
            Utils.TryCall("Text SetAutoWrapText", function()
                tb:SetAutoWrapText(autoWrap == true)
            end)
        end
    end

    --- Sets the text shadow offset and color.
    -- @param offset (table) Vector2D table like { X = 1.0, Y = 1.0 }.
    -- @param color (table|nil) RGB(A) table like { R = 0.0, G = 0.0, B = 0.0, A = 0.8 }.
    function textObject:SetShadow(offset, color)
        local tb = GetInternalTextBlock(self.Widget)
        if not Utils.IsValidObject(tb) then return end

        -- Detach the CommonUI style to unlock manual override
        Utils.TryCall("Text Detach Style", function() tb.Style = nil end)

        if offset and tb.SetShadowOffset then
            local vec = {
                X = offset.X or offset[1] or 1.0,
                Y = offset.Y or offset[2] or 1.0
            }
            Utils.TryCall("Text SetShadowOffset", function() tb:SetShadowOffset(vec) end)
        end

        if color and tb.SetShadowColorAndOpacity then
            local linearColor = {
                R = color.R or 0.0,
                G = color.G or 0.0,
                B = color.B or 0.0,
                A = color.A or 1.0
            }
            Utils.TryCall("Text SetShadowColor", function() tb:SetShadowColorAndOpacity(linearColor) end)
        end
    end

    --- Toggles the decorative line visibility.
    -- @param visibilityType (number) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    -- @see NativeUIVisibilityConstants
    function textObject:SetLineVisible(visibilityType)
        if type(visibilityType) ~= "number" then return end
        if not Utils.IsValidObject(self.Widget.IMG_Fade) or not self.Widget.IMG_Fade.SetVisibility then return end

        local visEnum = tonumber(visibilityType) or 0

        Utils.TryCall("SetLineVisible", function()
            self.Widget.IMG_Fade:SetVisibility(visEnum)
        end)
    end

    --- Sets the decorative line tint color.
    -- @param color (table) RGB(A) table like { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }.
    function textObject:SetLineColor(color)
        if Utils.IsValidObject(self.Widget.IMG_Fade) and color then
            local linearColor = {
                R = color.R or 1.0,
                G = color.G or 1.0,
                B = color.B or 1.0,
                A = color.A or 1.0
            }
            if self.Widget.IMG_Fade.SetColorAndOpacity then
                self.Widget.IMG_Fade:SetColorAndOpacity(linearColor)
            elseif self.Widget.IMG_Fade.Brush and self.Widget.IMG_Fade.Brush.TintColor then
                self.Widget.IMG_Fade.Brush.TintColor = {
                    SpecifiedColor = linearColor,
                    ColorUseRule = 0
                }
            end
        end
    end

    --- Sets the overall widget visibility.
    -- @param visibilityType (number) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    -- @see NativeUIVisibilityConstants
    function textObject:SetVisibility(visibilityType)
        if type(visibilityType) ~= "number" then return end
        if not Utils.IsValidObject(self.Widget) or not self.Widget.SetVisibility then return end

        local visEnum = tonumber(visibilityType) or 0

        Utils.TryCall("Text SetVisibility", function()
            self.Widget:SetVisibility(visEnum)
        end)
    end

    --- Retrieves the current widget visibility.
    -- @return (number|nil) NativeUI.Visibility.VISIBLE, NativeUI.Visibility.COLLAPSED, or NativeUI.Visibility.HIDDEN
    function textObject:GetVisibility()
        if not Utils.IsValidObject(self.Widget) or not self.Widget.GetVisibility then return nil end
        local ok, vis = Utils.TryCall("Text GetVisibility", function() return self.Widget:GetVisibility() end)
        if ok then return vis end
        return nil
    end

    textObject:SetStyle(stylePath)
    textObject:SetText(textObject.Text)

    return textObject
end

return TextComponent