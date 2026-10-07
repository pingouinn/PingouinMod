local NativeUI = require("code/NativeUI/init")
local TestHelpers = require("tests/TestHelpers")

local RowTest = {}

function RowTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 900.0, h = 700.0 })
    if not window then return nil end

    local status = NativeUI.CreateText("Select a Row method to test.", nil, true)
    local row = NativeUI.CreateRow(window)
    local child = NativeUI.CreateText("Row child", nil, false)

    window:AddHeaderWidget(NativeUI.CreateTitle("Row tests"))
    window:AddBodyWidget(status)
    window:AddBodyWidget(row)

    local function addButton(label, callback)
        TestHelpers.AddMethodButton(window, label, status, callback)
    end

    addButton("Add", function()
        row:Add(child, 1.0, { Left = 4.0, Top = 4.0, Right = 4.0, Bottom = 4.0 },
            NativeUI.Layout.VERTICAL_CENTER, { width = 180.0, height = 40.0 })
        return "called"
    end)
    addButton("RemoveChild", function()
        return row:RemoveChild(child)
    end)
    addButton("ClearChildren", function()
        row:ClearChildren()
        return "called"
    end)
    addButton("GetChildrenCount", function()
        return row:GetChildrenCount()
    end)
    addButton("GetChildAt", function()
        return row:GetChildAt(1) and "child found" or "nil"
    end)
    addButton("SetVisibility", function()
        row:SetVisibility(NativeUI.Visibility.HIDDEN)
        return "called"
    end)
    addButton("GetVisibility", function()
        return row:GetVisibility()
    end)
    addButton("SetEnabled", function()
        row:SetEnabled(false)
        return "called"
    end)
    addButton("GetIsEnabled", function()
        return row:GetIsEnabled()
    end)

    window:Show()
    return window
end

TestHelpers.RegisterWindowCommand("TestRow", RowTest, "Row")

return RowTest
