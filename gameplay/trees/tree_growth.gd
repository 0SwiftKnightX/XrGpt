class_name XRGptTreeGrowth
extends Node

enum GrowthState {
	SAPLING,
	FULL_GROWN
}

@export var growth_state: GrowthState = GrowthState.SAPLING
@export var growth_seconds: float = 300.0
@export var required_light: float = 0.5

var growth_elapsed := 0.0

func _process(delta: float) -> void:
	if growth_state == GrowthState.FULL_GROWN:
		return
	var light_level := _get_light_level()
	if light_level < required_light:
		return
	growth_elapsed += delta
	if growth_elapsed >= growth_seconds:
		growth_state = GrowthState.FULL_GROWN
		growth_elapsed = 0.0

func _get_light_level() -> float:
	var world_environment := get_viewport().get_world_3d()
	if world_environment == null:
		return 0.0
	var environment := world_environment.environment
	if environment == null:
		return 0.0
	return environment.ambient_light_energy
