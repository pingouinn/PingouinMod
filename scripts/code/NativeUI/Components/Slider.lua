local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")

local SliderComponent = {}
local SliderClass = nil
local ActiveSliders = {}
local WatcherActive = false

--- Retrieves the UClass for the slider widget.
-- @return (UClass|nil) The slider widget class.
local function GetClass()
    if not Utils.IsValidObject(SliderClass) then
        SliderClass = StaticFindObject(Config.Paths.sliderClass)
        if not SliderClass then
            SliderClass = UObject.Load(Config.Paths.sliderClass)
        end
    end
    return SliderClass
end

--- Starts the asynchronous value watcher loop if not already running.
local function EnsureWatcher()
    if WatcherActive then return end
    WatcherActive = true

    -- Used an asynchrounous watcher loop because i was'nt able to find a reliable way to hook into the slider's value change event.
    -- TODO : Maybe try again to find a valid hook from a delegate or event on the slider widget
    LoopAsync(50, function()
        local count = 0
        for address, sliderObject in pairs(ActiveSliders) do
            if sliderObject and Utils.IsValidObject(sliderObject.Widget) then
                count = count + 1
                local internalSlider = sliderObject.Widget.Slider_18
                if Utils.IsValidObject(internalSlider) then
                    local currentValue = internalSlider:GetValue()
                    if math.abs(currentValue - sliderObject.CurrentValue) > 0.0001 then
                        sliderObject.CurrentValue = currentValue
                        if sliderObject.OnChangeCallback then
                            sliderObject.OnChangeCallback(currentValue, sliderObject)
                        end
                    end
                end
            else
                ActiveSliders[address] = nil
            end
        end

        -- Stop watcher loop when no active sliders remain
        if count == 0 then
            WatcherActive = false
            return true
        end

        return false
    end)
end

--- Creates a slider component.
-- @param min_val (number|nil) Minimum value; defaults to 0.0.
-- @param max_val (number|nil) Maximum value; defaults to 1.0.
-- @param default_val (number|nil) Initial value; defaults to min_val.
-- @param step_size (number|nil) Step size for value changes; defaults to 0.05.
-- @param on_change (function|nil) Callback invoked with the new value and wrapper.
-- @return (table|nil) Slider wrapper, or nil when creation fails.
function SliderComponent.Create(min_val, max_val, default_val, step_size, on_change)
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass or not Utils.IsValidObject(widgetClass) then return nil end

    local instance = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(instance) then return nil end

    local minV = min_val or 0.0
    local maxV = max_val or 1.0
    local curV = default_val or minV
    local step = step_size or 0.05

    -- Configure slider properties
    Utils.TryCall("Configure slider properties", function()
        instance.MinRange = minV
        instance.MaxRange = maxV

        if Utils.IsValidObject(instance.Slider_18) then
            instance.Slider_18.StepSize = step
            instance.Slider_18:SetMinValue(minV)
            instance.Slider_18:SetMaxValue(maxV)
            instance.Slider_18:SetValue(curV)
        end

        if instance.SetValue then
            instance:SetValue(curV)
        end
    end, not DEBUG_MODE)

    local sliderObject = {
        Widget = instance,
        CurrentValue = curV,
        Min = minV,
        Max = maxV,
        Step = step,
        OnChangeCallback = on_change
    }

    if instance.GetAddress then
        ActiveSliders[tostring(instance:GetAddress())] = sliderObject
    end

    EnsureWatcher()

    --- Sets the slider's value, clamping it within the defined range.
    -- @param value (number) New value to set.
    function sliderObject:SetValue(value)
        self.CurrentValue = math.max(self.Min, math.min(self.Max, value))
        if Utils.IsValidObject(self.Widget) and Utils.IsValidObject(self.Widget.Slider_18) then
            self.Widget.Slider_18:SetValue(self.CurrentValue)
        end
        if Utils.IsValidObject(self.Widget) and self.Widget.SetValue then
            self.Widget:SetValue(self.CurrentValue)
        end
    end

    --- Returns the current value of the slider.
    -- @return (number) Current slider value.
    function sliderObject:GetValue()
        if Utils.IsValidObject(self.Widget) and Utils.IsValidObject(self.Widget.Slider_18) then
            return self.Widget.Slider_18:GetValue()
        end
        return self.CurrentValue
    end

    --- Refreshes the native widget from the wrapper state.
    function sliderObject:Refresh()
        self:SetValue(self.CurrentValue)
    end

    return sliderObject
end

--- Removes invalid widgets from the slider callback registry.
function SliderComponent.GC()
    for address, sliderObject in pairs(ActiveSliders) do
        if not sliderObject or not Utils.IsValidObject(sliderObject.Widget) then
            ActiveSliders[address] = nil
        end
    end
end

GCScheduler.RegisterGC(SliderComponent.GC, 10.0, true)

return SliderComponent