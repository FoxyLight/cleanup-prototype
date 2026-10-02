extends Node3D

signal entrance_cue_triggered

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

const TOTAL_REQUIRED_TARGETS: int = 18

const ENTRANCE_PAVING_ID: StringName = &"entrance_paving"
const ENTRANCE_SIGN_ID: StringName = &"entrance_sign"

var _registered_targets: Dictionary = {}
var _completed_targets: Dictionary = {}

var _unfinished_count: int = TOTAL_REQUIRED_TARGETS
var _progress_label: Label

var _entrance_cue_active: bool = false
var _entrance_sign: Node


func _ready() -> void:
	_register_required_targets()
	_create_progress_ui()
	_connect_target_signals()
	_update_progress_ui()

	print(
		"Theme Park progress initialized: ",
		_unfinished_count,
		" unfinished"
	)


func _register_required_targets() -> void:
	_registered_targets.clear()

	for target_id in REQUIRED_TARGET_IDS:
		if _registered_targets.has(target_id):
			push_error(
				"Duplicate required target ID: %s"
				% target_id
			)
			continue

		_registered_targets[target_id] = true

	if _registered_targets.size() != TOTAL_REQUIRED_TARGETS:
		push_error(
			"Theme Park required target registration mismatch. "
			+ "Expected %d, got %d."
			% [
				TOTAL_REQUIRED_TARGETS,
				_registered_targets.size()
			]
		)


func _create_progress_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "ThemeParkUI"

	add_child(canvas)

	_progress_label = Label.new()
	_progress_label.name = "ProgressLabel"

	_progress_label.position = Vector2(
		16.0,
		16.0
	)

	_progress_label.add_theme_font_size_override(
		"font_size",
		24
	)

	canvas.add_child(
		_progress_label
	)


func _connect_target_signals() -> void:
	var found_target_ids: Dictionary = {}

	_connect_target_signals_recursive(
		self,
		found_target_ids
	)

	for target_id in REQUIRED_TARGET_IDS:
		if not found_target_ids.has(target_id):
			push_error(
				"Required Theme Park target not found in scene: %s"
				% target_id
			)


func _connect_target_signals_recursive(
	node: Node,
	found_target_ids: Dictionary
) -> void:
	if node != self:
		_try_connect_target(
			node,
			found_target_ids
		)

	for child in node.get_children():
		_connect_target_signals_recursive(
			child,
			found_target_ids
		)


func _try_connect_target(
	node: Node,
	found_target_ids: Dictionary
) -> void:
	var target_id := _get_node_target_id(node)

	if target_id == &"":
		return

	if not _registered_targets.has(target_id):
		return

	if found_target_ids.has(target_id):
		push_error(
			"Duplicate Theme Park scene target ID: %s"
			% target_id
		)
		return

	var connected: bool = false

	if node.has_signal("cleaning_completed"):
		node.connect(
			"cleaning_completed",
			Callable(
				self,
				"_on_required_target_completed"
			)
		)

		connected = true

	elif node.has_signal("loose_mess_completed"):
		node.connect(
			"loose_mess_completed",
			Callable(
				self,
				"_on_required_target_completed"
			)
		)

		connected = true

	if not connected:
		push_error(
			"Required Theme Park target has no supported "
			+ "completion signal: %s"
			% target_id
		)
		return

	if target_id == ENTRANCE_SIGN_ID:
		_entrance_sign = node

	found_target_ids[target_id] = true


func _get_node_target_id(
	node: Node
) -> StringName:
	if node.has_signal("cleaning_completed"):
		var cleanable_id = node.get("_target_id")

		if cleanable_id != null:
			return StringName(cleanable_id)

	if node.has_signal("loose_mess_completed"):
		var loose_mess_id = node.get("target_id")

		if loose_mess_id != null:
			return StringName(loose_mess_id)

	return &""


func _on_required_target_completed(
	target_id: StringName
) -> void:
	record_completion(target_id)


func record_completion(
	target_id: StringName
) -> bool:
	if not _registered_targets.has(target_id):
		print(
			"Ignored unknown Theme Park target completion: ",
			target_id
		)

		return false

	if _completed_targets.has(target_id):
		return false

	_completed_targets[target_id] = true

	_unfinished_count = maxi(
		0,
		TOTAL_REQUIRED_TARGETS
		- _completed_targets.size()
	)

	_update_progress_ui()
	_update_entrance_cue(target_id)

	print(
		"Theme Park target completed: ",
		target_id,
		" | unfinished=",
		_unfinished_count
	)

	return true


func _update_entrance_cue(
	target_id: StringName
) -> void:
	if _entrance_cue_active:
		return

	if (
		target_id != ENTRANCE_PAVING_ID
		and target_id != ENTRANCE_SIGN_ID
	):
		return

	if not _completed_targets.has(
		ENTRANCE_PAVING_ID
	):
		return

	if not _completed_targets.has(
		ENTRANCE_SIGN_ID
	):
		return

	_activate_entrance_cue()


func _activate_entrance_cue() -> void:
	if _entrance_cue_active:
		return

	_entrance_cue_active = true

	if (
		_entrance_sign != null
		and _entrance_sign.has_method(
			"set_local_completion_cue"
		)
	):
		_entrance_sign.call(
			"set_local_completion_cue",
			true
		)

	entrance_cue_triggered.emit()

	print(
		"Theme Park entrance/plaza local cue activated"
	)


func reset_progress() -> void:
	_completed_targets.clear()

	_unfinished_count = (
		TOTAL_REQUIRED_TARGETS
	)

	reset_entrance_cue()
	_update_progress_ui()

	print(
		"Theme Park progress reset: ",
		_unfinished_count,
		" unfinished"
	)


func reset_entrance_cue() -> void:
	_entrance_cue_active = false

	if (
		_entrance_sign != null
		and _entrance_sign.has_method(
			"reset_local_completion_cue"
		)
	):
		_entrance_sign.call(
			"reset_local_completion_cue"
		)


func _update_progress_ui() -> void:
	if _progress_label == null:
		return

	_progress_label.text = (
		"Unfinished: %d"
		% _unfinished_count
	)


func get_unfinished_count() -> int:
	return _unfinished_count


func get_required_target_count() -> int:
	return _registered_targets.size()


func get_completed_target_count() -> int:
	return _completed_targets.size()


func has_required_target_id(
	target_id: StringName
) -> bool:
	return _registered_targets.has(target_id)


func get_progress_text() -> String:
	if _progress_label == null:
		return ""

	return _progress_label.text


func is_entrance_cue_active() -> bool:
	return _entrance_cue_active


func is_entrance_cue_visual_active() -> bool:
	if _entrance_sign == null:
		return false

	if not _entrance_sign.has_method(
		"is_local_completion_visual_active"
	):
		return false

	return bool(
		_entrance_sign.call(
			"is_local_completion_visual_active"
		)
	)