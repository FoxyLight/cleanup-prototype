extends SceneTree

var _passed: int = 0
var _failed: int = 0


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Theme Park Progress Tests ===")

	await process_frame

	await _test_progress_controller()

	print("")
	print("=== Theme Park Progress Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("THEME PARK PROGRESS TESTS PASSED")
		quit(0)
	else:
		print("THEME PARK PROGRESS TESTS FAILED")
		quit(1)


func _test_progress_controller() -> void:
	var packed: PackedScene = load(
		"res://scenes/theme_park/carousel_courtyard.tscn"
	)

	var scene: Node = packed.instantiate()

	root.add_child(scene)

	await process_frame

	_assert_equal_int(
		int(scene.call("get_required_target_count")),
		18,
		"controller registers exactly 18 required targets"
	)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		18,
		"initial unfinished count is 18"
	)

	_assert_equal_string(
		String(scene.call("get_progress_text")),
		"Unfinished: 18",
		"initial UI text matches count"
	)

	var expected_cleanables: Array[StringName] = [
		&"entrance_paving",
		&"entrance_sign",
		&"seating_paving",
		&"table",
		&"bench",
		&"carousel_platform",
		&"carousel_railing",
		&"carousel_horse"
	]

	var expected_litter: Array[StringName] = [
		&"litter_01",
		&"litter_02",
		&"litter_03",
		&"litter_04",
		&"litter_05",
		&"litter_06",
		&"litter_07"
	]

	var expected_debris: Array[StringName] = [
		&"debris_01",
		&"debris_02",
		&"debris_03"
	]

	for target_id in expected_cleanables:
		_assert_true(
			bool(
				scene.call(
					"has_required_target_id",
					target_id
				)
			),
			"cleanable ID registered: %s"
			% target_id
		)

	for target_id in expected_litter:
		_assert_true(
			bool(
				scene.call(
					"has_required_target_id",
					target_id
				)
			),
			"litter ID registered: %s"
			% target_id
		)

	for target_id in expected_debris:
		_assert_true(
			bool(
				scene.call(
					"has_required_target_id",
					target_id
				)
			),
			"debris ID registered: %s"
			% target_id
		)

	var first_result: bool = bool(
		scene.call(
			"record_completion",
			&"entrance_paving"
		)
	)

	_assert_true(
		first_result,
		"first unique completion is accepted"
	)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		17,
		"one unique completion decrements to 17"
	)

	_assert_equal_string(
		String(scene.call("get_progress_text")),
		"Unfinished: 17",
		"UI updates after completion"
	)

	var duplicate_result: bool = bool(
		scene.call(
			"record_completion",
			&"entrance_paving"
		)
	)

	_assert_true(
		not duplicate_result,
		"duplicate completion is rejected"
	)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		17,
		"duplicate completion does not decrement"
	)

	var unknown_result: bool = bool(
		scene.call(
			"record_completion",
			&"not_a_real_target"
		)
	)

	_assert_true(
		not unknown_result,
		"unknown target completion is rejected"
	)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		17,
		"unknown target does not decrement"
	)

	scene.call("reset_progress")

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		18,
		"controller reset restores 18"
	)

	for target_id in expected_cleanables:
		scene.call(
			"record_completion",
			target_id
		)

	for target_id in expected_litter:
		scene.call(
			"record_completion",
			target_id
		)

	for target_id in expected_debris:
		scene.call(
			"record_completion",
			target_id
		)

	_assert_equal_int(
		int(scene.call("get_completed_target_count")),
		18,
		"all 18 unique targets complete"
	)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		0,
		"all 18 unique targets produce zero unfinished"
	)

	_assert_equal_string(
		String(scene.call("get_progress_text")),
		"Unfinished: 0",
		"zero-state UI text is correct"
	)

	# Try every target again after reaching zero.
	for target_id in expected_cleanables:
		scene.call(
			"record_completion",
			target_id
		)

	for target_id in expected_litter:
		scene.call(
			"record_completion",
			target_id
		)

	for target_id in expected_debris:
		scene.call(
			"record_completion",
			target_id
		)

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		0,
		"unfinished count never becomes negative"
	)

	scene.call("reset_progress")

	_assert_equal_int(
		int(scene.call("get_unfinished_count")),
		18,
		"second reset remains deterministic"
	)

	_assert_equal_string(
		String(scene.call("get_progress_text")),
		"Unfinished: 18",
		"reset UI returns to Unfinished: 18"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _assert_true(
	condition: bool,
	label: String
) -> void:
	if condition:
		_pass(label)
	else:
		_fail(label)


func _assert_equal_int(
	actual: int,
	expected: int,
	label: String
) -> void:
	if actual == expected:
		_pass(label)
	else:
		_fail(
			"%s | expected=%d actual=%d"
			% [
				label,
				expected,
				actual
			]
		)


func _assert_equal_string(
	actual: String,
	expected: String,
	label: String
) -> void:
	if actual == expected:
		_pass(label)
	else:
		_fail(
			"%s | expected='%s' actual='%s'"
			% [
				label,
				expected,
				actual
			]
		)


func _pass(label: String) -> void:
	_passed += 1
	print("PASS: ", label)


func _fail(label: String) -> void:
	_failed += 1
	print("FAIL: ", label)