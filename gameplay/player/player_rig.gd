class_name XRGptPlayerRig
extends Node3D

## Compact XR humanoid proxy rig. Default height 0.8 m, clamped to 0.5-0.8 m.
## This is the gameplay rig foundation: named bones, per-bone hitboxes,
## finger attachment points, and controller-driven hand closing.

@export_range(0.5, 0.8, 0.025) var height: float = 0.8
@export var left_controller_path: NodePath = NodePath("../LeftController")
@export var right_controller_path: NodePath = NodePath("../RightController")
@export var visible_proxy: bool = true
@export var hitbox_layer: int = 8
@export var hitbox_mask: int = 0

var skeleton: Skeleton3D
var _left_controller: XRController3D
var _right_controller: XRController3D
var _bone_indices: Dictionary = {}

const BONE_LENGTHS := {
	"pelvis": 0.09, "spine": 0.11, "chest": 0.10, "neck": 0.07, "head": 0.12,
	"upper_arm_l": 0.11, "lower_arm_l": 0.11, "hand_l": 0.06,
	"upper_arm_r": 0.11, "lower_arm_r": 0.11, "hand_r": 0.06,
	"upper_leg_l": 0.17, "lower_leg_l": 0.17, "foot_l": 0.08,
	"upper_leg_r": 0.17, "lower_leg_r": 0.17, "foot_r": 0.08,
	"thumb1_l": 0.025, "thumb2_l": 0.022, "thumb3_l": 0.018,
	"index1_l": 0.028, "index2_l": 0.023, "index3_l": 0.018,
	"middle1_l": 0.03, "middle2_l": 0.025, "middle3_l": 0.019,
	"ring1_l": 0.028, "ring2_l": 0.023, "ring3_l": 0.018,
	"little1_l": 0.023, "little2_l": 0.020, "little3_l": 0.016,
	"thumb1_r": 0.025, "thumb2_r": 0.022, "thumb3_r": 0.018,
	"index1_r": 0.028, "index2_r": 0.023, "index3_r": 0.018,
	"middle1_r": 0.03, "middle2_r": 0.025, "middle3_r": 0.019,
	"ring1_r": 0.028, "ring2_r": 0.023, "ring3_r": 0.018,
	"little1_r": 0.023, "little2_r": 0.020, "little3_r": 0.016
}

func _ready() -> void:
	height = clampf(height, 0.5, 0.8)
	_left_controller = get_node_or_null(left_controller_path) as XRController3D
	_right_controller = get_node_or_null(right_controller_path) as XRController3D
	_build_rig()

func _process(_delta: float) -> void:
	if skeleton == null:
		return
	_update_hand_pose(_left_controller, false)
	_update_hand_pose(_right_controller, true)

func _build_rig() -> void:
	skeleton = Skeleton3D.new()
	skeleton.name = "Skeleton3D"
	add_child(skeleton)

	_add_bone("pelvis", -1, Transform3D(Basis.IDENTITY, Vector3(0, height * 0.50, 0)))
	_add_bone("spine", _idx("pelvis"), Transform3D(Basis.IDENTITY, Vector3(0, height * 0.13, 0)))
	_add_bone("chest", _idx("spine"), Transform3D(Basis.IDENTITY, Vector3(0, height * 0.12, 0)))
	_add_bone("neck", _idx("chest"), Transform3D(Basis.IDENTITY, Vector3(0, height * 0.10, 0)))
	_add_bone("head", _idx("neck"), Transform3D(Basis.IDENTITY, Vector3(0, height * 0.07, 0)))

	_add_limb("upper_leg_l", "pelvis", Vector3(-0.07, -0.02, 0), Vector3(0, -height * 0.22, 0))
	_add_limb("lower_leg_l", "upper_leg_l", Vector3.ZERO, Vector3(0, -height * 0.22, 0))
	_add_limb("foot_l", "lower_leg_l", Vector3.ZERO, Vector3(0, -height * 0.08, -0.035))
	_add_limb("upper_leg_r", "pelvis", Vector3(0.07, -0.02, 0), Vector3(0, -height * 0.22, 0))
	_add_limb("lower_leg_r", "upper_leg_r", Vector3.ZERO, Vector3(0, -height * 0.22, 0))
	_add_limb("foot_r", "lower_leg_r", Vector3.ZERO, Vector3(0, -height * 0.08, -0.035))

	_add_limb("upper_arm_l", "chest", Vector3(-0.08, height * 0.045, 0), Vector3(-height * 0.13, 0, 0))
	_add_limb("lower_arm_l", "upper_arm_l", Vector3.ZERO, Vector3(-height * 0.13, 0, 0))
	_add_limb("hand_l", "lower_arm_l", Vector3.ZERO, Vector3(-height * 0.07, 0, 0))
	_add_limb("upper_arm_r", "chest", Vector3(0.08, height * 0.045, 0), Vector3(height * 0.13, 0, 0))
	_add_limb("lower_arm_r", "upper_arm_r", Vector3.ZERO, Vector3(height * 0.13, 0, 0))
	_add_limb("hand_r", "lower_arm_r", Vector3.ZERO, Vector3(height * 0.07, 0, 0))

	_build_fingers("l")
	_build_fingers("r")
	_build_bone_attachments()

func _add_bone(name: String, parent_idx: int, rest: Transform3D) -> void:
	var idx := skeleton.add_bone(name)
	if idx < 0:
		return
	skeleton.set_bone_parent(idx, parent_idx)
	skeleton.set_bone_rest(idx, rest)
	skeleton.set_bone_pose(idx, rest)
	_bone_indices[name] = idx

func _add_limb(name: String, parent_name: String, start: Vector3, offset: Vector3) -> void:
	_add_bone(name, _idx(parent_name), Transform3D(Basis.IDENTITY, start))
	var idx := _idx(name)
	skeleton.set_bone_rest(idx, Transform3D(Basis.IDENTITY, offset))
	skeleton.set_bone_pose(idx, Transform3D(Basis.IDENTITY, offset))

func _build_fingers(side_name: String) -> void:
	var sign := -1.0 if side_name == "l" else 1.0
	var hand_idx := _idx("hand_" + side_name)
	var finger_data := [
		["thumb", Vector3(sign * 0.025, 0.005, -0.015)],
		["index", Vector3(sign * 0.040, 0.010, -0.030)],
		["middle", Vector3(sign * 0.055, 0.012, -0.035)],
		["ring", Vector3(sign * 0.068, 0.010, -0.030)],
		["little", Vector3(sign * 0.078, 0.005, -0.020)]
	]
	for data in finger_data:
		var base: String = data[0]
		var origin: Vector3 = data[1]
		var parent_idx := hand_idx
		for segment in range(1, 4):
			var bone_name := "%s%d_%s" % [base, segment, side_name]
			var step := Vector3(0, 0, -float(BONE_LENGTHS[bone_name]))
			_add_bone(bone_name, parent_idx, Transform3D(Basis.IDENTITY, origin if segment == 1 else Vector3.ZERO))
			var idx := _idx(bone_name)
			skeleton.set_bone_rest(idx, Transform3D(Basis.IDENTITY, step))
			skeleton.set_bone_pose(idx, Transform3D(Basis.IDENTITY, step))
			parent_idx = idx

func _build_bone_attachments() -> void:
	for bone_name in _bone_indices.keys():
		var idx: int = _bone_indices[bone_name]
		var attachment := BoneAttachment3D.new()
		attachment.name = "Bone_" + bone_name
		attachment.bone_idx = idx
		skeleton.add_child(attachment)
		_add_bone_proxy(attachment, bone_name)
		_add_bone_hitbox(attachment, bone_name)
		_add_finger_attachment_point(attachment, bone_name)

func _add_bone_proxy(parent: Node3D, bone_name: String) -> void:
	if not visible_proxy:
		return
	var length: float = float(BONE_LENGTHS.get(bone_name, 0.04))
	var mesh_instance := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.height = maxf(length, 0.012)
	mesh.radius = minf(maxf(length * 0.16, 0.006), 0.025)
	mesh.radial_segments = 6
	mesh.rings = 3
	mesh_instance.mesh = mesh
	mesh_instance.position.z = -length * 0.5
	parent.add_child(mesh_instance)

func _add_bone_hitbox(parent: Node3D, bone_name: String) -> void:
	var length: float = float(BONE_LENGTHS.get(bone_name, 0.04))
	var area := Area3D.new()
	area.name = "Hitbox_" + bone_name
	area.collision_layer = hitbox_layer
	area.collision_mask = hitbox_mask
	area.set_meta("bone_name", bone_name)
	area.set_meta("damage_target", self)
	parent.add_child(area)
	var shape_node := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.height = maxf(length, 0.012)
	shape.radius = minf(maxf(length * 0.16, 0.006), 0.025)
	shape_node.shape = shape
	shape_node.position.z = -length * 0.5
	area.add_child(shape_node)

func _add_finger_attachment_point(parent: Node3D, bone_name: String) -> void:
	if not bone_name.begins_with("ring3_"):
		return
	var point := XRGptAttachmentPoint.new()
	point.name = "RingAttachmentPoint"
	point.attachment_type = "Finger"
	point.side = "Left" if bone_name.ends_with("_l") else "Right"
	point.attachment_id = "finger.%s.ring" % ("left" if point.side == "Left" else "right")
	point.position_offset = Vector3(0, 0, -0.01)
	point.accepts_categories = ["Equipment"]
	parent.add_child(point)

func _update_hand_pose(controller: XRController3D, is_right: bool) -> void:
	if controller == null:
		return
	var grip := clampf(controller.get_float("grip"), 0.0, 1.0)
	_set_hand_clench("r" if is_right else "l", grip)

func _set_hand_clench(side_name: String, amount: float) -> void:
	var bones := ["thumb1", "thumb2", "thumb3", "index1", "index2", "index3", "middle1", "middle2", "middle3", "ring1", "ring2", "ring3", "little1", "little2", "little3"]
	for bone_base in bones:
		var bone_name := "%s_%s" % [bone_base, side_name]
		var idx := _idx(bone_name)
		if idx < 0:
			continue
		var angle := deg_to_rad(18.0 + 34.0 * amount)
		if bone_base.begins_with("thumb"):
			angle *= 0.75
		var rest := skeleton.get_bone_rest(idx)
		var rotation := Quaternion(Vector3.RIGHT, angle)
		skeleton.set_bone_pose(idx, Transform3D(Basis(rotation), rest.origin))

func _idx(name: String) -> int:
	if skeleton == null:
		return -1
	return int(_bone_indices.get(name, skeleton.find_bone(name)))
