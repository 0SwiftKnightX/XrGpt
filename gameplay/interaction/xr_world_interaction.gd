class_name XRGptWorldInteraction
extends Node

## Right Quest controller interaction ray.
## Trigger can mine/collect world drops, move inventory items, or activate creative items.

@export var right_controller_path: NodePath
@export var left_controller_path: NodePath
@export var max_distance := 1.0
@export_flags_3d_physics var interaction_collision_mask := 13
@export var break_damage := 100.0
@export var player_id := "player_1"
@export var inventory_path: NodePath
@export var active_equipment_path: NodePath

var _right_controller: XRController3D
var _left_controller: XRController3D
var _active_controller: XRController3D
var _inventory: XRGptInventoryController
var _active_equipment: XRGptActiveEquipmentController
var _held_item: XRGptItemInstance
var _origin_slot: XRGptItemSlot
var _held_visual: Node3D

signal interaction_succeeded(action_name: String, instance: XRGptItemInstance)
signal interaction_failed(action_name: String, reason: String)
signal item_placed(instance: XRGptItemInstance, world_item: Node3D)
signal item_repicked_up(instance: XRGptItemInstance)

func _ready() -> void:
	_right_controller = get_node_or_null(right_controller_path) as XRController3D
	_left_controller = get_node_or_null(left_controller_path) as XRController3D
	_inventory = get_node_or_null(inventory_path) as XRGptInventoryController
	_active_equipment = get_node_or_null(active_equipment_path) as XRGptActiveEquipmentController
	if _right_controller:
		_right_controller.button_pressed.connect(_on_right_button_pressed)
	if _left_controller:
		_left_controller.button_pressed.connect(_on_left_button_pressed)

func _on_right_button_pressed(action_name: String) -> void:
	_handle_trigger(_right_controller, action_name)

func _on_left_button_pressed(action_name: String) -> void:
	_handle_trigger(_left_controller, action_name)

func _handle_trigger(controller: XRController3D, action_name: String) -> void:
	if action_name != "trigger_click":
		return
	_active_controller = controller
	if _held_item != null:
		_release_held_item()
	else:
		_try_grab_or_world_interaction()

func _try_grab_or_world_interaction() -> void:
	var hit := _raycast(_active_controller)
	if hit.is_empty():
		interaction_failed.emit("trigger_interaction", "no_raycast_hit")
		return

	var slot := _find_item_slot(hit.get("collider") as Node)
	if slot != null and slot.item != null:
		_grab_from_slot(slot)
		return

	var collider := hit.get("collider") as Node
	var creative_button := _find_creative_button(collider)
	if creative_button != null:
		if creative_button.activate():
			interaction_succeeded.emit("creative_item_created", null)
		else:
			interaction_failed.emit("creative_item_activate", "creative_activation_failed")
		return

	if collider is XRGptProceduralPickable:
		_collect_procedural_item(collider as XRGptProceduralPickable)
		return
	if collider is XRGptItemDrop:
		_collect_drop(collider as XRGptItemDrop)
		return
	if collider is XRGptTerrainBlock:
		(collider as XRGptTerrainBlock).damage(break_damage, Vector3.ZERO, player_id)

func _raycast(controller: XRController3D = null) -> Dictionary:
	var source := controller if controller != null else _active_controller
	if source == null:
		return {}
	var from := source.global_position
	var direction := -source.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = interaction_collision_mask
	return get_viewport().get_world_3d().direct_space_state.intersect_ray(query)

func _find_item_slot(node: Node) -> XRGptItemSlot:
	var current := node
	while current != null:
		if current is XRGptItemSlot:
			return current as XRGptItemSlot
		current = current.get_parent()
	return null

func _find_creative_button(node: Node) -> XRGptCreativeItemButton:
	var current := node
	while current != null:
		if current is XRGptCreativeItemButton:
			return current as XRGptCreativeItemButton
		current = current.get_parent()
	return null

func _grab_from_slot(slot: XRGptItemSlot) -> void:
	if slot == null or slot.item == null:
		interaction_failed.emit("slot_grab", "empty_slot")
		return
	_held_item = slot.item
	_origin_slot = slot
	if slot.inventory_slot and _inventory:
		if not _inventory.remove_item_instance(_held_item):
			_held_item = null
			_origin_slot = null
			interaction_failed.emit("slot_grab", "inventory_remove_failed")
			return
	elif not slot.inventory_slot and _active_equipment:
		if not _active_equipment.remove_item(_held_item):
			_held_item = null
			_origin_slot = null
			interaction_failed.emit("slot_grab", "equipment_remove_failed")
	else:
		_held_item = null
		_origin_slot = null
		interaction_failed.emit("slot_grab", "missing_container")
		return
	_create_held_visual()

func _create_held_visual() -> bool:
	if _held_item == null or _active_controller == null:
		return false
	_clear_held_visual()
	var visual: Node3D = XRGptItemRuntime.spawn_instance(_held_item, _active_controller)
	if visual == null:
		return false
	_held_visual = visual
	var body: RigidBody3D = visual as RigidBody3D
	if body != null:
		body.freeze = true
		body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		body.collision_layer = 0
		body.collision_mask = 0
	visual.position = Vector3(0.0, -0.02, -0.12)
	visual.rotation = Vector3.ZERO
	return true

func _clear_held_visual() -> void:
	if _held_visual != null and is_instance_valid(_held_visual):
		_held_visual.queue_free()
	_held_visual = null

func _release_held_item() -> void:
	var hit := _raycast()
	var target := _find_item_slot(hit.get("collider") as Node) if not hit.is_empty() else null
	var placed := false

	if target != null and target != _origin_slot:
		if target.inventory_slot and _inventory:
			placed = _inventory.place_item_in_slot(_held_item, target)
		elif not target.inventory_slot and _active_equipment:
			placed = _active_equipment.place_item_in_slot(_held_item, target)
		if placed:
			_clear_held_visual()
			interaction_succeeded.emit("item_slot_placed", _held_item)
			_held_item = null
			_origin_slot = null
			return

	if not placed and target == null and _held_item != null and _place_held_item_in_world(hit):
		placed = true

	if not placed and _held_item != null and _origin_slot != null:
		if _origin_slot.inventory_slot and _inventory:
			placed = _inventory.place_item_in_slot(_held_item, _origin_slot)
		elif not _origin_slot.inventory_slot and _active_equipment:
			placed = _active_equipment.place_item_in_slot(_held_item, _origin_slot)
		if placed:
			_clear_held_visual()
			interaction_succeeded.emit("item_restored_to_origin", _held_item)

	if not placed and _held_item != null:
		if _inventory and _inventory.add_item_instance(_held_item):
			_clear_held_visual()
			placed = true
			interaction_succeeded.emit("item_returned_to_inventory", _held_item)
		else:
			_clear_held_visual()
			interaction_failed.emit("item_release", "no_valid_destination")

	_held_item = null
	_origin_slot = null

func _collect_drop(drop: XRGptItemDrop) -> void:
	if drop == null:
		interaction_failed.emit("drop_collect", "missing_drop")
		return
	if not drop.is_owned_by(player_id):
		interaction_failed.emit("drop_collect", "owner_mismatch")
		return
	if not drop.auto_collect or _inventory == null:
		interaction_failed.emit("drop_collect", "auto_collect_disabled_or_inventory_missing")
		return
	var definition := XRGptItemCatalog.find_definition(drop.item_id)
	if definition == null:
		interaction_failed.emit("drop_collect", "unknown_item_definition")
		return
	var instance := XRGptItemInstance.new()
	instance.setup(definition, player_id, drop.quantity)
	instance.first_claim_available = drop.first_claim_available
	if _inventory.add_item_instance(instance):
		interaction_succeeded.emit("drop_collected", instance)
		drop.queue_free()
	else:
		interaction_failed.emit("drop_collect", "inventory_full")

func _collect_procedural_item(item: XRGptProceduralPickable) -> bool:
	if item == null:
		interaction_failed.emit("procedural_collect", "missing_item")
		return false
	if _inventory == null:
		interaction_failed.emit("procedural_collect", "inventory_missing")
		return false
	if item.item_instance == null:
		interaction_failed.emit("procedural_collect", "item_instance_missing")
		return false
	var instance := item.item_instance
	var returned := item.return_to_inventory(_inventory, player_id)
	if returned:
		item_repicked_up.emit(instance)
		interaction_succeeded.emit("procedural_repickup", instance)
	else:
		interaction_failed.emit("procedural_collect", "inventory_full_or_owner_mismatch")
	return returned

func _place_held_item_in_world(hit: Dictionary) -> bool:
	if _held_item == null or hit.is_empty():
		return false
	var definition := XRGptItemCatalog.find_definition(_held_item.definition_id)
	if definition == null:
		return false
	var world_item: Node3D = _held_visual
	if world_item == null or not is_instance_valid(world_item):
		world_item = XRGptItemRuntime.spawn_instance(_held_item, get_tree().current_scene)
		if world_item == null:
			return false
	else:
		world_item.reparent(get_tree().current_scene, true)
		_held_visual = null
	var body: RigidBody3D = world_item as RigidBody3D
	if body != null:
		body.freeze = false
		body.collision_layer = 4
		body.collision_mask = 5
	var normal: Vector3 = hit.get("normal", Vector3.UP)
	var position: Vector3 = hit.get("position", Vector3.ZERO)
	world_item.global_position = position + normal.normalized() * 0.06
	item_placed.emit(_held_item, world_item)
	interaction_succeeded.emit("item_placed", _held_item)
	return true
