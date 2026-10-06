local NativeUI = require("code/NativeUI/init")
local ButtonComponent = require("code/NativeUI/Components/Button")

local ButtonTest = {}
local windowExists = nil

local function addMethodButton(parent, label, callback)
    parent:Add(NativeUI.CreateButton(label, callback))
end

function ButtonTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 900.0, h = 700.0, y=10.0 })
    if not window then return nil end

    local status = NativeUI.CreateText("Select a Button method to test.", nil, true)
    local button = NativeUI.CreateButton("Button under test", function()
        status:SetText("Click callback invoked.")
    end)

    window:AddHeaderWidget(NativeUI.CreateTitle("Button tests"))
    window:AddBodyWidget(status)
    window:AddBodyWidget(button)

    local row = NativeUI.CreateRow()
    window:AddBodyWidget(row)
    local colleft = NativeUI.CreateColumn()
    local colright = NativeUI.CreateColumn()
    row:Add(colleft, 0.5)
    row:Add(colright, 0.5)

    addMethodButton(colleft, "SetText", function()
        button:SetText("Updated button")
        status:SetText("SetText -> " .. button:GetText())
    end)
    addMethodButton(colleft, "GetText", function()
        status:SetText("GetText -> " .. button:GetText())
    end)
    addMethodButton(colleft, "SetStyle", function()
        button:SetStyle("Style_Button_ComputerScenario")
        status:SetText("SetStyle -> called")
    end)
    addMethodButton(colleft, "Click", function()
        button:Click()
    end)
    addMethodButton(colleft, "SetEnabled", function()
        button:SetEnabled(not button:GetIsEnabled())
        status:SetText("SetEnabled -> " .. tostring(button:GetIsEnabled()))
    end)
    addMethodButton(colleft, "IsEnabled", function()
        status:SetText("IsEnabled -> " .. tostring(button:GetIsEnabled()))
    end)
    addMethodButton(colleft, "SetTextColor", function()
        button:SetTextColor({ R = 1.0, G = 0.8, B = 0.1, A = 1.0 })
        status:SetText("SetTextColor -> called")
    end)
    addMethodButton(colleft, "SetFontSize", function()
        button:SetFontSize(18.0)
        status:SetText("SetFontSize -> called")
    end)
    addMethodButton(colright, "SetFont", function()
        button:SetFont(NativeUI.Paths.FONT_AFACAD, 16.0)
        status:SetText("SetFont -> called")
    end)
    addMethodButton(colright, "SetColor", function()
        button:SetColor({ R = 1.0, G = 0.0, B = 0.0, A = 1.0 })
        status:SetText("SetColor -> called")
    end)
    addMethodButton(colright, "SetToolTipText", function()
        button:SetToolTipText("Button tooltip")
        status:SetText("SetToolTipText -> called")
    end)
    addMethodButton(colright, "UnsetToolTipText", function()
        button:UnsetToolTipText()
        status:SetText("UnsetToolTipText -> called")
    end)
    addMethodButton(colright, "SetVisibility", function()
        button:SetVisibility(NativeUI.Visibility.COLLAPSED)
        status:SetText("SetVisibility -> called")
    end)
    addMethodButton(colright, "GetVisibility", function()
        local visibility = button:GetVisibility()
        status:SetText("GetVisibility -> " .. tostring(visibility))
    end)
    addMethodButton(colright, "GC", function()
        ButtonComponent.GC()
        status:SetText("GC -> called")
    end)

    window:Show()
    return window
end

RegisterConsoleCommandHandler("TestButton", function(fullCommand, args, _)
    if windowExists then 
        windowExists:Destroy()
        windowExists = nil
        return true 
    end

    windowExists = ButtonTest.CreateWindow()
    if windowExists then
        print("[NativeUI] Button test window created successfully.")
    else
        print("[NativeUI] Failed to create Button test window.")
    end
    return true
end)

return ButtonTest
