class_name XRGptBlackCubeTest
extends XRToolsPickable

## Dedicated XR physics test item.
## Grip alone is ordinary pickup/hold behavior supplied by XR Tools.
## Same-hand grip + trigger release throws the cube.
## Opposite-hand grip + trigger release launches the cube along the opposite hand's ray.

@export var left_controller_path: NodePath
@export var right_controller_path: NodePath
@export var throw_speed := 4.5
@export var projectile_speed := 8.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var projectile_max_distance := 10.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var projectile_ray_distance := 10.0
@export_range(0.0, 1.0, 0.05) var opposite_grip_threshold := 0.5

var _trigger_mode := ""
var _trigger_controller: XRController3D

func controller_action(controller: XRController3D) -> void:
	if controller == null:
		return
	_trigger_controller = controller
	if _is_opposite_grip_held(controller):
		_trigger_mode = "projectile"
	else:
		_trigger_mode = "throw"

func controller_action_release(controller: XRController3D) -> void:
	if controller == null or controller != _trigger_controller:
		return
	if _trigger_mode == "projectile" and _is_opposite_grip_held(controller):
		_launch_from_opposite_ray(controller)
	elif _trigger_mode == "throw":
		_throw_from_hand(controller)
	_trigger_mode = ""
	_trigger_controller = null

func action() -> void:
	# Intentionally empty: trigger behavior is handled by controller_action().

func action_release() -> void:
	# Intentionally empty: trigger behavior is handled by controller_action_release().

func _throw_from_hand(controller: XRController3D) -> void:
	var pickup := XRToolsFunctionPickup.find_instance(controller)
	if pickup == null or pickup.picked_up_object != self:
		return
	pickup.drop_object()
	linear_velocity = -controller.global_transform.basis.z * throw_speed

func _launch_from_opposite_ray(holding_controller: XRController3D) -> void:
	var opposite := _get_opposite_controller(holding_controller)
	if opposite == null:
		return
	var pickup := XRToolsFunctionPickup.find_instance(holding_controller)
	if pickup == null or pickup.picked_up_object != self:
		return

	var direction := -opposite.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(
		opposite.global_position,
		opposite.global_position + direction * projectile_ray_distance
	)
	query.exclude = [self]
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		direction = (hit.position - global_position).normalized()

	pickup.drop_object()
	linear_velocity = direction.normalized() * projectile_speed

	var projectile := get_node_or_null("ProjectileRuntime") as XRGptProjectileRuntime
	if projectile:
		projectile.activate(direction, projectile_speed, projectile_max_distance)

func _is_opposite_grip_held(holding_controller: XRController3D) -> bool:
	var opposite := _get_opposite_controller(holding_controller)
	if opposite == null:
		return false
	return opposite.get_float("grip") >= opposite_grip_threshold

func _get_opposite_controller(controller: XRController3D) -> XRController3D:
	var left := get_node_or_null(left_controller_path) as XRController3D
	var right := get_node_or_null(right_controller_path) as XRController3D
	if controller == left:
		return right
	if controller == right:
		return left
	return null
