extends SceneTree

var _passed: int = 0
var _failed: int = 0

var _litter_completion_count: int = 0
var _debris_completion_count: int = 0


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Theme Park Loose-Mess Tests ===")

	await process_frame

	await _test_scene_counts_and_ids()
	await _test_litter_behavior()
	await _test_debris_behavior()

	print("")
	print("=== Theme Park Loose-Mess Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("THEME PARK LOOSE-MESS TESTS PASSED")
		quit(0)
	else:
		print("THEME PARK LOOSE-MESS TESTS FAILED")
		quit(1)


func _test_scene_counts_and_ids() -> void:
	print("")
	print("-- exact counts and unique IDs --")

	var packed: PackedScene = load(
		"res://scenes/theme_park/carousel_courtyard.tscn"
	)

	var scene: Node = packed.instantiate()
	root.add_child(scene)

	await process_frame

	var litter_nodes: Array[Node] = []
	var debris_nodes: Array[Node] = []

	_collect_loose_mess(
		scene,
		litter_nodes,
		debris_nodes
	)

	_assert_equal_int(
		litter_nodes.size(),
		7,
		"scene contains exactly seven litter objects"
	)

	_assert_equal_int(
		debris_nodes.size(),
		3,
		"scene contains exactly three debris clusters"
	)

	var expected_litter := [
		&"litter_01",
		&"litter_02",
		&"litter_03",
		&"litter_04",
		&"litter_05",
		&"litter_06",
		&"litter_07"
	]

	var expected_debris := [
		&"debris_01",
		&"debris_02",
		&"debris_03"
	]

	var observed: Dictionary = {}

	for node in litter_nodes:
		var target_id: StringName = node.get(
			"target_id"
		)

		_assert_true(
			not observed.has(target_id),
			"litter target ID is unique: %s"
			% target_id
		)

		observed[target_id] = true

	for node in debris_nodes:
		var target_id: StringName = node.get(
			"target_id"
		)

		_assert_true(
			not observed.has(target_id),
			"debris target ID is unique: %s"
			% target_id
		)

		observed[target_id] = true

	for target_id in expected_litter:
		_assert_true(
			observed.has(target_id),
			"expected litter ID exists: %s"
			% target_id
		)

	for target_id in expected_debris:
		_assert_true(
			observed.has(target_id),
			"expected debris ID exists: %s"
			% target_id
		)

	scene.queue_free()

	await process_frame
	await process_frame


func _collect_loose_mess(
	node: Node,
	litter_nodes: Array[Node],
	debris_nodes: Array[Node]
) -> void:
	var script: Script = node.get_script()

	if script != null:
		var path: String = script.resource_path

		if path == (
			"res://scripts/theme_park/litter_object.gd"
		):
			litter_nodes.append(node)

		elif path == (
			"res://scripts/theme_park/debris_cluster.gd"
		):
			debris_nodes.append(node)

	for child in node.get_children():
		_collect_loose_mess(
			child,
			litter_nodes,
			debris_nodes
		)


func _test_litter_behavior() -> void:
	print("")
	print("-- litter one-shot completion and reset --")

	var script: Script = load(
		"res://scripts/theme_park/litter_object.gd"
	)

	var litter: Node = script.new()

	litter.set(
		"target_id",
		&"litter_test"
	)

	root.add_child(litter)

	await process_frame

	_litter_completion_count = 0

	litter.connect(
		"loose_mess_completed",
		Callable(
			self,
			"_on_litter_completed"
		)
	)

	var carry_result: bool = bool(
		litter.call("begin_carry")
	)

	_assert_true(
		not carry_result,
		"litter interaction never enters carry state"
	)

	_assert_true(
		bool(litter.call("is_completed")),
		"litter completes immediately"
	)

	_assert_equal_int(
		_litter_completion_count,
		1,
		"litter completion signal fires once"
	)

	litter.call("begin_carry")

	_assert_equal_int(
		_litter_completion_count,
		1,
		"completed litter cannot complete twice"
	)

	litter.call("reset_loose_mess")

	await process_frame

	_assert_true(
		not bool(litter.call("is_completed")),
		"litter reset restores incomplete state"
	)

	var mesh: MeshInstance3D = litter.get(
		"_mesh_instance"
	)

	_assert_true(
		mesh != null and mesh.visible,
		"litter reset restores visibility"
	)

	var collision: CollisionShape3D = litter.get(
		"_collision_shape"
	)

	_assert_true(
		collision != null
		and not collision.disabled,
		"litter reset restores collision"
	)

	litter.queue_free()

	await process_frame


func _test_debris_behavior() -> void:
	print("")
	print("-- debris one-shot completion and reset --")

	var script: Script = load(
		"res://scripts/theme_park/debris_cluster.gd"
	)

	var debris: Node = script.new()

	debris.set(
		"target_id",
		&"debris_test"
	)

	root.add_child(debris)

	await process_frame

	_debris_completion_count = 0

	debris.connect(
		"loose_mess_completed",
		Callable(
			self,
			"_on_debris_completed"
		)
	)

	var carry_result: bool = bool(
		debris.call("begin_carry")
	)

	_assert_true(
		not carry_result,
		"debris interaction never enters carry state"
	)

	_assert_true(
		bool(debris.call("is_clearing")),
		"debris enters clearing state"
	)

	# Repeated interaction while clearing must do nothing.
	debris.call("begin_carry")
	debris.call("begin_carry")

	_assert_equal_int(
		_debris_completion_count,
		0,
		"repeated debris interaction does not complete early"
	)

	await create_timer(0.45).timeout

	_assert_true(
		bool(debris.call("is_completed")),
		"debris completes after clear delay"
	)

	_assert_equal_int(
		_debris_completion_count,
		1,
		"debris completion signal fires once"
	)

	debris.call("begin_carry")

	_assert_equal_int(
		_debris_completion_count,
		1,
		"completed debris cannot complete twice"
	)

	debris.call("reset_loose_mess")

	await process_frame

	_assert_true(
		not bool(debris.call("is_completed")),
		"debris reset restores incomplete state"
	)

	_assert_true(
		not bool(debris.call("is_clearing")),
		"debris reset clears active clearing state"
	)

	var timer: Timer = debris.get(
		"_clear_timer"
	)

	_assert_true(
		timer != null and timer.is_stopped(),
		"debris reset cancels clear timer"
	)

	var visual_root: Node3D = debris.get(
		"_visual_root"
	)

	_assert_true(
		visual_root != null
		and visual_root.visible,
		"debris reset restores visibility"
	)

	var collision: CollisionShape3D = debris.get(
		"_collision_shape"
	)

	_assert_true(
		collision != null
		and not collision.disabled,
		"debris reset restores collision"
	)

	debris.queue_free()

	await process_frame


func _on_litter_completed(
	_target_id: StringName
) -> void:
	_litter_completion_count += 1


func _on_debris_completed(
	_target_id: StringName
) -> void:
	_debris_completion_count += 1


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