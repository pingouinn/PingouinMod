----- STATIC DATA -----
UEHelpers = require("UEHelpers")
GB_StrToBool = {["true"]=true, ["TRUE"]=true, ["True"]=true, ["false"]=false, ["FALSE"]=false, ["False"]=false}
Constants = require("code/Constants")


-- Make an exception for the utils module to be loaded first because we depend on it
Utils = require("code/utils/Utils")

---- Dependencies -----
LIP = require("dependencies/LIP") -- Lua INI Parser

-- Set INI path for LIP
local info = debug.getinfo(1, "S")
local raw_script_path = info.source:sub(2)
local clean_script_path = Utils.SanitizePath(raw_script_path) 
SCRIPT_DIR = clean_script_path:match("(.*[/\\])")
print("[PingouinMod] Config INI path: " .. SCRIPT_DIR .. "config.ini")
LIP.INIPATH = SCRIPT_DIR .. "config.ini"

local ConfigData = LIP.loadWrapper()
local SettingsConfig = ConfigData.Settings or {}
local KeybindConfig = ConfigData.Keybinds or {}

local function ResolveConfiguredKey(settingName, defaultKey)
	local keyName = string.upper(tostring(KeybindConfig[settingName] or defaultKey))
	return Key[keyName] or Key[defaultKey]
end

Keybinds = {
	PlayerCheat = ResolveConfiguredKey("PlayerCheatKey", "F1"),
	NoClip = ResolveConfiguredKey("NoClipKey", "F2"),
	WorldBoundaries = ResolveConfiguredKey("WorldBoundariesKey", "F5"),
	EntityOutline = ResolveConfiguredKey("EntityOutlineKey", "F6"),
	GodMode = ResolveConfiguredKey("GodModeKey", "F7"),
	Collision = ResolveConfiguredKey("CollisionKey", "F8"),
	EntitySelector = ResolveConfiguredKey("EntitySelectorKey", "F9"),
}

MOD_FOLDER = Utils.GetModFolder(clean_script_path)
print("[PingouinMod] Mod folder path: " .. MOD_FOLDER .. "\n")

-- DEBUG_MODE is a global variable that controls whether debug messages and protected calls are printed.
DEBUG_MODE = GB_StrToBool[tostring(SettingsConfig.DEBUG_MODE)] or false

------ File imports ------

-- Sys

ShortNaming = require("code/system/ShortNamingUtils")
GCScheduler = require("code/system/GCScheduler")

-- Gameplay

PlayerCheat = require("code/PlayerCheat")
Teleport = require("code/Teleport")
GodMode = require("code/GodMode")
NoClip = require("code/NoClip")
Spawner = require("code/Spawner")
DisableWorldBoundaries = require("code/DisableWorldBoundaries")
EntityOutline = require("code/EntityOutline")
BarrierOpener = require("code/BarrierOpener")
CollisionDeactivator = require("code/CollisionDeactivator")
EntitySelector = require("code/EntitySelector")
DevUI = require("code/DevUI")

-- UI
NativeUI = require("code/NativeUI/init")

WildFire = Utils.RequireUE4SSDump(MOD_FOLDER .. "/shared/types/Wildfire.lua")
if WildFire == nil then print("[PingouinMod] ERROR: Failed to load Wildfire UE4SS dump\n") end

----- MAIN CODE -----
print("[PingouinMod] Mod loaded\n")