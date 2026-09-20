class_name XRGptUIManagement
extends RefCounted

var hud_enabled := true
var components := {
	"health": true,
	"experience": true,
	"compass": true,
	"coordinates": true,
	"depth_height": true,
	"mini_map": false,
	"passive_equipment": false,
	"passive_abilities": false
}

func set_hud_enabled(enabled: bool) -> void:
	hud_enabled = enabled

func set_component_enabled(component_id: String, enabled: bool) -> void:
	if components.has(component_id):
		components[component_id] = enabled

func is_component_enabled(component_id: String) -> bool:
	return hud_enabled and components.get(component_id, false)
