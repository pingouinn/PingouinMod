local Core = require("code/NativeUI/Core")
local Config = require("code/NativeUI/Config")

local Window = {}
Window.__index = Window

local BgClass = nil

--- Resolves and caches the NativeUI background widget class.
-- @return (UClass|nil) The background widget class.
local function GetClass()
    if not BgClass then
        BgClass = StaticFindObject(Config.Paths.backgroundClass)
    end
    return BgClass
end

--- Gets the blur component of the window's root widget, if available.
-- @return (UBackgroundBlur|nil) The blur component, or nil if not found.
local function GetBlurWidget(instance)
    if not Utils.IsValidObject(instance) then return nil end

    if Utils.IsValidObject(instance.BackgroundBlur_0) then
        return instance.BackgroundBlur_0
    end

    if Utils.IsValidObject(instance.WidgetTree) then
        local tree = instance.WidgetTree

        if tree.FindWidget then
            local ok, blur = pcall(function() return tree:FindWidget("BackgroundBlur_0") end)
            if ok and Utils.IsValidObject(blur) then
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

--- Creates a NativeUI window backed by the game's background widget.
-- @param config (table|nil) Window options: x, y, w, h, and zOrder.
-- @return (table|nil) A window object, or nil when the widget cannot be created.
function Window.New(config)
    config = config or {}
    Core.Init()
    local playerController = Utils.GetPlayerController()
    local widgetClass = GetClass()
    if not playerController or not widgetClass then return nil end

    local root = Core.UMG_Lib:Create(playerController, widgetClass, playerController)
    if not Utils.IsValidObject(root) then return nil end

    local VBoxMain = nil
    local HBoxHeader = nil
    local VBoxBody = nil

    -- Dynamic search for the main vertical box, header horizontal box, and body vertical box within the widget tree
    if root.WidgetTree and root.WidgetTree.RootWidget then
        local Canvas = root.WidgetTree.RootWidget
        if Canvas.GetChildrenCount and Canvas.GetChildAt then
            for i = 0, Canvas:GetChildrenCount() - 1 do
                local child = Canvas:GetChildAt(i)
                if Utils.IsValidObject(child) then
                    local name = Utils.GetObjectName(child:GetClass())
                    if name and name:match("VerticalBox") then
                        VBoxMain = child
                        break
                    end
                end
            end
        end
    end

    if VBoxMain and VBoxMain.GetChildrenCount and VBoxMain.GetChildAt then
        for i = 0, VBoxMain:GetChildrenCount() - 1 do
            local child = VBoxMain:GetChildAt(i)
            if Utils.IsValidObject(child) then
                local name = Utils.GetObjectName(child:GetClass())
                if name and name:match("HorizontalBox") and not HBoxHeader then
                    HBoxHeader = child
                elseif name and name:match("VerticalBox") and child ~= VBoxMain and not VBoxBody then
                    VBoxBody = child
                end
            end
        end
    end

    -- Default fallbacks if the expected boxes are not found
    if not HBoxHeader and VBoxMain and VBoxMain:GetChildrenCount() > 0 then
        HBoxHeader = VBoxMain:GetChildAt(0)
    end
    if not VBoxBody then
        VBoxBody = VBoxMain
    end

    local window = setmetatable({
        RootWidget = root,
        VBox = VBoxMain,
        HBox = HBoxHeader,
        BodyBox = VBoxBody,
        IsOpen = false,
        Position = {X = config.x or 200.0, Y = config.y or 150.0},
        Size = {X = config.w or 650.0, Y = config.h or 450.0},
        ZOrder = config.zOrder or 9999,
        Children = {}
    }, Window)

    return window
end

--- Adds a component to the window header.
-- @param component (table|UWidget) Component wrapper or widget to add.
-- @param padding (table|nil) Optional Slate padding.
function Window:AddHeaderWidget(component, padding)
    if not component then return end
    local rawWidget = component.Widget or component

    if self.HBox and rawWidget and self.HBox.AddChildToHorizontalBox then
        local success, errorMessage = pcall(function()
            local slot = self.HBox:AddChildToHorizontalBox(rawWidget)
            if slot then
                padding = padding or {Left = 16.0, Top = 8.0, Right = 0.0, Bottom = 0.0}
                slot:SetPadding(padding)
            end
        end)
        if not success then print("[NativeUI Error] AddHeaderWidget failed: " .. tostring(errorMessage)) end
    end
    table.insert(self.Children, component)
end

--- Adds a component to the window body.
-- @param widgetItem (table|UWidget) Component wrapper or widget to add.
-- @param padding (table|nil) Optional Slate padding.
function Window:AddBodyWidget(widgetItem, padding)
    if not widgetItem then
        print("[NativeUI Error] AddBodyWidget : widgetItem is nil !")
        return
    end

    -- Extraction robuste du UObject si c'est une table de composant
    local actualWidget = widgetItem
    if type(widgetItem) == "table" then
        actualWidget = widgetItem.Widget or widgetItem
    end

    if not self.BodyBox then
        print("[NativeUI Error] AddBodyBox : BodyBox is not found on this window !")
        return
    end

    if not actualWidget then
        print("[NativeUI Error] AddBodyWidget : The UObject to add is nil !")
        return
    end

    local success, errorMessage = pcall(function()
        local slot = self.BodyBox:AddChildToVerticalBox(actualWidget)
        if slot and padding then
            slot:SetPadding(padding)
        end
    end)
    if not success then
        print("[NativeUI Error] AddBodyWidget failed: " .. tostring(errorMessage))
        return
    end

    table.insert(self.Children, widgetItem)
end

-- Sets the blur strenght of the window's background blur widget.
-- @param strength (number) Blur strength value (0.0 = completely sharp / disabled, 10.0 = default game blur).
function Window:SetBlurStrength(strength)
    local blur = GetBlurWidget(self.RootWidget)
    if not blur then return end

    local val = tonumber(strength) or 0.0
    pcall(function()
        if blur.SetBlurStrength then
            blur:SetBlurStrength(val)
        else
            blur.BlurStrength = val
        end

        -- If the blur strength is 0.0 or less, collapse the blur widget to avoid unnecessary rendering.
        if val <= 0.0 then
            blur:SetVisibility(2) -- Collapsed
        else
            blur:SetVisibility(0) -- Visible
        end
    end)
end

-- Disables the blur effect on the window's background by setting the blur strength to 0.0.
function Window:DisableBlur()
    self:SetBlurStrength(0.0)
end

--- Shows the window and switches the player to game-and-UI input.
function Window:Show()
    if not self.RootWidget then return end
    self.IsOpen = true

    local success, errorMessage = pcall(function()
        self.RootWidget:AddToViewport(self.ZOrder)

        if self.RootWidget.SetPositionInViewport then
            self.RootWidget:SetPositionInViewport(self.Position, false)
        end
        if self.RootWidget.SetDesiredSizeInViewport then
            self.RootWidget:SetDesiredSizeInViewport(self.Size)
        end
    end)
    if not success then print("[NativeUI Error] Show failed: " .. tostring(errorMessage)) end

    for _, child in ipairs(self.Children) do
        if child.Refresh then
            child:Refresh()
        end
    end

    local playerController = Utils.GetPlayerController()
    if playerController then
        local success, errorMessage = pcall(function()
            playerController.bShowMouseCursor = true
            playerController.bEnableClickEvents = true
            playerController.bEnableMouseOverEvents = true

            local umgLibrary = Core.UMG_Lib
            if umgLibrary and umgLibrary.SetInputMode_GameAndUIEx then
                umgLibrary:SetInputMode_GameAndUIEx(playerController, self.RootWidget, 0, false, false)
            end
        end)
        if not success then print("[NativeUI Error] Show input setup failed: " .. tostring(errorMessage)) end
    end
end

--- Hides the window and restores game-only input.
function Window:Hide()
    if not self.RootWidget then return end
    self.IsOpen = false

    local success, errorMessage = pcall(function()
        self.RootWidget:RemoveFromParent()
    end)
    if not success then print("[NativeUI Error] Hide failed: " .. tostring(errorMessage)) end

    local playerController = Utils.GetPlayerController()
    if playerController then
        local success, errorMessage = pcall(function()
            playerController.bShowMouseCursor = false
            local umgLibrary = Core.UMG_Lib
            if umgLibrary and umgLibrary.SetInputMode_GameOnly then
                umgLibrary:SetInputMode_GameOnly(playerController, false)
            end
        end)
        if not success then print("[NativeUI Error] Hide input setup failed: " .. tostring(errorMessage)) end
    end
end

--- Toggles the window visibility.
function Window:Toggle()
    if self.IsOpen then self:Hide() else self:Show() end
end

return Window