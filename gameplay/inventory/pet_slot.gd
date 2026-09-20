class_name XRGptPetSlot
extends XRGptItemSlot

func can_accept(candidate: XRGptItemInstance) -> bool:
	return candidate != null and candidate.definition_id.begins_with("pet.")
