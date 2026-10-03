extends "res://scripts/cleanable_base.gd"

enum SurfaceOrientation {
	HORIZONTAL,
	VERTICAL
}

@export var target_id: StringName = &"movie_studio_cleanable"
@export var width_m: float = 1.0
@export var height_m: float = 1.0
@export var orientation: SurfaceOrientation = SurfaceOrientation.HORIZONTAL

@export var clean_color: Color = Color(0.56, 0.42, 0.26, 1.0)
@export var dirty_color: Color = Color(0.22, 0.12, 0.06, 1.0)


func _get_geometry_config() -> Dictionary:
	var safe_width: float = maxf(0.25, width_m)
	var safe_height: float = maxf(0.25, height_m)

	var mask_width: int = maxi(
		16,
		int(round(safe_width * TEXELS_PER_METER))
	)

	var mask_height: int = maxi(
		16,
		int(round(safe_height * TEXELS_PER_METER))
	)

	var half_width: float = safe_width * 0.5
	var half_height: float = safe_height * 0.5

	var vertices := PackedVector3Array()

	if orientation == SurfaceOrientation.HORIZONTAL:
		vertices = PackedVector3Array([
			Vector3(-half_width, 0.0, -half_height),
			Vector3(-half_width, 0.0, half_height),
			Vector3(half_width, 0.0, half_height),

			Vector3(-half_width, 0.0, -half_height),
			Vector3(half_width, 0.0, half_height),
			Vector3(half_width, 0.0, -half_height)
		])
	else:
		# Keep the vertical surface's world X axis aligned with UV U
		# and world Y axis aligned with UV V. The previous vertex order
		# crossed those axes, which visibly stretched the cleaning brush
		# on rectangular vertical surfaces such as the back wall and doors.
		vertices = PackedVector3Array([
			Vector3(-half_width, -half_height, 0.0),
			Vector3(-half_width, half_height, 0.0),
			Vector3(half_width, half_height, 0.0),

			Vector3(-half_width, -half_height, 0.0),
			Vector3(half_width, half_height, 0.0),
			Vector3(half_width, -half_height, 0.0)
		])

	var uv2 := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),

		Vector2(0.0, 0.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0)
	])

	return {
		"target_id": target_id,
		"mask_width": mask_width,
		"mask_height": mask_height,
		"vertices": vertices,
		"uv2": uv2,
		"face_groups": PackedInt32Array([0, 0]),
		"group_bounds": [
			Rect2i(
				0,
				0,
				mask_width,
				mask_height
			)
		]
	}


func _create_material() -> void:
	var shader := Shader.new()

	shader.code = """
shader_type spatial;

render_mode cull_disabled;

uniform sampler2D dirt_mask : filter_nearest, repeat_disable;

uniform vec3 clean_color = vec3(0.56, 0.42, 0.26);
uniform vec3 dirty_color = vec3(0.22, 0.12, 0.06);

uniform vec3 inspection_color = vec3(1.0, 0.85, 0.15);
uniform float inspection_strength = 0.0;

void fragment() {
	float dirt = texture(dirt_mask, UV2).r;

	vec3 base_color = mix(
		clean_color,
		dirty_color,
		dirt
	);

	ALBEDO = mix(
		base_color,
		inspection_color,
		inspection_strength
	);

	ROUGHNESS = 0.84;
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader

	material.set_shader_parameter(
		"dirt_mask",
		_runtime_texture
	)

	material.set_shader_parameter(
		"clean_color",
		Vector3(
			clean_color.r,
			clean_color.g,
			clean_color.b
		)
	)

	material.set_shader_parameter(
		"dirty_color",
		Vector3(
			dirty_color.r,
			dirty_color.g,
			dirty_color.b
		)
	)

	_mesh_instance.material_override = material
