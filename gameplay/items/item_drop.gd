class_name XRGptItemDrop
extends RigidBody3D

## Physical world item drop.
## The same drop can be rendered solid for its owner or ghosted for other players.

@export var item_id := "rock"
@export var item_name := "Rock"
@export var quantity := 1
@export var owner_id := ""
@export var first_claim_available := true
@export var auto_collect := true
@export var relinquishable := false

var local_player_id := ""
var _settled := false
var _rotation_speed := 1.4

func _ready() -> void:
	can_sleep = false
	angular_damp = 0.15
	angular_velocity = Vector3(0.0, _rotation_speed, 0.0)
	body_entered.connect(_on_body_entered)

func configure_drop(p_item_id: String, p_item_name: String, p_owner_id: String, p_auto_collect: bool, p_relinquishable: bool) -> void:
	item_id = p_item_id
	item_name = p_item_name
	owner_id = p_owner_id
	local_player_id = p_owner_id
	_refresh_visual_state()
	auto_collect = p_auto_collect
	relinquishable = p_relinquishable

func launch_from_block(origin: Vector3, direction: Vector3) -> void:
	global_position = origin
	var launch_direction := direction.normalized()
	if launch_direction.length_squared() < 0.01:
		launch_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
	apply_central_impulse(launch_direction * 0.55 + Vector3.UP * 0.85)
	apply_torque_impulse(Vector3(randf_range(-0.35, 0.35), randf_range(-0.6, 0.6), randf_range(-0.35, 0.35)))

func is_owned_by(local_id: String) -> bool:
	return owner_id.is_empty() or owner_id == local_id

func set_local_owner_view(local_id: String) -> void:
	local_player_id = local_id
	_refresh_visual_state()

func _refresh_visual_state() -> void:
	var visual := get_node_or_null("Visual") as MeshInstance3D
	if visual == null:
		return
	var material := visual.get_active_material(0) as StandardMaterial3D
	if material == null:
		return
	material = material.duplicate() as StandardMaterial3D
	visual.material_override = material
	if material == null:
		return
	material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED if is_owned_by(local_player_id) else BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color.a = 1.0 if is_owned_by(local_player_id) else 0.32

func _on_body_entered(_body: Node) -> void:
	if linear_velocity.length() < 0.35:
		_settled = true
		angular_velocity = Vector3(0.0, _rotation_speed, 0.0)
