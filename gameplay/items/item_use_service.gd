class_name XRGptItemUseService
extends RefCounted

signal item_used(instance: XRGptItemInstance, context: String)

func can_use(instance: XRGptItemInstance, context: String) -> bool:
	if instance == null:
		return false
	if context == "inventory":
		return instance.has_capability(XRGptItemCapability.INVENTORY_USE)
	if context == "world":
		return instance.has_capability(XRGptItemCapability.WORLD_USE)
	return false

func use(instance: XRGptItemInstance, context: String) -> XRGptInventoryResult:
	if not can_use(instance, context):
		return XRGptInventoryResult.failure(XRGptInventoryResult.CAPABILITY_MISSING)
	item_used.emit(instance, context)
	return XRGptInventoryResult.success_result(instance)
