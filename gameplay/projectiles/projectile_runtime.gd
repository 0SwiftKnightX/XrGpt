class_name XRGptProjectileRuntime
extends Node

## Reusable projectile lifetime module.
## Attach this as a child of a physics body that should become a projectile.

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var max_distance := 10.0
@export var destroy_on_impact := true
@export var launch_speed := 8.0
@export var gravity_scale := 1.0
@export var linear_damp := 0.0
@export var angular_damp := 0.0

var _active := false
var _start_position := Vector3.ZERO

signal projectile_started
signal projectile_finished(reason: String)

func _ready() -> void:
	var body := get_parent() as RigidBody3D
	if body:
		body.body_entered.connect(_on_body_entered)
		body.linear_damp = linear_damp
		body.angular_damp = angular_damp

func activate(direction: Vector3, speed: float = -1.0, distance_limit: float = -1.0) -> void:
	var body := get_parent() as RigidBody3D
	if body == null:
		return
	var launch_direction := direction.normalized()
	if launch_direction.length_squared() < 0.0001:
		return
	max_distance = distance_limit if distance_limit > 0.0 else max_distance
	var actual_speed := speed if speed > 0.0 else launch_speed
	_start_position = body.global_position
	_active = true
	body.continuous_cd = true
	body.gravity_scale = gravity_scale
	body.linear_velocity = launch_direction * actual_speed
	projectile_started.emit()

func deactivate(reason: String = "manual") -> void:
	if not _active:
		return
	_finish(reason)

func _physics_process(_delta: float) -> void:
	if not _active:
		return
	var body := get_parent() as RigidBody3D
	if body == null:
		_active = false
		return
	if body.global_position.distance_to(_start_position) >= max_distance:
		_finish("distance")

func _on_body_entered(_body: Node) -> void:
	if _active and destroy_on_impact:
		_finish("impact")

func _finish(reason: String) -> void:
	_active = false
	projectile_finished.emit(reason)
	var body := get_parent() as RigidBody3D
	if body:
		body.queue_free()
