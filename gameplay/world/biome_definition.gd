class_name XRGptBiomeDefinition
extends Resource

## Minimal data contract for biome/environment rules.
## This is intentionally data-only; terrain generation, spawning, weather,
## and rendering systems consume it rather than embedding biome logic.

@export var biome_id := ""
@export var display_name := ""
@export var climate_id := ""
@export_range(0.0, 1.0, 0.01) var humidity := 0.5
@export_range(0.0, 1.0, 0.01) var temperature := 0.5

func is_valid() -> bool:
	return not biome_id.is_empty()
