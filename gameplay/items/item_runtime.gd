class_name XRGptItemRuntime
extends RefCounted

## Bridges an authoritative inventory ItemInstance to its procedural 3D runtime.
## The generated node carries the same item instance; no duplicate definition is created.

static func spawn_instance(instance: XRGptItemInstance) -> Node3D:
	if instance == null or instance.definition_id.is_empty():
		return null
	var definition := XRGptItemCatalog.find_definition(instance.definition_id)
	if definition == null:
		return null
	return XRGptItemProceduralFactory.create_world_item(definition, instance.owner_id, instance)

static func spawn_definition(definition: XRGptItemDefinition, owner_id: String = "player_1") -> Node3D:
	if definition == null:
		return null
	var instance := XRGptItemInstance.new()
	instance.setup(definition, owner_id)
	return spawn_instance(instance)
