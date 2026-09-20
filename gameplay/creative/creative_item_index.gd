class_name XRGptCreativeItemIndex
extends Node3D

@export var owner_inventory_path: NodePath
var permissions := XRGptPlayerPermissions.new()
var catalog: Array[XRGptItemDefinition] = []

func _ready() -> void:
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
	if definition == null:
		return false
	for existing in catalog:
		if existing != null and existing.item_id == definition.item_id:
			return true
	catalog.append(definition)
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
	var instance := XRGptItemInstance.new()
	instance.setup(definition, owner_id)
	var inventory := get_node_or_null(owner_inventory_path)
	if inventory and inventory.has_method("add_item_instance"):
		if inventory.add_item_instance(instance):
			return instance
	return null

func generate_world_item(definition: XRGptItemDefinition, owner_id: String = "player_1") -> Node3D:
	if not can_open() or definition == null:
		return null
	return XRGptItemProceduralFactory.create_world_item(definition, owner_id)
