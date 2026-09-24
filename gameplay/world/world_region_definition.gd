class_name XRGptWorldRegionDefinition
extends Resource

## Stable, data-only identity for a world region.
## Geometry, terrain generation, spawning, navigation, and persistence systems
## can consume this definition without owning or recreating the world hierarchy.

@export var region_id := ""
@export var display_name := ""
@export var coordinates := Vector2i.ZERO
@export var region_size_meters := Vector2(64.0, 64.0)

func is_valid() -> bool:
	return not region_id.is_empty() and region_size_meters.x > 0.0 and region_size_meters.y > 0.0

func contains_local_position(local_position: Vector3) -> bool:
	if not is_valid():
		return false
	var half_size := region_size_meters * 0.5
	return local_position.x >= -half_size.x and local_position.x < half_size.x and local_position.z >= -half_size.y and local_position.z < half_size.y
