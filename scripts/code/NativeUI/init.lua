--- init.lua is the entry point for the NativeUI module, providing a unified interface for creating and managing UI components in Unreal Engine. It exposes functions for creating windows, buttons, switches, text elements, sliders, and input fields, as well as utility functions for handling input focus and visibility. The module organizes its components into containers and utilities for easy access and management.
-- @author PingouinTheDev

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
local Constants = require("code/Constants")
local Core = require("code/NativeUI/Core")

local NativeUI = {}

NativeUI.Layout = Constants.NativeUI.Layout
NativeUI.Visibility = Constants.NativeUI.Visibility
NativeUI.Input = Constants.NativeUI.Input
NativeUI.Paths = Constants.NativeUI.Paths

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