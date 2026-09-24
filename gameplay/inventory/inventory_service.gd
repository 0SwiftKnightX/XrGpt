class_name XRGptInventoryService
extends RefCounted

signal item_added(instance: XRGptItemInstance, container: XRGptInventoryContainer)
signal item_removed(instance: XRGptItemInstance, container: XRGptInventoryContainer)
signal item_moved(instance: XRGptItemInstance, from_container: XRGptInventoryContainer, to_container: XRGptInventoryContainer)

func add_item(container: XRGptInventoryContainer, instance: XRGptItemInstance) -> XRGptInventoryResult:
	if container == null:
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_CONTAINER)
	var result := container.add_instance(instance)
	if result.success:
		item_added.emit(instance, container)
	return result

func remove_item(container: XRGptInventoryContainer, instance: XRGptItemInstance) -> XRGptInventoryResult:
	if container == null:
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_CONTAINER)
	var result := container.remove_instance(instance)
	if result.success:
		item_removed.emit(instance, container)
	return result

func move_item(from_container: XRGptInventoryContainer, to_container: XRGptInventoryContainer, instance: XRGptItemInstance) -> XRGptInventoryResult:
	if from_container == null or to_container == null:
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_CONTAINER)
	if from_container == to_container:
		return XRGptInventoryResult.failure(XRGptInventoryResult.SAME_LOCATION)
	if not from_container.contains(instance):
		return XRGptInventoryResult.failure(XRGptInventoryResult.ITEM_NOT_FOUND)
	if to_container.max_slots > 0 and to_container.get_items().size() >= to_container.max_slots:
		return XRGptInventoryResult.failure(XRGptInventoryResult.CAPACITY_FULL)
	var removed := from_container.remove_instance(instance)
	if not removed.success:
		return removed
	var added := to_container.add_instance(instance)
	if not added.success:
		from_container.add_instance(instance)
		return added
	item_moved.emit(instance, from_container, to_container)
	return added
