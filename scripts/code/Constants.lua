--- Constants.lua defines constant values used throughout the mod, including class paths for static mesh actors and components, as well as a trace distance for raycasting operations.
-- @author PingouinTheDev

local Constants = {

    -- Meshes and actors
    STATIC_MESH_ACTOR_CLASS_PATH = "/Script/Engine.StaticMeshActor",
    STATIC_MESH_CLASS_PATH = "/Script/Engine.StaticMesh",
    STATIC_MESH_COMPONENT_CLASS_PATH = "/Script/Engine.StaticMeshComponent",
    TRACE_DISTANCE = 10000.0,

}


-- NativeUI Constants
Constants.NativeUI = {}

Constants.NativeUI.Paths = {
    BACKGROUND_CLASS = "/Game/Wildfire/Blueprints/UI/SubMenus/Social/WBP_BackgroundRegion.WBP_BackgroundRegion_C",
    BUTTON_CLASS = "/Game/Wildfire/Blueprints/UI/WBP_ButtonBase.WBP_ButtonBase_C",
    SWITCH_CLASS = "/Game/Wildfire/Blueprints/UI/SubMenus/Settings/WBP_Button_Switch.WBP_Button_Switch_C",
    TEXT_CLASS = "/Game/Wildfire/Blueprints/UI/SubMenus/WBP_SettingsText.WBP_SettingsText_C",
    TITLE_CLASS = "/Game/Wildfire/Blueprints/UI/HUD/Mission/WBP_Title.WBP_Title_C",
    SLIDER_CLASS = "/Game/Wildfire/Blueprints/UI/SubMenus/WBP_Slider.WBP_Slider_C",
    TEXTBOX_CLASS = "/Script/UMG.EditableTextBox",

    HORIZONTAL_BOX_CLASS = "/Script/UMG.HorizontalBox",
    VERTICAL_BOX_CLASS = "/Script/UMG.VerticalBox",
    SIZE_BOX_CLASS = "/Script/UMG.SizeBox",
    SPACER_CLASS = "/Script/UMG.Spacer",

    FONT_AFACAD = "/Game/Wildfire/Fonts/MissionFont/Afacad_Font.Afacad_Font",
    WIDGET_LIBRARY = "/Script/UMG.Default__WidgetBlueprintLibrary",
    BUTTON_CLICK_FUNCTION = "/Script/CommonUI.CommonButtonBase:HandleButtonClicked",
}

Constants.NativeUI.Layout = {
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

Constants.NativeUI.Visibility = {
    VISIBLE = 0,
    HIDDEN = 2,
}

Constants.NativeUI.Input = {
    MOUSE_LOCK_DO_NOT_LOCK = 0,
}

return Constants
