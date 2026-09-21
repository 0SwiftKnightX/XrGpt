class_name XRGptAttachmentRegressionAudit
extends RefCounted

## Runtime failure-path regression suite for Phase 1 attachment contracts.
## This deliberately uses the real attachment controller/point/profile classes.

static func run(root: Node) -> Array[String]:
	var errors: Array[String] = []
	if root == null:
		errors.append("ATTACHMENT_REGRESSION_ROOT_MISSING")
		return errors

	_check_xr_origin_topology(root, errors)
	_check_profiles_and_bidirectional_contract(errors)
	_check_controller_transactions(errors)
	_check_hand_pose(root, errors)
	return errors

static func _check_xr_origin_topology(root: Node, errors: Array[String]) -> void:
	var xr := root.get_node_or_null("XROrigin3D")
	if xr == null:
		errors.append("XR_ORIGIN_MISSING")
		return
	var rig := xr.get_node_or_null("PlayerRig") as XRGptPlayerRig
	if rig == null:
		errors.append("PLAYER_RIG_MISSING")
		return

	for side in ["left", "right"]:
		var hand_id: String = "hand." + side
		if rig.get_attachment_point(hand_id) != null:
			errors.append("HAND_ATTACHMENT_DUPLICATE_RUNTIME_ID:" + hand_id)
	var expected_fingers: Array[String] = ["thumb", "index", "middle", "ring", "little"]
	for side in ["left", "right"]:
		for finger in expected_fingers:
			for segment in range(1, 4):
				var suffix := "" if segment == 1 else ".%d" % segment
				var id := "finger.%s.%s%s" % [side, finger, suffix]
				if rig.get_attachment_point(id) == null:
					errors.append("FINGER_ATTACHMENT_MISSING:" + id)

	var right_hand := xr.get_node_or_null("RightController/RightHandAttachment") as XRGptAttachmentPoint
	var left_hand := xr.get_node_or_null("LeftController/LeftHandAttachment") as XRGptAttachmentPoint
	if right_hand == null or right_hand.attachment_id != "hand.right":
		errors.append("RIGHT_HAND_ID_INVALID")
	if left_hand == null or left_hand.attachment_id != "hand.left":
		errors.append("LEFT_HAND_ID_INVALID")
	if right_hand != null and not right_hand.slot_ids.has("01"):
		errors.append("RIGHT_HAND_SLOT_ID_INVALID")
	if left_hand != null and not left_hand.slot_ids.has("02"):
		errors.append("LEFT_HAND_SLOT_ID_INVALID")

static func _check_profiles_and_bidirectional_contract(errors: Array[String]) -> void:
	var ring := XRGptItemCatalog.find_definition("equipment.test_ring")
	var glove := XRGptItemCatalog.find_definition("equipment.test_glove")
	if ring == null or ring.attachment_profile == null:
		errors.append("RING_PROFILE_MISSING")
		return
	if glove == null or glove.attachment_profile == null:
		errors.append("GLOVE_PROFILE_MISSING")
		return

	var right_ring := XRGptAttachmentPoint.new()
	right_ring.attachment_id = "finger.right.ring"
	right_ring.attachment_type = "Finger"
	right_ring.side = "Right"
	right_ring.accepts_categories = ["Equipment"]
	right_ring.accepted_rarities = ["Common"]
	right_ring.exclusive = true

	var left_ring := XRGptAttachmentPoint.new()
	left_ring.attachment_id = "finger.left.ring"
	left_ring.attachment_type = "Finger"
	left_ring.side = "Left"
	left_ring.accepts_categories = ["Equipment"]
	left_ring.accepted_rarities = ["Common"]

	var right_index := XRGptAttachmentPoint.new()
	right_index.attachment_id = "finger.right.index"
	right_index.attachment_type = "Finger"
	right_index.side = "Right"
	right_index.accepts_categories = ["Equipment"]
	right_index.accepted_rarities = ["Common"]

	var body := XRGptAttachmentPoint.new()
	body.attachment_id = "body.torso"
	body.attachment_type = "Body"
	body.side = "Any"
	body.accepts_categories = ["Equipment"]
	body.accepted_rarities = ["Common"]

	var ring_instance := XRGptItemInstance.new()
	ring_instance.setup(ring, "player_1")
	if not right_ring.can_attach_for_slot(ring_instance, "ring"):
		errors.append("BIDIRECTIONAL_RIGHT_RING_ACCEPT_FAILED")
	if left_ring.can_attach_for_slot(ring_instance, "ring"):
		errors.append("LEFT_RIGHT_COMPATIBILITY_NOT_ENFORCED")
	if right_index.can_attach_for_slot(ring_instance, "ring"):
		errors.append("FINGER_COMPATIBILITY_NOT_ENFORCED")
	if body.can_attach_for_slot(ring_instance, "ring"):
		errors.append("BODY_COMPATIBILITY_NOT_ENFORCED")
	ring_instance.rarity = "Rare"
	if right_ring.can_attach_for_slot(ring_instance, "ring"):
		errors.append("RARITY_RULE_NOT_ENFORCED")

	var glove_instance := XRGptItemInstance.new()
	glove_instance.setup(glove, "player_1")
	if not right_ring.can_attach_for_slot(glove_instance, "glove"):
		# Expected: ring point rejects a hand-profile item.
		pass
	else:
		errors.append("ITEM_SIDE_PROFILE_NOT_ENFORCED")
	var right_hand := XRGptAttachmentPoint.new()
	right_hand.attachment_id = "hand.right"
	right_hand.attachment_type = "Hand"
	right_hand.side = "Right"
	right_hand.accepts_categories = ["Equipment"]
	if not right_hand.can_attach_for_slot(glove_instance, "glove"):
		errors.append("RIGHT_HAND_GLOVE_COMPATIBILITY_FAILED")
	var left_hand := XRGptAttachmentPoint.new()
	left_hand.attachment_id = "hand.left"
	left_hand.attachment_type = "Hand"
	left_hand.side = "Left"
	left_hand.accepts_categories = ["Equipment"]
	if left_hand.can_attach_for_slot(glove_instance, "glove"):
		errors.append("LEFT_RIGHT_GLOVE_COMPATIBILITY_NOT_ENFORCED")

static func _check_controller_transactions(errors: Array[String]) -> void:
	var harness := Node3D.new()
	var controller := XRGptAttachmentController.new()
	harness.add_child(controller)

	var point := XRGptAttachmentPoint.new()
	point.name = "TestExclusiveRing"
	point.attachment_id = "finger.right.ring"
	point.attachment_type = "Finger"
	point.side = "Right"
	point.accepts_categories = ["Equipment"]
	point.slot_ids = []
	point.exclusive = true
	controller.add_child(point)

	var slot_a := XRGptEquipmentSlot.new()
	slot_a.name = "SlotA"
	slot_a.slot_id = "A"
	slot_a.inventory_slot = false
	controller.add_child(slot_a)
	var slot_b := XRGptEquipmentSlot.new()
	slot_b.name = "SlotB"
	slot_b.slot_id = "B"
	slot_b.inventory_slot = false
	controller.add_child(slot_b)

	var ring_def := XRGptItemCatalog.find_definition("equipment.test_ring")
	var item_a := XRGptItemInstance.new()
	item_a.setup(ring_def, "player_1")
	var item_b := XRGptItemInstance.new()
	item_b.setup(ring_def, "player_1")
	slot_a.set_item(item_a)
	slot_b.set_item(item_b)

	var failures: Array[String] = []
	var detached_signals: Array[String] = []
	controller.attachment_detached.connect(func(slot_id: String, attachment_id: String): detached_signals.append(slot_id + ":" + attachment_id))
	controller.attachment_failed.connect(func(slot_id: String, reason: String): failures.append(slot_id + ":" + reason))
	var successes: Array[String] = []
	controller.attachment_succeeded.connect(func(slot_id: String, attachment_id: String): successes.append(slot_id + ":" + attachment_id)

	if not controller.attach_slot(slot_a):
		errors.append("INITIAL_ATTACHMENT_FAILED")
	elif successes.size() != 1 or successes[0] != "A:finger.right.ring":
		errors.append("ATTACHMENT_SUCCESS_SIGNAL_MISSING")
	if controller.attach_slot(slot_b):
		errors.append("EXCLUSIVE_OCCUPANCY_ACCEPTED")
	elif failures.is_empty() or not failures.back().ends_with(":ATTACHMENT_OCCUPIED"):
		errors.append("EXPLICIT_OCCUPANCY_FAILURE_REASON_MISSING")
	if point.current_slot_id != "A":
		errors.append("OWNERSHIP_NOT_PRESERVED_AFTER_REJECTION")
	if item_a.attachment_id != point.attachment_id:
		errors.append("ITEM_ATTACHMENT_ID_NOT_PRESERVED")

	# Force runtime visual creation to fail after compatibility succeeds.
	var previous_visual := controller._attached_visuals.get("A") as Node3D
	XRGptItemRuntime.test_force_spawn_failure = true
	if controller.attach_slot(slot_a):
		errors.append("INVALID_RUNTIME_VISUAL_ACCEPTED")
	else:
		if failures.is_empty() or not failures.back().ends_with(":RUNTIME_VISUAL_FAILED"):
			errors.append("EXPLICIT_VISUAL_FAILURE_REASON_MISSING")
		if point.current_slot_id != "A":
			errors.append("ATTACHMENT_OWNERSHIP_LOST_ON_VISUAL_FAILURE")
		var retained := controller._attached_visuals.get("A") as Node3D
		if retained != previous_visual:
			errors.append("HELD_VISUAL_NOT_PRESERVED_ON_FAILURE")

	XRGptItemRuntime.test_force_spawn_failure = false
	controller.detach_slot(slot_a)
	if point.current_slot_id != "":
		errors.append("DETACHMENT_POINT_CLEANUP_FAILED")
	if not item_a.attachment_id.is_empty():
		errors.append("DETACHMENT_ITEM_CLEANUP_FAILED")
	if failures.is_empty() or successes.is_empty():
		errors.append("LIFECYCLE_SIGNAL_STATE_INVALID")

	harness.free()

static func _check_hand_pose(root: Node, errors: Array[String]) -> void:
	var rig := root.get_node_or_null("XROrigin3D/PlayerRig") as XRGptPlayerRig
	if rig == null:
		return
	rig._set_hand_clench("l", 0.25)
	rig._set_hand_clench("r", 0.75)
	if not is_equal_approx(float(rig._pose_amounts.get("l", -1.0)), 0.25):
		errors.append("LEFT_HAND_POSE_STATE_MISSING")
	if not is_equal_approx(float(rig._pose_amounts.get("r", -1.0)), 0.75):
		errors.append("RIGHT_HAND_POSE_STATE_MISSING")
