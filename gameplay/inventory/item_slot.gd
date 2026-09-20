class_name XRGptItemSlot
extends Node3D

@export var slot_id := ""
@export var accepts_category := ""
@export var inventory_slot := true

var item: XRGptItemInstance
var _label: Label3D

func _ready() -> void:
	_label = get_node_or_null("ItemLabel") as Label3D
	_refresh_visual()

func can_accept(candidate: XRGptItemInstance) -> bool:
	if candidate == null or item != null:
		return false
	if accepts_category.is_empty():
		return true
	return candidate.category == accepts_category

func set_item(candidate: XRGptItemInstance) -> bool:
	if not can_accept(candidate):
		return false
	item = candidate
	_refresh_visual()
	return true

func clear_item() -> XRGptItemInstance:
	var previous := item
	item = null
	_refresh_visual()
	return previous

func _refresh_visual() -> void:
	if _label == null:
		return
	if item == null:
		_label.text = ""
	else:
		_label.text = item.display_name + (" x" + str(item.quantity) if item.quantity > 1 else "")
