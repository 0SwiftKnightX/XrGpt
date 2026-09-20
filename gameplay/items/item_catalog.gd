class_name XRGptItemCatalog
extends RefCounted

## Single authoritative pool of item definitions currently implemented in-game.
## Every consumer resolves definitions through this same catalog; no consumer owns
## a second authoritative definition list.

const ROCK_DEFINITION: XRGptItemDefinition = preload("res://gameplay/items/rock_definition.tres")
const STONE_DEFINITION: XRGptItemDefinition = preload("res://gameplay/items/stone_definition.tres")
const BLACK_CUBE_DEFINITION: XRGptItemDefinition = preload("res://gameplay/items/black_cube_test_item.tres")

static func get_all_definitions() -> Array[XRGptItemDefinition]:
	return [
		ROCK_DEFINITION,
		STONE_DEFINITION,
		BLACK_CUBE_DEFINITION
	]

static func find_definition(item_id: String) -> XRGptItemDefinition:
	if item_id.is_empty():
		return null
	for definition in get_all_definitions():
		if definition.item_id == item_id:
			return definition
	return null

static func contains_definition(item_id: String) -> bool:
	return find_definition(item_id) != null

static func validate() -> Array[String]:
	var errors: Array[String] = []
	var seen := {}
	for definition in get_all_definitions():
		if definition == null:
			errors.append("CATALOG_DEFINITION_NULL")
			continue
		if definition.item_id.is_empty():
			errors.append("CATALOG_ITEM_ID_EMPTY:" + definition.display_name)
			continue
		if seen.has(definition.item_id):
			errors.append("CATALOG_ITEM_ID_DUPLICATE:" + definition.item_id)
		else:
			seen[definition.item_id] = true
	return errors
