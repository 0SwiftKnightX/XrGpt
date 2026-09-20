class_name XRGptHudManager
extends Node3D

var component_enabled := {
	"health": true,
	"experience": true,
	"compass": true,
	"coordinates": true,
	"depth_height": true,
	"mini_map": false,
	"passive_equipment": false,
	"passive_abilities": false
}

func set_component_enabled(component_id: String, enabled: bool) -> void:
	if component_enabled.has(component_id):
		component_enabled[component_id] = enabled

func is_component_enabled(component_id: String) -> bool:
	return component_enabled.get(component_id, false)

func set_hud_enabled(enabled: bool) -> void:
	for component_id in component_enabled:
		component_enabled[component_id] = enabled
