class_name XRGptAttachmentPoint
extends Marker3D

## A physical attachment location. Item definitions also carry an attachment
## profile; attachment succeeds only when both contracts match.

@export_category("Identity")
@export var attachment_id: String = ""
@export var display_name: String = ""
@export_enum("Hand", "Finger", "Head", "Body", "Back", "Waist", "Foot", "Custom")
var attachment_type: String = "Hand"
@export_enum("Any", "Left", "Right")
var side: String = "Any"

@export_category("Compatibility")
@export var accepts_categories: Array[String] = ["Equipment"]
@export var accepted_item_ids: Array[String] = []
@export var accepted_rarities: Array[String] = []
@export var slot_ids: Array[String] = []
@export var exclusive: bool = true
@export var enabled: bool = true

@export_category("Attachment Transform")
## Default location transform. Item profiles contribute model-specific offsets.
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
	return can_attach_for_slot(instance, current_slot_id)

func can_attach_for_slot(instance: XRGptItemInstance, candidate_slot_id: String) -> bool:
	if not enabled or instance == null:
		return false
	if not slot_ids.is_empty() and not slot_ids.has(candidate_slot_id):
		return false
	if exclusive and not current_slot_id.is_empty() and current_slot_id != candidate_slot_id:
		return false
	if not accepts_categories.is_empty() and not accepts_categories.has(instance.category):
		return false
	if not accepted_item_ids.is_empty() and not accepted_item_ids.has(instance.definition_id):
		return false
	if not accepted_rarities.is_empty() and not accepted_rarities.has(instance.rarity):
		return false
	var definition: XRGptItemDefinition = XRGptItemCatalog.find_definition(instance.definition_id)
	if definition == null or definition.attachment_profile == null:
		return false
	return definition.attachment_profile.accepts_point(self)

func set_attachment_state(slot_id: String, occupied: bool) -> void:
	current_slot_id = slot_id if occupied else ""

func get_attachment_transform(instance: XRGptItemInstance = null) -> Transform3D:
	var result := Transform3D(Basis.IDENTITY, position_offset)
	result.basis = Basis.from_euler(Vector3(
		deg_to_rad(rotation_offset_degrees.x),
		deg_to_rad(rotation_offset_degrees.y),
		deg_to_rad(rotation_offset_degrees.z)
	))
	result.basis = result.basis.scaled(scale_multiplier)
	if instance != null:
		var definition: XRGptItemDefinition = XRGptItemCatalog.find_definition(instance.definition_id)
		if definition != null and definition.attachment_profile != null:
			result = result * definition.attachment_profile.get_transform()
	return result
