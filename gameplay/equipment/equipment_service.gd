class_name XRGptEquipmentService
extends RefCounted

signal equipment_changed(slot_id: String, equipped: XRGptItemInstance, displaced: XRGptItemInstance)

var _slots: Dictionary = {}

func define_slot(slot_id: String, accepted_categories: Array[String] = []) -> void:
	_slots[slot_id] = {"accepted_categories": accepted_categories, "item": null}

func can_equip(slot_id: String, instance: XRGptItemInstance) -> bool:
	if instance == null or not _slots.has(slot_id):
		return false
	if not instance.has_capability(XRGptItemCapability.EQUIPABLE):
		return false
	var accepted: Array = _slots[slot_id]["accepted_categories"]
	return accepted.is_empty() or accepted.has(instance.category)

func get_equipped(slot_id: String) -> XRGptItemInstance:
	if not _slots.has(slot_id):
		return null
	return _slots[slot_id]["item"] as XRGptItemInstance

func equip(slot_id: String, instance: XRGptItemInstance) -> XRGptInventoryResult:
	if not _slots.has(slot_id):
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_CONTAINER)
	if not can_equip(slot_id, instance):
		return XRGptInventoryResult.failure(XRGptInventoryResult.EQUIPMENT_REJECTED)
	var displaced := _slots[slot_id]["item"] as XRGptItemInstance
	_slots[slot_id]["item"] = instance
	equipment_changed.emit(slot_id, instance, displaced)
	return XRGptInventoryResult.success_result(instance, "equipment:" + slot_id)

func unequip(slot_id: String) -> XRGptInventoryResult:
	if not _slots.has(slot_id):
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_CONTAINER)
	var existing := _slots[slot_id]["item"] as XRGptItemInstance
	if existing == null:
		return XRGptInventoryResult.failure(XRGptInventoryResult.ITEM_NOT_FOUND)
	_slots[slot_id]["item"] = null
	equipment_changed.emit(slot_id, null, existing)
	return XRGptInventoryResult.success_result(existing, "equipment:" + slot_id)
