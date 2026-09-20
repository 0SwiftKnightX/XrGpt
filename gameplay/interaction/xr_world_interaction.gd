class_name XRGptWorldInteraction
extends Node

## Minimal Quest interaction prototype:
## right-trigger ray breaks the first terrain block it hits.
## Inventory remains on the Y button and is handled by InventoryController.

@export var right_controller_path: NodePath
@export var max_distance := 8.0
@export var break_damage := 100.0
@export var player_id := "player_1"
@export var inventory_path: NodePath

var _right_controller: XRController3D
var _inventory: Node

func _ready() -> void:
	_right_controller = get_node_or_null(right_controller_path) as XRController3D
	_inventory = get_node_or_null(inventory_path)
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
	if collider is XRGptItemDrop:
		_collect_drop(collider as XRGptItemDrop)
		return
	if collider is XRGptTerrainBlock:
		(collider as XRGptTerrainBlock).damage(break_damage, Vector3.ZERO, player_id)

func _collect_drop(drop: XRGptItemDrop) -> void:
	if not drop.is_owned_by(player_id):
		return
	if not drop.auto_collect or _inventory == null:
		return
	var instance := XRGptItemInstance.new()
	instance.definition_id = drop.item_id
	instance.quantity = drop.quantity
	instance.owner_id = player_id
	instance.first_claim_available = drop.first_claim_available
	if _inventory.has_method("add_item_instance") and _inventory.add_item_instance(instance):
		drop.queue_free()
