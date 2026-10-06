--- Constants.lua defines constant values used throughout the mod, including class paths for static mesh actors and components, as well as a trace distance for raycasting operations.
-- @author PingouinTheDev

---@class NativeUIPathsConstants
---@field BACKGROUND_CLASS string Unreal Blueprint path for the background region widget
---@field BUTTON_CLASS string Unreal Blueprint path for the base button widget
---@field SWITCH_CLASS string Unreal Blueprint path for the switch/toggle button widget
---@field TEXT_CLASS string Unreal Blueprint path for the settings text widget
---@field TITLE_CLASS string Unreal Blueprint path for the HUD mission title widget
---@field SLIDER_CLASS string Unreal Blueprint path for the slider widget
---@field TEXTBOX_CLASS string Unreal class path for editable text boxes
---@field HORIZONTAL_BOX_CLASS string Unreal UMG class path for horizontal box containers
---@field VERTICAL_BOX_CLASS string Unreal UMG class path for vertical box containers
---@field SIZE_BOX_CLASS string Unreal UMG class path for size box containers
---@field SPACER_CLASS string Unreal UMG class path for spacer widgets
---@field FONT_AFACAD string Unreal asset path for the Afacad font family
---@field WIDGET_LIBRARY string Unreal default object path for WidgetBlueprintLibrary
---@field BUTTON_CLICK_FUNCTION string Unreal function path handling button click events

---@class NativeUILayoutConstants
---@field HORIZONTAL_FILL integer Horizontal alignment setting: fill available space
---@field HORIZONTAL_LEFT integer Horizontal alignment setting: align to the left
---@field HORIZONTAL_CENTER integer Horizontal alignment setting: align to the center
---@field HORIZONTAL_RIGHT integer Horizontal alignment setting: align to the right
---@field VERTICAL_FILL integer Vertical alignment setting: fill available space
---@field VERTICAL_TOP integer Vertical alignment setting: align to the top
---@field VERTICAL_CENTER integer Vertical alignment setting: align to the center
---@field VERTICAL_BOTTOM integer Vertical alignment setting: align to the bottom
---@field SIZE_AUTO integer Sizing rule: automatically adapt to content size
---@field SIZE_FILL integer Sizing rule: stretch and fill parent container

---@class NativeUIVisibilityConstants
---@field VISIBLE integer UMG Slate visibility state: visible
---@field COLLAPSED integer UMG Slate visibility state: collapsed
---@field HIDDEN integer UMG Slate visibility state: hidden

---@class NativeUIJustificationConstants
---@field LEFT integer Text justification: left-aligned
---@field CENTER integer Text justification: center-aligned
---@field RIGHT integer Text justification: right-aligned

---@class NativeUIInputConstants
---@field MOUSE_LOCK_DO_NOT_LOCK integer Viewport mouse capture mode: do not lock mouse cursor

---@class NativeUIConstants
---@field Paths NativeUIPathsConstants Blueprint and class asset paths for UI widgets
---@field Layout NativeUILayoutConstants Alignment and sizing enumeration constants
---@field Visibility NativeUIVisibilityConstants Slate visibility states for widgets
---@field Input NativeUIInputConstants Mouse lock behavior constants

---@class Constants
---@field STATIC_MESH_ACTOR_CLASS_PATH string Class path used to resolve StaticMeshActor instances
---@field STATIC_MESH_CLASS_PATH string Class path used to resolve StaticMesh assets
---@field STATIC_MESH_COMPONENT_CLASS_PATH string Class path used to resolve StaticMeshComponent instances
---@field TRACE_DISTANCE number Default raycast trace length in Unreal units

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
    COLLAPSED = 1,
    HIDDEN = 2,
}

Constants.NativeUI.Justification = {
    LEFT = 0,
    CENTER = 1,
    RIGHT = 2,
}

Constants.NativeUI.Input = {
    MOUSE_LOCK_DO_NOT_LOCK = 0,
}

return Constants
