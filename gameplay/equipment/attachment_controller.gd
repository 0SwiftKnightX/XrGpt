class_name XRGptAttachmentController
extends Node3D

## First attachment layer: equipment can become a physical child of a tracked
## hand/controller without changing the inventory item instance.

@export var right_hand_attachment_path: NodePath
@export var left_hand_attachment_path: NodePath

var _right_hand_attachment: XRGptAttachmentPoint
var _left_hand_attachment: XRGptAttachmentPoint
var _attached_visuals: Dictionary = {}

func _ready() -> void:
	_right_hand_attachment = get_node_or_null(right_hand_attachment_path) as XRGptAttachmentPoint
	_left_hand_attachment = get_node_or_null(left_hand_attachment_path) as XRGptAttachmentPoint

func attach_slot(slot: XRGptItemSlot) -> bool:
	if slot == null or slot.item == null:
		return false
	var attachment: XRGptAttachmentPoint = _attachment_for_slot(slot)
	if attachment == null:
		return false
	attachment.current_slot_id = slot.slot_id
	if not attachment.can_attach(slot.item):
		attachment.current_slot_id = ""
		return false
		return false
	detach_slot(slot)
	var visual: Node3D = XRGptItemRuntime.spawn_instance(slot.item, attachment)
	if visual == null:
		return false
	var body: RigidBody3D = visual as RigidBody3D
	if body != null:
		body.freeze = true
		body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		body.collision_layer = 0
		body.collision_mask = 0
	var attachment_transform: Transform3D = attachment.get_attachment_transform()
	visual.position = attachment_transform.origin
	visual.basis = attachment_transform.basis
	_attached_visuals[slot.slot_id] = visual
	attachment.set_attachment_state(slot.slot_id, true)
	return true

func detach_slot(slot: XRGptItemSlot) -> void:
	if slot == null:
		return
	var visual: Node3D = _attached_visuals.get(slot.slot_id) as Node3D
	if visual != null and is_instance_valid(visual):
		visual.queue_free()
	var attachment: XRGptAttachmentPoint = _attachment_for_slot(slot)
	if attachment != null:
		attachment.set_attachment_state(slot.slot_id, false)
	_attached_visuals.erase(slot.slot_id)

func _attachment_for_slot(slot: XRGptItemSlot) -> XRGptAttachmentPoint:
	match slot.slot_id:
		"01":
			return _right_hand_attachment
		"02":
			return _left_hand_attachment
		_:
			return null
