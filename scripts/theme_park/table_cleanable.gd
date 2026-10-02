extends "res://scripts/theme_park/theme_park_cleanable_base.gd"

const MASK_WIDTH: int = 128
const MASK_HEIGHT: int = 96


func _get_geometry_config() -> Dictionary:
	var vertices := PackedVector3Array()
	var uv2 := PackedVector2Array()
	var face_groups := PackedInt32Array()

	# Preserve the existing dirt workload.
	#
	# Tabletop:
	# 1.40 m × 0.80 m
	# ~89.6 × 51.2 texels at 64 texels/m.
	#
	# Apron:
	# 1.40 m × 0.40 m
	# ~89.6 × 25.6 texels at 64 texels/m.
	var bounds: Array = [
		Rect2i(0, 0, 90, 52),
		Rect2i(0, 52, 90, 26)
	]

	# Tabletop.
	#
	# UV horizontal axis -> 1.40 m world X width.
	# UV vertical axis   -> 0.80 m world Z depth.
	_append_rect(
		vertices,
		uv2,
		face_groups,
		Vector3(
			0.0,
			0.0,
			0.0
		),
		Vector3(
			1.40,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.0,
			0.80
		),
		bounds[0],
		0
	)

	# Front apron.
	#
	# UV horizontal axis -> 1.40 m world X width.
	# UV vertical axis   -> 0.40 m world Y height.
	#
	# The old mapping had these axes transposed, which stretched
	# the cleaning brush dramatically.
	_append_rect(
		vertices,
		uv2,
		face_groups,
		Vector3(
			0.0,
			-0.20,
			0.40
		),
		Vector3(
			1.40,
			0.0,
			0.0
		),
		Vector3(
			0.0,
			0.40,
			0.0
		),
		bounds[1],
		1
	)

	return {
		"target_id": &"table",
		"mask_width": MASK_WIDTH,
		"mask_height": MASK_HEIGHT,
		"vertices": vertices,
		"uv2": uv2,
		"face_groups": face_groups,
		"group_bounds": bounds
	}


func _append_rect(
	vertices: PackedVector3Array,
	uv2: PackedVector2Array,
	face_groups: PackedInt32Array,
	center: Vector3,
	width_axis: Vector3,
	height_axis: Vector3,
	rect: Rect2i,
	group_id: int
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


func _pixel_to_uv(
	x: int,
	y: int
) -> Vector2:
	return Vector2(
		float(x) / float(MASK_WIDTH - 1),
		float(y) / float(MASK_HEIGHT - 1)
	)