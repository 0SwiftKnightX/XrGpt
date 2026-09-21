extends Node

## CI/runtime structural verification entry point.
## Instantiates the real main scene, waits for generated PlayerRig attachment
## points, runs XRGptConnectionAudit, and exits non-zero on any audit error.

func _ready() -> void:
	await get_tree().process_frame
	var main_scene := preload("res://main.tscn")
	var main := main_scene.instantiate()
	add_child(main)
	await get_tree().process_frame

	var errors := XRGptConnectionAudit.run(main)
	for pass_index in range(3):
		var regression_errors := XRGptAttachmentRegressionAudit.run(main)
		for error in regression_errors:
			errors.append("ATTACHMENT_REGRESSION_PASS_%d: %s" % [pass_index + 1, error])
	if errors.is_empty():
		print("XRGPT_CONNECTION_AUDIT: PASS")
		main.queue_free()
		get_tree().quit(0)
		return

	for error in errors:
		push_error("XRGPT_CONNECTION_AUDIT: " + error)
	print("XRGPT_CONNECTION_AUDIT: FAIL (%d errors)" % errors.size())
	main.queue_free()
	get_tree().quit(1)
