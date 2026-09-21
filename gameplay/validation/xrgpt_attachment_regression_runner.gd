class_name XRGptAttachmentRegressionRunner
extends Node

## Headless entry point for the Phase 1 attachment regression suite.
## The suite is executed three times to catch state leakage between runs.

@export var run_count := 3

func _ready() -> void:
	await get_tree().process_frame
	var main_scene := preload("res://main.tscn")
	var main := main_scene.instantiate()
	get_tree().root.add_child(main)
	await get_tree().process_frame

	var failures: Array[String] = []
	for pass_index in range(run_count):
		var errors := XRGptAttachmentRegressionAudit.run(main)
		if not errors.is_empty():
			for error in errors:
				failures.append("PASS_%d:%s" % [pass_index + 1, error])
			print("ATTACHMENT_REGRESSION_PASS_%d:%s" % [pass_index + 1, "FAIL" if not errors.is_empty() else "PASS"])

	main.queue_free()
	await get_tree().process_frame

	if failures.is_empty():
		print("ATTACHMENT_REGRESSION:PASS")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("ATTACHMENT_REGRESSION:FAIL")
		get_tree().quit(1)
