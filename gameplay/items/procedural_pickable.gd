class_name XRGptProceduralPickable
extends XRToolsPickable

## Generic XR Tools pickup shell for procedurally generated item bodies.
## The authoritative item identity remains the inventory ItemInstance.

var item_instance: XRGptItemInstance
var definition_id := ""

signal inventory_returned(instance: XRGptItemInstance)

func bind_item_instance(instance: XRGptItemInstance) -> void:
	item_instance = instance
	definition_id = instance.definition_id if instance != null else ""

func ensure_item_instance(default_item_id: String = "", owner_id: String = "player_1") -> XRGptItemInstance:
	if item_instance != null:
		return item_instance
	var resolved_id := definition_id if not definition_id.is_empty() else default_item_id
	if resolved_id.is_empty():
		return null
	var definition := XRGptItemCatalog.find_definition(resolved_id)
	if definition == null:
		return null
	var instance := XRGptItemInstance.new()
	instance.setup(definition, owner_id)
	bind_item_instance(instance)
	return item_instance

func return_to_inventory(inventory: XRGptInventoryController, local_player_id: String) -> bool:
	if inventory == null or item_instance == null:
		return false
	if not item_instance.owner_id.is_empty() and item_instance.owner_id != local_player_id:
		return false
	if not inventory.add_item_instance(item_instance):
		return false
	inventory_returned.emit(item_instance)
	queue_free()
	return true
