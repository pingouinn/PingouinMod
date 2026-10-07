--- Row.lua provides a wrapper for creating and managing horizontal row containers in Unreal Engine's NativeUI system.
-- It includes methods for adding, removing, sizing, and clearing child components, as well as visibility and interaction controls.
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

    return setmetatable({
        Widget = instance,
        Children = {},
        isEnabled = true
    }, Row)
end

--- Adds a widget to the horizontal row.
-- @param widgetItem (table|UWidget) Component wrapper or raw widget to add.
-- @param fillRatio (number|nil) Fill ratio; zero or nil uses automatic sizing.
-- @param padding (table|nil) Optional Slate padding table {Left = 0, Top = 0, Right = 0, Bottom = 0}.
-- @param verticalAlignment (number|nil) Optional vertical alignment enum value.
-- @param constraints (table|nil) Optional width and height constraints like {width = 120, height = 40}.
-- @see NativeUILayoutConstants
-- @return (UHorizontalBoxSlot|nil) Created slot, or nil when adding fails.
function Row:Add(widgetItem, fillRatio, padding, verticalAlignment, constraints)
    if not widgetItem or not Utils.IsValidObject(self.Widget) then return nil end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return nil end

    local widgetToAdd = rawWidget
    local sizeBoxWrapper = nil

    if constraints then
        sizeBoxWrapper = WrapInSizeBox(rawWidget, constraints.width, constraints.height, self.Widget)
        widgetToAdd = sizeBoxWrapper
    end

    local success, slot = Utils.TryCall("Add widget to row", function()
        return self.Widget:AddChildToHorizontalBox(widgetToAdd)
    end)
    if not success or not slot then return nil end

    Utils.TryCall("Configure row slot", function()
        local isFill = fillRatio and fillRatio > 0
        slot:SetSize({
            Value = isFill and fillRatio or 1.0,
            SizeRule = isFill and Constants.NativeUI.Layout.SIZE_FILL or Constants.NativeUI.Layout.SIZE_AUTO
        })
        if padding then slot:SetPadding(padding) end
        slot:SetVerticalAlignment(verticalAlignment or Constants.NativeUI.Layout.VERTICAL_CENTER)
    end)

    table.insert(self.Children, {
        Item = widgetItem,
        RawWidget = rawWidget,
        Wrapper = sizeBoxWrapper
    })
    return slot
end

--- Removes a child widget from the row container.
-- @param widgetItem (table|UWidget) Component wrapper or raw widget to remove.
-- @return (boolean) True if removed successfully, false otherwise.
function Row:RemoveChild(widgetItem)
    if not widgetItem or not Utils.IsValidObject(self.Widget) then return false end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return false end

    local targetToRemove = rawWidget
    local foundIndex = nil

    for i, entry in ipairs(self.Children) do
        if entry.Item == widgetItem or entry.RawWidget == rawWidget or entry.Wrapper == rawWidget then
            if entry.Wrapper then
                targetToRemove = entry.Wrapper
            end
            foundIndex = i
            break
        end
    end

    local removed = false
    Utils.TryCall("Remove child from row", function()
        removed = self.Widget:RemoveChild(targetToRemove)
    end)

    if foundIndex then
        table.remove(self.Children, foundIndex)
    end

    return removed == true
end

--- Clears all child widgets from the row.
function Row:ClearChildren()
    if not Utils.IsValidObject(self.Widget) then return end
    Utils.TryCall("Clear row children", function()
        self.Widget:ClearChildren()
    end)
    self.Children = {}
end

--- Retrieves the total number of child widgets in the row.
-- @return (number) Number of children.
function Row:GetChildrenCount()
    if not Utils.IsValidObject(self.Widget) or not self.Widget.GetChildrenCount then
        return #self.Children
    end
    local ok, count = Utils.TryCall("Get row children count", function()
        return self.Widget:GetChildrenCount()
    end)
    return ok and count or #self.Children
end

--- Retrieves a child wrapper or widget at the specified 1-based index.
-- @param index (number) 1-based child index.
-- @return (table|UWidget|nil) Child component or nil if out of bounds.
function Row:GetChildAt(index)
    local idx = tonumber(index)
    if not idx or idx < 1 then return nil end
    return self.Children[idx]
end

--- Sets the visibility of the row container.
-- @param visibility (number) Visibility state (0 to 4).
-- @see NativeUIVisibilityConstants
function Row:SetVisibility(visibility)
    if not Utils.IsValidObject(self.Widget) then return end
    local v = tonumber(visibility)
    if not v or v < 0 or v > 4 then return end

    Utils.TryCall("Set row visibility", function()
        self.Widget:SetVisibility(v)
    end)
end

--- Retrieves the current visibility state of the row container.
-- @return (number|nil) Visibility state (0 to 4) or nil on failure.
-- @see NativeUIVisibilityConstants
function Row:GetVisibility()
    if not Utils.IsValidObject(self.Widget) or not self.Widget.GetVisibility then return nil end
    local ok, vis = Utils.TryCall("Get row visibility", function()
        return self.Widget:GetVisibility()
    end)
    return ok and vis or nil
end

--- Enables or disables interaction on the row container.
-- @param isEnabled (boolean) Whether the container should be interactive.
function Row:SetEnabled(isEnabled)
    self.isEnabled = isEnabled == true
    if Utils.IsValidObject(self.Widget) and self.Widget.SetIsEnabled then
        Utils.TryCall("Set row enabled", function()
            self.Widget:SetIsEnabled(self.isEnabled)
        end)
    end
end

--- Checks if the row container is currently enabled.
-- @return (boolean) True if enabled, false otherwise.
function Row:GetIsEnabled()
    return self.isEnabled == true
end

return Row