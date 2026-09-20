class_name XRGptTerrainBlock
extends StaticBody3D

## Base terrain block. The block is the world representation;
## breaking it creates a separate physical item drop.

@export var item_id := "rock"
@export var item_name := "Rock"
@export var max_health := 100.0
@export var drop_scene: PackedScene
@export var drop_auto_collect := true
@export var drop_relinquishable := false

var health := 100.0

func _ready() -> void:
	health = max_health

func damage(amount: float, drop_direction: Vector3 = Vector3.FORWARD, owner_id: String = "") -> void:
	if amount <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	if health <= 0.0:
		break_block(drop_direction, owner_id)

func break_block(drop_direction: Vector3 = Vector3.FORWARD, owner_id: String = "") -> Node3D:
	var drop: Node3D = null
	if drop_scene:
		drop = drop_scene.instantiate()
		get_tree().current_scene.add_child(drop)
		if drop is XRGptItemDrop:
			drop.configure_drop(item_id, item_name, owner_id, drop_auto_collect, drop_relinquishable)
			drop.launch_from_block(global_position + Vector3.UP * 0.15, drop_direction)
	queue_free()
	return drop
