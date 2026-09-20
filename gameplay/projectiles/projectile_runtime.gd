class_name XRGptProjectileRuntime
extends Node

## Reusable projectile lifetime module.
## Attach this as a child of a physics body that should become a projectile.

@export_custom(PROPERTY_HINT_NONE, "suffix:m") var max_distance := 10.0
@export var destroy_on_impact := true

var _active := false
var _start_position := Vector3.ZERO

signal projectile_finished(reason: String)

func _ready() -> void:
	var body := get_parent() as RigidBody3D
	if body:
		body.body_entered.connect(_on_body_entered)

func activate(direction: Vector3, speed: float, distance_limit: float = -1.0) -> void:
	var body := get_parent() as RigidBody3D
	if body == null:
		return
	var launch_direction := direction.normalized()
	if launch_direction.length_squared() < 0.0001:
		return
	max_distance = distance_limit if distance_limit > 0.0 else max_distance
	_start_position = body.global_position
	_active = true
	body.continuous_cd = true
	body.linear_velocity = launch_direction * speed

func deactivate(reason: String = "manual") -> void:
	if not _active:
		return
	_active = false
	projectile_finished.emit(reason)

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
