extends Node

## CI/runtime structural verification entry point.
## Headless validation deliberately removes StartXR before adding the real
## main scene so CI does not attempt to initialize a physical OpenXR runtime.
## Quest/device validation must still execute the real StartXR path.
func _ready() -> void:
	await get_tree().process_frame
	var main_scene := preload("res://main.tscn")
	var main := main_scene.instantiate()
	var start_xr := main.get_node_or_null("StartXR")
	if start_xr != null:
		main.remove_child(start_xr)
		start_xr.free()
	add_child(main)
	await get_tree().process_frame

	var errors := XRGptConnectionAudit.run(main)
	if errors.is_empty():
		print("XRGPT_CONNECTION_AUDIT: PASS")
	else:
		for error in errors:
			push_error("XRGPT_CONNECTION_AUDIT: " + error)
		print("XRGPT_CONNECTION_AUDIT: FAIL (%d errors)" % errors.size())

	main.queue_free()
	get_tree().quit(0 if errors.is_empty() else 1)
