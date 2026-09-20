class_name XRGptCreativeItemButton
extends Node3D

@export var item_definition: XRGptItemDefinition
@export var creative_index_path: NodePath
@export var owner_id := "player_1"

func _ready() -> void:
	var index := get_node_or_null(creative_index_path) as XRGptCreativeItemIndex
	if index == null or item_definition == null:
		return
	var catalog_definition := index.get_definition(item_definition.item_id)
	if catalog_definition == null:
		item_definition = null
		return
	item_definition = catalog_definition

func activate() -> bool:
	var index := get_node_or_null(creative_index_path) as XRGptCreativeItemIndex
	if index == null or item_definition == null:
		return false
	return index.create_item(item_definition, owner_id) != null
