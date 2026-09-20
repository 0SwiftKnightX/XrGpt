class_name XRGptWorldInteraction
extends Node

## Right Quest controller interaction ray.
## Trigger can mine/collect world drops or physically move inventory items.

@export var right_controller_path: NodePath
@export var max_distance := 8.0
@export var break_damage := 100.0
@export var player_id := "player_1"
@export var inventory_path: NodePath
@export var active_equipment_path: NodePath

var _right_controller: XRController3D
var _inventory: XRGptInventoryController
var _active_equipment: XRGptActiveEquipmentController
var _held_item: XRGptItemInstance
var _origin_slot: XRGptItemSlot

func _ready() -> void:
	_right_controller = get_node_or_null(right_controller_path) as XRController3D
	_inventory = get_node_or_null(inventory_path) as XRGptInventoryController
	_active_equipment = get_node_or_null(active_equipment_path) as XRGptActiveEquipmentController
	if _right_controller:
		_right_controller.button_pressed.connect(_on_right_button_pressed)

func _on_right_button_pressed(action_name: String) -> void:
	if action_name != "trigger_click":
		return
	if _held_item != null:
		_release_held_item()
	else:
		_try_grab_or_world_interaction()

func _try_grab_or_world_interaction() -> void:
	var hit := _raycast()
	if hit.is_empty():
		return

	var slot := _find_item_slot(hit.get("collider") as Node)
	if slot != null and slot.item != null:
		_grab_from_slot(slot)
		return

	var collider := hit.get("collider") as Node
	if collider is XRGptItemDrop:
		_collect_drop(collider as XRGptItemDrop)
		return
	if collider is XRGptTerrainBlock:
		(collider as XRGptTerrainBlock).damage(break_damage, Vector3.ZERO, player_id)

func _raycast() -> Dictionary:
	if _right_controller == null:
		return {}
	var from := _right_controller.global_position
	var direction := -_right_controller.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = true
	return get_viewport().get_world_3d().direct_space_state.intersect_ray(query)

func _find_item_slot(node: Node) -> XRGptItemSlot:
	var current := node
	while current != null:
		if current is XRGptItemSlot:
			return current as XRGptItemSlot
		current = current.get_parent()
	return null

func _grab_from_slot(slot: XRGptItemSlot) -> void:
	_held_item = slot.clear_item()
	_origin_slot = slot
	if _held_item == null:
		return

	if slot.inventory_slot and _inventory:
		_inventory.remove_item_instance(_held_item)
	elif not slot.inventory_slot and _active_equipment:
		_active_equipment.remove_item(_held_item)

func _release_held_item() -> void:
	var hit := _raycast()
	var target := _find_item_slot(hit.get("collider") as Node) if not hit.is_empty() else null
	var placed := false

	if target != null and target != _origin_slot and target.set_item(_held_item):
		placed = true
		if target.inventory_slot and _inventory:
			if not _inventory.items.has(_held_item):
				_inventory.items.append(_held_item)
		_held_item = null
		_origin_slot = null
		return

	if _origin_slot != null and _origin_slot.set_item(_held_item):
		placed = true
		if _origin_slot.inventory_slot and _inventory and not _inventory.items.has(_held_item):
			_inventory.items.append(_held_item)

	if not placed and _held_item != null:
		if _inventory and _inventory.add_item_instance(_held_item):
			placed = true

	_held_item = null
	_origin_slot = null

func _collect_drop(drop: XRGptItemDrop) -> void:
	if not drop.is_owned_by(player_id):
		return
	if not drop.auto_collect or _inventory == null:
		return
	var instance := XRGptItemInstance.new()
	instance.definition_id = drop.item_id
	instance.display_name = drop.item_name
	instance.category = "Blocks"
	instance.quantity = drop.quantity
	instance.owner_id = player_id
	instance.first_claim_available = drop.first_claim_available
	if _inventory.add_item_instance(instance):
		drop.queue_free()
