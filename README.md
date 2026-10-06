# 🐧 PingouinMod

> A modular modding framework for **Rescue Ops: Wildfire**, powered by UE4SS.

[![UE4SS](https://img.shields.io/badge/Powered%20by-UE4SS-blue)](https://github.com/UE4SS-RE/RE-UE4SS)
[![Game](https://img.shields.io/badge/Game-Rescue%20Ops%3A%20Wildfire-orange)](https://store.steampowered.com/app/2915770/Rescue_Ops_Wildfire/)
[![Language](https://img.shields.io/badge/Language-Lua-blue)](https://www.lua.org/)

## About

**PingouinMod** is a Lua framework and API for extending **Rescue Ops: Wildfire** with custom gameplay features, debugging tools, and development utilities.

The project is built on [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) and provides reusable abstractions for interacting with Unreal Engine objects, actors, vectors, traces, assets, and UE4SS dumps. The goal is to let modders focus on their features instead of repeating low-level engine integration code.

## Documentation

The API reference is generated from the Lua source and published through GitHub Pages:

[![API Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue?style=flat-square)](https://pingouinn.github.io/PingouinMod/)

## Features

### Utility API

The utility facade is exposed through [Utils.lua](scripts/code/utils/Utils.lua) and is split into focused modules:

- [Types.lua](scripts/code/utils/Types.lua): UE4SS values, objects, and vector normalization
- [Math.lua](scripts/code/utils/Math.lua): vector calculations and position comparisons
- [Entity.lua](scripts/code/utils/Entity.lua): players, controllers, cheat managers, and static meshes
- [Player.lua](scripts/code/utils/Player.lua): player-related helpers
- [World.lua](scripts/code/utils/World.lua): traces and surface placement
- [Path.lua](scripts/code/utils/Path.lua): path utilities and UE4SS dump loading

[ShortNamingUtils.lua](scripts/code/system/ShortNamingUtils.lua) adds short, configurable names for Unreal assets. These names are resolved through [config.ini](scripts/config.ini), so commands can use a short name instead of a full asset path.

### Gameplay features

- [PlayerCheat.lua](scripts/code/PlayerCheat.lua): player cheats, including invincibility, increased speed, super jump, and movement adjustments
- [GodMode.lua](scripts/code/GodMode.lua): player god mode
- [Teleport.lua](scripts/code/Teleport.lua): absolute and relative player teleportation
- [NoClip.lua](scripts/code/NoClip.lua): free movement for the player and vehicles, with camera controls
- [Spawner.lua](scripts/code/Spawner.lua): actor and static mesh spawning, tracking, cleanup, and console commands
- [CollisionDeactivator.lua](scripts/code/CollisionDeactivator.lua): collision toggling for supported entities
- [DisableWorldBoundaries.lua](scripts/code/DisableWorldBoundaries.lua): toggleable world-boundary disabling
- [BarrierOpener.lua](scripts/code/BarrierOpener.lua): automatic opening of barriers when approached in a vehicle

### Debugging and development tools

- [EntityOutline.lua](scripts/code/EntityOutline.lua): raycast-based entity selection and visual outlines
- [EntitySelector.lua](scripts/code/EntitySelector.lua): entity selection helpers for inspection and debugging
- [DevUI.lua](scripts/code/DevUI.lua): experimental dashboard for testing the NativeUI components
- [NativeUI](scripts/code/NativeUI/init.lua): reusable windows, rows, columns, buttons, switches, sliders, text, and text-input components
- [GcScheduler.lua](scripts/code/system/GcScheduler.lua): scheduled garbage-collection support

### Dependencies

- [LIP.lua](scripts/dependencies/LIP.lua): Lua INI parser used to load the mod configuration

## Installation

1. Install [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) in your **Rescue Ops: Wildfire** installation directory.
2. Copy the `PingouinMod` folder to:

   ```text
   RescueOps\Wildfire\Binaries\Win64\Mods\
   ```

3. Launch the game. UE4SS should load the mod automatically.
4. Check the UE4SS console for:

   ```text
   [PingouinMod] Mod loaded
   ```

## Configuration

Edit [config.ini](scripts/config.ini) to:

- enable or disable debug output with `DEBUG_MODE`
- change the key used by each feature
- add or update short asset names in the `[ShortNaming]` section

Blueprint class paths must include the `_C` suffix. Short names must be unique and map to a single Unreal asset path.

The default keybinds are:

| Feature | Default key |
| --- | --- |
| Player cheats | `F1` |
| NoClip | `F2` |
| World boundaries | `F5` |
| Entity outline | `F6` |
| God mode | `F7` |
| Collision | `F8` |
| Entity selector | `F9` |

## Console commands

The currently available commands include:

- `pos`: display the current player position
- `tp x y z`: teleport the player to the specified coordinates
- `Spawn <AssetPath or ShortName>`: spawn an actor or static mesh from a full asset path or a configured short name
- `DeleteAll`: delete all actors spawned by the mod

Example:

```text
Spawn /Game/Environment/Props/S_Cone.S_Cone
Spawn CONE
```

## Architecture

The mod is initialized by [main.lua](scripts/main.lua). Core utilities, configuration, gameplay modules, and UI components are loaded as separate modules:

```text
main.lua
├── utils/
│   ├── Utils.lua
│   ├── Types.lua
│   ├── Math.lua
│   ├── Entity.lua
│   ├── Player.lua
│   ├── World.lua
│   └── Path.lua
├── system/
│   ├── ShortNamingUtils.lua
│   └── GcScheduler.lua
├── NativeUI/
├── Gameplay modules
└── dependencies/
    └── LIP.lua
```

## Roadmap

- [ ] Add an object-placer tool
- [ ] Expand the NativeUI-based development tools
- [ ] Model injection

## Contributing

Contributions, bug reports, and suggestions are welcome. Please keep new features modular, document public Lua functions, and update this README when user-facing behavior changes.

## License

PingouinMod is distributed under the [GNU GPL-3.0 License](LICENSE).

You may use, modify, and redistribute the project, provided that derivative works remain open source under the GPL-3.0 license.

## Useful links

- [UE4SS Documentation](https://docs.ue4ss.com/)
- [Rescue Ops: Wildfire on Steam](https://store.steampowered.com/app/2915770/Rescue_Ops_Wildfire/)

---

*Last updated: October 2026*
