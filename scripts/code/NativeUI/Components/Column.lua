--- Column.lua provides a wrapper for creating and managing vertical column containers in Unreal Engine's NativeUI system.
-- It includes methods for adding, removing, sizing, and clearing child components, as well as visibility and interaction controls.
-- @author PingouinTheDev

local Core = require("code/NativeUI/Core")
local Constants = require("code/Constants")

local Column = {}
Column.__index = Column

local verticalBoxClass = nil

--- Resolves and caches the native vertical box class.
-- @return (UClass|nil) The vertical box class.
local function GetClass()
    if not Utils.IsValidObject(verticalBoxClass) then
        verticalBoxClass = StaticFindObject(Constants.NativeUI.Paths.VERTICAL_BOX_CLASS)
    end
    return verticalBoxClass
end

--- Creates a vertical column container.
-- @param parentWidget (UWidget|table|nil) Optional parent used as the memory owner.
-- @return (table|nil) Column wrapper, or nil when creation fails.
function Column.Create(parentWidget)
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
        print("[NativeUI Error] Failed to construct the vertical column widget.")
        return nil
    end

    return setmetatable({
        Widget = instance,
        Children = {},
        isEnabled = true
    }, Column)
end

--- Adds a widget to the vertical column.
-- @param widgetItem (table|UWidget) Component wrapper or raw widget to add.
-- @param fillRatio (number|nil) Fill ratio; zero or nil uses automatic sizing.
-- @param padding (table|nil) Optional Slate padding table {Left = 0, Top = 0, Right = 0, Bottom = 0}.
-- @param horizontalAlignment (number|nil) Optional horizontal alignment enum value.
-- @see NativeUILayoutConstants
-- @return (UVerticalBoxSlot|nil) Created slot, or nil when adding fails.
function Column:Add(widgetItem, fillRatio, padding, horizontalAlignment)
    if not widgetItem or not Utils.IsValidObject(self.Widget) then return nil end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return nil end

    local success, slot = Utils.TryCall("Add widget to column", function()
        return self.Widget:AddChildToVerticalBox(rawWidget)
    end)
    if not success or not slot then return nil end

    Utils.TryCall("Configure column slot", function()
        local isFill = fillRatio and fillRatio > 0
        slot:SetSize({
            Value = isFill and fillRatio or 1.0,
            SizeRule = isFill and Constants.NativeUI.Layout.SIZE_FILL or Constants.NativeUI.Layout.SIZE_AUTO
        })
        slot:SetPadding(padding or {Left = 0.0, Top = 4.0, Right = 0.0, Bottom = 4.0})
        slot:SetHorizontalAlignment(horizontalAlignment or Constants.NativeUI.Layout.HORIZONTAL_FILL)
    end)

    table.insert(self.Children, widgetItem)
    return slot
end

--- Removes a child widget from the column container.
-- @param widgetItem (table|UWidget) Component wrapper or raw widget to remove.
-- @return (boolean) True if removed successfully, false otherwise.
function Column:RemoveChild(widgetItem)
    if not widgetItem or not Utils.IsValidObject(self.Widget) then return false end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return false end

    local removed = false
    Utils.TryCall("Remove child from column", function()
        removed = self.Widget:RemoveChild(rawWidget)
    end)

    for i, child in ipairs(self.Children) do
        local currentRaw = child.Widget or child
        if currentRaw == rawWidget or child == widgetItem then
            table.remove(self.Children, i)
            break
        end
    end

    return removed == true
end

--- Clears all child widgets from the column.
function Column:ClearChildren()
    if not Utils.IsValidObject(self.Widget) then return end
    Utils.TryCall("Clear column children", function()
        self.Widget:ClearChildren()
    end)
    self.Children = {}
end

--- Retrieves the total number of child widgets in the column.
-- @return (number) Number of children.
function Column:GetChildrenCount()
    if not Utils.IsValidObject(self.Widget) or not self.Widget.GetChildrenCount then
        return #self.Children
    end
    local ok, count = Utils.TryCall("Get column children count", function()
        return self.Widget:GetChildrenCount()
    end)
    return ok and count or #self.Children
end

--- Retrieves a child wrapper or widget at the specified 1-based index.
-- @param index (number) 1-based child index.
-- @return (table|UWidget|nil) Child component or nil if out of bounds.
function Column:GetChildAt(index)
    local idx = tonumber(index)
    if not idx or idx < 1 then return nil end
    return self.Children[idx]
end

--- Sets the visibility of the column container.
-- @param visibility (number) Visibility state (0 to 4).
-- @see NativeUIVisibilityConstants
function Column:SetVisibility(visibility)
    if not Utils.IsValidObject(self.Widget) then return end
    local v = tonumber(visibility)
    if not v or v < 0 or v > 4 then return end

    Utils.TryCall("Set column visibility", function()
        self.Widget:SetVisibility(v)
    end)
end

--- Retrieves the current visibility state of the column container.
-- @return (number|nil) Visibility state (0 to 4) or nil on failure.
-- @see NativeUIVisibilityConstants
function Column:GetVisibility()
    if not Utils.IsValidObject(self.Widget) or not self.Widget.GetVisibility then return nil end
    local ok, vis = Utils.TryCall("Get column visibility", function()
        return self.Widget:GetVisibility()
    end)
    return ok and vis or nil
end

--- Enables or disables interaction on the column container.
-- @param isEnabled (boolean) Whether the container should be interactive.
function Column:SetEnabled(isEnabled)
    self.isEnabled = isEnabled == true
    if Utils.IsValidObject(self.Widget) and self.Widget.SetIsEnabled then
        Utils.TryCall("Set column enabled", function()
            self.Widget:SetIsEnabled(self.isEnabled)
        end)
    end
end

--- Checks if the column container is currently enabled.
-- @return (boolean) True if enabled, false otherwise.
function Column:GetIsEnabled()
    return self.isEnabled == true
end

return Column