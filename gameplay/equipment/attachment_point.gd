class_name XRGptAttachmentPoint
extends Marker3D

## Data + transform definition for one physical equipment attachment location.

@export_category("Identity")
@export var attachment_id: String = ""
@export var display_name: String = ""
@export var attachment_type: String = "Hand"
@export var side: String = "Right"

@export_category("Compatibility")
@export var accepts_categories: Array[String] = ["Equipment"]
@export var accepted_item_ids: Array[String] = []
@export var slot_ids: Array[String] = []
@export var exclusive: bool = true
@export var enabled: bool = true

@export_category("Attachment Transform")
@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset_degrees: Vector3 = Vector3.ZERO
@export var scale_multiplier: Vector3 = Vector3.ONE

@export_category("Tracking")
@export var tracked_controller_path: NodePath
@export var follow_tracking: bool = true

@export_category("Runtime")
@export var visible_when_empty: bool = false
@export var hide_physics_while_attached: bool = true
@export var current_slot_id: String = ""

func can_attach(instance: XRGptItemInstance) -> bool:
	if not enabled or instance == null:
		return false
	if not slot_ids.is_empty() and not slot_ids.has(current_slot_id):
		return false
	if not accepts_categories.is_empty() and not accepts_categories.has(instance.category):
		return false
	if not accepted_item_ids.is_empty() and not accepted_item_ids.has(instance.definition_id):
		return false
	return true

func set_attachment_state(slot_id: String, occupied: bool) -> void:
	current_slot_id = slot_id if occupied else ""

func get_attachment_transform() -> Transform3D:
	var transform := Transform3D(Basis.IDENTITY, position_offset)
	transform.basis = Basis.from_euler(Vector3(
		deg_to_rad(rotation_offset_degrees.x),
		deg_to_rad(rotation_offset_degrees.y),
		deg_to_rad(rotation_offset_degrees.z)
	))
	transform.basis = transform.basis.scaled(scale_multiplier)
	return transform
