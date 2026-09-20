@tool
class_name XRToolsStartXR
extends Node
signal xr_started
signal xr_ended
signal xr_failed_to_initialize
static var _xr_active := false
static var _start_xr_nodes: Array[XRToolsStartXR]
@export var viewport: Viewport
@export var render_target_size_multiplier := 1.0
@export var enable_passthrough := false: set = _set_enable_passthrough
@export var physics_rate_multiplier := 1
@export var target_refresh_rate := 0.0
var xr_interface: XRInterface
var xr_frame_rate := 0.0
var _enter_web_xr: CanvasLayer
var _webxr_session_query := false
static func get_start_xr_node() -> XRToolsStartXR:
	if _start_xr_nodes.is_empty():
		push_warning("No StartXR node has been added to the scene tree.")
		return null
	return _start_xr_nodes[0]
static func is_xr_active() -> bool:
	return _xr_active
func _enter_tree() -> void:
	_start_xr_nodes.push_back(self)
	if _start_xr_nodes.size() > 1:
		push_warning("More than one StartXR node has been instanced!")
func _ready() -> void:
	if not Engine.is_editor_hint():
		_enter_web_xr = $EnterWebXR
		_initialize()
func _exit_tree() -> void:
	_start_xr_nodes.erase(self)
func end_xr() -> void:
	if xr_interface is WebXRInterface:
		xr_interface.uninitialize()
		return
	get_tree().quit()
func get_xr_viewport() -> Viewport:
	return viewport if viewport else get_viewport()
func _find_closest(values: Array, target: float) -> float:
	if values.is_empty():
		return 0.0
	var best: float = values.front()
	for v: float in values:
		if absf(target - v) < absf(target - best):
			best = v
	return best
func _initialize() -> bool:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface:
		return _setup_for_openxr()
	xr_interface = XRServer.find_interface("WebXR")
	if xr_interface:
		return _setup_for_webxr()
	xr_interface = null
	print("No XR interface detected")
	xr_failed_to_initialize.emit()
	return false
func _on_openxr_focused_state() -> void:
	if not _xr_active:
		_xr_active = true
		xr_started.emit()
func _on_openxr_session_begun() -> void:
	_set_xr_frame_rate()
func _on_openxr_visible_state() -> void:
	if _xr_active:
		_xr_active = false
		xr_ended.emit()
func _on_webxr_session_ended() -> void:
	_enter_web_xr.visible = true
	get_xr_viewport().transparent_bg = false
	get_xr_viewport().use_xr = false
	_xr_active = false
	xr_ended.emit()
func _on_webxr_session_failed(message: String) -> void:
	OS.alert("Unable to enter VR: " + message)
	_enter_web_xr.visible = true
func _on_webxr_session_started() -> void:
	_set_xr_frame_rate()
	_enter_web_xr.visible = false
	get_xr_viewport().transparent_bg = enable_passthrough
	get_xr_viewport().use_xr = true
	_xr_active = true
	xr_started.emit()
func _on_webxr_session_supported(session_mode: String, supported: bool) -> void:
	if not _webxr_session_query:
		return
	_webxr_session_query = false
	if not supported:
		OS.alert("Your web browser doesn't support " + session_mode + ". Sorry!")
		xr_failed_to_initialize.emit()
		return
	_enter_web_xr.visible = true
func _on_enter_webxr_button_pressed() -> void:
	xr_interface.session_mode = "immersive-ar" if enable_passthrough else "immersive-vr"
	xr_interface.requested_reference_space_types = "bounded-floor, local-floor, local"
	xr_interface.required_features = "local-floor"
	xr_interface.optional_features = "bounded-floor"
	if ProjectSettings.get_setting_with_override("xr/openxr/extensions/hand_tracking"):
		xr_interface.optional_features += ", hand-tracking"
	if not xr_interface.initialize():
		OS.alert("Failed to initialise WebXR")
func _set_enable_passthrough(p_new_value: bool) -> void:
	enable_passthrough = p_new_value
	if xr_interface:
		if enable_passthrough:
			enable_passthrough = xr_interface.start_passthrough()
		else:
			xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_OPAQUE
		get_xr_viewport().transparent_bg = enable_passthrough
func _set_xr_frame_rate() -> void:
	xr_frame_rate = xr_interface.get_display_refresh_rate()
	var desired_rate := target_refresh_rate if target_refresh_rate > 0 else xr_frame_rate
	var available_rates: Array = xr_interface.get_available_display_refresh_rates()
	if available_rates.size() > 1 and desired_rate > 0:
		var rate := _find_closest(available_rates, desired_rate)
		if rate > 0:
			xr_interface.set_display_refresh_rate(rate)
			xr_frame_rate = rate
	var active_rate := xr_frame_rate if xr_frame_rate > 0 else 144.0
	Engine.physics_ticks_per_second = int(roundf(active_rate * physics_rate_multiplier))
func _setup_for_openxr() -> bool:
	xr_interface.render_target_size_multiplier = render_target_size_multiplier
	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			push_error("OpenXR: Failed to initialize")
			xr_failed_to_initialize.emit()
			return false
	if xr_interface is OpenXRInterface:
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_xr_viewport().transparent_bg = enable_passthrough
	get_xr_viewport().use_xr = true
	return true
func _setup_for_webxr() -> bool:
	if xr_interface is WebXRInterface:
		xr_interface.session_supported.connect(_on_webxr_session_supported)
		xr_interface.session_started.connect(_on_webxr_session_started)
		xr_interface.session_ended.connect(_on_webxr_session_ended)
		xr_interface.session_failed.connect(_on_webxr_session_failed)
	if get_xr_viewport().use_xr:
		return true
	_webxr_session_query = true
	xr_interface.is_session_supported("immersive-ar" if enable_passthrough else "immersive-vr")
	return true
