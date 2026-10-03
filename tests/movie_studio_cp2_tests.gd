extends SceneTree

var _passed: int = 0
var _failed: int = 0

var _discard_signal_count: int = 0

const EXPECTED_DISCARD_IDS: Array[StringName] = [
	&"discard_bottle_01",
	&"discard_paper_01",
	&"discard_food_01",
	&"discard_plate_01",
	&"discard_paper_02",
	&"discard_bottle_02",
	&"discard_food_02"
]


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Movie Studio MS-CP2 Tests ===")

	await process_frame
	await _test_seven_discard_targets()

	print("")
	print("=== Movie Studio MS-CP2 Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("MOVIE STUDIO MS-CP2 TESTS PASSED")
		quit(0)
	else:
		print("MOVIE STUDIO MS-CP2 TESTS FAILED")
		quit(1)


func _test_seven_discard_targets() -> void:
	var packed: PackedScene = load(
		"res://scenes/movie_studio/saloon_after_fight.tscn"
	)

	_assert_true(
		packed != null,
		"saloon scene loads"
	)

	if packed == null:
		return

	var scene: Node = packed.instantiate()
	root.add_child(scene)

	await process_frame

	var discard_nodes: Array[Node] = []
	_collect_nodes_with_signal(
		scene,
		&"discard_completed",
		discard_nodes
	)

	_assert_equal_int(
		discard_nodes.size(),
		7,
		"scene contains exactly seven DISCARD targets"
	)

	var found_ids: Dictionary = {}

	for discard_node in discard_nodes:
		var target_id = discard_node.get(
			"target_id"
		)

		if target_id != null:
			found_ids[
				StringName(target_id)
			] = true

		discard_node.connect(
			"discard_completed",
			Callable(
				self,
				"_on_discard_completed"
			)
		)

		_assert_true(
			not bool(
				discard_node.call(
					"is_completed"
				)
			),
			"DISCARD target begins incomplete"
		)

		_assert_true(
			bool(
				discard_node.call(
					"is_inspection_eligible"
				)
			),
			"unfinished DISCARD target is inspection eligible"
		)

		_assert_true(
			bool(
				discard_node.call(
					"is_visual_active"
				)
			),
			"unfinished DISCARD target is visible"
		)

	for target_id in EXPECTED_DISCARD_IDS:
		_assert_true(
			found_ids.has(target_id),
			"required DISCARD target present: %s"
			% target_id
		)

	var cleanables: Array[Node] = []
	_collect_nodes_with_signal(
		scene,
		&"cleaning_completed",
		cleanables
	)

	_assert_equal_int(
		cleanables.size(),
		5,
		"MS-CP1 five-cleanable count remains unchanged"
	)

	for discard_node in discard_nodes:
		var carry_result: bool = bool(
			discard_node.call(
				"begin_carry"
			)
		)

		_assert_true(
			not carry_result,
			"DISCARD interaction never enters carry state"
		)

		_assert_true(
			bool(
				discard_node.call(
					"is_completed"
				)
			),
			"DISCARD interaction completes target immediately"
		)

		_assert_true(
			not bool(
				discard_node.call(
					"is_visual_active"
				)
			),
			"completed DISCARD target disappears"
		)

	_assert_equal_int(
		_discard_signal_count,
		7,
		"seven unique DISCARD interactions emit seven completions"
	)

	var first_discard: Node = discard_nodes[0]

	var duplicate_result: bool = bool(
		first_discard.call(
			"begin_carry"
		)
	)

	_assert_true(
		not duplicate_result,
		"completed DISCARD target still rejects carrying"
	)

	_assert_equal_int(
		_discard_signal_count,
		7,
		"completed DISCARD target does not emit twice"
	)

	first_discard.call(
		"reset_discard"
	)

	await process_frame

	_assert_true(
		not bool(
			first_discard.call(
				"is_completed"
			)
		),
		"DISCARD reset restores incomplete state"
	)

	_assert_true(
		bool(
			first_discard.call(
				"is_visual_active"
			)
		),
		"DISCARD reset restores visibility"
	)

	first_discard.call(
		"begin_carry"
	)

	_assert_equal_int(
		_discard_signal_count,
		8,
		"reset target can complete once in a new cycle"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _collect_nodes_with_signal(
	node: Node,
	signal_name: StringName,
	output: Array[Node]
) -> void:
	if node.has_signal(signal_name):
		output.append(node)

	for child in node.get_children():
		_collect_nodes_with_signal(
			child,
			signal_name,
			output
		)


func _on_discard_completed(
	_target_id: StringName
) -> void:
	_discard_signal_count += 1


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
	push_error(
		"FAIL: %s"
		% label
	)
