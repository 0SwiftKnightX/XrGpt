class_name XRGptInventoryController
extends Node3D

## First inventory prototype.
## Y on the left controller toggles the physical inventory board.

@export var local_player_id := "player_1"
@export var left_controller_path: NodePath
@export var inventory_distance := 1.15

var inventory_open := false
var _board: Node3D
var _slots: Array[Node3D] = []

func _ready() -> void:
	_board = get_node_or_null("InventoryBoard")
	if _board:
		_board.visible = false
	for child in get_children():
		if child.name.begins_with("InventorySlot"):
			_slots.append(child)
	var left_controller := get_node_or_null(left_controller_path)
	if left_controller and left_controller.has_signal("button_pressed"):
		left_controller.button_pressed.connect(_on_left_controller_button_pressed)

func _on_left_controller_button_pressed(action_name: String) -> void:
	if action_name == "by_button":
		toggle_inventory()

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
