class_name XRGptActiveEquipmentSlot
extends XRGptItemSlot

@export var slot_index: int = 0

func return_item_to_inventory(inventory: Node) -> bool:
	if item == null:
		return false
	if inventory.has_method("return_active_item"):
		var accepted: bool = inventory.return_active_item(item)
		if accepted:
			item = null
		return accepted
	return false
