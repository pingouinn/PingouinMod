local NativeUI = require("code/NativeUI/init")
local Entity = require("code/Utils/Entity")
local TestHelpers = require("tests/TestHelpers")
local Spawner = require("code/Spawner")

local EntityTest = {}
local referenceEntity = nil

function EntityTest.CreateWindow()
    local window = NativeUI.CreateWindow({ w = 900.0, h = 850.0 })
    if not window then return nil end
    local status = NativeUI.CreateText("Select an Entity method to test.", nil, true)
    window:AddHeaderWidget(NativeUI.CreateTitle("Entity tests"))
    window:AddBodyWidget(status)

    local function addButton(label, callback)
        TestHelpers.AddMethodButton(window, label, status, callback)
    end

    addButton("Setup Entity", function() 
        referenceEntity = Spawner.SpawnActor("CCFM")
    end)

    addButton("GetActorLocation", function() return Entity.GetActorLocation(referenceEntity) or "nil" end)
    addButton("GetObjectName", function() return Entity.GetObjectName(referenceEntity) or "nil" end)
    addButton("HasObjectName", function() return Entity.HasObjectName(referenceEntity, "CCFM") end)
    addButton("ResolveStaticMesh", function()
        return Entity.ResolveStaticMesh("/Game/Invalid/SM_Test.SM_Test", referenceEntity) or "nil"
    end)
    addButton("GetEntityKey", function() return Entity.GetEntityKey(referenceEntity) or "nil" end)
    addButton("GetTopLevelEntity", function() return Entity.GetTopLevelEntity(referenceEntity) or "nil" end)
    addButton("DisableEntityCollision", function() 
        Entity.DisableEntityCollision(referenceEntity) 
        return Entity.GetActorSpawnCollisionMethod(referenceEntity)
    end)


    window:Show()
    return window
end

TestHelpers.RegisterWindowCommand("TestEntity", EntityTest, "Entity")

return EntityTest
