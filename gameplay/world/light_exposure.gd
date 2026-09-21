class_name XRGptLightExposure
extends Node

## Computes terrain-visible light from the sun/moon plus weather.
## A later terrain system can query get_visible_light() for growth rules.

enum Weather { CLEAR, RAIN, SNOW }

@export var weather: Weather = Weather.CLEAR
@export_range(0.0, 1.0, 0.01) var base_visible_light := 1.0

const RAIN_VISIBLE_MULTIPLIER := 0.20
const SNOW_VISIBLE_MULTIPLIER := 0.70
const NIGHT_VISIBLE_MULTIPLIER := 0.50

func get_weather_multiplier() -> float:
	match weather:
		Weather.RAIN:
			return RAIN_VISIBLE_MULTIPLIER
		Weather.SNOW:
			return SNOW_VISIBLE_MULTIPLIER
		_:
			return 1.0

func get_visible_light(daylight_factor: float) -> float:
	var day_or_night: float = lerp(NIGHT_VISIBLE_MULTIPLIER, 1.0, clamp(daylight_factor, 0.0, 1.0))
	return clamp(base_visible_light * day_or_night * get_weather_multiplier(), 0.0, 1.0)

func get_growth_light(daylight_factor: float, direct_sunlight: bool) -> float:
	var visible: float = get_visible_light(daylight_factor)
	# Direct sunlight is what the block-growth system will eventually
	# obtain from a real occlusion ray. For now this preserves the hook.
	if direct_sunlight:
		return visible
	return visible * 0.35
