class_name XRGptRayPointer
extends Node3D

## Quest controller interaction ray.
## The ray itself is intentionally simple now; its appearance can be customized later
## by player settings/items without changing interaction logic.

@export var max_distance := 8.0
@export_flags_3d_physics var pointer_collision_mask := 13
@export var pointer_radius := 0.006
@export var default_color := Color(0.4, 0.75, 1.0, 0.55)
@export var hit_color := Color(0.8, 1.0, 0.9, 0.85)

var _ray_mesh: MeshInstance3D
var _controller: XRController3D
var _material: StandardMaterial3D
var _reticle: MeshInstance3D
var _reticle_material: StandardMaterial3D

func _ready() -> void:
	_controller = get_parent() as XRController3D
	_ray_mesh = get_node_or_null("Ray") as MeshInstance3D
	_reticle = get_node_or_null("Reticle") as MeshInstance3D
	if _reticle:
		_reticle_material = _reticle.get_active_material(0) as StandardMaterial3D
		if _reticle_material:
			_reticle_material = _reticle_material.duplicate() as StandardMaterial3D
			_reticle.material_override = _reticle_material
	if _ray_mesh:
		_material = _ray_mesh.get_active_material(0) as StandardMaterial3D
		if _material:
			_material = _material.duplicate() as StandardMaterial3D
			_ray_mesh.material_override = _material
			set_ray_color(default_color)

func set_ray_color(color: Color) -> void:
	default_color = color
	if _material:
		_material.albedo_color = color
		_material.emission_enabled = true
		_material.emission = Color(color.r, color.g, color.b, 1.0)
	_set_reticle_color(color)

func _set_reticle_color(color: Color) -> void:
	if _reticle_material:
		_reticle_material.albedo_color = color
		_reticle_material.emission_enabled = true
		_reticle_material.emission = Color(color.r, color.g, color.b, 1.0)

func _process(_delta: float) -> void:
	if _controller == null or _ray_mesh == null:
		return
	var from := _controller.global_position
	var direction := -_controller.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * max_distance)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = pointer_collision_mask
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
	var distance := max_distance
	if not hit.is_empty():
		distance = from.distance_to(hit.position)
	_ray_mesh.position = Vector3(0.0, 0.0, -distance * 0.5)
	_ray_mesh.scale = Vector3(1.0, distance, 1.0)
	if _reticle:
		_reticle.visible = not hit.is_empty()
		if not hit.is_empty():
			_reticle.global_position = hit.position
			_set_reticle_color(hit_color)
