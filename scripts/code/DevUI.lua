local NativeUI = require("code/NativeUI/init")
local StyleExtractor = require("code/NativeUI/Style/StyleExtractor")

local Dashboard = nil

local function BuildDashboard()
    Dashboard = NativeUI.CreateWindow({
        title = "TEST MOD MENU",
        x = 100.0,
        y = 50.0,
        w = 1500.0,
        h = 800.0
    })
    if not Dashboard then return end

    local HeaderTitle = NativeUI.CreateTitle("MOD MENU TEST")
    Dashboard:AddHeaderWidget(HeaderTitle)

    local InfoText = NativeUI.CreateText("This is a test of the mod menu system. You can add buttons, switches, and other UI elements here.", "Style_Text_MainMenu", false)
    Dashboard:AddBodyWidget(InfoText)

    local TestButton = NativeUI.CreateButton("Click Me", function()
        print("Button clicked!")
    end, "Style_Button_BlackYellow")
    Dashboard:AddBodyWidget(TestButton)

    local TestSwitch = NativeUI.CreateSwitch(false, function(newState)
        print("Switch toggled ! New state: " .. tostring(newState))
        if newState then
            InfoText:SetText("You just toggled the switch ON !")
        else
            InfoText:SetText("This is a test of the mod menu system. You can add buttons, switches, and other UI elements here.")
        end
    end, "Style_Switch_Default")
    Dashboard:AddBodyWidget(TestSwitch)
end

RegisterKeyBind(Key.I, function()
    if not Dashboard then
        BuildDashboard()
    end
    if Dashboard then
        Dashboard:Toggle()
    end
end)
