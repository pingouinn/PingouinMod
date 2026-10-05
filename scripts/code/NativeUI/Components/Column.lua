local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")

local Column = {}
Column.__index = Column

local verticalBoxClass = nil

--- Resolves and caches the native vertical box class.
-- @return (UClass|nil) The vertical box class.
local function GetClass()
    if not Utils.IsValidObject(verticalBoxClass) then
        verticalBoxClass = StaticFindObject(Config.Paths.verticalBoxClass)
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

    return setmetatable({Widget = instance, Children = {}}, Column)
end

--- Adds a widget to the column.
-- @param widgetItem (table|UWidget) Component wrapper or widget to add.
-- @param fillRatio (number|nil) Fill ratio; zero or nil uses automatic sizing.
-- @param padding (table|nil) Optional Slate padding.
-- @return (FVerticalBoxSlot|nil) Created slot, or nil when adding fails.
function Column:Add(widgetItem, fillRatio, padding)
    if not widgetItem then return nil end
    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return nil end

    local success, slot = Utils.TryCall("Add widget to column", function()
        return self.Widget:AddChildToVerticalBox(rawWidget)
    end)
    if not success or not slot then return nil end

    Utils.TryCall("Configure column slot", function()
        local isFill = fillRatio and fillRatio > 0
        slot:SetSize({Value = isFill and fillRatio or 1.0, SizeRule = isFill and Config.Layout.SIZE_FILL or Config.Layout.SIZE_AUTO})
        slot:SetPadding(padding or {Left = 0.0, Top = 4.0, Right = 0.0, Bottom = 4.0})
        slot:SetHorizontalAlignment(Config.Layout.HORIZONTAL_FILL)
    end)
    table.insert(self.Children, widgetItem)
    return slot
end

--- Refreshes all child components in the column.
function Column:Refresh()
    for _, child in ipairs(self.Children) do
        if child.Refresh then child:Refresh() end
    end
end

return Column
