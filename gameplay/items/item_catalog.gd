class_name XRGptItemCatalog
extends RefCounted

## Single authoritative pool of item definitions currently implemented in-game.
## Creative uses this same pool; new items are added here as definitions appear.

static func get_all_definitions() -> Array[XRGptItemDefinition]:
	return [
		load("res://gameplay/items/rock_definition.tres") as XRGptItemDefinition,
		load("res://gameplay/items/stone_definition.tres") as XRGptItemDefinition,
		load("res://gameplay/items/black_cube_test_item.tres") as XRGptItemDefinition
	]

static func find_definition(item_id: String) -> XRGptItemDefinition:
	for definition in get_all_definitions():
		if definition != null and definition.item_id == item_id:
			return definition
	return null
