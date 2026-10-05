local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")
local TextUtils = require("code/NativeUI/Components/Text/TextUtils")

local TextComponent = {}
local TextClass = nil

--- Retrieves the UClass for the text widget.
-- @return (UClass|nil) The text widget class.
local function GetClass()
    if not Utils.IsValidObject(TextClass) then
        TextClass = StaticFindObject(Config.Paths.textClass)
    end
    return TextClass
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

    Utils.TryCall("Show text widget", function() instance:SetVisibility(Config.Visibility.VISIBLE) end)
    Utils.TryCall("Set text line visibility", function()
        if Utils.IsValidObject(instance.IMG_Fade) then
            instance.IMG_Fade:SetVisibility(showLine and Config.Visibility.VISIBLE or Config.Visibility.HIDDEN)
        end
    end)

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

    --- Applies a text style.
    -- @param stylePath (string|nil) Style identifier or asset path.
    function textObject:SetStyle(stylePath)
        TextUtils.ApplyStyle(self.Widget, stylePath)
    end

    --- Refreshes the native widget from the wrapper state.
    function textObject:Refresh()
        self:SetText(self.Text)
    end

    textObject:SetStyle(stylePath)
    textObject:SetText(textObject.Text)

    return textObject
end

return TextComponent