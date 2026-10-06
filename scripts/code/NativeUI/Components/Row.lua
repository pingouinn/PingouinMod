--- Row.lua provides a wrapper for creating and managing horizontal row containers in Unreal Engine's NativeUI system. It includes methods for adding widgets to the row, applying size constraints, and refreshing child components.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")

local Row = {}
Row.__index = Row

local horizontalBoxClass = nil
local sizeBoxClass = nil

--- Resolves and caches the native horizontal box class.
-- @return (UClass|nil) The horizontal box class.
local function GetClass()
    if not Utils.IsValidObject(horizontalBoxClass) then
        horizontalBoxClass = StaticFindObject(Constants.NativeUI.Paths.HORIZONTAL_BOX_CLASS)
    end
    return horizontalBoxClass
end

--- Resolves and caches the native size box class.
-- @return (UClass|nil) The size box class.
local function GetSizeBoxClass()
    if not Utils.IsValidObject(sizeBoxClass) then
        sizeBoxClass = StaticFindObject(Constants.NativeUI.Paths.SIZE_BOX_CLASS)
    end
    return sizeBoxClass
end

--- Wraps a widget in a size box when width or height constraints are provided.
-- @param rawWidget (UWidget) Widget to wrap.
-- @param width (number|nil) Optional width constraint.
-- @param height (number|nil) Optional height constraint.
-- @param outer (UObject|nil) Memory owner for the size box.
-- @return (UWidget) Original or wrapped widget.
local function WrapInSizeBox(rawWidget, width, height, outer)
    if not width and not height then return rawWidget end

    local widgetClass = GetSizeBoxClass()
    if not Utils.IsValidObject(widgetClass) then return rawWidget end

    local sizeBox
    Utils.TryCall("Create row size box", function()
        sizeBox = Utils.ConstructObject(widgetClass, outer or rawWidget)
    end)
    if not Utils.IsValidObject(sizeBox) then return rawWidget end

    Utils.TryCall("Configure row size box", function()
        if width then
            sizeBox.bOverride_WidthOverride = true
            sizeBox.WidthOverride = width
        end
        if height then
            sizeBox.bOverride_HeightOverride = true
            sizeBox.HeightOverride = height
        end
        sizeBox:AddChild(rawWidget)
    end)
    return sizeBox
end

--- Creates a horizontal row container.
-- @param parentWidget (UWidget|table|nil) Optional parent used as the memory owner.
-- @return (table|nil) Row wrapper, or nil when creation fails.
function Row.Create(parentWidget)
    Core.Init()
    local widgetClass = GetClass()
    if not Utils.IsValidObject(widgetClass) then return nil end

    local outer = parentWidget
    if type(outer) == "table" then outer = outer.Widget end
    if not Utils.IsValidObject(outer) then
        outer = Utils.GetPlayerController()
    end

    local instance = Utils.ConstructObject(widgetClass, outer)
    if not Utils.IsValidObject(instance) then
        print("[NativeUI Error] Failed to construct the horizontal row widget.")
        return nil
    end

    return setmetatable({Widget = instance, Children = {}}, Row)
end

--- Adds a widget to the row.
-- @param widgetItem (table|UWidget) Component wrapper or widget to add.
-- @param fillRatio (number|nil) Fill ratio; zero or nil uses automatic sizing.
-- @param padding (table|nil) Optional Slate padding.
-- @param verticalAlignment (number|nil) Vertical alignment enum.
-- @param constraints (table|nil) Optional width and height constraints.
-- @return (FHorizontalBoxSlot|nil) Created slot, or nil when adding fails.
function Row:Add(widgetItem, fillRatio, padding, verticalAlignment, constraints)
    if not widgetItem then return nil end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return nil end

    if constraints then
        rawWidget = WrapInSizeBox(rawWidget, constraints.width, constraints.height, self.Widget)
    end

    local success, slot = Utils.TryCall("Add widget to row", function()
        return self.Widget:AddChildToHorizontalBox(rawWidget)
    end)
    if not success or not slot then return nil end

    Utils.TryCall("Configure row slot", function()
        local isFill = fillRatio and fillRatio > 0
        slot:SetSize({Value = isFill and fillRatio or 1.0, SizeRule = isFill and Constants.NativeUI.Layout.SIZE_FILL or Constants.NativeUI.Layout.SIZE_AUTO})
        if padding then slot:SetPadding(padding) end
        slot:SetVerticalAlignment(verticalAlignment or Constants.NativeUI.Layout.VERTICAL_CENTER)
    end)
    table.insert(self.Children, widgetItem)
    return slot
end

--- Refreshes all child components in the row.
function Row:Refresh()
    for _, child in ipairs(self.Children) do
        if child.Refresh then child:Refresh() end
    end
end

return Row
