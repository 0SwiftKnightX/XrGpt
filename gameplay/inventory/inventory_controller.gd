class_name XRGptInventoryController
extends Node3D

## First physical inventory prototype.
## Y on the left controller toggles the board.
## The board follows the player's head only while it is open.

@export var local_player_id := "player_1"
@export var left_controller_path: NodePath
@export var camera_path: NodePath
@export var inventory_distance := 1.15
@export var inventory_height_offset := -0.12

var inventory_open := false
var _board: Node3D
var _camera: XRCamera3D

func _ready() -> void:
	_board = get_node_or_null("InventoryBoard")
	_camera = get_node_or_null(camera_path) as XRCamera3D
	if _board:
		_board.visible = false
	var left_controller := get_node_or_null(left_controller_path)
	if left_controller and left_controller.has_signal("button_pressed"):
		left_controller.button_pressed.connect(_on_left_controller_button_pressed)

func _process(_delta: float) -> void:
	if not inventory_open or _board == null or _camera == null:
		return
	var camera_transform := _camera.global_transform
	_board.global_position = camera_transform.origin - camera_transform.basis.z * inventory_distance + Vector3.UP * inventory_height_offset
	_board.look_at(camera_transform.origin, Vector3.UP)

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
