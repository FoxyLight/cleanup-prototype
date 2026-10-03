extends "res://scripts/theme_park/theme_park_cleanable_base.gd"

const MASK_WIDTH: int = 512
const MASK_HEIGHT: int = 256
const TEXELS_PER_METER_LOCAL: float = 64.0


func _get_geometry_config() -> Dictionary:
	var vertices := PackedVector3Array()
	var uv2 := PackedVector2Array()
	var face_groups := PackedInt32Array()
	var face_dirt_enabled := PackedByteArray()

	# Every UV island is sized to preserve approximately 64 texels/m.
	#
	# Face groups:
	#
	# BODY
	#  0  left       required
	#  1  right      required
	#  2  front      required
	#  3  rear       required
	#  4  top        excluded because saddle overlaps it
	#  5  bottom     excluded
	#
	# NECK
	#  6  left       required
	#  7  right      required
	#  8  front      required
	#  9  rear       required
	# 10  sky/top    excluded
	# 11  ground/bottom excluded
	#
	# HEAD
	# 12  left       required
	# 13  right      required
	# 14  front      required
	# 15  rear       required
	# 16  sky/top    excluded
	# 17  ground/bottom excluded
	#
	# SADDLE
	# 18  top        required
	# 19  left       required
	# 20  right      required
	# 21  front      excluded because neck obstructs access
	# 22  rear       required
	# 23  bottom     excluded

	var bounds: Array = [
		# BODY
		Rect2i(0,   0, 102, 58),  # 0 left
		Rect2i(104, 0, 102, 58),  # 1 right
		Rect2i(208, 0, 54, 58),   # 2 front
		Rect2i(264, 0, 54, 58),   # 3 rear
		Rect2i(320, 0, 102, 54),  # 4 top
		Rect2i(0,  64, 102, 54),  # 5 bottom

		# NECK
		Rect2i(104, 64, 38, 70),  # 6 left
		Rect2i(144, 64, 38, 70),  # 7 right
		Rect2i(184, 64, 36, 70),  # 8 front
		Rect2i(222, 64, 36, 70),  # 9 rear
		Rect2i(260, 64, 38, 36),  # 10 top
		Rect2i(300, 64, 38, 36),  # 11 bottom

		# HEAD
		Rect2i(340, 64, 46, 36),  # 12 left
		Rect2i(388, 64, 46, 36),  # 13 right
		Rect2i(436, 64, 37, 36),  # 14 front
		Rect2i(0, 140, 37, 36),   # 15 rear
		Rect2i(40, 140, 46, 37),  # 16 top
		Rect2i(88, 140, 46, 37),  # 17 bottom

		# SADDLE
		Rect2i(136, 140, 58, 39), # 18 top
		Rect2i(196, 140, 58, 20), # 19 left
		Rect2i(256, 140, 58, 20), # 20 right
		Rect2i(316, 140, 39, 20), # 21 front
		Rect2i(357, 140, 39, 20), # 22 rear
		Rect2i(398, 140, 58, 39)  # 23 bottom
	]

	# ------------------------------------------------------------
	# BODY
	# ------------------------------------------------------------

	var body_length: float = 102.0 / TEXELS_PER_METER_LOCAL
	var body_height: float = 58.0 / TEXELS_PER_METER_LOCAL
	var body_depth: float = 54.0 / TEXELS_PER_METER_LOCAL

	var body_center := Vector3(
		0.0,
		0.0,
		0.0
	)

	# Left.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			0.0,
			0.0,
			-body_depth * 0.5
		),
		Vector3(
			body_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			body_height,
			0.0
		),
		bounds[0],
		0,
		true
	)

	# Right.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			0.0,
			0.0,
			body_depth * 0.5
		),
		Vector3(
			body_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			body_height,
			0.0
		),
		bounds[1],
		1,
		true
	)

	# Front / chest.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			body_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			body_depth
		),
		Vector3(
			0.0,
			body_height,
			0.0
		),
		bounds[2],
		2,
		true
	)

	# Rear / rump.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			-body_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			body_depth
		),
		Vector3(
			0.0,
			body_height,
			0.0
		),
		bounds[3],
		3,
		true
	)

	# Top.
	#
	# Visible geometry, but not required because the saddle overlaps
	# the surface and would otherwise hide required dirt.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			0.0,
			body_height * 0.5,
			0.0
		),
		Vector3(
			body_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			body_depth
		),
		bounds[4],
		4,
		false
	)

	# Bottom / underside.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		body_center + Vector3(
			0.0,
			-body_height * 0.5,
			0.0
		),
		Vector3(
			body_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			body_depth
		),
		bounds[5],
		5,
		false
	)

	# ------------------------------------------------------------
	# NECK
	# ------------------------------------------------------------

	# Deliberately simple rectangular neck.
	#
	# This removes the ambiguous sloped surfaces from the previous
	# implementation. The four upright sides are straightforward
	# cleaning targets. The literal sky-facing and ground-facing
	# faces exist visually but never contain required dirt.

	var neck_length: float = 38.0 / TEXELS_PER_METER_LOCAL
	var neck_height: float = 70.0 / TEXELS_PER_METER_LOCAL
	var neck_depth: float = 36.0 / TEXELS_PER_METER_LOCAL

	var neck_center := Vector3(
		0.62,
		0.93,
		0.0
	)

	# Left.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			0.0,
			0.0,
			-neck_depth * 0.5
		),
		Vector3(
			neck_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			neck_height,
			0.0
		),
		bounds[6],
		6,
		true
	)

	# Right.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			0.0,
			0.0,
			neck_depth * 0.5
		),
		Vector3(
			neck_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			neck_height,
			0.0
		),
		bounds[7],
		7,
		true
	)

	# Front.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			neck_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			neck_depth
		),
		Vector3(
			0.0,
			neck_height,
			0.0
		),
		bounds[8],
		8,
		true
	)

	# Rear.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			-neck_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			neck_depth
		),
		Vector3(
			0.0,
			neck_height,
			0.0
		),
		bounds[9],
		9,
		true
	)

	# Sky-facing top.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			0.0,
			neck_height * 0.5,
			0.0
		),
		Vector3(
			neck_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			neck_depth
		),
		bounds[10],
		10,
		false
	)

	# Ground-facing bottom.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		neck_center + Vector3(
			0.0,
			-neck_height * 0.5,
			0.0
		),
		Vector3(
			neck_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			neck_depth
		),
		bounds[11],
		11,
		false
	)

	# ------------------------------------------------------------
	# HEAD
	# ------------------------------------------------------------

	var head_length: float = 46.0 / TEXELS_PER_METER_LOCAL
	var head_height: float = 36.0 / TEXELS_PER_METER_LOCAL
	var head_depth: float = 37.0 / TEXELS_PER_METER_LOCAL

	var head_center := Vector3(
		0.95,
		1.48,
		0.0
	)

	# Left.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			0.0,
			0.0,
			-head_depth * 0.5
		),
		Vector3(
			head_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			head_height,
			0.0
		),
		bounds[12],
		12,
		true
	)

	# Right.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			0.0,
			0.0,
			head_depth * 0.5
		),
		Vector3(
			head_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			head_height,
			0.0
		),
		bounds[13],
		13,
		true
	)

	# Front.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			head_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			head_depth
		),
		Vector3(
			0.0,
			head_height,
			0.0
		),
		bounds[14],
		14,
		true
	)

	# Rear.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			-head_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			head_depth
		),
		Vector3(
			0.0,
			head_height,
			0.0
		),
		bounds[15],
		15,
		false
	)

	# Sky-facing top.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			0.0,
			head_height * 0.5,
			0.0
		),
		Vector3(
			head_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			head_depth
		),
		bounds[16],
		16,
		false
	)

	# Ground-facing bottom.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		head_center + Vector3(
			0.0,
			-head_height * 0.5,
			0.0
		),
		Vector3(
			head_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			head_depth
		),
		bounds[17],
		17,
		false
	)

	# ------------------------------------------------------------
	# SADDLE
	# ------------------------------------------------------------

	var saddle_length: float = 58.0 / TEXELS_PER_METER_LOCAL
	var saddle_height: float = 20.0 / TEXELS_PER_METER_LOCAL
	var saddle_depth: float = 39.0 / TEXELS_PER_METER_LOCAL

	var saddle_center := Vector3(
		-0.10,
		0.55,
		0.0
	)

	# Top.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			0.0,
			saddle_height * 0.5,
			0.0
		),
		Vector3(
			saddle_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			saddle_depth
		),
		bounds[18],
		18,
		true
	)

	# Left.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			0.0,
			0.0,
			-saddle_depth * 0.5
		),
		Vector3(
			saddle_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			saddle_height,
			0.0
		),
		bounds[19],
		19,
		true
	)

	# Right.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			0.0,
			0.0,
			saddle_depth * 0.5
		),
		Vector3(
			saddle_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			saddle_height,
			0.0
		),
		bounds[20],
		20,
		true
	)

	# Front.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			saddle_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			saddle_depth
		),
		Vector3(
			0.0,
			saddle_height,
			0.0
		),
		bounds[21],
		21,
		false
	)

	# Rear.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			-saddle_length * 0.5,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			saddle_depth
		),
		Vector3(
			0.0,
			saddle_height,
			0.0
		),
		bounds[22],
		22,
		true
	)

	# Bottom.
	_append_face(
		vertices,
		uv2,
		face_groups,
		face_dirt_enabled,
		saddle_center + Vector3(
			0.0,
			-saddle_height * 0.5,
			0.0
		),
		Vector3(
			saddle_length,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			saddle_depth
		),
		bounds[23],
		23,
		false
	)

	return {
		"target_id": &"carousel_horse",
		"mask_width": MASK_WIDTH,
		"mask_height": MASK_HEIGHT,
		"vertices": vertices,
		"uv2": uv2,
		"face_groups": face_groups,
		"face_dirt_enabled": face_dirt_enabled,
		"group_bounds": bounds
	}


func _append_face(
	vertices: PackedVector3Array,
	uv2: PackedVector2Array,
	face_groups: PackedInt32Array,
	face_dirt_enabled: PackedByteArray,
	center: Vector3,
	width_axis: Vector3,
	height_axis: Vector3,
	rect: Rect2i,
	group_id: int,
	dirt_enabled: bool
) -> void:
	var half_width := width_axis * 0.5
	var half_height := height_axis * 0.5

	var a: Vector3 = (
		center
		- half_width
		- half_height
	)

	var b: Vector3 = (
		center
		- half_width
		+ half_height
	)

	var c: Vector3 = (
		center
		+ half_width
		+ half_height
	)

	var d: Vector3 = (
		center
		+ half_width
		- half_height
	)

	vertices.append(a)
	vertices.append(b)
	vertices.append(c)

	vertices.append(a)
	vertices.append(c)
	vertices.append(d)

	var uv_a := _pixel_to_uv(
		rect.position.x,
		rect.position.y
	)

	var uv_b := _pixel_to_uv(
		rect.position.x,
		rect.end.y - 1
	)

	var uv_c := _pixel_to_uv(
		rect.end.x - 1,
		rect.end.y - 1
	)

	var uv_d := _pixel_to_uv(
		rect.end.x - 1,
		rect.position.y
	)

	uv2.append(uv_a)
	uv2.append(uv_b)
	uv2.append(uv_c)

	uv2.append(uv_a)
	uv2.append(uv_c)
	uv2.append(uv_d)

	face_groups.append(group_id)
	face_groups.append(group_id)

	var dirt_value: int = 1 if dirt_enabled else 0

	face_dirt_enabled.append(dirt_value)
	face_dirt_enabled.append(dirt_value)


func _pixel_to_uv(
	x: int,
	y: int
) -> Vector2:
	return Vector2(
		float(x) / float(MASK_WIDTH - 1),
		float(y) / float(MASK_HEIGHT - 1)
	)