class_name XRGptWorldEnvironmentRoot
extends Node3D

## Lightweight world/environment coordinator.
## This foundation owns world-system containers while preserving the existing
## WorldEnvironment and DayNightCycle implementations in the main scene.

@export var world_environment_path: NodePath = NodePath("../WorldEnvironment")
@export var day_night_cycle_path: NodePath = NodePath("../DayNightCycle")

func get_world_environment() -> WorldEnvironment:
	return get_node_or_null(world_environment_path) as WorldEnvironment

func get_day_night_cycle() -> XRGptDayNightCycle:
	return get_node_or_null(day_night_cycle_path) as XRGptDayNightCycle

func is_foundation_ready() -> bool:
	return get_world_environment() != null and get_day_night_cycle() != null
