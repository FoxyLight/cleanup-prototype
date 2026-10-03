extends Node3D

signal entrance_cue_triggered
signal final_payoff_triggered

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

const CAROUSEL_HORSE_ID: StringName = &"carousel_horse"

const CAROUSEL_CENTER := Vector3(
	10.0,
	1.72,
	6.75
)

const CAROUSEL_BULB_COUNT: int = 12
const CAROUSEL_BULB_RADIUS: float = 2.0

const HORSE_PAYOFF_RISE: float = 0.18
const HORSE_PAYOFF_HALF_DURATION: float = 0.35

const PHRASE_MIX_RATE: int = 22050
const PHRASE_DURATION: float = 0.56

@export var final_payoff_audio_enabled: bool = true

var _registered_targets: Dictionary = {}
var _completed_targets: Dictionary = {}

var _unfinished_count: int = TOTAL_REQUIRED_TARGETS
var _progress_label: Label

var _entrance_cue_active: bool = false
var _entrance_sign: Node

var _final_payoff_active: bool = false

var _carousel_horse: Node3D
var _carousel_horse_initial_position: Vector3
var _horse_tween: Tween

var _payoff_bulbs_root: Node3D
var _payoff_bulbs: Array[MeshInstance3D] = []
var _payoff_lights: Array[OmniLight3D] = []

var _bulb_unlit_material: StandardMaterial3D
var _bulb_lit_material: StandardMaterial3D

var _completion_audio_player: AudioStreamPlayer

var _final_payoff_trigger_count: int = 0
var _completion_phrase_trigger_count: int = 0
var _horse_motion_trigger_count: int = 0


func _ready() -> void:
	_register_required_targets()
	_create_progress_ui()
	_connect_target_signals()
	_create_final_payoff_nodes()
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

	if target_id == CAROUSEL_HORSE_ID:
		_carousel_horse = node as Node3D

		if _carousel_horse != null:
			_carousel_horse_initial_position = (
				_carousel_horse.position
			)

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
	_update_final_payoff()

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


func _create_final_payoff_nodes() -> void:
	_create_payoff_materials()
	_create_payoff_bulbs()
	_create_payoff_lights()
	_create_completion_audio_player()

	_set_final_payoff_visuals(false)


func _create_payoff_materials() -> void:
	_bulb_unlit_material = StandardMaterial3D.new()

	_bulb_unlit_material.albedo_color = Color(
		0.28,
		0.20,
		0.08,
		1.0
	)

	_bulb_unlit_material.roughness = 0.65

	_bulb_lit_material = StandardMaterial3D.new()

	_bulb_lit_material.albedo_color = Color(
		1.0,
		0.83,
		0.36,
		1.0
	)

	_bulb_lit_material.emission_enabled = true

	_bulb_lit_material.emission = Color(
		1.0,
		0.67,
		0.18,
		1.0
	)

	_bulb_lit_material.roughness = 0.25


func _create_payoff_bulbs() -> void:
	_payoff_bulbs_root = Node3D.new()
	_payoff_bulbs_root.name = "FinalPayoffBulbs"

	add_child(
		_payoff_bulbs_root
	)

	for index in range(
		CAROUSEL_BULB_COUNT
	):
		var angle: float = (
			TAU
			* float(index)
			/ float(CAROUSEL_BULB_COUNT)
		)

		var bulb := MeshInstance3D.new()

		bulb.name = (
			"Bulb%02d"
			% (index + 1)
		)

		var bulb_mesh := SphereMesh.new()
		bulb_mesh.radius = 0.07
		bulb_mesh.height = 0.14

		bulb.mesh = bulb_mesh

		bulb.position = (
			CAROUSEL_CENTER
			+ Vector3(
				cos(angle)
					* CAROUSEL_BULB_RADIUS,
				0.0,
				sin(angle)
					* CAROUSEL_BULB_RADIUS
			)
		)

		bulb.material_override = (
			_bulb_unlit_material
		)

		_payoff_bulbs_root.add_child(
			bulb
		)

		_payoff_bulbs.append(
			bulb
		)


func _create_payoff_lights() -> void:
	for index in range(4):
		var angle: float = (
			TAU
			* float(index)
			/ 4.0
		)

		var light := OmniLight3D.new()

		light.name = (
			"PayoffLight%02d"
			% (index + 1)
		)

		light.position = (
			CAROUSEL_CENTER
			+ Vector3(
				cos(angle) * 1.45,
				0.05,
				sin(angle) * 1.45
			)
		)

		light.light_color = Color(
			1.0,
			0.72,
			0.32,
			1.0
		)

		light.light_energy = 0.75
		light.omni_range = 2.6
		light.shadow_enabled = false
		light.visible = false

		add_child(light)

		_payoff_lights.append(light)


func _create_completion_audio_player() -> void:
	_completion_audio_player = (
		AudioStreamPlayer.new()
	)

	_completion_audio_player.name = (
		"FinalPayoffAudio"
	)

	_completion_audio_player.stream = (
		_create_completion_phrase()
	)

	_completion_audio_player.volume_db = -7.0

	add_child(
		_completion_audio_player
	)


func _create_completion_phrase() -> AudioStreamWAV:
	var sample_count: int = int(
		PHRASE_DURATION
		* float(PHRASE_MIX_RATE)
	)

	var data := PackedByteArray()

	data.resize(
		sample_count * 2
	)

	for sample_index in range(
		sample_count
	):
		var time: float = (
			float(sample_index)
			/ float(PHRASE_MIX_RATE)
		)

		var frequency: float = (
			_get_phrase_frequency(time)
		)

		var amplitude: float = 0.0

		if frequency > 0.0:
			var envelope: float = (
				_get_phrase_envelope(time)
			)

			amplitude = (
				sin(
					TAU
					* frequency
					* time
				)
				* 0.22
				* envelope
			)

		var encoded_sample: int = int(
			clamp(
				amplitude,
				-1.0,
				1.0
			)
			* 32767.0
		)

		data.encode_s16(
			sample_index * 2,
			encoded_sample
		)

	var stream := AudioStreamWAV.new()

	stream.format = (
		AudioStreamWAV.FORMAT_16_BITS
	)

	stream.mix_rate = PHRASE_MIX_RATE
	stream.stereo = false
	stream.data = data

	return stream


func _get_phrase_frequency(
	time: float
) -> float:
	if time >= 0.00 and time < 0.16:
		return 523.25

	if time >= 0.19 and time < 0.35:
		return 659.25

	if time >= 0.38 and time < 0.56:
		return 783.99

	return 0.0


func _get_phrase_envelope(
	time: float
) -> float:
	if time >= 0.00 and time < 0.16:
		return _note_envelope(
			time,
			0.00,
			0.16
		)

	if time >= 0.19 and time < 0.35:
		return _note_envelope(
			time,
			0.19,
			0.35
		)

	if time >= 0.38 and time < 0.56:
		return _note_envelope(
			time,
			0.38,
			0.56
		)

	return 0.0


func _note_envelope(
	time: float,
	start_time: float,
	end_time: float
) -> float:
	const FADE_TIME: float = 0.025

	var attack: float = clamp(
		(time - start_time)
		/ FADE_TIME,
		0.0,
		1.0
	)

	var release: float = clamp(
		(end_time - time)
		/ FADE_TIME,
		0.0,
		1.0
	)

	return min(
		attack,
		release
	)


func _update_final_payoff() -> void:
	if _final_payoff_active:
		return

	if _unfinished_count != 0:
		return

	_activate_final_payoff()


func _activate_final_payoff() -> void:
	if _final_payoff_active:
		return

	_final_payoff_active = true
	_final_payoff_trigger_count += 1

	_set_final_payoff_visuals(true)
	_play_completion_phrase()
	_play_horse_motion()

	final_payoff_triggered.emit()

	print(
		"Theme Park final carousel payoff activated"
	)


func _set_final_payoff_visuals(
	active: bool
) -> void:
	var material: Material = (
		_bulb_lit_material
		if active
		else _bulb_unlit_material
	)

	for bulb in _payoff_bulbs:
		if bulb != null:
			bulb.material_override = material

	for light in _payoff_lights:
		if light != null:
			light.visible = active


func _play_completion_phrase() -> void:
	_completion_phrase_trigger_count += 1

	if not final_payoff_audio_enabled:
		return

	if _completion_audio_player == null:
		return

	_completion_audio_player.stop()
	_completion_audio_player.play()


func _play_horse_motion() -> void:
	_horse_motion_trigger_count += 1

	if _carousel_horse == null:
		return

	if (
		_horse_tween != null
		and _horse_tween.is_valid()
	):
		_horse_tween.kill()

	_carousel_horse.position = (
		_carousel_horse_initial_position
	)

	var raised_position := (
		_carousel_horse_initial_position
		+ Vector3.UP
			* HORSE_PAYOFF_RISE
	)

	_horse_tween = create_tween()

	_horse_tween.set_trans(
		Tween.TRANS_SINE
	)

	_horse_tween.set_ease(
		Tween.EASE_IN_OUT
	)

	_horse_tween.tween_property(
		_carousel_horse,
		"position",
		raised_position,
		HORSE_PAYOFF_HALF_DURATION
	)

	_horse_tween.tween_property(
		_carousel_horse,
		"position",
		_carousel_horse_initial_position,
		HORSE_PAYOFF_HALF_DURATION
	)


func reset_progress() -> void:
	_completed_targets.clear()

	_unfinished_count = (
		TOTAL_REQUIRED_TARGETS
	)

	reset_entrance_cue()
	reset_final_payoff()
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


func reset_final_payoff() -> void:
	_final_payoff_active = false

	_set_final_payoff_visuals(false)

	if _completion_audio_player != null:
		_completion_audio_player.stop()

	if (
		_horse_tween != null
		and _horse_tween.is_valid()
	):
		_horse_tween.kill()

	_horse_tween = null

	if _carousel_horse != null:
		_carousel_horse.position = (
			_carousel_horse_initial_position
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


func is_final_payoff_active() -> bool:
	return _final_payoff_active


func is_final_payoff_visual_active() -> bool:
	if not _final_payoff_active:
		return false

	if _payoff_bulbs.is_empty():
		return false

	if _payoff_lights.is_empty():
		return false

	for bulb in _payoff_bulbs:
		if (
			bulb == null
			or bulb.material_override
				!= _bulb_lit_material
		):
			return false

	for light in _payoff_lights:
		if (
			light == null
			or not light.visible
		):
			return false

	return true


func is_final_payoff_horse_at_rest() -> bool:
	if _carousel_horse == null:
		return false

	return _carousel_horse.position.is_equal_approx(
		_carousel_horse_initial_position
	)


func get_final_payoff_trigger_count() -> int:
	return _final_payoff_trigger_count


func get_completion_phrase_trigger_count() -> int:
	return _completion_phrase_trigger_count


func get_horse_motion_trigger_count() -> int:
	return _horse_motion_trigger_count