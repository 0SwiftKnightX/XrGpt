extends Node

func _ready() -> void:
	var definition := XRGptItemCatalog.ROCK_DEFINITION
	assert(definition != null)
	assert(not definition.item_id.is_empty())

	var first := XRGptItemInstance.new()
	first.setup(definition, "player_1", 10)
	var second := XRGptItemInstance.new()
	second.setup(definition, "player_1", 20)
	assert(first.instance_id != second.instance_id)
	assert(first.has_capability(XRGptItemCapability.INSPECTABLE))

	var backpack := XRGptInventoryContainer.new()
	backpack.setup("backpack", 8)
	var storage := XRGptInventoryContainer.new()
	storage.setup("storage", 8)
	var inventory := XRGptInventoryService.new()
	assert(inventory.add_item(backpack, first).success)
	assert(inventory.move_item(backpack, storage, first).success)
	assert(not backpack.contains(first))
	assert(storage.contains(first))

	var equipment := XRGptEquipmentService.new()
	equipment.define_slot("main_hand", ["Equipment"])
	assert(not equipment.equip("main_hand", first).success)

	var read_model := XRGptInventoryReadModel.new()
	read_model.rebuild(storage.get_items())
	assert(read_model.visible_items.size() == 1)

	print("XRGPT_INVENTORY_ARCHITECTURE_AUDIT: PASS")
	get_tree().quit()
