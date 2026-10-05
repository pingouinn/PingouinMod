local Window = require("code/NativeUI/Window")
local Title = require("code/NativeUI/Components/Text/Title")
local Text = require("code/NativeUI/Components/Text/Text")
local Button = require("code/NativeUI/Components/Button")
local Switch = require("code/NativeUI/Components/Switch")
local Slider = require("code/NativeUI/Components/Slider")
local TextInput = require("code/NativeUI/Components/TextInput")

-- Containers
local Row = require("code/NativeUI/Components/Row")
local Column = require("code/NativeUI/Components/Column")
local Spacer = require("code/NativeUI/Components/Spacer")

-- Utilities
local Config = require("code/NativeUI/Config")
local Core = require("code/NativeUI/Core")

local NativeUI = {}

NativeUI.Layout = Config.Layout
NativeUI.Visibility = Config.Visibility
NativeUI.Input = Config.Input
NativeUI.CreateWindow = Window.New
NativeUI.CreateButton = Button.Create
NativeUI.CreateSwitch = Switch.Create
NativeUI.CreateText = Text.Create
NativeUI.CreateTitle = Title.Create
NativeUI.CreateRow = Row.Create
NativeUI.CreateColumn = Column.Create
NativeUI.CreateSpacer = Spacer.Create
NativeUI.CreateSlider = Slider.Create
NativeUI.CreateTextInput = TextInput.Create
NativeUI.CommitFocusedInput = Core.CommitFocusedInput

-- Exposed functions 
NativeUI.IsAnyInputFocused = Core.IsAnyInputFocused

return NativeUI