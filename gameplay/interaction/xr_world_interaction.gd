class_name XRGptWorldInteraction
extends Node

## Minimal Quest interaction prototype:
## right-trigger ray breaks the first terrain block it hits.
## Inventory remains on the Y button and is handled by InventoryController.

@export var right_controller_path: NodePath
@export var max_distance := 8.0
@export var break_damage := 100.0
@export var player_id := "player_1"

var _right_controller: XRController3D

func _ready() -> void:
	_right_controller = get_node_or_null(right_controller_path) as XRController3D
	if _right_controller:
		_right_controller.button_pressed.connect(_on_right_button_pressed)

func _on_right_button_pressed(action_name: String) -> void:
	if action_name != "trigger_click":
		return
	_break_target()

func _break_target() -> void:
	if _right_controller == null:
		return
	var from := _right_controller.global_position
	var direction := -_right_controller.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = false
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider := hit.get("collider") as Node
	if collider is XRGptTerrainBlock:
		(collider as XRGptTerrainBlock).damage(break_damage, direction, player_id)
