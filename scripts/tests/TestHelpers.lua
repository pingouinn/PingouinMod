local NativeUI = require("code/NativeUI/init")

local TestHelpers = {}

local windowExists = {}

function TestHelpers.AddMethodButton(window, label, status, callback)
    window:AddBodyWidget(NativeUI.CreateButton(label, function()
        local success, result = pcall(callback)
        if success then
            local message = result == nil and "called" or tostring(result)
            status:SetText(label .. " -> " .. message)
        else
            status:SetText(label .. " -> ERROR: " .. tostring(result))
            print("[NativeUI Test] " .. label .. " failed: " .. tostring(result))
        end
    end))
end

function TestHelpers.RegisterWindowCommand(commandName, testModule, description)
    RegisterConsoleCommandHandler(commandName, function()
        if windowExists[commandName] then 
            windowExists[commandName]:Destroy()
            windowExists[commandName] = nil
            return true 
        end

        windowExists[commandName] = testModule.CreateWindow()
        if windowExists[commandName] then
            print("[NativeUI] " .. description .. " test window created successfully.")
        else
            print("[NativeUI] Failed to create " .. description .. " test window.")
        end
        return true
    end)
end

return TestHelpers
