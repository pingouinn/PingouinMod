--- Title.lua provides a wrapper for creating and managing title components in Unreal Engine's NativeUI system. It includes methods for setting title text, applying styles, and refreshing the native widget.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")
local TextUtils = require("code/NativeUI/Components/Text/TextUtils")

local TitleComponent = {}
local TitleClass = nil

--- Retrieves the UClass for the title widget.
-- @return (UClass|nil) The title widget class.
local function GetClass()
    if not Utils.IsValidObject(TitleClass) then
        TitleClass = StaticFindObject(Constants.NativeUI.Paths.TITLE_CLASS)
    end
    return TitleClass
end

--- Creates a title component.
-- @param initialText (string|nil) Initial title text.
-- @param stylePath (string|nil) Style identifier or asset path.
-- @return (table|nil) Title wrapper, or nil when creation fails.
function TitleComponent.Create(initialText, stylePath)
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(instance) then return nil end

    Utils.TryCall("Show title widget", function() instance:SetVisibility(Constants.NativeUI.Visibility.VISIBLE) end)

    local titleObject = {
        Widget = instance,
        Text = initialText or ""
    }

    --- Updates the title text.
    -- @param value (any) New title text.
    function titleObject:SetText(value)
        self.Text = tostring(value or "")
        TextUtils.SetText(instance, Utils.ToFText(self.Text))
    end

    --- Applies a title text style.
    -- @param stylePath (string|nil) Style identifier or asset path.
    function titleObject:SetStyle(stylePath)
        TextUtils.ApplyStyle(self.Widget, stylePath)
    end

    --- Refreshes the native widget from the wrapper state.
    function titleObject:Refresh()
        self:SetText(self.Text)
    end

    titleObject:SetStyle(stylePath)
    titleObject:SetText(titleObject.Text)

    return titleObject
end

return TitleComponent