# World Environment Foundation

This directory contains the shared world/environment foundation.

## Current scope

- world_environment_root.tscn provides the world-system root and stable containers for future terrain, biome, resource/spawn, interaction, and persistence systems.
- world_environment_root.gd coordinates the existing main-scene WorldEnvironment and XRGptDayNightCycle without replacing either system.
- day_night_cycle.gd remains the authoritative day/night implementation.
- light_exposure.gd remains the existing lighting/weather hook for future environment consumers.
- xr_player_spawn.gd remains the existing deterministic XR player spawn system.

The foundation intentionally does not implement terrain generation, biome generation, weather simulation, resource spawning, persistence, creatures, vehicles, quests, or multiplayer.


## World data contracts

- `world_region_definition.gd` defines stable region identity, integer region coordinates, physical region dimensions, and local containment checks.
- `biome_definition.gd` defines the minimal data-only biome identity/climate fields needed by later terrain, weather, spawning, and environment systems.
- These resources intentionally contain no generation, scene ownership, persistence, navigation, or runtime spawning logic.
