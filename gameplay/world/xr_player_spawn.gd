class_name XRGptPlayerSpawn
extends Node

## Places the XR origin at a deterministic world spawn instead of relying on
## the scene's saved transform. This keeps the player's real-world tracking
## offset intact while giving the game a known floor-level starting point.

@export var player_origin_path: NodePath
@export var start_xr_path: NodePath
@export var spawn_position := Vector3(0.0, 0.0, 0.8)
@export var spawn_rotation_degrees := Vector3(0.0, 0.0, 0.0)

var _player_origin: XROrigin3D
var _start_xr: XRToolsStartXR

func _ready() -> void:
	_player_origin = get_node_or_null(player_origin_path) as XROrigin3D
	_start_xr = get_node_or_null(start_xr_path) as XRToolsStartXR
	_apply_spawn()
	if _start_xr != null:
		_start_xr.xr_started.connect(_on_xr_started)

func _on_xr_started() -> void:
	_apply_spawn()

func _apply_spawn() -> void:
	if _player_origin == null:
		return
	_player_origin.global_position = spawn_position
	_player_origin.global_rotation_degrees = spawn_rotation_degrees
