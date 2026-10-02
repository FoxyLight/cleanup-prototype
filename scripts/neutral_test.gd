extends Node3D

@export var completion_audio_enabled: bool = true

const TOTAL_REQUIRED_TARGETS: int = 4

const AUDIO_SAMPLE_RATE: int = 22050
const COMPLETION_TONE_HZ: float = 660.0
const COMPLETION_TONE_SECONDS: float = 0.12
const COMPLETION_TONE_VOLUME: float = 0.16

@onready var horizontal_cleanable: StaticBody3D = (
	$CleanablePanel
)

@onready var vertical_cleanable: StaticBody3D = (
	$VerticalCleanable
)

@onready var cube_cleanable: StaticBody3D = (
	$CubeCleanable
)

@onready var movable_object: StaticBody3D = (
	$MovableObject
)

@onready var placement_target: Area3D = (
	$PlacementTarget
)

@onready var player: CharacterBody3D = (
	$Player
)

var _unfinished_count: int = TOTAL_REQUIRED_TARGETS
var _completed_targets: Dictionary = {}

var _progress_label: Label
var _completion_audio_player: AudioStreamPlayer


func _ready() -> void:
	_create_progress_ui()

	if completion_audio_enabled:
		_create_completion_audio()

	_connect_completion_signals()
	_update_progress_ui()

	print(
		"Neutral progress initialized: ",
		_unfinished_count,
		" unfinished"
	)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		_restart_neutral_test()


func _create_progress_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "NeutralUI"

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


func _create_completion_audio() -> void:
	_completion_audio_player = AudioStreamPlayer.new()
	_completion_audio_player.name = "CompletionAudio"

	add_child(
		_completion_audio_player
	)

	var stream := AudioStreamWAV.new()

	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AUDIO_SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED

	var sample_count := int(
		AUDIO_SAMPLE_RATE
		* COMPLETION_TONE_SECONDS
	)

	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var time_seconds := (
			float(sample_index)
			/ float(AUDIO_SAMPLE_RATE)
		)

		var progress := (
			float(sample_index)
			/ float(
				maxi(sample_count - 1, 1)
			)
		)

		var envelope := 1.0 - progress

		var wave := sin(
			TAU
			* COMPLETION_TONE_HZ
			* time_seconds
		)

		var sample_value := int(
			clampf(
				wave
				* envelope
				* COMPLETION_TONE_VOLUME,
				-1.0,
				1.0
			)
			* 32767.0
		)

		data.encode_s16(
			sample_index * 2,
			sample_value
		)

	stream.data = data

	_completion_audio_player.stream = (
		stream
	)


func _connect_completion_signals() -> void:
	horizontal_cleanable.cleaning_completed.connect(
		_on_required_target_completed
	)

	vertical_cleanable.cleaning_completed.connect(
		_on_required_target_completed
	)

	cube_cleanable.cleaning_completed.connect(
		_on_required_target_completed
	)

	movable_object.placement_completed.connect(
		_on_required_target_completed
	)


func _on_required_target_completed(
	target_id: StringName
) -> void:
	if _completed_targets.has(
		target_id
	):
		return

	_completed_targets[target_id] = true

	_unfinished_count = maxi(
		0,
		_unfinished_count - 1
	)

	_update_progress_ui()
	_play_completion_audio()

	print(
		"Required target completed: ",
		target_id,
		" | unfinished=",
		_unfinished_count
	)


func _play_completion_audio() -> void:
	if _completion_audio_player == null:
		return

	if _completion_audio_player.stream == null:
		return

	_completion_audio_player.play()


func _update_progress_ui() -> void:
	_progress_label.text = (
		"Unfinished: %d"
		% _unfinished_count
	)


func _restart_neutral_test() -> void:
	print(
		"Restarting neutral test..."
	)

	player.reset_runtime_state()

	horizontal_cleanable.reset_cleanable()
	vertical_cleanable.reset_cleanable()
	cube_cleanable.reset_cleanable()

	placement_target.reset_target()
	movable_object.reset_movable()

	_completed_targets.clear()

	_unfinished_count = (
		TOTAL_REQUIRED_TARGETS
	)

	_update_progress_ui()

	print(
		"Neutral restart complete: ",
		_unfinished_count,
		" unfinished"
	)