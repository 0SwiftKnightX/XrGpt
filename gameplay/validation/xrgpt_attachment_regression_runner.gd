extends Node

## Phase 1 attachment regression entry point.
## Headless validation removes StartXR so tests exercise the real main scene
## without requiring a physical OpenXR runtime.

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

	var errors: Array[String] = XRGptAttachmentRegressionAudit.run(main)
	if errors.is_empty():
		print("ATTACHMENT_REGRESSION_PASS")
	else:
		for error in errors:
			push_error("ATTACHMENT_REGRESSION_FAIL: %s" % error)

	main.queue_free()
	get_tree().quit(0 if errors.is_empty() else 1)
