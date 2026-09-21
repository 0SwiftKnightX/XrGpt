class_name XRGptAttachmentProfile
extends Resource

## Item-side attachment contract. Both the item and attachment point must agree.

@export_category("Attachment Identity")
@export var attachment_types: Array[String] = []
@export var preferred_sides: Array[String] = []
@export var allowed_attachment_ids: Array[String] = []

@export_category("Model-Specific Transform")
@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset_degrees: Vector3 = Vector3.ZERO
@export var scale_multiplier: Vector3 = Vector3.ONE

func accepts_point(point: XRGptAttachmentPoint) -> bool:
	if point == null or not point.enabled:
		return false
	if not attachment_types.is_empty() and not attachment_types.has(point.attachment_type):
		return false
	if not preferred_sides.is_empty() and not preferred_sides.has(point.side):
		return false
	if not allowed_attachment_ids.is_empty() and not allowed_attachment_ids.has(point.attachment_id):
		return false
	return true

func get_transform() -> Transform3D:
	var result := Transform3D(Basis.IDENTITY, position_offset)
	result.basis = Basis.from_euler(Vector3(
		deg_to_rad(rotation_offset_degrees.x),
		deg_to_rad(rotation_offset_degrees.y),
		deg_to_rad(rotation_offset_degrees.z)
	))
	result.basis = result.basis.scaled(scale_multiplier)
	return result
