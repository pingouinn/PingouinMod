local NativeUI = require("code/NativeUI/init")
local Layout = NativeUI.Layout

local dashboard = nil

--- Builds the development dashboard used to exercise NativeUI components.
local function BuildDashboard()
    dashboard = NativeUI.CreateWindow({
        title = "TEST MOD MENU",
        x = 100.0,
        y = 50.0,
        w = 1500.0,
        h = 800.0
    })
    if not dashboard then return end

    dashboard:SetBlurStrength(3.0)

    local headerRow = NativeUI.CreateRow()
    dashboard:AddHeaderWidget(headerRow)

    -- Title on the left (Auto + padding)
    local headerTitle = NativeUI.CreateTitle("MOD MENU TEST")
    headerRow:Add(headerTitle, 0.0, { Left = 0.0, Top = 0.0, Right = 0.0, Bottom = 0.0 }, Layout.VERTICAL_CENTER)

    -- Spacer in the middle (Fill will take the remaining space between the title and the close button)
    local spacer = NativeUI.CreateSpacer(headerRow)
    headerRow:Add(spacer, 1.0)

    -- Close button on the right (Auto + padding)
    local closeButton = NativeUI.CreateButton("", function()
        if dashboard then
            dashboard:Hide()
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
    dashboard:AddBodyWidget(sp1, { height = 20.0 })

    local infoText = NativeUI.CreateText("This is a test of the mod menu system. You can add buttons, switches, and other UI elements here.", "Style_Text_MainMenu", false)
    dashboard:AddBodyWidget(infoText)

    local sp2 = NativeUI.CreateSpacer()
    dashboard:AddBodyWidget(sp2, { height = 20.0 })

    local button = NativeUI.CreateButton("TEST", function()
        print("Button clicked!")
    end, "Style_Button_BlackYellow")
    dashboard:AddBodyWidget(button, { height = 45.0 })

    local sp3 = NativeUI.CreateSpacer()
    dashboard:AddBodyWidget(sp3, { height = 40.0 })

    local mainRow = NativeUI.CreateRow()
    dashboard:AddBodyWidget(mainRow, { padding = { Left = 0.0, Top = 8.0, Right = 0.0, Bottom = 0.0 } })

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
end

RegisterKeyBind(Key.I, function()
    if not dashboard then
        BuildDashboard()
    end
    if dashboard then
        dashboard:Toggle()
    end
end)
