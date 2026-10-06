local NativeUI = require("code/NativeUI/init")

local TextTest = {}
local windowExists = nil

local function addMethodButton(parent, label, callback)
    parent:Add(NativeUI.CreateButton(label, callback))
end

function TextTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 760.0, h = 700.0, x = 100.0,y = 10.0, })
    if not window then return nil end

    local status = NativeUI.CreateText("Select a Text method to test.", nil, false)
    local text = NativeUI.CreateText("Text under test", nil, true)
    local color = { R = 1.0, G = 0.8, B = 0.1, A = 1.0 }

    window:AddHeaderWidget(NativeUI.CreateTitle("Text tests"))
    window:AddBodyWidget(status)
    window:AddBodyWidget(text)

    local row = NativeUI.CreateRow()
    window:AddBodyWidget(row)
    local colleft = NativeUI.CreateColumn()
    local colright = NativeUI.CreateColumn()
    row:Add(colleft, 0.5)
    row:Add(colright, 0.5)

    addMethodButton(colleft, "SetText", function()
        text:SetText("Updated text")
        status:SetText("SetText -> " .. text:GetText())
    end)
    addMethodButton(colleft, "GetText", function()
        status:SetText("GetText -> " .. text:GetText())
    end)
    addMethodButton(colleft, "SetStyle", function()
        text:SetStyle("Style_Text_ComputerTitle")
        status:SetText("SetStyle -> called")
    end)
    addMethodButton(colleft, "SetColor", function()
        text:SetColor({ R = 1.0, G = 0.0, B = 0.0, A = 1.0 })
        status:SetText("SetColor -> called")
    end)
    addMethodButton(colleft, "SetFontSize", function()
        text:SetFontSize(18.0)
        status:SetText("SetFontSize -> called")
    end)
    addMethodButton(colleft, "SetFont", function()
        text:SetFont(NativeUI.Paths.FONT_AFACAD, 16.0)
        status:SetText("SetFont -> called")
    end)
    addMethodButton(colright, "SetJustification", function()
        text:SetJustification(1)
        status:SetText("SetJustification -> called")
    end)
    addMethodButton(colright, "SetAutoWrap", function()
        text:SetAutoWrap(true)
        status:SetText("SetAutoWrap -> called")
    end)
    addMethodButton(colright, "SetShadow", function()
        text:SetShadow({ X = 1.0, Y = 1.0 }, { R = 0.0, G = 0.0, B = 0.0, A = 0.8 })
        status:SetText("SetShadow -> called")
    end)
    addMethodButton(colright, "SetLineVisible", function()
        text:SetLineVisible(NativeUI.Visibility.COLLAPSED)
        status:SetText("SetLineVisible -> called")
    end)
    addMethodButton(colright, "SetLineColor", function()
        text:SetLineColor({ R = 0.0, G = 1.0, B = 1.0, A = 1.0 })
        status:SetText("SetLineColor -> called")
    end)
    addMethodButton(colright, "SetVisibility", function()
        text:SetVisibility(NativeUI.Visibility.HIDDEN)
        status:SetText("SetVisibility -> called")
    end)
    addMethodButton(colright, "GetVisibility", function()
        local visibility = text:GetVisibility()
        status:SetText("GetVisibility -> " .. tostring(visibility))
    end)
    
    window:Show()
    return window
end

RegisterConsoleCommandHandler("TestText", function(fullCommand, args, _)
    if windowExists then 
        windowExists:Destroy()
        windowExists = nil
        return true 
    end

    windowExists = TextTest.CreateWindow()
    if windowExists then
        print("[NativeUI] Text test window created successfully.")
    else
        print("[NativeUI] Failed to create Text test window.")
    end
    return true
end)


return TextTest
