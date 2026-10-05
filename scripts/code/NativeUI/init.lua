local Core = require("code/NativeUI/Core")
local Window = require("code/NativeUI/Window")
local Title = require("code/NativeUI/Components/Text/Title")
local Text = require("code/NativeUI/Components/Text/Text")
local Button = require("code/NativeUI/Components/Button")
local Switch = require("code/NativeUI/Components/Switch")

-- Style 
local StyleExtractor = require("code/NativeUI/Style/StyleExtractor")
local StyleUtils = require("code/NativeUI/Style/StyleUtils")

local NativeUI = {
    Core = Core,
    Window = Window,
    Title = Title,
    Text = Text,
    Button = Button,
    Switch = Switch
}

--- Creates a NativeUI window.
-- @param config (table|nil) Window options.
-- @return (table|nil) The created window.
function NativeUI.CreateWindow(config)
    return Window.New(config)
end

--- Creates a title component.
-- @param initialText (string|nil) Initial title text.
-- @param stylePath (string|nil) Style identifier or asset path.
function NativeUI.CreateTitle(initialText, stylePath)
    return Title.Create(initialText, stylePath)
end

--- Creates a text component.
-- @param initialText (string|nil) Initial text.
-- @param stylePath (string|nil) Style identifier or asset path.
function NativeUI.CreateText(initialText, stylePath, showLine)
    return Text.Create(initialText, stylePath, showLine)
end

--- Creates a button component.
-- @param label (string|nil) Button label.
-- @param onClick (function|nil) Callback invoked on click.
-- @param stylePath (string|nil) Style identifier or asset path.
function NativeUI.CreateButton(label, onClick, stylePath)
    return Button.Create(label, onClick, stylePath)
end

--- Creates a switch component.
-- @param initialState (boolean|nil) Initial checked state.
-- @param onToggle (function|nil) Callback invoked with the new state.
-- @param stylePath (string|nil) Style identifier or asset path.
function NativeUI.CreateSwitch(initialState, onToggle, stylePath)
    return Switch.Create(initialState, onToggle, stylePath)
end

return NativeUI