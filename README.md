# 🐧 PingouinMod

> A comprehensive modding framework for Rescue Ops: Wildfire built on UE4SS

[![UE4SS](https://img.shields.io/badge/Powered%20by-UE4SS-blue)](https://github.com/UE4SS-RE/RE-UE4SS)
[![Game](https://img.shields.io/badge/Game-Rescue%20Ops%3A%20Wildfire-orange)](https://store.steampowered.com/app/2915770/Rescue_Ops_Wildfire/)
[![Lua](https://img.shields.io/badge/Language-Lua-blue)](https://www.lua.org/)

## 🎯 About

**PingouinMod** is a framework/API for Rescue Ops: Wildfire designed to facilitate game modding in the future. Built on **UE4SS** (Unreal Engine 4 Scripting System), this mod provides a foundation for developing custom features and development tools.

The main goal is to create a reusable abstraction layer that simplifies interaction with the Unreal Engine API, allowing modders to focus on content creation rather than engine technical details.



## ✨ Features

### 🛠️ Utility Scripts

#### Utility modules
The utility API is exposed through [**Utils.lua**](scripts/code/utils/Utils.lua), split into focused modules:

- [**Types.lua**](scripts/code/utils/Types.lua): UE4SS values, objects, and vector normalization
- [**Math.lua**](scripts/code/utils/Math.lua): vector calculations and position comparisons
- [**Entity.lua**](scripts/code/utils/Entity.lua): players, controllers, cheat managers, and static meshes
- [**World.lua**](scripts/code/utils/World.lua): traces and surface placement
- [**Path.lua**](scripts/code/utils/Path.lua): paths and UE4SS dump loading

#### [**ShortNamingUtils.lua**](scripts/code/ShortNamingUtils.lua)
Short naming system to simplify Unreal asset invocation with automatic path resolution


### 🎮 Gameplay Features
---

#### [**PlayerCheat.lua**](scripts/code/PlayerCheat.lua)
Player cheat mode: invincibility, increased speed, super jump, and movement adjustments

#### [**Teleport.lua**](scripts/code/Teleport.lua)
Complete teleportation system with absolute/relative position support and console commands

#### [**NoClip.lua**](scripts/code/NoClip.lua)
Advanced NoClip mode for player and vehicles with free camera management and custom controls

#### [**Spawner.lua**](scripts/code/Spawner.lua)
UE4 actor and StaticMesh spawning system with entity tracking, garbage collection, and console commands (Spawn/DeleteAll)

### 🔍 Debug Tools

---

#### [**EntityOutline.lua**](scripts/code/EntityOutline.lua)
Raycast detection system and visual entity outline to facilitate debugging and inspection

#### [**BarrierOpener.lua**](scripts/code/BarrierOpener.lua)
Automatic opening of game barriers when the player approaches them in a vehicle

#### [**DisableWorldBoundaries.lua**](scripts/code/DisableWorldBoundaries.lua)
World boundaries disabling (in development)


### 📦 Dependencies
---

#### [**LIP.lua**](scripts/dependencies/LIP.lua)
Lua INI Parser for configuration file management



## 📥 Installation

1. **Prerequisites**: Install [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) in your Rescue Ops: Wildfire folder
2. Place the `PingouinMod` folder in: `RescueOps\Wildfire\Binaries\Win64\Mods\`
3. Launch the game - the mod will load automatically
4. Check the UE4SS console to confirm: `[PingouinMod] Mod loaded`


## 🎯 Usage

### Console Commands

- `pos` - Display current player position
- `tp x y z` - Teleport player to specified coordinates
- `Spawn <AssetPath> or <ShortName>` - Spawn an actor or a StaticMesh from its asset path or ShortNaming if provided in [config.ini](scripts/config.ini)
- Example StaticMesh: `Spawn /Game/Environment/Props/S_Cone.S_Cone`
- `DeleteAll` - Delete all spawned actors

### Keybinds

Configurable in [config.ini](scripts/config.ini)

## 🔧 Architecture

The mod uses a modular architecture where each feature is isolated in its own module:

```
main.lua (Entry Point)
    └── utils/
        ├── Utils.lua (Utility API facade)
        ├── Types.lua
        ├── Math.lua
        ├── Entity.lua
        ├── World.lua
        └── Path.lua
    ├── LIP.lua (INI Parser)
    └── Feature Modules
        ├── PlayerCheat
        ├── Teleport
        ├── NoClip
        ├── Spawner
        ├── EntityOutline
        ├── BarrierOpener
        ├── ShortNamingUtils
        └── DisableWorldBoundaries
```


## 🚀 Roadmap

- [ ] Object Placer
- [ ] Improve robustness
- [ ] Vehicle / Model injection 


## 🤝 Contributing

This project serves as a foundation for future mod development on Rescue Ops: Wildfire. Contributions and suggestions are welcome!


## 📝 License

Developed by **PingouinTheDev** for the Rescue Ops: Wildfire community.
Conceaded under the GPL-3.0 license, you can modify the code and use it, but it still need to be an Open-sourced project under GPL licence.


## 🔗 Useful Links

- [UE4SS Documentation](https://docs.ue4ss.com/)

---

*Last updated: October 2026*
