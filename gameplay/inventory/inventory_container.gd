class_name XRGptInventoryContainer
extends RefCounted

signal changed(container: XRGptInventoryContainer)

var container_id: String = ""
var max_slots: int = 0
var _items: Array[XRGptItemInstance] = []

func setup(id: String, capacity: int = 0) -> void:
	container_id = id
	max_slots = maxi(capacity, 0)

func get_items() -> Array[XRGptItemInstance]:
	return _items.duplicate()

func contains(instance: XRGptItemInstance) -> bool:
	return instance != null and _items.has(instance)

func add_instance(instance: XRGptItemInstance) -> XRGptInventoryResult:
	if instance == null or instance.definition_id.is_empty():
		return XRGptInventoryResult.failure(XRGptInventoryResult.INVALID_ITEM)
	if contains(instance):
		return XRGptInventoryResult.failure(XRGptInventoryResult.SAME_LOCATION)
	if max_slots > 0 and _items.size() >= max_slots:
		return XRGptInventoryResult.failure(XRGptInventoryResult.CAPACITY_FULL)
	_items.append(instance)
	changed.emit(self)
	return XRGptInventoryResult.success_result(instance, container_id)

func remove_instance(instance: XRGptItemInstance) -> XRGptInventoryResult:
	var index := _items.find(instance)
	if index < 0:
		return XRGptInventoryResult.failure(XRGptInventoryResult.ITEM_NOT_FOUND)
	_items.remove_at(index)
	changed.emit(self)
	return XRGptInventoryResult.success_result(instance, container_id)

func find_instance(instance_id: String) -> XRGptItemInstance:
	if instance_id.is_empty():
		return null
	for instance in _items:
		if instance.instance_id == instance_id:
			return instance
	return null

func clear() -> void:
	_items.clear()
	changed.emit(self)
