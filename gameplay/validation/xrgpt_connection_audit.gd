class_name XRGptConnectionAudit
extends RefCounted

## Pre-run structural audit for the current XR item/inventory/creative chain.
## Call run() from a debug bootstrap or editor test scene before Quest deployment.

static func run(root: Node) -> Array[String]:
	var errors: Array[String] = []
	if root == null:
		errors.append("AUDIT_ROOT_MISSING")
		return errors
	_check_catalog(errors)
	_check_main_connections(root, errors)
	_check_instance_and_runtime_contract(errors)
	return errors

static func _check_instance_and_runtime_contract(errors: Array[String]) -> void:
	for definition in XRGptItemCatalog.get_all_definitions():
		if definition == null:
			continue
		var instance := XRGptItemInstance.new()
		instance.setup(definition, "player_1")
		if instance.definition_id != definition.item_id:
			errors.append("INSTANCE_DEFINITION_MISMATCH: " + definition.item_id)
		if instance.owner_id != "player_1":
			errors.append("INSTANCE_OWNER_MISMATCH: " + definition.item_id)
		if instance.quantity < 1 or instance.quantity > definition.max_stack:
			errors.append("INSTANCE_QUANTITY_INVALID: " + definition.item_id)
		var world_item := XRGptItemRuntime.spawn_instance(instance)
		if world_item == null:
			errors.append("RUNTIME_SPAWN_FAILED: " + definition.item_id)
			continue
		if not world_item is RigidBody3D:
			errors.append("RUNTIME_OBJECT_NOT_RIGID_BODY: " + definition.item_id)
		if not world_item is XRGptProceduralPickable:
			errors.append("RUNTIME_OBJECT_NOT_PICKABLE: " + definition.item_id)
		else:
			var pickable := world_item as XRGptProceduralPickable
			if pickable.item_instance != instance:
				errors.append("RUNTIME_INSTANCE_MISMATCH: " + definition.item_id)
			if not pickable.has_method("pick_up") or not pickable.has_method("return_to_inventory"):
				errors.append("RUNTIME_PICKUP_RETURN_API_MISSING: " + definition.item_id)
			if definition.item_id == "test.black_cube":
				if pickable.get("left_controller_path") != NodePath("XROrigin3D/LeftController"):
					errors.append("BLACK_CUBE_LEFT_CONTROLLER_PATH_INVALID")
				if pickable.get("right_controller_path") != NodePath("XROrigin3D/RightController"):
					errors.append("BLACK_CUBE_RIGHT_CONTROLLER_PATH_INVALID")
		if world_item.get_node_or_null("Visual") == null:
			errors.append("RUNTIME_VISUAL_MISSING: " + definition.item_id)
		if world_item.get_node_or_null("CollisionShape3D") == null:
			errors.append("RUNTIME_COLLISION_MISSING: " + definition.item_id)
		world_item.free()

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
			var generated_body := generated as RigidBody3D
			if generated_body == null:
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
			if not generated.has_method("pick_up") or not generated.has_method("can_pick_up"):
				errors.append("GENERATED_PICKUP_API_MISSING: " + definition.item_id)
			if generated_body != null and (generated_body.collision_layer & 4) == 0:
				errors.append("GENERATED_PICKUP_LAYER_MISMATCH: " + definition.item_id)
			if generated.get_parent() != null:
				generated.get_parent().remove_child(generated)
			generated.free()

static func _check_main_connections(root: Node, errors: Array[String]) -> void:
	var xr_origin := root.get_node_or_null("XROrigin3D")
	if xr_origin == null:
		errors.append("XR_ORIGIN_MISSING: Main/XROrigin3D")
		return

	var inventory := xr_origin.get_node_or_null("InventoryController") as XRGptInventoryController
	if inventory == null:
		errors.append("INVENTORY_MISSING: Main/XROrigin3D/InventoryController")
	else:
		if inventory.left_controller_path != NodePath("../LeftController"):
			errors.append("INVENTORY_LEFT_CONTROLLER_PATH_INVALID")
		if inventory.camera_path != NodePath("../XRCamera3D"):
			errors.append("INVENTORY_CAMERA_PATH_INVALID")

	var equipment := xr_origin.get_node_or_null("ActiveEquipmentController") as XRGptActiveEquipmentController
	if equipment == null:
		errors.append("ACTIVE_EQUIPMENT_MISSING: Main/XROrigin3D/ActiveEquipmentController")
	elif equipment.camera_path != NodePath("../XRCamera3D"):
		errors.append("ACTIVE_EQUIPMENT_CAMERA_PATH_INVALID")

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
		if (interaction.interaction_collision_mask & 4) == 0:
			errors.append("WORLD_INTERACTION_MASK_EXCLUDES_LAYER_3")
		if (interaction.interaction_collision_mask & 8) == 0:
			errors.append("WORLD_INTERACTION_MASK_EXCLUDES_LAYER_4")

	var left := xr_origin.get_node_or_null("LeftController") as XRController3D
	var right := xr_origin.get_node_or_null("RightController") as XRController3D
	if left == null:
		errors.append("LEFT_CONTROLLER_MISSING")
	else:
		_check_pickup_function(left, "LEFT", errors)
		_check_ray_pointer(left, "LEFT", errors)
	if right == null:
		errors.append("RIGHT_CONTROLLER_MISSING")
	else:
		_check_pickup_function(right, "RIGHT", errors)
		_check_ray_pointer(right, "RIGHT", errors)

static func _check_pickup_function(controller: XRController3D, label: String, errors: Array[String]) -> void:
	var pickup := XRToolsFunctionPickup.find_instance(controller)
	if pickup == null:
		errors.append(label + "_PICKUP_FUNCTION_MISSING")
		return
	if not pickup.has_method("drop_object"):
		errors.append(label + "_PICKUP_DROP_API_MISSING")
	if (pickup.grab_collision_mask & 4) == 0:
		errors.append(label + "_PICKUP_GRAB_MASK_EXCLUDES_LAYER_3")
	if (pickup.ranged_collision_mask & 4) == 0:
		errors.append(label + "_PICKUP_RANGED_MASK_EXCLUDES_LAYER_3")


static func _check_ray_pointer(controller: XRController3D, label: String, errors: Array[String]) -> void:
	var pointer := controller.get_node_or_null("RayPointer") as XRGptRayPointer
	if pointer == null:
		errors.append(label + "_RAY_POINTER_MISSING")
		return
	if (pointer.pointer_collision_mask & 4) == 0:
		errors.append(label + "_RAY_POINTER_MASK_EXCLUDES_LAYER_3")
	if (pointer.pointer_collision_mask & 8) == 0:
		errors.append(label + "_RAY_POINTER_MASK_EXCLUDES_LAYER_4")
