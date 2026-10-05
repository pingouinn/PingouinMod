local Config = {}

--- Unreal paths used by NativeUI widgets and libraries.
Config.Paths = {
    backgroundClass = "/Game/Wildfire/Blueprints/UI/SubMenus/Social/WBP_BackgroundRegion.WBP_BackgroundRegion_C",
    buttonClass = "/Game/Wildfire/Blueprints/UI/WBP_ButtonBase.WBP_ButtonBase_C",
    switchClass = "/Game/Wildfire/Blueprints/UI/SubMenus/Settings/WBP_Button_Switch.WBP_Button_Switch_C",
    textClass = "/Game/Wildfire/Blueprints/UI/SubMenus/WBP_SettingsText.WBP_SettingsText_C",
    titleClass = "/Game/Wildfire/Blueprints/UI/HUD/Mission/WBP_Title.WBP_Title_C",

    -- Unreal library paths used by NativeUI for widget creation and text conversion.
    widgetLibrary = "/Script/UMG.Default__WidgetBlueprintLibrary",
    buttonClickFunction = "/Script/CommonUI.CommonButtonBase:HandleButtonClicked",
}

return Config
