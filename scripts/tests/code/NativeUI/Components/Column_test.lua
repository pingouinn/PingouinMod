local NativeUI = require("code/NativeUI/init")
local TestHelpers = require("tests/TestHelpers")

local ColumnTest = {}

function ColumnTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 900.0, h = 700.0 })
    if not window then return nil end

    local status = NativeUI.CreateText("Select a Column method to test.", nil, true)
    local column = NativeUI.CreateColumn(window)
    local child = NativeUI.CreateText("Column child", nil, false)

    window:AddHeaderWidget(NativeUI.CreateTitle("Column tests"))
    window:AddBodyWidget(status)
    window:AddBodyWidget(column)

    local function addButton(label, callback)
        TestHelpers.AddMethodButton(window, label, status, callback)
    end

    addButton("Add", function()
        column:Add(child, 1.0, { Left = 4.0, Top = 4.0, Right = 4.0, Bottom = 4.0 },
            NativeUI.Layout.HORIZONTAL_FILL)
        return "called"
    end)
    addButton("RemoveChild", function() return column:RemoveChild(child) end)
    addButton("ClearChildren", function()
        column:ClearChildren()
        return "called"
    end)
    addButton("GetChildrenCount", function() return column:GetChildrenCount() end)
    addButton("GetChildAt", function()
        return column:GetChildAt(1) and "child found" or "nil"
    end)
    addButton("SetVisibility", function()
        column:SetVisibility(NativeUI.Visibility.HIDDEN)
        return "called"
    end)
    addButton("GetVisibility", function() return column:GetVisibility() end)
    addButton("SetEnabled", function()
        column:SetEnabled(false)
        return "called"
    end)
    addButton("GetIsEnabled", function() return column:GetIsEnabled() end)

    window:Show()
    return window
end

TestHelpers.RegisterWindowCommand("TestColumn", ColumnTest, "Column")

return ColumnTest