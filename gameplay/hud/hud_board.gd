class_name XRGptHudBoard
extends Node3D

@export var camera_path: NodePath
@export var distance := 1.55
@export var vertical_offset := 0.12

var _camera: XRCamera3D

func _ready() -> void:
	_camera = get_node_or_null(camera_path) as XRCamera3D

func _process(_delta: float) -> void:
	if _camera == null:
		return
	var t := _camera.global_transform
	global_position = t.origin - t.basis.z * distance + Vector3.UP * vertical_offset
	look_at(t.origin, Vector3.UP)
