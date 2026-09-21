class_name XRGptAttachmentPoint
extends Marker3D

## Data carried by a physical attachment location.
## The transform comes from the tracked hand/controller; these fields describe
## what the location is allowed to receive.

@export var attachment_id: String = ""
@export var attachment_type: String = "Hand"
@export var side: String = "Right"
@export var accepts_categories: Array[String] = ["Equipment"]
@export var slot_ids: Array[String] = []
@export var enabled: bool = true

func can_attach(instance: XRGptItemInstance) -> bool:
	if not enabled or instance == null:
		return false
	if not slot_ids.is_empty() and instance.definition_id.is_empty():
		return false
	if not accepts_categories.is_empty() and not accepts_categories.has(instance.category):
		return false
	return true
