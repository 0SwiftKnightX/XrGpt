class_name XRGptBlackCubeTest
extends XRGptProceduralPickable

## Dedicated XR physics test item.
## Grip alone is ordinary pickup/hold behavior supplied by XR Tools.
## Same-hand grip + trigger release throws the cube.
## Opposite-hand grip + trigger release launches the cube along the opposite hand's ray.

enum TestState {
	IDLE,
	HELD,
	THROW_READY,
	PROJECTILE_READY,
	THROWN,
	PROJECTILE
}

@export var left_controller_path: NodePath
@export var right_controller_path: NodePath
@export var throw_speed := 4.5
@export var projectile_speed := 8.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var projectile_max_distance := 10.0
@export var launch_feedback_time := 0.15
@export var throw_feedback_time := 0.15
@export_range(0.0, 1.0, 0.05) var opposite_grip_threshold := 0.5

var _trigger_mode := ""
var _trigger_controller: XRController3D
var _state := TestState.IDLE
var _feedback_tween: Tween
var _base_scale := Vector3.ONE

signal test_state_changed(state: TestState)
signal test_action_fired(action_name: String)

func _ready() -> void:
	_base_scale = scale
	ensure_item_instance("test.black_cube", "player_1")
	var projectile := get_node_or_null("ProjectileRuntime") as XRGptProjectileRuntime
	if projectile:
		projectile.projectile_started.connect(_on_projectile_started)
		projectile.projectile_finished.connect(_on_projectile_finished)

func controller_action(controller: XRController3D) -> void:
	if controller == null:
		return
	_trigger_controller = controller
	if _is_opposite_grip_held(controller):
		_set_state(TestState.PROJECTILE_READY)
		_trigger_mode = "projectile"
	else:
		_set_state(TestState.THROW_READY)
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
	pass

func action_release() -> void:
	# Intentionally empty: trigger behavior is handled by controller_action_release().
	pass

func _throw_from_hand(controller: XRController3D) -> void:
	var pickup := XRToolsFunctionPickup.find_instance(controller)
	if pickup == null or pickup.picked_up_object != self:
		return
	pickup.drop_object()
	linear_velocity = -controller.global_transform.basis.z * throw_speed
	_set_state(TestState.THROWN)
	test_action_fired.emit("throw")
	_show_feedback(throw_feedback_time)

func _launch_from_opposite_ray(holding_controller: XRController3D) -> void:
	var opposite := _get_opposite_controller(holding_controller)
	if opposite == null:
		return
	var pickup := XRToolsFunctionPickup.find_instance(holding_controller)
	if pickup == null or pickup.picked_up_object != self:
		return

	var direction := -opposite.global_transform.basis.z
	pickup.drop_object()

	var projectile := get_node_or_null("ProjectileRuntime") as XRGptProjectileRuntime
	if projectile:
		_set_state(TestState.PROJECTILE)
		projectile.activate(direction, projectile_speed, projectile_max_distance)
	else:
		linear_velocity = direction.normalized() * projectile_speed
		_set_state(TestState.PROJECTILE)
	test_action_fired.emit("projectile_launch")
	_show_feedback(launch_feedback_time)

func _is_opposite_grip_held(holding_controller: XRController3D) -> bool:
	var opposite := _get_opposite_controller(holding_controller)
	if opposite == null:
		return false
	return opposite.get_float("grip") >= opposite_grip_threshold

func _get_opposite_controller(controller: XRController3D) -> XRController3D:
	var left := _resolve_controller(left_controller_path, "LeftController")
	var right := _resolve_controller(right_controller_path, "RightController")
	if controller == left:
		return right
	if controller == right:
		return left
	return null

func _resolve_controller(path: NodePath, fallback_name: String) -> XRController3D:
	if not path.is_empty():
		var configured := get_node_or_null(path) as XRController3D
		if configured != null:
			return configured
	var scene := get_tree().current_scene
	if scene != null:
		return scene.find_child(fallback_name, true, false) as XRController3D
	return null

func _set_state(new_state: TestState) -> void:
	if _state == new_state:
		return
	_state = new_state
	test_state_changed.emit(_state)

func _show_feedback(duration: float) -> void:
	var visual := get_node_or_null("Visual") as MeshInstance3D
	if visual == null:
		return
	if _feedback_tween:
		_feedback_tween.kill()
	visual.scale = _base_scale * 1.35
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(visual, "scale", _base_scale, duration)

func _on_projectile_started() -> void:
	_set_state(TestState.PROJECTILE)

func _on_projectile_finished(reason: String) -> void:
	test_action_fired.emit("projectile_finished:" + reason)
