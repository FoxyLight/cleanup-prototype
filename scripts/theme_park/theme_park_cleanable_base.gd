extends "res://scripts/cleanable_base.gd"

@export var clean_color: Color = Color(0.65, 0.65, 0.65, 1.0)
@export var dirty_color: Color = Color(0.28, 0.18, 0.09, 1.0)


func _create_material() -> void:
    var shader := Shader.new()

    shader.code = """
shader_type spatial;

render_mode cull_disabled;

uniform sampler2D dirt_mask : filter_nearest, repeat_disable;

uniform vec3 clean_color = vec3(0.65, 0.65, 0.65);
uniform vec3 dirty_color = vec3(0.28, 0.18, 0.09);

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

    ROUGHNESS = 0.82;
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
