class_name XRGptItemSlot
extends Node3D

var item: XRGptItemInstance

func can_accept(_candidate: XRGptItemInstance) -> bool:
	return true

func set_item(candidate: XRGptItemInstance) -> bool:
	if not can_accept(candidate):
		return false
	item = candidate
	return true

func clear_item() -> XRGptItemInstance:
	var previous := item
	item = null
	return previous
