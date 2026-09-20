class_name XRGptRayPointer
extends Node3D

@export var max_distance := 8.0
@export var pointer_radius := 0.006

var _ray_mesh: MeshInstance3D
var _controller: XRController3D

func _ready() -> void:
	_controller = get_parent() as XRController3D
	_ray_mesh = get_node_or_null("Ray") as MeshInstance3D

func _process(_delta: float) -> void:
	if _controller == null or _ray_mesh == null:
		return
	var from := _controller.global_position
	var direction := -_controller.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = true
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
	var distance := max_distance
	if not hit.is_empty():
		distance = from.distance_to(hit.position)
	_ray_mesh.position = Vector3(0.0, 0.0, -distance * 0.5)
	_ray_mesh.scale = Vector3(1.0, distance, 1.0)
