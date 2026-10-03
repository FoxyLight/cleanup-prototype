extends SceneTree

var _passed: int = 0
var _failed: int = 0

var _payoff_signal_count: int = 0

const REQUIRED_TARGET_IDS: Array[StringName] = [
	&"entrance_paving",
	&"entrance_sign",
	&"seating_paving",
	&"table",
	&"bench",
	&"carousel_platform",
	&"carousel_railing",
	&"carousel_horse",
	&"litter_01",
	&"litter_02",
	&"litter_03",
	&"litter_04",
	&"litter_05",
	&"litter_06",
	&"litter_07",
	&"debris_01",
	&"debris_02",
	&"debris_03"
]


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Theme Park Final Payoff Tests ===")

	await process_frame

	await _test_final_payoff()

	print("")
	print("=== Theme Park Final Payoff Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print(
			"THEME PARK FINAL PAYOFF TESTS PASSED"
		)

		quit(0)

	else:
		print(
			"THEME PARK FINAL PAYOFF TESTS FAILED"
		)

		quit(1)


func _test_final_payoff() -> void:
	var packed: PackedScene = load(
		"res://scenes/theme_park/carousel_courtyard.tscn"
	)

	var scene: Node = packed.instantiate()

	scene.set(
		"final_payoff_audio_enabled",
		false
	)

	root.add_child(scene)

	await process_frame

	scene.connect(
		"final_payoff_triggered",
		Callable(
			self,
			"_on_final_payoff_triggered"
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
				"is_final_payoff_active"
			)
		),
		"final payoff begins inactive"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_final_payoff_visual_active"
			)
		),
		"final payoff visuals begin inactive"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_horse_at_rest"
			)
		),
		"carousel horse begins at rest"
	)

	for index in range(
		REQUIRED_TARGET_IDS.size() - 1
	):
		scene.call(
			"record_completion",
			REQUIRED_TARGET_IDS[index]
		)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		1,
		"17 completions leave one unfinished"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_final_payoff_active"
			)
		),
		"17 completions do not trigger final payoff"
	)

	_assert_equal_int(
		_payoff_signal_count,
		0,
		"17 completions emit no final payoff signal"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_completion_phrase_trigger_count"
			)
		),
		0,
		"17 completions do not trigger phrase"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_horse_motion_trigger_count"
			)
		),
		0,
		"17 completions do not trigger horse motion"
	)

	scene.call(
		"record_completion",
		REQUIRED_TARGET_IDS[
			REQUIRED_TARGET_IDS.size() - 1
		]
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		0,
		"18th completion reaches zero unfinished"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_active"
			)
		),
		"18th completion activates final payoff"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_visual_active"
			)
		),
		"carousel bulbs and lights activate"
	)

	_assert_equal_int(
		_payoff_signal_count,
		1,
		"final payoff signal fires exactly once"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_final_payoff_trigger_count"
			)
		),
		1,
		"final payoff controller activates once"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_completion_phrase_trigger_count"
			)
		),
		1,
		"completion phrase is triggered once"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_horse_motion_trigger_count"
			)
		),
		1,
		"horse motion is triggered once"
	)

	for target_id in REQUIRED_TARGET_IDS:
		scene.call(
			"record_completion",
			target_id
		)

	_assert_equal_int(
		_payoff_signal_count,
		1,
		"duplicate completions do not retrigger payoff"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_final_payoff_trigger_count"
			)
		),
		1,
		"duplicate completions preserve one-shot state"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_completion_phrase_trigger_count"
			)
		),
		1,
		"duplicates do not replay phrase"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_horse_motion_trigger_count"
			)
		),
		1,
		"duplicates do not restart horse motion"
	)

	scene.call("reset_progress")

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		18,
		"reset restores 18 unfinished"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_final_payoff_active"
			)
		),
		"reset deactivates final payoff"
	)

	_assert_true(
		not bool(
			scene.call(
				"is_final_payoff_visual_active"
			)
		),
		"reset turns payoff visuals off"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_horse_at_rest"
			)
		),
		"reset restores horse position"
	)

	for reverse_index in range(
		REQUIRED_TARGET_IDS.size() - 1,
		-1,
		-1
	):
		scene.call(
			"record_completion",
			REQUIRED_TARGET_IDS[
				reverse_index
			]
		)

	_assert_equal_int(
		int(
			scene.call(
				"get_unfinished_count"
			)
		),
		0,
		"reverse completion order still reaches zero"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_active"
			)
		),
		"payoff can trigger again after reset"
	)

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_visual_active"
			)
		),
		"visual payoff returns after reset cycle"
	)

	_assert_equal_int(
		_payoff_signal_count,
		2,
		"second completion cycle emits once more"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_final_payoff_trigger_count"
			)
		),
		2,
		"controller triggers once per completion cycle"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_completion_phrase_trigger_count"
			)
		),
		2,
		"phrase triggers once per completion cycle"
	)

	_assert_equal_int(
		int(
			scene.call(
				"get_horse_motion_trigger_count"
			)
		),
		2,
		"horse motion triggers once per completion cycle"
	)

	scene.call("reset_progress")

	_assert_true(
		bool(
			scene.call(
				"is_final_payoff_horse_at_rest"
			)
		),
		"final reset restores horse after second cycle"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _on_final_payoff_triggered() -> void:
	_payoff_signal_count += 1


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
	print(
		"PASS: ",
		label
	)


func _fail(label: String) -> void:
	_failed += 1
	print(
		"FAIL: ",
		label
	)