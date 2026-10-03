extends SceneTree

var _passed: int = 0
var _failed: int = 0

var _return_signal_count: int = 0

const EXPECTED_PROP_IDS: Array[StringName] = [
	&"return_hat",
	&"return_lantern",
	&"return_stool",
	&"return_mug"
]

const EXPECTED_TARGET_IDS: Array[StringName] = [
	&"return_hat_rack",
	&"return_lantern_hook",
	&"return_stool_spot",
	&"return_mug_shelf"
]


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Movie Studio MS-CP3 Tests ===")

	await process_frame
	await _test_four_return_targets()

	print("")
	print("=== Movie Studio MS-CP3 Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("MOVIE STUDIO MS-CP3 TESTS PASSED")
		quit(0)
	else:
		print("MOVIE STUDIO MS-CP3 TESTS FAILED")
		quit(1)


func _test_four_return_targets() -> void:
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

	var return_props: Array[Node] = []
	_collect_nodes_with_signal(
		scene,
		&"return_completed",
		return_props
	)

	_assert_equal_int(
		return_props.size(),
		4,
		"scene contains exactly four RETURN props"
	)

	var placement_targets: Array[Node] = []
	_collect_placement_targets(
		scene,
		placement_targets
	)

	_assert_equal_int(
		placement_targets.size(),
		4,
		"scene contains exactly four RETURN destinations"
	)

	var found_prop_ids: Dictionary = {}
	var found_target_ids: Dictionary = {}

	for prop in return_props:
		var prop_id = prop.get("prop_id")
		var required_target_id = prop.get(
			"required_target_id"
		)

		if prop_id != null:
			found_prop_ids[
				StringName(prop_id)
			] = true

		if required_target_id != null:
			found_target_ids[
				StringName(required_target_id)
			] = true

		prop.connect(
			"return_completed",
			Callable(
				self,
				"_on_return_completed"
			)
		)

		_assert_true(
			not bool(prop.call("is_carried")),
			"RETURN prop begins not carried"
		)

		_assert_true(
			not bool(prop.call("is_placed")),
			"RETURN prop begins not placed"
		)

		_assert_true(
			bool(
				prop.call(
					"is_inspection_eligible"
				)
			),
			"unfinished RETURN prop is inspection eligible"
		)

	for prop_id in EXPECTED_PROP_IDS:
		_assert_true(
			found_prop_ids.has(prop_id),
			"required RETURN prop present: %s"
			% prop_id
		)

	for target_id in EXPECTED_TARGET_IDS:
		_assert_true(
			found_target_ids.has(target_id),
			"required RETURN destination present: %s"
			% target_id
		)

	var targets_by_id: Dictionary = {}

	for target in placement_targets:
		targets_by_id[
			StringName(
				target.get("target_id")
			)
		] = target

	for prop in return_props:
		var target_id := StringName(
			prop.get("required_target_id")
		)

		var target: Node = targets_by_id[
			target_id
		]

		_assert_true(
			bool(prop.call("begin_carry")),
			"RETURN prop can begin carry"
		)

		_assert_true(
			bool(
				target.call(
					"accepts_object",
					prop
				)
			),
			"matching RETURN destination accepts prop"
		)

		prop.call(
			"place_at_target",
			target.call(
				"get_snap_transform"
			)
		)

		target.call("mark_occupied")

		_assert_true(
			bool(prop.call("is_placed")),
			"successful RETURN placement marks prop placed"
		)

		_assert_true(
			bool(target.call("is_occupied")),
			"successful RETURN placement occupies destination"
		)

		_assert_true(
			not bool(prop.call("begin_carry")),
			"placed RETURN prop rejects pickup"
		)

	_assert_equal_int(
		_return_signal_count,
		4,
		"four successful placements emit four completions"
	)

	var first_prop: Node = return_props[0]
	var first_target: Node = targets_by_id[
		StringName(
			first_prop.get(
				"required_target_id"
			)
		)
	]

	first_prop.call("reset_return_prop")
	first_target.call("reset_target")

	_assert_true(
		not bool(first_prop.call("is_placed")),
		"RETURN reset clears placed state"
	)

	_assert_true(
		not bool(first_target.call("is_occupied")),
		"RETURN destination reset clears occupancy"
	)

	_assert_true(
		bool(first_prop.call("begin_carry")),
		"reset RETURN prop can be carried again"
	)

	first_prop.call(
		"place_at_target",
		first_target.call(
			"get_snap_transform"
		)
	)

	first_target.call("mark_occupied")

	_assert_equal_int(
		_return_signal_count,
		5,
		"reset RETURN prop can complete once in a new cycle"
	)

	var discard_nodes: Array[Node] = []
	_collect_nodes_with_signal(
		scene,
		&"discard_completed",
		discard_nodes
	)

	_assert_equal_int(
		discard_nodes.size(),
		7,
		"MS-CP2 seven DISCARD targets remain unchanged"
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
		"MS-CP1 five cleanables remain unchanged"
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


func _collect_placement_targets(
	node: Node,
	output: Array[Node]
) -> void:
	if (
		node.has_method("accepts_object")
		and node.has_method("get_snap_transform")
		and node.has_method("mark_occupied")
	):
		output.append(node)

	for child in node.get_children():
		_collect_placement_targets(
			child,
			output
		)


func _on_return_completed(
	_target_id: StringName
) -> void:
	_return_signal_count += 1


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
