class_name XRGptItemProceduralFactory
extends RefCounted

## Runtime-only item generator.
## Item geometry, collision, and special behavior are assembled from scripts;
## no imported model/texture asset is required.

static func create_world_item(definition: XRGptItemDefinition, owner_id: String = "player_1", instance: XRGptItemInstance = null) -> Node3D:
	if definition == null or definition.item_id.is_empty():
		return null
	var canonical := XRGptItemCatalog.find_definition(definition.item_id)
	if canonical == null or canonical != definition:
		return null
	if instance == null:
		instance = XRGptItemInstance.new()
		instance.setup(canonical, owner_id)
	if instance.definition_id != canonical.item_id or instance.owner_id != owner_id:
		return null

	match canonical.item_id:
		"block.rock":
			return _create_physical_block(canonical, owner_id, instance, Vector3(1.0, 1.0, 1.0), Color(0.29, 0.27, 0.24), 0.35)
		"block.stone":
			return _create_physical_block(canonical, owner_id, instance, Vector3(1.0, 1.0, 1.0), Color(0.46, 0.45, 0.42), 0.45)
		"test.black_cube":
			return _create_black_cube(canonical, instance)
		_:
			return null

static func _create_physical_block(definition: XRGptItemDefinition, _owner_id: String, instance: XRGptItemInstance, size: Vector3, color: Color, mass: float) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.name = definition.display_name.replace(" ", "") + "Procedural"
	body.set_script(load("res://gameplay/items/procedural_pickable.gd"))
	var pickable := body as XRGptProceduralPickable
	if pickable != null:
		pickable.bind_item_instance(instance)
	body.mass = mass
	body.continuous_cd = true
	body.collision_layer = 4
	body.collision_mask = 5

	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	visual.mesh = mesh
	visual.material_override = material
	body.add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	return body

static func _create_black_cube(definition: XRGptItemDefinition, instance: XRGptItemInstance) -> RigidBody3D:
	var body := RigidBody3D.new()
	body.name = "BlackCubeTestProcedural"
	body.set_script(load("res://gameplay/test_items/black_cube_test.gd"))
	body.collision_layer = 4
	body.collision_mask = 5
	body.mass = 0.05
	body.continuous_cd = true
	body.linear_damp = 0.05
	body.angular_damp = 0.15
	body.set("press_to_hold", true)
	body.set("ranged_grab_method", 1)
	body.set("throw_speed", 4.5)
	body.set("projectile_speed", 8.0)
	body.set("projectile_max_distance", 10.0)
	var pickable := body as XRGptProceduralPickable
	if pickable != null:
		pickable.bind_item_instance(instance)
	body.set("left_controller_path", NodePath("../XROrigin3D/LeftController"))
	body.set("right_controller_path", NodePath("../XROrigin3D/RightController"))

	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.1, 0.1, 0.1)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.005, 0.005, 0.008)
	material.roughness = 0.82
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	visual.mesh = mesh
	visual.material_override = material
	body.add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = Vector3(0.1, 0.1, 0.1)
	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	var label := Label3D.new()
	label.name = "ItemName"
	label.text = definition.display_name
	label.font_size = 24
	label.modulate = Color(0.1, 0.45, 1.0)
	label.outline_size = 4
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.09, 0)
	body.add_child(label)

	var projectile_script = load("res://gameplay/projectiles/projectile_runtime.gd")
	var projectile := Node.new()
	projectile.name = "ProjectileRuntime"
	projectile.set_script(projectile_script)
	projectile.set("max_distance", 10.0)
	projectile.set("destroy_on_impact", true)
	projectile.set("launch_speed", 8.0)
	projectile.set("gravity_scale", 1.0)
	projectile.set("linear_damp", 0.05)
	projectile.set("angular_damp", 0.15)
	body.add_child(projectile)

	return body
