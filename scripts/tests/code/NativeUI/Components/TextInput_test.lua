local NativeUI = require("code/NativeUI/init")
local TextInputComponent = require("code/NativeUI/Components/TextInput")

local TextInputTest = {}
local windowExists = nil

local function addMethodButton(parent, label, callback)
    parent:Add(NativeUI.CreateButton(label, callback))
end

function TextInputTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 1500.0, h = 760.0, y = 10.0 })
    if not window then return nil end

    local status = NativeUI.CreateText("Select a TextInput method to test.", nil, true)
    local input = NativeUI.CreateTextInput("Type here", "Initial text")

    window:AddHeaderWidget(NativeUI.CreateTitle("TextInput tests"))
    window:AddBodyWidget(status)
    window:AddBodyWidget(input)

    local row = NativeUI.CreateRow()
    window:AddBodyWidget(row)
    local colleft = NativeUI.CreateColumn()
    local colright = NativeUI.CreateColumn()
    row:Add(colleft, 0.5)
    row:Add(colright, 0.5)

    addMethodButton(colleft, "SetText", function()
        input:SetText("Updated text")
        status:SetText("SetText -> " .. input:GetText())
    end)
    addMethodButton(colleft, "GetText", function()
        status:SetText("GetText -> " .. input:GetText())
    end)
    addMethodButton(colleft, "Clear", function()
        input:Clear()
        status:SetText("Clear -> " .. input:GetText())
    end)
    addMethodButton(colleft, "SetHintText", function()
        input:SetHintText("Updated hint")
        status:SetText("SetHintText -> called")
    end)
    addMethodButton(colleft, "SetBackgroundColorNormal", function()
        input:SetBackgroundColorNormal({ R = 0.0, G = 0.0, B = 1.0, A = 1.0 })
        status:SetText("SetBackgroundColorNormal -> called")
    end)
    addMethodButton(colleft, "SetBackgroundColorHovered", function()
        input:SetBackgroundColorHovered({ R = 0.0, G = 1.0, B = 0.0, A = 1.0 })
        status:SetText("SetBackgroundColorHovered -> called")
    end)
    addMethodButton(colleft, "SetBackgroundColorFocused", function()
        input:SetBackgroundColorFocused({ R = 1.0, G = 0.0, B = 0.0, A = 0.5 })
        status:SetText("SetBackgroundColorFocused -> called")
    end)
    addMethodButton(colleft, "SetTextColor", function()
        input:SetTextColor({ R = 1.0, G = 1.0, B = 0.0, A = 1.0 })
        status:SetText("SetTextColor -> called")
    end)
    addMethodButton(colleft, "SetFont", function()
        input:SetFont(NativeUI.Paths.FONT_AFACAD, 16.0)
        status:SetText("SetFont -> called")
    end)
    addMethodButton(colright, "SetFontSize", function()
        input:SetFontSize(18.0)
        status:SetText("SetFontSize -> called")
    end)
    addMethodButton(colright, "SetErrorState", function()
        input:SetErrorState(true)
        status:SetText("SetErrorState(true) -> called")
    end)
    addMethodButton(colright, "SetReadOnly", function()
        input:SetReadOnly(not input:GetIsReadOnly())
        status:SetText("SetReadOnly(" .. tostring(not input:GetIsReadOnly()) .. ") -> called")
    end)
    addMethodButton(colright, "SetIsPassword", function()
        input:SetIsPassword(not input:GetIsPassword())
        status:SetText("SetIsPassword(" .. tostring(not input:GetIsPassword()) .. ") -> called")
    end)
    addMethodButton(colright, "SetKeyboardFocus", function()
        input:SetKeyboardFocus()
        status:SetText("SetKeyboardFocus -> " .. tostring(input:HasFocus()))
    end)
    addMethodButton(colright, "HasFocus", function()
        status:SetText("HasFocus -> " .. tostring(input:HasFocus()))
    end)
    addMethodButton(colright, "SetVisibility", function()
        input:SetVisibility(NativeUI.Visibility.HIDDEN)
        status:SetText("SetVisibility -> called")
    end)
    addMethodButton(colright, "GetVisibility", function()
        local visibility = input:GetVisibility()
        status:SetText("GetVisibility -> " .. tostring(visibility))
    end)
    addMethodButton(colright, "GC", function()
        TextInputComponent.GC()
        status:SetText("GC -> called")
    end)

    window:Show()
    return window
end

RegisterConsoleCommandHandler("TestTextInput", function(fullCommand, args, _)
    if windowExists then 
        windowExists:Destroy()
        windowExists = nil
        return true 
    end

    windowExists = TextInputTest.CreateWindow()
    if windowExists then
        print("[NativeUI] TextInput test window created successfully.")
    else
        print("[NativeUI] Failed to create TextInput test window.")
    end
    return true
end)

return TextInputTest
