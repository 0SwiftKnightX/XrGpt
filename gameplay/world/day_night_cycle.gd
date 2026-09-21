class_name XRGptDayNightCycle
extends Node3D

## Foundation for a deterministic sun/moon cycle.
## The same directional-light architecture will later feed terrain growth
## and weather visibility calculations.

@export_range(0.0, 24.0, 0.1) var time_of_day := 12.0
@export var day_length_seconds := 900.0
@export var sun_energy := 1.0
@export var moon_energy := 0.35
@export var sun_color := Color(1.0, 0.93, 0.78)
@export var moon_color := Color(0.45, 0.55, 1.0)
@export var enabled := false

@onready var sun: DirectionalLight3D = $Sun
@onready var moon: DirectionalLight3D = $Moon
@onready var sky: Sky = null
var environment: Environment = null

func _ready() -> void:
	var environment_node := get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
	if environment_node and environment_node.environment:
		environment = environment_node.environment
		sky = environment_node.environment.sky
	_update_lights()

func _process(delta: float) -> void:
	if enabled and day_length_seconds > 0.0:
		time_of_day = fmod(time_of_day + (24.0 / day_length_seconds) * delta, 24.0)
	_update_lights()

func _update_lights() -> void:
	var sun_angle: float = (time_of_day / 24.0) * TAU - PI * 0.5
	var daylight: float = clamp(sin(sun_angle), 0.0, 1.0)
	var moonlight: float = clamp(-sin(sun_angle), 0.0, 1.0)

	sun.rotation_degrees = Vector3(rad_to_deg(sun_angle), 0.0, 0.0)
	moon.rotation_degrees = Vector3(rad_to_deg(sun_angle + PI), 0.0, 0.0)

	sun.light_color = sun_color
	moon.light_color = moon_color
	sun.light_energy = sun_energy * daylight
	moon.light_energy = moon_energy * moonlight

	# Rotate the skybox with the celestial cycle.
	if environment:
		environment.sky_rotation = Vector3(0.0, (time_of_day / 24.0) * TAU, 0.0)

	# Rotate the procedural sky colors with the celestial cycle.
	if sky and sky.sky_material is ProceduralSkyMaterial:
		var material: ProceduralSkyMaterial = sky.sky_material as ProceduralSkyMaterial
		material.sky_top_color = Color(0.025, 0.035, 0.065, 1).lerp(Color(0.18, 0.38, 0.75, 1), daylight)
		material.sky_horizon_color = Color(0.12, 0.15, 0.2, 1).lerp(Color(0.55, 0.72, 1.0, 1), daylight)
