class_name XRGptInventoryController
extends Node3D

@export var local_player_id := "player_1"
@export var left_controller_path: NodePath
@export var camera_path: NodePath
@export var inventory_distance := 1.15
@export var inventory_height_offset := -0.12

var inventory_open := false
var items: Array[XRGptItemInstance] = []
var _board: Node3D
var _camera: XRCamera3D
var _slots: Array[XRGptItemSlot] = []

signal item_added(instance: XRGptItemInstance, slot: XRGptItemSlot)
signal item_removed(instance: XRGptItemInstance, slot: XRGptItemSlot)
signal item_returned(instance: XRGptItemInstance)

func _ready() -> void:
	_board = get_node_or_null("InventoryBoard")
	_camera = get_node_or_null(camera_path) as XRCamera3D
	_cache_slots()
	if _board:
		_board.visible = false
	var left_controller := get_node_or_null(left_controller_path)
	if left_controller and left_controller.has_signal("button_pressed"):
		left_controller.button_pressed.connect(_on_left_controller_button_pressed)

func _cache_slots() -> void:
	_slots.clear()
	for child in get_children():
		if child is XRGptItemSlot:
			_slots.append(child as XRGptItemSlot)
	_slots.sort_custom(func(a, b): return a.slot_id < b.slot_id)

func _process(_delta: float) -> void:
	if not inventory_open or _board == null or _camera == null:
		return
	var camera_transform := _camera.global_transform
	_board.global_position = camera_transform.origin - camera_transform.basis.z * inventory_distance + Vector3.UP * inventory_height_offset
	_board.look_at(camera_transform.origin, Vector3.UP)

func _on_left_controller_button_pressed(action_name: String) -> void:
	if action_name == "by_button":
		toggle_inventory()

func add_item_instance(instance: XRGptItemInstance) -> bool:
	if instance == null:
		return false
	var existing_slot := _find_slot_for_instance(instance)
	if existing_slot != null:
		if not items.has(instance):
			items.append(instance)
		item_added.emit(instance, existing_slot)
		return true
	for slot in _slots:
		if slot.item == null and slot.set_item(instance):
			if not items.has(instance):
				items.append(instance)
			item_added.emit(instance, slot)
			return true
	return false

func remove_item_instance(instance: XRGptItemInstance) -> bool:
	var index := items.find(instance)
	if index < 0:
		return false
	var slot := _find_slot_for_instance(instance)
	items.remove_at(index)
	if slot != null and slot.item == instance:
		slot.clear_item()
	item_removed.emit(instance, slot)
	return true

func place_item_in_slot(instance: XRGptItemInstance, slot: XRGptItemSlot) -> bool:
	if instance == null or slot == null:
		return false
	if not slot.set_item(instance):
		return false
	if not items.has(instance):
		items.append(instance)
	item_added.emit(instance, slot)
	return true

func return_active_item(instance: XRGptItemInstance) -> bool:
	var added := add_item_instance(instance)
	if added:
		item_returned.emit(instance)
	return added

func _find_slot_for_instance(instance: XRGptItemInstance) -> XRGptItemSlot:
	for slot in _slots:
		if slot.item == instance:
			return slot
	return null

func get_slots() -> Array[XRGptItemSlot]:
	return _slots

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	if _board:
		_board.visible = inventory_open

func open_inventory() -> void:
	inventory_open = true
	if _board:
		_board.visible = true

func close_inventory() -> void:
	inventory_open = false
	if _board:
		_board.visible = false
