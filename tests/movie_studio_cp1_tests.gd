extends SceneTree

var _passed: int = 0
var _failed: int = 0

const EXPECTED_TARGET_IDS: Array[StringName] = [
	&"saloon_floor",
	&"bar_top",
	&"back_wall",
	&"fight_table",
	&"saloon_doors"
]


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Movie Studio MS-CP1 Tests ===")

	await process_frame
	await _test_saloon_shell_and_cleanables()

	print("")
	print("=== Movie Studio MS-CP1 Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("MOVIE STUDIO MS-CP1 TESTS PASSED")
		quit(0)
	else:
		print("MOVIE STUDIO MS-CP1 TESTS FAILED")
		quit(1)


func _test_saloon_shell_and_cleanables() -> void:
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

	var cleanables: Array[Node] = []
	_collect_cleanables(
		scene,
		cleanables
	)

	_assert_equal_int(
		cleanables.size(),
		5,
		"scene contains exactly five cleanables"
	)

	var found_ids: Dictionary = {}

	for cleanable in cleanables:
		var target_id = cleanable.get(
			"_target_id"
		)

		if target_id != null:
			found_ids[
				StringName(target_id)
			] = true

		_assert_true(
			not bool(
				cleanable.call(
					"is_completed"
				)
			),
			"cleanable begins incomplete"
		)

		_assert_true(
			bool(
				cleanable.call(
					"is_inspection_eligible"
				)
			),
			"cleanable begins inspection eligible"
		)

		_assert_approx(
			float(
				cleanable.call(
					"get_clean_fraction"
				)
			),
			0.0,
			0.000001,
			"cleanable begins at zero clean fraction"
		)

	for target_id in EXPECTED_TARGET_IDS:
		_assert_true(
			found_ids.has(target_id),
			"required MS-CP1 cleanable present: %s"
			% target_id
		)

	var loose_mess_nodes: Array[Node] = []
	_collect_nodes_with_signal(
		scene,
		&"loose_mess_completed",
		loose_mess_nodes
	)

	_assert_equal_int(
		loose_mess_nodes.size(),
		0,
		"MS-CP1 adds no discard/reset loose-mess targets"
	)

	_assert_true(
		scene.get_node_or_null(
			"BaseFloor"
		) != null,
		"saloon shell includes base floor"
	)

	_assert_true(
		scene.get_node_or_null(
			"BarBase"
		) != null,
		"saloon shell includes bar"
	)

	_assert_true(
		scene.get_node_or_null(
			"FightTableBase"
		) != null,
		"saloon shell includes fight table"
	)

	_assert_true(
		scene.get_node_or_null(
			"Player"
		) != null,
		"saloon scene includes player"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _collect_cleanables(
	node: Node,
	output: Array[Node]
) -> void:
	if node.has_signal(
		"cleaning_completed"
	):
		output.append(node)

	for child in node.get_children():
		_collect_cleanables(
			child,
			output
		)


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


func _assert_approx(
	actual: float,
	expected: float,
	tolerance: float,
	label: String
) -> void:
	if absf(
		actual - expected
	) <= tolerance:
		_pass(label)
	else:
		_fail(
			"%s | expected=%f actual=%f tolerance=%f"
			% [
				label,
				expected,
				actual,
				tolerance
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
