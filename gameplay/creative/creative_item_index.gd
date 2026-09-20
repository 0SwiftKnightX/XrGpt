class_name XRGptCreativeItemIndex
extends Node3D

@export var owner_inventory_path: NodePath
var permissions := XRGptPlayerPermissions.new()
var catalog: Array[XRGptItemDefinition] = []

func set_role_authoritative(new_role: XRGptPlayerPermissions.Role) -> void:
	permissions.set_role_authoritative(new_role)

func can_open() -> bool:
	return permissions.can_use_creative()

func add_definition(definition: XRGptItemDefinition) -> bool:
	if not can_open() or definition == null:
		return false
	catalog.append(definition)
	return true

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
