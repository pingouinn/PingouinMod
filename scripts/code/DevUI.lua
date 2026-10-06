--- DevUI.lua is a sandbox to test NativeUI components, including buttons, switches, sliders, and text inputs. It registers a keybind to toggle the dashboard visibility.
-- @author PingouinTheDev

local NativeUI = require("code/NativeUI/init")
local Layout = NativeUI.Layout

local Dashboard = nil

--- Builds the development Dashboard used to exercise NativeUI components.
local function BuildDashboard()
    Dashboard = NativeUI.CreateWindow({
        title = "TEST MOD MENU",
        x = 100.0,
        y = 50.0,
        w = 1500.0,
        h = 800.0
    })
    if not Dashboard then return end

    Dashboard:SetBlurStrength(3.0)

    local headerRow = NativeUI.CreateRow()
    Dashboard:AddHeaderWidget(headerRow)

    -- Title on the left (Auto + padding)
    local headerTitle = NativeUI.CreateTitle("MOD MENU TEST")
    headerRow:Add(headerTitle, 0.0, { Left = 0.0, Top = 0.0, Right = 0.0, Bottom = 0.0 }, Layout.VERTICAL_CENTER)

    -- Spacer in the middle (Fill will take the remaining space between the title and the close button)
    local spacer = NativeUI.CreateSpacer(headerRow)
    headerRow:Add(spacer, 1.0)

    -- Close button on the right (Auto + padding)
    local closeButton = NativeUI.CreateButton("", function()
        if Dashboard then
            Dashboard:Hide()
        end
    end, "Style_Button_Close")

    headerRow:Add(
        closeButton,
        0.0,                                                    -- Auto
        { Left = 0.0, Top = 0.0, Right = 16.0, Bottom = 0.0 },  -- Right padding
        Layout.VERTICAL_CENTER,                                 -- Center vertical alignment
        { width = 100.0, height = 100.0 }                       -- Fixed size for the close button
    )

    -- BODY CONTENT

    local sp1 = NativeUI.CreateSpacer()
    Dashboard:AddBodyWidget(sp1, { height = 20.0 })

    local infoText = NativeUI.CreateText("This is a test of the mod menu system. You can add buttons, switches, and other UI elements here.", "Style_Text_MainMenu", false)
    Dashboard:AddBodyWidget(infoText)

    local sp2 = NativeUI.CreateSpacer()
    Dashboard:AddBodyWidget(sp2, { height = 20.0 })

    local button = NativeUI.CreateButton("TEST", function()
        print("Button clicked!")
    end, "Style_Button_BlackYellow")
    Dashboard:AddBodyWidget(button, { height = 45.0 })

    local sp3 = NativeUI.CreateSpacer()
    Dashboard:AddBodyWidget(sp3, { height = 40.0 })

    local mainRow = NativeUI.CreateRow()
    Dashboard:AddBodyWidget(mainRow, { padding = { Left = 0.0, Top = 8.0, Right = 0.0, Bottom = 0.0 } })

    -- Left column (50% of available width: fill = 1.0)
    local colLeft = NativeUI.CreateColumn(mainRow)
    mainRow:Add(colLeft, 1.0, { Left = 0.0, Top = 0.0, Right = 12.0, Bottom = 0.0 }, Layout.VERTICAL_TOP)

    colLeft:Add(NativeUI.CreateText("TELEPORT", "Style_Text_MontSerrat_Bold_Outline"))
    colLeft:Add(NativeUI.CreateButton("Station", function() print("Caserne") end))
    colLeft:Add(NativeUI.CreateButton("OFFROAD", function() print("OFFROAD") end))

    -- Right column (50% of available width: fill = 1.0)
    local colRight = NativeUI.CreateColumn(mainRow)
    mainRow:Add(colRight, 1.0, { Left = 12.0, Top = 0.0, Right = 0.0, Bottom = 0.0 }, Layout.VERTICAL_TOP)

    colRight:Add(NativeUI.CreateText("PLAYER ABILITIES", "Style_Text_MontSerrat_Bold_Outline"))
    local rowRight = NativeUI.CreateRow(colRight)
    colRight:Add(rowRight, 1.0, { Left = 0.0, Top = 0.0, Right = 0.0, Bottom = 0.0 })

    local godModeLabel = NativeUI.CreateText("Activate God Mode", nil, true)
    rowRight:Add(godModeLabel, 1.0, nil, Layout.VERTICAL_CENTER)  -- Center

    local godModeSwitch = NativeUI.CreateSwitch(false, function(state)
        print("God Mode toggled: " .. tostring(state))
    end)
    rowRight:Add(godModeSwitch, 0.0, nil, Layout.VERTICAL_CENTER) -- Center

    -- Slider 

    local sliderRow = NativeUI.CreateRow(colRight)
    colRight:Add(sliderRow, 0.0, { Left = 0.0, Top = 4.0, Right = 0.0, Bottom = 4.0 })

    local fovLabel = NativeUI.CreateText("FOV : 90", nil, true)
    sliderRow:Add(fovLabel, 1.0, nil, 2) -- Takes the remaining space, with vertical alignment centered

    local fovSlider = NativeUI.CreateSlider(70.0, 120.0, 90.0, 1.0, function(val)
        fovLabel:SetText(string.format("FOV : %d", math.floor(val)))
    end)
    sliderRow:Add(fovSlider, 0.0, nil, 2, { width = 180.0, height = 32.0 })

    -- Bouton de test pour voir si la valeur bouge sous le capot
    Dashboard:AddBodyWidget(NativeUI.CreateButton("Lire valeur slider", function()
        local raw = fovSlider.Widget.Slider_18:GetValue()
        print("Valeur interne Slider_18 : " .. tostring(raw))
        print("Valeur GetValue Blueprint : " .. tostring(fovSlider:GetValue()))
    end))


    -- TEXTBOX
    local searchRow = NativeUI.CreateRow(colRight)
    colRight:Add(searchRow, 0.0, { Left = 0.0, Top = 4.0, Right = 0.0, Bottom = 4.0 })

    local ipInput = NativeUI.CreateTextInput("127.0.0.1", "", function(text, method)
        print(string.format("[NativeUI] Texte validé (méthode %s) : %s", tostring(method), text))
    end, function(text)
        print(string.format("[NativeUI] Texte modifié : %s", text))
    end)

    searchRow:Add(ipInput, 1.0, nil, 2, { height = 36.0 })
end

RegisterKeyBind(Key.I, function()
    if not NativeUI.IsAnyInputFocused() then
        if not Dashboard then
            BuildDashboard()
            if Dashboard then
                Dashboard:Show()
            end
        else
            Dashboard:Toggle()
        end
    end
end)
