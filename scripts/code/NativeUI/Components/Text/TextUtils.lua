local StyleHelper = require("code/NativeUI/Style/StyleUtils")

local TextUtils = {}

--- Applies a CommonUI text style to the first available text block on a widget.
-- @param instance (UUserWidget) Widget containing a text block.
-- @param stylePath (string|UObject) Style identifier, asset path, or style object.
function TextUtils.ApplyStyle(instance, stylePath)
    local styleObject = StyleHelper.ResolveStyle("Text", stylePath)
    if not styleObject then return end

    pcall(function()
        local targetText = instance.TitleText
        if not Utils.IsValidObject(targetText) then
            targetText = instance.CommonTextBlock
        end
        if Utils.IsValidObject(targetText) then
            targetText.Style = styleObject
            if targetText.SetStyle then targetText:SetStyle(styleObject) end
        end
    end)
end

--- Applies text to the first available text property on a widget.
-- @param instance (UUserWidget) Widget containing a text block.
-- @param text (FText) Unreal text value.
function TextUtils.SetText(instance, text)
    pcall(function() instance.Text = text end)
    pcall(function()
        if instance.SetText then instance:SetText(text) end
    end)
    pcall(function()
        local targetText = instance.TitleText
        if not Utils.IsValidObject(targetText) then
            targetText = instance.CommonTextBlock
        end
        if Utils.IsValidObject(targetText) then targetText:SetText(text) end
    end)
end

return TextUtils
