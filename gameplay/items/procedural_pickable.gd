@tool
class_name XRGptProceduralPickable
extends XRToolsPickable

## Generic XR Tools pickup shell for procedurally generated item bodies.
## The authoritative item identity remains the inventory ItemInstance.

var item_instance: XRGptItemInstance
var definition_id := ""
var is_xr_held := false
var held_by: Node3D = null

signal inventory_returned(instance: XRGptItemInstance)
signal xr_picked_up(pickable: XRGptProceduralPickable)
signal xr_dropped(pickable: XRGptProceduralPickable)
signal xr_grabbed(pickable: XRGptProceduralPickable, by: Node3D)
signal xr_released(pickable: XRGptProceduralPickable, by: Node3D)

func _ready() -> void:
	super._ready()
	if not picked_up.is_connected(_on_xr_picked_up):
		picked_up.connect(_on_xr_picked_up)
	if not dropped.is_connected(_on_xr_dropped):
		dropped.connect(_on_xr_dropped)
	if not grabbed.is_connected(_on_xr_grabbed):
		grabbed.connect(_on_xr_grabbed)
	if not released.is_connected(_on_xr_released):
		released.connect(_on_xr_released)

func _on_xr_picked_up(pickable: XRToolsPickable) -> void:
	is_xr_held = true
	held_by = pickable.get_picked_up_by() as Node3D
	xr_picked_up.emit(pickable as XRGptProceduralPickable)

func _on_xr_dropped(pickable: XRToolsPickable) -> void:
	is_xr_held = false
	held_by = null
	xr_dropped.emit(pickable as XRGptProceduralPickable)

func _on_xr_grabbed(pickable: XRToolsPickable, by: Node3D) -> void:
	xr_grabbed.emit(pickable as XRGptProceduralPickable, by)

func _on_xr_released(pickable: XRToolsPickable, by: Node3D) -> void:
	xr_released.emit(pickable as XRGptProceduralPickable, by)

func bind_item_instance(instance: XRGptItemInstance) -> void:
	item_instance = instance
	definition_id = instance.definition_id if instance != null else ""

func ensure_item_instance(default_item_id: String = "", owner_id: String = "player_1") -> XRGptItemInstance:
	if item_instance != null:
		return item_instance
	var resolved_id: String = definition_id if not definition_id.is_empty() else default_item_id
	if resolved_id.is_empty():
		return null
	var definition: XRGptItemDefinition = XRGptItemCatalog.find_definition(resolved_id)
	if definition == null:
		return null
	var instance: XRGptItemInstance = XRGptItemInstance.new()
	instance.setup(definition, owner_id)
	bind_item_instance(instance)
	return item_instance

func return_to_inventory(inventory: XRGptInventoryController, local_player_id: String) -> bool:
	if inventory == null or item_instance == null:
		return false
	if not item_instance.owner_id.is_empty() and item_instance.owner_id != local_player_id:
		return false
	if not inventory.add_item_instance(item_instance):
		return false
	inventory_returned.emit(item_instance)
	queue_free()
	return true
