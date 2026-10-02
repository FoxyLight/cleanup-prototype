extends "res://scripts/theme_park/theme_park_cleanable_base.gd"

const WIDTH_M: float = 2.2
const HEIGHT_M: float = 1.2

const MASK_WIDTH: int = 141
const MASK_HEIGHT: int = 77

var _local_completion_cue_active: bool = false
var _completion_light: OmniLight3D


func _ready() -> void:
	super._ready()
	_create_local_completion_cue()


func _create_local_completion_cue() -> void:
	_completion_light = OmniLight3D.new()
	_completion_light.name = "LocalCompletionLight"

	_completion_light.position = Vector3(
		0.0,
		0.0,
		0.35
	)

	_completion_light.light_color = Color(
		1.0,
		0.78,
		0.45,
		1.0
	)

	_completion_light.light_energy = 1.25
	_completion_light.omni_range = 3.0
	_completion_light.shadow_enabled = false
	_completion_light.visible = false

	add_child(_completion_light)


func set_local_completion_cue(
	active: bool
) -> void:
	_local_completion_cue_active = active

	if _completion_light != null:
		_completion_light.visible = active


func reset_local_completion_cue() -> void:
	set_local_completion_cue(false)


func is_local_completion_cue_active() -> bool:
	return _local_completion_cue_active


func is_local_completion_visual_active() -> bool:
	return (
		_completion_light != null
		and _completion_light.visible
	)


func _get_geometry_config() -> Dictionary:
	var half_width: float = WIDTH_M * 0.5
	var half_height: float = HEIGHT_M * 0.5

	var vertices := PackedVector3Array([
		Vector3(
			-half_width,
			-half_height,
			0.0
		),
		Vector3(
			half_width,
			half_height,
			0.0
		),
		Vector3(
			-half_width,
			half_height,
			0.0
		),

		Vector3(
			-half_width,
			-half_height,
			0.0
		),
		Vector3(
			half_width,
			-half_height,
			0.0
		),
		Vector3(
			half_width,
			half_height,
			0.0
		)
	])

	var uv2 := PackedVector2Array([
		Vector2(0.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),

		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0)
	])

	return {
		"target_id": &"entrance_sign",
		"mask_width": MASK_WIDTH,
		"mask_height": MASK_HEIGHT,
		"vertices": vertices,
		"uv2": uv2,

		"face_groups": PackedInt32Array([
			0,
			0
		]),

		"group_bounds": [
			Rect2i(
				0,
				0,
				MASK_WIDTH,
				MASK_HEIGHT
			)
		]
	}