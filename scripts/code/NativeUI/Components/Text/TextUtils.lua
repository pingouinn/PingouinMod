--- TextUtils.lua provides utility functions for managing text components in Unreal Engine's NativeUI system. It includes methods for applying styles and setting text on widgets.
-- @author PingouinTheDev

local StyleHelper = require("code/NativeUI/Style/StyleUtils")

local TextUtils = {}

--- Finds the first valid text block exposed by a widget.
-- @param instance (UUserWidget) Widget containing a text block.
-- @return (UTextBlock|nil) Text block, or nil when unavailable.
local function ResolveTextBlock(instance)
    if Utils.IsValidObject(instance.TitleText) then
        return instance.TitleText
    end
    if Utils.IsValidObject(instance.CommonTextBlock) then
        return instance.CommonTextBlock
    end
    return nil
end

--- Applies a CommonUI text style to the first available text block on a widget.
-- @param instance (UUserWidget) Widget containing a text block.
-- @param stylePath (string|UObject) Style identifier, asset path, or style object.
function TextUtils.ApplyStyle(instance, stylePath)
    if not Utils.IsValidObject(instance) then return end
    local styleObject = StyleHelper.ResolveStyle("Text", stylePath)
    if not styleObject then return end

    local targetText = ResolveTextBlock(instance)
    if not targetText then return end
    Utils.TryCall("Apply text style", function()
        targetText.Style = styleObject
        if targetText.SetStyle then targetText:SetStyle(styleObject) end
    end)
end

--- Applies text to the first available text property on a widget.
-- @param instance (UUserWidget) Widget containing a text block.
-- @param text (FText) Unreal text value.
function TextUtils.SetText(instance, text)
    if not Utils.IsValidObject(instance) then return end
    Utils.TryCall("Set text property", function() instance.Text = text end)
    Utils.TryCall("Set widget text", function()
        if instance.SetText then instance:SetText(text) end
    end, not DEBUG_MODE) -- Ignore errors when the widget doesn't have a SetText function
    local targetText = ResolveTextBlock(instance)
    if targetText then
        Utils.TryCall("Set text block value", function() targetText:SetText(text) end)
    end
end

return TextUtils
