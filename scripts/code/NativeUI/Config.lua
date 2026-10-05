local Config = {}

--- Unreal paths used by NativeUI widgets and libraries.
Config.Paths = {
    backgroundClass = "/Game/Wildfire/Blueprints/UI/SubMenus/Social/WBP_BackgroundRegion.WBP_BackgroundRegion_C",
    buttonClass = "/Game/Wildfire/Blueprints/UI/WBP_ButtonBase.WBP_ButtonBase_C",
    switchClass = "/Game/Wildfire/Blueprints/UI/SubMenus/Settings/WBP_Button_Switch.WBP_Button_Switch_C",
    textClass = "/Game/Wildfire/Blueprints/UI/SubMenus/WBP_SettingsText.WBP_SettingsText_C",
    titleClass = "/Game/Wildfire/Blueprints/UI/HUD/Mission/WBP_Title.WBP_Title_C",
    sliderClass = "/Game/Wildfire/Blueprints/UI/SubMenus/WBP_Slider.WBP_Slider_C",

    horizontalBoxClass = "/Script/UMG.HorizontalBox",
    verticalBoxClass = "/Script/UMG.VerticalBox",
    sizeBoxClass = "/Script/UMG.SizeBox",
    spacerClass = "/Script/UMG.Spacer",

    widgetLibrary = "/Script/UMG.Default__WidgetBlueprintLibrary",
    buttonClickFunction = "/Script/CommonUI.CommonButtonBase:HandleButtonClicked",
}

Config.Layout = {
    HORIZONTAL_FILL = 0,
    HORIZONTAL_LEFT = 1,
    HORIZONTAL_CENTER = 2,
    HORIZONTAL_RIGHT = 3,
    VERTICAL_FILL = 0,
    VERTICAL_TOP = 1,
    VERTICAL_CENTER = 2,
    VERTICAL_BOTTOM = 3,
    SIZE_AUTO = 0,
    SIZE_FILL = 1,
}

Config.Visibility = {
    VISIBLE = 0,
    HIDDEN = 2,
}

Config.Input = {
    MOUSE_LOCK_DO_NOT_LOCK = 0,
}

return Config
