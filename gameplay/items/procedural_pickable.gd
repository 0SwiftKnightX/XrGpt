class_name XRGptProceduralPickable
extends XRToolsPickable

## Generic XR Tools pickup shell for procedurally generated item bodies.
## The authoritative item identity remains the inventory ItemInstance.

var item_instance: XRGptItemInstance
var definition_id := ""

func bind_item_instance(instance: XRGptItemInstance) -> void:
	item_instance = instance
	definition_id = instance.definition_id if instance != null else ""
