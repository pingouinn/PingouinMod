local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")

local Window = {}
Window.__index = Window

local backgroundClass = nil
local sizeBoxClass = nil

--- Resolves and caches the background widget class.
-- @return (UClass|nil) The background widget class.
local function GetBackgroundClass()
    if not Utils.IsValidObject(backgroundClass) then
        backgroundClass = StaticFindObject(Config.Paths.backgroundClass)
    end
    return backgroundClass
end

--- Resolves and caches the native size box class.
-- @return (UClass|nil) The size box class.
local function GetSizeBoxClass()
    if not Utils.IsValidObject(sizeBoxClass) then
        sizeBoxClass = StaticFindObject(Config.Paths.sizeBoxClass)
    end
    return sizeBoxClass
end

--- Finds the background blur widget in a root widget.
-- @param instance (UUserWidget|nil) Root widget to inspect.
-- @return (UWidget|nil) Background blur widget, or nil when unavailable.
local function GetBlurWidget(instance)
    if not Utils.IsValidObject(instance) then return nil end

    if Utils.IsValidObject(instance.BackgroundBlur_0) then
        return instance.BackgroundBlur_0
    end

    if Utils.IsValidObject(instance.WidgetTree) then
        local tree = instance.WidgetTree
        if tree.FindWidget then
            local success, blur = Utils.TryCall("Find background blur", function()
                return tree:FindWidget("BackgroundBlur_0")
            end)
            if success and Utils.IsValidObject(blur) then
                return blur
            end
        end

        local root = tree.RootWidget
        if Utils.IsValidObject(root) and root.GetChildrenCount and root.GetChildAt then
            for i = 0, root:GetChildrenCount() - 1 do
                local child = root:GetChildAt(i)
                if Utils.IsValidObject(child) then
                    local objectName = Utils.GetObjectName(child)
                    if objectName and objectName:find("BackgroundBlur") then
                        return child
                    end
                end
            end
        end
    end

    return nil
end

--- Wraps a widget in a UMG size box when constraints are provided.
-- @param rawWidget (UWidget) Widget to wrap.
-- @param width (number|nil) Optional width constraint.
-- @param height (number|nil) Optional height constraint.
-- @param outer (UObject|nil) Memory owner for the size box.
-- @return (UWidget) Original or wrapped widget.
local function WrapInSizeBox(rawWidget, width, height, outer)
    if not width and not height then
        return rawWidget
    end

    local widgetClass = GetSizeBoxClass()
    if not Utils.IsValidObject(widgetClass) then return rawWidget end

    local box = Utils.ConstructObject(widgetClass, outer or rawWidget)

    if not Utils.IsValidObject(box) then return rawWidget end

    Utils.TryCall("Configure window size box", function()
        if width then
            box.bOverride_WidthOverride = true
            box.WidthOverride = width
        end
        if height then
            box.bOverride_HeightOverride = true
            box.HeightOverride = height
        end
        box:AddChild(rawWidget)
    end)

    return box
end

--- Creates a NativeUI window backed by the game's background widget.
-- @param config (table|nil) Window options: x, y, w, h, and zOrder.
-- @return (table|nil) A window object, or nil when the widget cannot be created.
function Window.New(config)
    config = config or {}
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetBackgroundClass()
    if not playerController or not Utils.IsValidObject(widgetClass) then return nil end

    local root = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(root) then return nil end

    local headerBox = nil

    -- Find the header box in the Blueprint widget tree.
    if root.WidgetTree and root.WidgetTree.RootWidget then
        local canvas = root.WidgetTree.RootWidget
        if canvas.GetChildrenCount and canvas.GetChildAt then
            for i = 0, canvas:GetChildrenCount() - 1 do
                local child = canvas:GetChildAt(i)
                if Utils.IsValidObject(child) and (Utils.GetObjectName(child) or ""):find("VerticalBox") then
                    if child.GetChildrenCount and child:GetChildrenCount() > 0 then
                        local first = child:GetChildAt(0)
                        if Utils.IsValidObject(first) and (Utils.GetObjectName(first) or ""):find("HorizontalBox") then
                            headerBox = first
                        end
                    end
                    break
                end
            end
        end
    end

    -- Create the native vertical body container.
    local bodyClass = StaticFindObject(Config.Paths.verticalBoxClass)
    local bodyBox = nil

    if Utils.IsValidObject(bodyClass) then
        bodyBox = Utils.ConstructObject(bodyClass, root)
    end

    -- Inject the body container into the Blueprint content slot.
    local contentSlot = root.ContentSlot
    if contentSlot and contentSlot.SetContent and Utils.IsValidObject(bodyBox) then
        Utils.TryCall("Assign window body", function()
            contentSlot:SetContent(bodyBox)
        end)
    else
        print("[NativeUI Warning] Failed to assign the body container to ContentSlot.")
    end

    local window = setmetatable({
        RootWidget = root,
        HBox = headerBox,
        BodyBox = bodyBox,
        IsOpen = false,
        Position = { X = config.x or 200.0, Y = config.y or 150.0 },
        Size = { X = config.w or 650.0, Y = config.h or 450.0 },
        ZOrder = config.zOrder or 9999,
        Children = {}
    }, Window)

    return window
end

--- Adds a component to the window header.
-- @param component (table|UWidget) Component wrapper or widget to add.
-- @param padding (table|nil) Optional Slate padding.
-- @param verticalAlignment (number|nil) Vertical alignment enum.
function Window:AddHeaderWidget(component, padding, verticalAlignment)
    if not component or not self.HBox then return end
    local rawWidget = component.Widget or component
    if not Utils.IsValidObject(rawWidget) then return end

    Utils.TryCall("Add widget to window header", function()
        local slot = self.HBox:AddChildToHorizontalBox(rawWidget)
        if slot then
            slot:SetSize({ Value = 1.0, SizeRule = Config.Layout.SIZE_FILL })
            slot:SetVerticalAlignment(verticalAlignment or Config.Layout.VERTICAL_CENTER)
            if padding then
                slot:SetPadding(padding)
            end
        end
    end)
    table.insert(self.Children, component)
end

--- Adds a component to the window body.
-- @param widgetItem (table|UWidget) Component wrapper or widget to add.
-- @param constraints (table|nil) Optional padding, width, height, and fill settings.
function Window:AddBodyWidget(widgetItem, constraints)
    if not widgetItem or not self.BodyBox then return end
    constraints = constraints or {}

    local rawWidget = widgetItem.Widget or widgetItem
    if not Utils.IsValidObject(rawWidget) then return end

    local targetWidget = WrapInSizeBox(rawWidget, constraints.width, constraints.height, self.BodyBox)

    Utils.TryCall("Add widget to window body", function()
        local slot = self.BodyBox:AddChildToVerticalBox(targetWidget)
        if slot then
            if constraints.padding then
                slot:SetPadding(constraints.padding)
            else
                slot:SetPadding({ Left = 8.0, Top = 4.0, Right = 8.0, Bottom = 4.0 })
            end

            if constraints.fill and constraints.fill > 0 then
                slot:SetSize({ Value = constraints.fill, SizeRule = Config.Layout.SIZE_FILL })
            else
                slot:SetSize({ Value = 1.0, SizeRule = Config.Layout.SIZE_AUTO })
            end
        end
    end)

    table.insert(self.Children, widgetItem)
end

--- Sets the background blur strength.
-- @param strength (number) Blur strength; zero disables the blur.
function Window:SetBlurStrength(strength)
    local blur = GetBlurWidget(self.RootWidget)
    if not blur then return end

    local val = tonumber(strength) or 0.0
    Utils.TryCall("Set window blur strength", function()
        if blur.SetBlurStrength then
            blur:SetBlurStrength(val)
        else
            blur.BlurStrength = val
        end
        blur:SetVisibility(val <= 0.0 and Config.Visibility.HIDDEN or Config.Visibility.VISIBLE)
    end)
end

--- Disables the background blur.
function Window:DisableBlur()
    self:SetBlurStrength(0.0)
end

--- Shows the window and enables game-and-UI input.
function Window:Show()
    if not self.RootWidget then return end
    self.IsOpen = true

    Utils.TryCall("Show window", function()
        self.RootWidget:AddToViewport(self.ZOrder)
        if self.RootWidget.SetPositionInViewport then
            self.RootWidget:SetPositionInViewport(self.Position, false)
        end
        if self.RootWidget.SetDesiredSizeInViewport then
            self.RootWidget:SetDesiredSizeInViewport(self.Size)
        end
    end)

    for _, child in ipairs(self.Children) do
        if child.Refresh then
            child:Refresh()
        end
    end

    local playerController = Utils.GetPlayerController()
    if playerController then
        Utils.TryCall("Enable window input", function()
            playerController.bShowMouseCursor = true
            playerController.bEnableClickEvents = true
            playerController.bEnableMouseOverEvents = true
            if Core.UMG_Lib and Core.UMG_Lib.SetInputMode_GameAndUIEx then
                Core.UMG_Lib:SetInputMode_GameAndUIEx(
                    playerController,
                    self.RootWidget,
                    Config.Input.MOUSE_LOCK_DO_NOT_LOCK,
                    false,
                    false
                )
            end
        end)
    end
end

--- Hides the window and restores game-only input.
function Window:Hide()
    if not self.RootWidget then return end
    self.IsOpen = false

    Utils.TryCall("Hide window", function()
        self.RootWidget:RemoveFromParent()
    end)

    local playerController = Utils.GetPlayerController()
    if playerController then
        Utils.TryCall("Restore game input", function()
            playerController.bShowMouseCursor = false
            if Core.UMG_Lib and Core.UMG_Lib.SetInputMode_GameOnly then
                Core.UMG_Lib:SetInputMode_GameOnly(playerController, false)
            end
        end)
    end
end

--- Toggles the window visibility.
function Window:Toggle()
    if self.IsOpen then self:Hide() else self:Show() end
end

return Window