class_name XRGptAttachmentController
extends Node3D

## Resolves equipment slots to attachment points by identity and compatibility.
## There is no hard-coded "slot 01 = right hand" rule.

@export var attachment_root_path: NodePath

var _attachment_points: Array[XRGptAttachmentPoint] = []
var _attached_visuals: Dictionary = {}
var _slot_attachments: Dictionary = {}

signal attachment_succeeded(slot_id: String, attachment_id: String)
signal attachment_failed(slot_id: String, reason: String)
signal attachment_detached(slot_id: String, attachment_id: String)

func _ready() -> void:
	_refresh_attachment_points()

func _refresh_attachment_points() -> void:
	_attachment_points.clear()
	var root: Node = get_node_or_null(attachment_root_path) if not attachment_root_path.is_empty() else self
	if root == null:
		root = self
	_collect_attachment_points(root)

func _collect_attachment_points(node: Node) -> void:
	for child: Node in node.get_children():
		if child is XRGptAttachmentPoint:
			_attachment_points.append(child as XRGptAttachmentPoint)
		_collect_attachment_points(child)

func attach_slot(slot: XRGptItemSlot) -> bool:
	if slot == null or slot.item == null:
		attachment_failed("" if slot == null else slot.slot_id, "EMPTY_SLOT")
		return false
	_refresh_attachment_points()
	var attachment: XRGptAttachmentPoint = _find_attachment_for_slot(slot)
	if attachment == null:
		attachment_failed(slot.slot_id, "NO_COMPATIBLE_ATTACHMENT")
		return false
	if attachment.exclusive and not attachment.current_slot_id.is_empty() and attachment.current_slot_id != slot.slot_id:
		attachment_failed(slot.slot_id, "ATTACHMENT_OCCUPIED")
		return false
	detach_slot(slot)
	attachment.current_slot_id = slot.slot_id
	if not attachment.can_attach(slot.item):
		attachment.current_slot_id = ""
		attachment_failed(slot.slot_id, "COMPATIBILITY_REJECTED")
		return false
	var visual: Node3D = XRGptItemRuntime.spawn_instance(slot.item, attachment)
	if visual == null:
		attachment.current_slot_id = ""
		attachment_failed(slot.slot_id, "RUNTIME_VISUAL_FAILED")
		return false
	var body: RigidBody3D = visual as RigidBody3D
	if body != null and attachment.hide_physics_while_attached:
		body.freeze = true
		body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		body.collision_layer = 0
		body.collision_mask = 0
	visual.transform = attachment.get_attachment_transform(slot.item)
	_attached_visuals[slot.slot_id] = visual
	_slot_attachments[slot.slot_id] = attachment
	slot.item.attachment_id = attachment.attachment_id
	slot.item.attachment_type = attachment.attachment_type
	slot.item.attachment_side = attachment.side
	attachment.set_attachment_state(slot.slot_id, true)
	attachment_succeeded.emit(slot.slot_id, attachment.attachment_id)
	return true

func detach_slot(slot: XRGptItemSlot) -> void:
	if slot == null:
		return
	var detached_attachment_id := ""
	var known_attachment: XRGptAttachmentPoint = _slot_attachments.get(slot.slot_id) as XRGptAttachmentPoint
	var visual: Node3D = _attached_visuals.get(slot.slot_id) as Node3D
	if visual != null and is_instance_valid(visual):
		visual.queue_free()
	var attachment: XRGptAttachmentPoint = known_attachment
	if attachment != null:
		detached_attachment_id = attachment.attachment_id
		attachment.set_attachment_state(slot.slot_id, false)
	if slot.item != null:
		slot.item.clear_attachment_state()
	_attached_visuals.erase(slot.slot_id)
	_slot_attachments.erase(slot.slot_id)
	if not detached_attachment_id.is_empty():
		attachment_detached.emit(slot.slot_id, detached_attachment_id)

func get_attachment_points() -> Array[XRGptAttachmentPoint]:
	_refresh_attachment_points()
	return _attachment_points

func _find_attachment_for_slot(slot: XRGptItemSlot) -> XRGptAttachmentPoint:
	if slot == null or slot.item == null:
		return null
	for point in _attachment_points:
		if not point.enabled:
			continue
		if not point.slot_ids.is_empty() and not point.slot_ids.has(slot.slot_id):
			continue
		if point.exclusive and not point.current_slot_id.is_empty() and point.current_slot_id != slot.slot_id:
			continue
		var previous_slot_id := point.current_slot_id
		point.current_slot_id = slot.slot_id
		if point.can_attach(slot.item):
			return point
		point.current_slot_id = previous_slot_id
	return null
