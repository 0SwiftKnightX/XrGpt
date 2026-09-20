class_name XRGptCreativeItemIndex
extends Node3D

@export var owner_inventory_path: NodePath
@export var initial_role: XRGptPlayerPermissions.Role = XRGptPlayerPermissions.Role.GUEST
var permissions := XRGptPlayerPermissions.new()
var catalog: Array[XRGptItemDefinition] = []

signal item_created(instance: XRGptItemInstance)
signal world_item_generated(instance: XRGptItemInstance, world_item: Node3D)
signal world_item_spawned(instance: XRGptItemInstance, world_item: Node3D)

func _ready() -> void:
	permissions.set_role_authoritative(initial_role)
	_refresh_catalog()

func _refresh_catalog() -> void:
	catalog.clear()
	for definition in XRGptItemCatalog.get_all_definitions():
		if definition != null:
			catalog.append(definition)

func set_role_authoritative(new_role: XRGptPlayerPermissions.Role) -> void:
	permissions.set_role_authoritative(new_role)

func can_open() -> bool:
	return permissions.can_use_creative()

func add_definition(definition: XRGptItemDefinition) -> bool:
	if definition == null or definition.item_id.is_empty():
		return false
	var canonical := XRGptItemCatalog.find_definition(definition.item_id)
	if canonical == null or canonical != definition:
		return false
	for existing in catalog:
		if existing != null and existing.item_id == definition.item_id:
			return true
	catalog.append(canonical)
	return true

func get_definition(item_id: String) -> XRGptItemDefinition:
	for definition in catalog:
		if definition != null and definition.item_id == item_id:
			return definition
	return null

func get_catalog() -> Array[XRGptItemDefinition]:
	return catalog.duplicate()

func create_item(definition: XRGptItemDefinition, owner_id: String) -> XRGptItemInstance:
	if not can_open() or definition == null:
		return null
	var canonical := XRGptItemCatalog.find_definition(definition.item_id)
	if canonical == null or canonical != definition:
		return null
	var instance := XRGptItemInstance.new()
	instance.setup(canonical, owner_id)
	var inventory := get_node_or_null(owner_inventory_path)
	if inventory and inventory.has_method("add_item_instance"):
		if inventory.add_item_instance(instance):
			item_created.emit(instance)
			return instance
	return null

func generate_world_item(definition: XRGptItemDefinition, owner_id: String = "player_1") -> Node3D:
	if not can_open() or definition == null:
		return null
	var canonical := XRGptItemCatalog.find_definition(definition.item_id)
	if canonical == null or canonical != definition:
		return null
	var instance := XRGptItemInstance.new()
	instance.setup(canonical, owner_id)
	var world_item := XRGptItemRuntime.spawn_instance(instance, get_tree().current_scene)
	if world_item != null:
		world_item_generated.emit(instance, world_item)
	return world_item

func spawn_item_instance(instance: XRGptItemInstance) -> Node3D:
	if not can_open() or instance == null:
		return null
	if not XRGptItemCatalog.contains_definition(instance.definition_id):
		return null
	var world_item := XRGptItemRuntime.spawn_instance(instance, get_tree().current_scene)
	if world_item != null:
		world_item_spawned.emit(instance, world_item)
	return world_item
