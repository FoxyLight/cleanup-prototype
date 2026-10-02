extends SceneTree

var _passed: int = 0
var _failed: int = 0

var _cue_trigger_count: int = 0


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Theme Park Entrance Cue Tests ===")

	await process_frame

	await _test_entrance_cue()

	print("")
	print("=== Theme Park Entrance Cue Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print(
			"THEME PARK ENTRANCE CUE TESTS PASSED"
		)
		quit(0)
	else:
		print(
			"THEME PARK ENTRANCE CUE TESTS FAILED"
		)
		quit(1)


func _test_entrance_cue() -> void:
	var packed: PackedScene = load(
		"res://scenes/theme_park/carousel_courtyard.tscn"
	)

	var scene: Node = packed.instantiate()

	root.add_child(scene)

	await process_frame

	scene.connect(
		"entrance_cue_triggered",
		Callable(
			self,
			"_on_entrance_cue_triggered"
		)
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_required_target_count"
			)
		),
		18,
		"required target count remains 18"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		18,
		"initial unfinished count remains 18"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"entrance cue begins inactive"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_visual_active"
			)
		),
		"entrance cue visual begins inactive"
	)

	scene.call(
		"record_completion",
		&"entrance_paving"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"paving alone does not trigger cue"
	)

	_assert_equal_int(
		_cue_trigger_count,
		0,
		"paving alone emits no cue"
	)

	scene.call("reset_progress")

	scene.call(
		"record_completion",
		&"entrance_sign"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"sign alone does not trigger cue"
	)

	_assert_equal_int(
		_cue_trigger_count,
		0,
		"sign alone emits no cue"
	)

	scene.call(
		"record_completion",
		&"table"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"unrelated target does not trigger cue"
	)

	scene.call("reset_progress")

	scene.call(
		"record_completion",
		&"entrance_paving"
	)

	scene.call(
		"record_completion",
		&"entrance_sign"
	)

	_assert_true(
		bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"paving then sign triggers cue"
	)

	_assert_true(
		bool(
			scene.call(
				"is_entrance_cue_visual_active"
			)
		),
		"local sign visual activates"
	)

	_assert_equal_int(
		_cue_trigger_count,
		1,
		"paving then sign triggers exactly once"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		16,
		"entrance completion preserves progress"
	)

	scene.call(
		"record_completion",
		&"entrance_paving"
	)

	scene.call(
		"record_completion",
		&"entrance_sign"
	)

	_assert_equal_int(
		_cue_trigger_count,
		1,
		"duplicate completion does not retrigger cue"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		16,
		"duplicates do not alter progress"
	)

	scene.call("reset_progress")

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"reset makes cue inactive"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_entrance_cue_visual_active"
			)
		),
		"reset disables local visual"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		18,
		"reset restores progress to 18"
	)

	scene.call(
		"record_completion",
		&"entrance_sign"
	)

	scene.call(
		"record_completion",
		&"entrance_paving"
	)

	_assert_true(
		bool(
			scene.call(
				"is_entrance_cue_active"
			)
		),
		"sign then paving triggers cue"
	)

	_assert_equal_int(
		_cue_trigger_count,
		2,
		"cue retriggers once after deterministic reset"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _on_entrance_cue_triggered() -> void:
	_cue_trigger_count += 1


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


func _pass(label: String) -> void:
	_passed += 1
	print("PASS: ", label)


func _fail(label: String) -> void:
	_failed += 1
	print("FAIL: ", label)