class_name XRGptActiveEquipmentController
extends Node3D

@export var camera_path: NodePath
@export var distance := 0.95
@export var vertical_offset := -0.48

var is_open := true
var _board: Node3D
var _camera: XRCamera3D
var _slots: Array[XRGptItemSlot] = []

func _ready() -> void:
	_board = get_node_or_null("ActiveEquipmentBoard")
	_camera = get_node_or_null(camera_path) as XRCamera3D
	_cache_slots()
	if _board:
		_board.visible = is_open

func _cache_slots() -> void:
	_slots.clear()
	if _board == null:
		return
	for child in _board.get_children():
		if child is XRGptItemSlot:
			_slots.append(child as XRGptItemSlot)
	_slots.sort_custom(func(a, b): return a.slot_id < b.slot_id)

func _process(_delta: float) -> void:
	if not is_open or _board == null or _camera == null:
		return
	var camera_transform := _camera.global_transform
	_board.global_position = camera_transform.origin - camera_transform.basis.z * distance + Vector3.UP * vertical_offset
	_board.look_at(camera_transform.origin, Vector3.UP)

func get_slots() -> Array[XRGptItemSlot]:
	return _slots

func toggle() -> void:
	is_open = not is_open
	if _board:
		_board.visible = is_open

func place_item(instance: XRGptItemInstance) -> bool:
	for slot in _slots:
		if slot.set_item(instance):
			return true
	return false

func place_item_in_slot(instance: XRGptItemInstance, slot: XRGptItemSlot) -> bool:
	if instance == null or slot == null or slot.inventory_slot:
		return false
	if not _slots.has(slot):
		return false
	for existing in _slots:
		if existing.item == instance:
			return false
	return slot.set_item(instance)

func remove_item(instance: XRGptItemInstance) -> bool:
	for slot in _slots:
		if slot.item == instance:
			slot.clear_item()
			return true
	return false
