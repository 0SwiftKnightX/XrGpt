class_name XRGptEquipmentSlot
extends XRGptItemSlot

@export var accepted_category: String = ""

func can_accept(candidate: XRGptItemInstance) -> bool:
	if candidate == null:
		return false
	if accepted_category.is_empty():
		return true
	return candidate.definition_id.begins_with(accepted_category)
