class_name XRGptInventoryReadModel
extends RefCounted

var active_category: String = "All"
var search_text: String = ""
var selected_item_instance_id: String = ""
var sort_key: String = "name"
var visible_items: Array[XRGptItemInstance] = []
var available_actions: Array[String] = []

func rebuild(source: Array[XRGptItemInstance]) -> void:
	visible_items.clear()
	var query := search_text.strip_edges().to_lower()
	for item in source:
		if item == null:
			continue
		if active_category != "All" and item.category != active_category:
			continue
		if not query.is_empty() and not item.display_name.to_lower().contains(query):
			continue
		visible_items.append(item)
	visible_items.sort_custom(func(a, b): return a.display_name.naturalnocasecmp_to(b.display_name) < 0)

func get_selected(source: Array[XRGptItemInstance]) -> XRGptItemInstance:
	if selected_item_instance_id.is_empty():
		return null
	for item in source:
		if item != null and item.instance_id == selected_item_instance_id:
			return item
	return null
