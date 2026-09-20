class_name XRGptConnectionAudit
extends RefCounted

## Pre-run structural audit for the current XR item/inventory/creative chain.
## Call run() from a debug bootstrap or editor test scene before Quest deployment.

static func run(root: Node) -> Array[String]:
	var errors: Array[String] = []
	_check_catalog(errors)
	_check_main_connections(root, errors)
	return errors

static func _check_catalog(errors: Array[String]) -> void:
	var definitions := XRGptItemCatalog.get_all_definitions()
	if definitions.is_empty():
		errors.append("ITEM_POOL_EMPTY: XRGptItemCatalog returned no definitions.")
		return

	var ids := {}
	for definition in definitions:
		if definition == null:
			errors.append("ITEM_DEFINITION_NULL: Catalog contains a null definition.")
			continue
		if definition.item_id.is_empty():
			errors.append("ITEM_ID_EMPTY: " + definition.display_name)
		if ids.has(definition.item_id):
			errors.append("ITEM_ID_DUPLICATE: " + definition.item_id)
		ids[definition.item_id] = true
		var test_instance := XRGptItemInstance.new()
		test_instance.setup(definition, "player_1")
		var generated := XRGptItemProceduralFactory.create_world_item(definition, "player_1", test_instance)
		if generated == null:
			errors.append("PROCEDURAL_GENERATOR_MISSING: " + definition.item_id)
		else:
			if not generated is RigidBody3D:
				errors.append("GENERATED_OBJECT_NOT_RIGID_BODY: " + definition.item_id)
			if not generated is XRGptProceduralPickable:
				errors.append("GENERATED_OBJECT_NOT_PICKABLE: " + definition.item_id)
			else:
				var pickable := generated as XRGptProceduralPickable
				if pickable.item_instance != test_instance:
					errors.append("GENERATED_INSTANCE_MISMATCH: " + definition.item_id)
			if generated.get_node_or_null("Visual") == null:
				errors.append("GENERATED_VISUAL_MISSING: " + definition.item_id)
			if generated.get_node_or_null("CollisionShape3D") == null:
				errors.append("GENERATED_COLLISION_MISSING: " + definition.item_id)
			generated.free()

static func _check_main_connections(root: Node, errors: Array[String]) -> void:
	var xr_origin := root.get_node_or_null("XROrigin3D")
	if xr_origin == null:
		errors.append("XR_ORIGIN_MISSING: Main/XROrigin3D")
		return

	var inventory := xr_origin.get_node_or_null("InventoryController") as XRGptInventoryController
	if inventory == null:
		errors.append("INVENTORY_MISSING: Main/XROrigin3D/InventoryController")

	var creative := xr_origin.get_node_or_null("CreativeItemIndex") as XRGptCreativeItemIndex
	if creative == null:
		errors.append("CREATIVE_INDEX_MISSING: Main/XROrigin3D/CreativeItemIndex")
	elif inventory == null:
		errors.append("CREATIVE_INVENTORY_UNVERIFIED: InventoryController missing.")
	elif creative.owner_inventory_path != NodePath("../InventoryController"):
		errors.append("CREATIVE_INVENTORY_PATH_INVALID: expected ../InventoryController")

	var interaction := xr_origin.get_node_or_null("WorldInteraction") as XRGptWorldInteraction
	if interaction == null:
		errors.append("WORLD_INTERACTION_MISSING: Main/XROrigin3D/WorldInteraction")
	else:
		if interaction.right_controller_path != NodePath("../RightController"):
			errors.append("RIGHT_CONTROLLER_PATH_INVALID")
		if interaction.left_controller_path != NodePath("../LeftController"):
			errors.append("LEFT_CONTROLLER_PATH_INVALID")

	var left := xr_origin.get_node_or_null("LeftController") as XRController3D
	var right := xr_origin.get_node_or_null("RightController") as XRController3D
	if left == null:
		errors.append("LEFT_CONTROLLER_MISSING")
	else:
		_check_pickup_function(left, "LEFT", errors)
	if right == null:
		errors.append("RIGHT_CONTROLLER_MISSING")
	else:
		_check_pickup_function(right, "RIGHT", errors)

static func _check_pickup_function(controller: XRController3D, label: String, errors: Array[String]) -> void:
	var pickup := XRToolsFunctionPickup.find_instance(controller)
	if pickup == null:
		errors.append(label + "_PICKUP_FUNCTION_MISSING")
		return
	if not pickup.has_method("drop_object"):
		errors.append(label + "_PICKUP_DROP_API_MISSING")
	if pickup.grab_collision_mask & 4 == 0:
		errors.append(label + "_PICKUP_GRAB_MASK_EXCLUDES_LAYER_3")
	if pickup.ranged_collision_mask & 4 == 0:
		errors.append(label + "_PICKUP_RANGED_MASK_EXCLUDES_LAYER_3")
