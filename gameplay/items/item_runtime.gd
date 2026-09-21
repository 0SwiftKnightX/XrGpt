class_name XRGptItemRuntime
extends RefCounted

## Bridges an authoritative inventory ItemInstance to its procedural 3D runtime.
## The generated node carries the same item instance; no duplicate definition is created.

static func spawn_instance(instance: XRGptItemInstance, parent: Node3D = null) -> Node3D:
	if instance == null or instance.definition_id.is_empty():
		return null
	var definition: XRGptItemDefinition = XRGptItemCatalog.find_definition(instance.definition_id)
	if definition == null:
		return null
	var world_item := XRGptItemProceduralFactory.create_world_item(definition, instance.owner_id, instance)
	if not _is_valid_generated_item(world_item, instance):
		if world_item != null:
			world_item.free()
		return null
	if parent != null:
		parent.add_child(world_item)
	return world_item

static func _is_valid_generated_item(world_item: Node3D, instance: XRGptItemInstance) -> bool:
	if world_item == null or instance == null:
		return false
	if not world_item is RigidBody3D:
		return false
	if not world_item is XRGptProceduralPickable:
		return false
	var pickable := world_item as XRGptProceduralPickable
	if pickable.item_instance != instance:
		return false
	if world_item.get_node_or_null("Visual") == null:
		return false
	if world_item.get_node_or_null("CollisionShape3D") == null:
		return false
	return true

static func spawn_definition(definition: XRGptItemDefinition, owner_id: String = "player_1", parent: Node3D = null) -> Node3D:
	if definition == null:
		return null
	var instance := XRGptItemInstance.new()
	instance.setup(definition, owner_id)
	return spawn_instance(instance, parent)
