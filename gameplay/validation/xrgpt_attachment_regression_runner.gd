extends Node

## Phase 1 attachment regression entry point.
## Headless validation removes StartXR so tests exercise the real main scene
## without requiring a physical OpenXR runtime.
@export var run_count := 3

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

	var all_passed := true
	for pass_index in range(run_count):
		var errors := XRGptAttachmentRegressionAudit.run(main)
		if errors.is_empty():
			print("ATTACHMENT_REGRESSION_PASS_%d" % [pass_index + 1])
		else:
			all_passed = false
			for error in errors:
				push_error("ATTACHMENT_REGRESSION_PASS_%d: %s" % [pass_index + 1, error])

	main.queue_free()
	get_tree().quit(0 if all_passed else 1)
