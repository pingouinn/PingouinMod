local NativeUI = require("code/NativeUI/init")
local Math = require("code/Utils/Math")
local TestHelpers = require("tests/TestHelpers")
local Types = require("code/utils/Types")

local MathTest = {}

function MathTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 900.0, h = 500.0 })
    if not window then return nil end
    local status = NativeUI.CreateText("Select a Math method to test.", nil, true)
    window:AddHeaderWidget(NativeUI.CreateTitle("Math tests"))
    window:AddBodyWidget(status)

    local function addButton(label, callback)
        TestHelpers.AddMethodButton(window, label, status, callback)
    end

    addButton("GetPositionInFront", function()
        local value = Math.GetPositionInFront(
            { X = 0, Y = 0, Z = 0 },
            { Pitch = 0, Yaw = 0, Roll = 0 },
            100
        )
        local valueUnpacked = Utils.ReadVector(value)
        return string.format("X=%s, Y=%s, Z=%s", tostring(valueUnpacked.X), tostring(valueUnpacked.Y), tostring(valueUnpacked.Z)) or "nil"
    end)
    addButton("GetForwardVector", function()
        local value = Math.GetForwardVector({ Pitch = 0, Yaw = 0, Roll = 0 })
        local valueUnpacked = Utils.ReadVector(value)
        return string.format("X=%s, Y=%s, Z=%s", tostring(valueUnpacked.X), tostring(valueUnpacked.Y), tostring(valueUnpacked.Z)) or "nil"
    end)
    addButton("CheckLocationEquality", function()
        return Math.CheckLocationEquality(
            { X = 1, Y = 2, Z = 3 },
            { X = 1.001, Y = 2, Z = 3 },
            0.01
        )
    end)

    window:Show()
    return window
end

TestHelpers.RegisterWindowCommand("TestMath", MathTest, "Math")

return MathTest
