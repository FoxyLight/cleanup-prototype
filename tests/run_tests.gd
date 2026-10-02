extends SceneTree

const EPSILON: float = 0.0001

var _passed: int = 0
var _failed: int = 0
var _completion_signal_count: int = 0


func _init() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	print("")
	print("=== Shared Interaction Baseline Tests ===")

	await process_frame

	await _test_cleanable_core()
	await _test_frame_step_independence()
	await _test_completion_and_restart()
	await _test_movable_state()
	await _test_neutral_progress_and_restart()

	print("")
	print("=== Test Results ===")
	print("Passed: ", _passed)
	print("Failed: ", _failed)

	if _failed == 0:
		print("SHARED BASELINE AUTOMATED TESTS PASSED")
		quit(0)
	else:
		print("SHARED BASELINE AUTOMATED TESTS FAILED")
		quit(1)


func _new_horizontal_cleanable() -> Node:
	var script: Script = load(
		"res://scripts/cleanable_panel.gd"
	)

	var cleanable: Node = script.new()
	root.add_child(cleanable)

	await process_frame

	return cleanable


func _test_cleanable_core() -> void:
	print("")
	print("-- cleanable core --")

	var panel: Node = await _new_horizontal_cleanable()

	var initial_dirt: float = float(
		panel.get("_initial_dirt_amount")
	)

	_assert_approx(
		initial_dirt,
		36864.0,
		EPSILON,
		"horizontal initial dirt denominator"
	)

	_assert_approx(
		float(panel.call("get_clean_fraction")),
		0.0,
		EPSILON,
		"new cleanable starts at 0% clean"
	)

	var runtime_mask: Image = panel.get(
		"_runtime_mask"
	)

	var bounds: Rect2i = (
		panel.get("_group_bounds")[0]
	)

	var changed: bool = bool(
		panel.call(
			"_paint_brush",
			96,
			96,
			0.05,
			bounds
		)
	)

	_assert_true(
		changed,
		"brush reports dirt change"
	)

	var center_value: float = (
		runtime_mask.get_pixel(
			96,
			96
		).r
	)

	# CLEAN_RATE_PER_SECOND = 6.0.
	# 0.05 seconds removes 0.30 from a fully dirty texel.
	_assert_approx(
		center_value,
		0.70,
		0.0005,
		"grayscale dirt removal is proportional to delta"
	)

	panel.call("reset_cleanable")

	var before_invalid: float = float(
		panel.call("get_clean_fraction")
	)

	panel.call(
		"clean_at_hit",
		Vector3.ZERO,
		-1,
		0.05
	)

	var after_invalid: float = float(
		panel.call("get_clean_fraction")
	)

	_assert_approx(
		before_invalid,
		after_invalid,
		EPSILON,
		"invalid collision face performs no cleaning"
	)

	# Triangle 0 centroid:
	# position (-0.5, 0, 0.5)
	# expected UV2 approximately (1/3, 2/3)
	# expected mask pixel approximately (64, 127).
	panel.call(
		"clean_at_hit",
		Vector3(-0.5, 0.0, 0.5),
		0,
		0.01
	)

	runtime_mask = panel.get("_runtime_mask")

	var mapped_value: float = (
		runtime_mask.get_pixel(
			64,
			127
		).r
	)

	_assert_true(
		mapped_value < 1.0,
		"known triangle hit maps to expected UV2 mask region"
	)

	var barycentric: Vector3 = panel.call(
		"_calculate_barycentric",
		Vector3(-0.5, 0.0, 0.5),
		Vector3(-1.5, 0.0, -1.5),
		Vector3(-1.5, 0.0, 1.5),
		Vector3(1.5, 0.0, 1.5)
	)

	_assert_approx(
		barycentric.x,
		1.0 / 3.0,
		EPSILON,
		"barycentric component U"
	)

	_assert_approx(
		barycentric.y,
		1.0 / 3.0,
		EPSILON,
		"barycentric component V"
	)

	_assert_approx(
		barycentric.z,
		1.0 / 3.0,
		EPSILON,
		"barycentric component W"
	)

	panel.queue_free()
	await process_frame


func _test_frame_step_independence() -> void:
	print("")
	print("-- frame-step independence --")

	var panel_a: Node = await _new_horizontal_cleanable()
	var panel_b: Node = await _new_horizontal_cleanable()

	var hit := Vector3(
		-0.5,
		0.0,
		0.5
	)

	# Same total cleaning time: 0.10 seconds.
	for _i in range(10):
		panel_a.call(
			"clean_at_hit",
			hit,
			0,
			0.01
		)

	for _i in range(5):
		panel_b.call(
			"clean_at_hit",
			hit,
			0,
			0.02
		)

	var fraction_a: float = float(
		panel_a.call("get_clean_fraction")
	)

	var fraction_b: float = float(
		panel_b.call("get_clean_fraction")
	)

	_assert_approx(
		fraction_a,
		fraction_b,
		0.00001,
		"equal cleaning time produces equal dirt removal across physics step sizes"
	)

	panel_a.queue_free()
	panel_b.queue_free()

	await process_frame


func _test_completion_and_restart() -> void:
	print("")
	print("-- completion and immutable restart --")

	var panel: Node = await _new_horizontal_cleanable()

	_completion_signal_count = 0

	panel.connect(
		"cleaning_completed",
		Callable(
			self,
			"_on_test_cleaning_completed"
		)
	)

	var initial_dirt: float = float(
		panel.get("_initial_dirt_amount")
	)

	panel.set(
		"_current_dirt_amount",
		initial_dirt * 0.04
	)

	panel.call("_check_completion")

	_assert_true(
		bool(panel.get("_completed")),
		"95% threshold marks target complete"
	)

	_assert_approx(
		float(panel.get("_current_dirt_amount")),
		0.0,
		EPSILON,
		"completion clears authoritative dirt remainder"
	)

	var runtime_mask: Image = panel.get(
		"_runtime_mask"
	)

	_assert_approx(
		runtime_mask.get_pixel(0, 0).r,
		0.0,
		EPSILON,
		"completion clears visual dirt remainder"
	)

	_assert_equal_int(
		_completion_signal_count,
		1,
		"completion signal fires once"
	)

	panel.call("_check_completion")

	_assert_equal_int(
		_completion_signal_count,
		1,
		"repeat completion check cannot fire signal twice"
	)

	panel.call("reset_cleanable")

	_assert_true(
		not bool(panel.get("_completed")),
		"restart restores completion eligibility"
	)

	_assert_approx(
		float(panel.call("get_clean_fraction")),
		0.0,
		EPSILON,
		"restart restores zero clean fraction"
	)

	runtime_mask = panel.get("_runtime_mask")

	_assert_approx(
		runtime_mask.get_pixel(0, 0).r,
		1.0,
		EPSILON,
		"restart restores immutable initial dirt mask"
	)

	panel.queue_free()
	await process_frame


func _test_movable_state() -> void:
	print("")
	print("-- movable state --")

	var script: Script = load(
		"res://scripts/movable_object.gd"
	)

	var movable: Node = script.new()

	movable.position = Vector3(
		2.0,
		0.25,
		2.0
	)

	root.add_child(movable)

	await process_frame

	var initial_transform: Transform3D = (
		movable.global_transform
	)

	var pickup_succeeded: bool = bool(
		movable.call("begin_carry")
	)

	_assert_true(
		pickup_succeeded,
		"unplaced movable can begin carry"
	)

	_assert_true(
		bool(movable.call("is_carried")),
		"begin carry enters carried state"
	)

	_assert_equal_int(
		int(movable.collision_layer),
		0,
		"carried movable leaves collision layers"
	)

	var free_drop_transform := Transform3D(
		Basis.IDENTITY,
		Vector3(3.0, 0.25, 3.0)
	)

	movable.call(
		"free_drop",
		free_drop_transform
	)

	_assert_true(
		not bool(movable.call("is_carried")),
		"free drop exits carried state"
	)

	_assert_true(
		not bool(movable.call("is_placed")),
		"free drop does not mark object placed"
	)

	_assert_equal_int(
		int(movable.collision_layer),
		2,
		"free drop restores collision layer"
	)

	_assert_vector3_approx(
		movable.global_position,
		Vector3(3.0, 0.25, 3.0),
		EPSILON,
		"free drop applies candidate transform"
	)

	pickup_succeeded = bool(
		movable.call("begin_carry")
	)

	_assert_true(
		pickup_succeeded,
		"dropped movable can be picked up again"
	)

	var placement_transform := Transform3D(
		Basis.IDENTITY,
		Vector3(4.0, 0.25, 4.0)
	)

	movable.call(
		"place_at_target",
		placement_transform
	)

	_assert_true(
		bool(movable.call("is_placed")),
		"placement marks movable complete"
	)

	_assert_true(
		not bool(movable.call("is_carried")),
		"placement clears carried state"
	)

	var rejected_pickup: bool = bool(
		movable.call("begin_carry")
	)

	_assert_true(
		not rejected_pickup,
		"placed movable rejects pickup"
	)

	movable.call("reset_movable")

	_assert_true(
		not bool(movable.call("is_carried")),
		"movable restart clears carried state"
	)

	_assert_true(
		not bool(movable.call("is_placed")),
		"movable restart clears placed state"
	)

	_assert_transform_origin_approx(
		movable.global_transform,
		initial_transform,
		EPSILON,
		"movable restart restores original transform"
	)

	_assert_true(
		bool(
			movable.call(
				"is_inspection_eligible"
			)
		),
		"unplaced movable is inspection eligible"
	)

	movable.queue_free()
	await process_frame


func _test_neutral_progress_and_restart() -> void:
	print("")
	print("-- neutral progress, inspection, and restart --")

	var packed: PackedScene = load(
		"res://scenes/neutral_test.tscn"
	)

	var scene: Node = packed.instantiate()

	scene.set(
		"completion_audio_enabled",
		false
	)

	root.add_child(scene)

	await process_frame
	await physics_frame

	_assert_equal_int(
		int(scene.get("_unfinished_count")),
		4,
		"neutral progress starts at exactly four"
	)

	scene.call(
		"_on_required_target_completed",
		&"horizontal_panel"
	)

	_assert_equal_int(
		int(scene.get("_unfinished_count")),
		3,
		"first unique completion decrements progress"
	)

	scene.call(
		"_on_required_target_completed",
		&"horizontal_panel"
	)

	_assert_equal_int(
		int(scene.get("_unfinished_count")),
		3,
		"duplicate completion does not decrement progress"
	)

	var horizontal: Node = scene.get_node(
		"CleanablePanel"
	)

	var cube: Node = scene.get_node(
		"CubeCleanable"
	)

	_assert_approx(
		float(
			cube.get(
				"_initial_dirt_amount"
			)
		),
		20480.0,
		EPSILON,
		"cube denominator excludes inaccessible bottom face"
	)

	_assert_true(
		bool(
			horizontal.call(
				"is_inspection_eligible"
			)
		),
		"unfinished cleanable is inspection eligible"
	)

	_assert_true(
		bool(
			horizontal.call(
				"is_inspection_eligible"
			)
		),
		"unfinished cleanable is inspection eligible"
	)

	horizontal.call(
		"set_inspection_highlight",
		true
	)

	var mesh_instance: MeshInstance3D = (
		horizontal.get("_mesh_instance")
	)

	var shader_material: ShaderMaterial = (
		mesh_instance.material_override
		as ShaderMaterial
	)

	_assert_approx(
		float(
			shader_material.get_shader_parameter(
				"inspection_strength"
			)
		),
		0.24,
		EPSILON,
		"inspection highlight enables visual strength"
	)

	horizontal.call(
		"set_inspection_highlight",
		false
	)

	_assert_approx(
		float(
			shader_material.get_shader_parameter(
				"inspection_strength"
			)
		),
		0.0,
		EPSILON,
		"inspection highlight can be cleared"
	)

	var movable: Node = scene.get_node(
		"MovableObject"
	)

	var player: Node = scene.get_node(
		"Player"
	)

	var placement_target: Node = scene.get_node(
		"PlacementTarget"
	)

	# Contaminate several independent runtime states.
	horizontal.call(
		"clean_at_hit",
		horizontal.global_position
			+ Vector3(-0.5, 0.0, 0.5),
		0,
		0.05
	)

	player.global_position = Vector3(
		2.0,
		1.0,
		2.0
	)

	var picked_up: bool = bool(
		movable.call("begin_carry")
	)

	_assert_true(
		picked_up,
		"restart setup can enter carried state"
	)

	placement_target.call(
		"mark_occupied"
	)

	scene.call(
		"_restart_neutral_test"
	)

	_assert_equal_int(
		int(scene.get("_unfinished_count")),
		4,
		"coordinated restart restores progress to four"
	)

	_assert_approx(
		float(
			horizontal.call(
				"get_clean_fraction"
			)
		),
		0.0,
		EPSILON,
		"coordinated restart restores dirt"
	)

	_assert_true(
		not bool(
			movable.call("is_carried")
		),
		"coordinated restart clears carried movable"
	)

	_assert_true(
		not bool(
			movable.call("is_placed")
		),
		"coordinated restart clears placed movable"
	)

	_assert_true(
		not bool(
			placement_target.call(
				"is_occupied"
			)
		),
		"coordinated restart clears placement occupancy"
	)

	var initial_player_transform: Transform3D = (
		player.get(
			"_initial_global_transform"
		)
	)

	_assert_transform_origin_approx(
		player.global_transform,
		initial_player_transform,
		EPSILON,
		"coordinated restart restores player position"
	)

	scene.queue_free()

	await process_frame
	await process_frame


func _on_test_cleaning_completed(
	_target_id: StringName
) -> void:
	_completion_signal_count += 1


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
	if absf(actual - expected) <= tolerance:
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


func _assert_vector3_approx(
	actual: Vector3,
	expected: Vector3,
	tolerance: float,
	label: String
) -> void:
	if actual.distance_to(expected) <= tolerance:
		_pass(label)
	else:
		_fail(
			"%s | expected=%s actual=%s"
			% [
				label,
				str(expected),
				str(actual)
			]
		)


func _assert_transform_origin_approx(
	actual: Transform3D,
	expected: Transform3D,
	tolerance: float,
	label: String
) -> void:
	_assert_vector3_approx(
		actual.origin,
		expected.origin,
		tolerance,
		label
	)


func _pass(label: String) -> void:
	_passed += 1
	print("PASS: ", label)


func _fail(label: String) -> void:
	_failed += 1
	push_error(
		"FAIL: " + label
	)