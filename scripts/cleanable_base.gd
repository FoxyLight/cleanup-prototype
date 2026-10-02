extends StaticBody3D

signal cleaning_completed(target_id: StringName)

const TEXELS_PER_METER: float = 64
const BRUSH_RADIUS_M: float = 0.22
const CLEAN_RATE_PER_SECOND: float = 6
const COMPLETE_THRESHOLD: float = 0.95

var _target_id: StringName

var _mesh_instance: MeshInstance3D
var _collision_shape: CollisionShape3D

var _initial_mask: Image
var _runtime_mask: Image
var _runtime_texture: ImageTexture

var _mask_width: int = 0
var _mask_height: int = 0
var _brush_radius_px: int = 0

var _initial_dirt_amount: float = 0.0
var _current_dirt_amount: float = 0.0

var _completed: bool = false

var _face_vertices: Array = []
var _face_uv2: Array = []
var _face_groups: PackedInt32Array
var _face_dirt_enabled: PackedByteArray
var _group_bounds: Array = []

var _last_progress_bucket: int = 0


func _ready() -> void:
    var config: Dictionary = _get_geometry_config()

    if config.is_empty():
        push_error(
            "%s returned no cleanable geometry configuration."
            % name
        )
        return

    _target_id = StringName(
        config["target_id"]
    )

    _mask_width = int(
        config["mask_width"]
    )

    _mask_height = int(
        config["mask_height"]
    )

    _brush_radius_px = maxi(
        1,
        int(
            round(
                BRUSH_RADIUS_M
                * TEXELS_PER_METER
            )
        )
    )

    _build_geometry(config)
    _create_dirt_masks()
    _create_material()

    print(
        "Cleanable ready: ",
        _target_id,
        " mask=",
        _mask_width,
        "x",
        _mask_height,
        " initial_dirt=",
        _initial_dirt_amount,
        " brush_px=",
        _brush_radius_px
    )


func _get_geometry_config() -> Dictionary:
    return {}


func _build_geometry(
    config: Dictionary
) -> void:
    var vertices: PackedVector3Array = (
        config["vertices"]
    )

    var uv2: PackedVector2Array = (
        config["uv2"]
    )

    _face_groups = config[
        "face_groups"
    ]

    _face_dirt_enabled = config.get(
        "face_dirt_enabled",
        PackedByteArray()
    )

    _group_bounds = config[
        "group_bounds"
    ]

    if vertices.size() % 3 != 0:
        push_error(
            "%s vertex count is not divisible by 3."
            % name
        )
        return

    if uv2.size() != vertices.size():
        push_error(
            "%s UV2 count does not match vertex count."
            % name
        )
        return

    var face_count: int = int(
        vertices.size() / 3
    )

    if _face_groups.size() != face_count:
        push_error(
            "%s face-group count does not match triangle count."
            % name
        )
        return

    if _face_dirt_enabled.is_empty():
        _face_dirt_enabled.resize(
            face_count
        )

        for i in range(
            face_count
        ):
            _face_dirt_enabled[i] = 1

    if (
        _face_dirt_enabled.size()
        != face_count
    ):
        push_error(
            "%s face-dirt-enabled count does not match triangle count."
            % name
        )
        return

    var normals := PackedVector3Array()

    for i in range(
        0,
        vertices.size(),
        3
    ):
        var a: Vector3 = vertices[i]
        var b: Vector3 = vertices[i + 1]
        var c: Vector3 = vertices[i + 2]

        var normal: Vector3 = (
            (b - a)
            .cross(c - a)
            .normalized()
        )

        normals.append(normal)
        normals.append(normal)
        normals.append(normal)

    var arrays: Array = []
    arrays.resize(
        Mesh.ARRAY_MAX
    )

    arrays[
        Mesh.ARRAY_VERTEX
    ] = vertices

    arrays[
        Mesh.ARRAY_NORMAL
    ] = normals

    arrays[
        Mesh.ARRAY_TEX_UV
    ] = uv2

    arrays[
        Mesh.ARRAY_TEX_UV2
    ] = uv2

    var array_mesh := ArrayMesh.new()

    array_mesh.add_surface_from_arrays(
        Mesh.PRIMITIVE_TRIANGLES,
        arrays
    )

    _mesh_instance = MeshInstance3D.new()
    _mesh_instance.name = "Visual"
    _mesh_instance.mesh = array_mesh

    add_child(
        _mesh_instance
    )

    _face_vertices.clear()
    _face_uv2.clear()

    for face_index in range(
        face_count
    ):
        var start: int = (
            face_index * 3
        )

        _face_vertices.append(
            PackedVector3Array([
                vertices[start],
                vertices[start + 1],
                vertices[start + 2]
            ])
        )

        _face_uv2.append(
            PackedVector2Array([
                uv2[start],
                uv2[start + 1],
                uv2[start + 2]
            ])
        )

    var concave_shape := (
        ConcavePolygonShape3D.new()
    )

    concave_shape.set_faces(
        vertices
    )

    concave_shape.backface_collision = true

    _collision_shape = CollisionShape3D.new()
    _collision_shape.name = "CleaningCollision"
    _collision_shape.shape = concave_shape

    add_child(
        _collision_shape
    )


func _create_dirt_masks() -> void:
    if (
        _mask_width <= 0
        or _mask_height <= 0
    ):
        push_error(
            "%s has invalid dirt-mask dimensions."
            % name
        )
        return

    _initial_mask = Image.create_empty(
        _mask_width,
        _mask_height,
        false,
        Image.FORMAT_RF
    )

    # Start clean. Only designated UV islands are filled with dirt.
    _initial_mask.fill(
        Color(
            0.0,
            0.0,
            0.0,
            1.0
        )
    )

    var dirt_groups: Dictionary = {}

    for face_index in range(
        _face_groups.size()
    ):
        if (
            _face_dirt_enabled[
                face_index
            ] == 0
        ):
            continue

        var group_id: int = (
            _face_groups[
                face_index
            ]
        )

        if (
            group_id < 0
            or group_id
                >= _group_bounds.size()
        ):
            continue

        dirt_groups[group_id] = true

    # Fill each designated UV island exactly once.
    for group_id_variant in dirt_groups.keys():
        var group_id: int = int(
            group_id_variant
        )

        var bounds: Rect2i = (
            _group_bounds[
                group_id
            ]
        )

        for y in range(
            bounds.position.y,
            bounds.position.y
                + bounds.size.y
        ):
            for x in range(
                bounds.position.x,
                bounds.position.x
                    + bounds.size.x
            ):
                _initial_mask.set_pixel(
                    x,
                    y,
                    Color(
                        1.0,
                        1.0,
                        1.0,
                        1.0
                    )
                )

    _runtime_mask = Image.create_empty(
        _mask_width,
        _mask_height,
        false,
        Image.FORMAT_RF
    )

    _runtime_mask.copy_from(
        _initial_mask
    )

    _runtime_texture = (
        ImageTexture.create_from_image(
            _runtime_mask
        )
    )

    _initial_dirt_amount = (
        _sum_dirt(
            _initial_mask
        )
    )

    _current_dirt_amount = (
        _initial_dirt_amount
    )


func _create_material() -> void:
    var shader := Shader.new()

    shader.code = """
shader_type spatial;

render_mode cull_disabled;

uniform sampler2D dirt_mask : filter_nearest, repeat_disable;

uniform vec3 clean_color = vec3(0.12, 0.48, 0.78);
uniform vec3 dirty_color = vec3(0.30, 0.20, 0.10);

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

    ROUGHNESS = 0.85;
}
"""

    var material := ShaderMaterial.new()
    material.shader = shader

    material.set_shader_parameter(
        "dirt_mask",
        _runtime_texture
    )

    _mesh_instance.material_override = material


func clean_at_hit(
    global_hit_point: Vector3,
    face_index: int,
    delta: float
) -> void:
    if _completed:
        return

    if delta <= 0.0:
        return

    if face_index < 0:
        return

    if (
        face_index
        >= _face_vertices.size()
    ):
        return

    if (
        face_index
        < _face_dirt_enabled.size()
        and _face_dirt_enabled[
            face_index
        ] == 0
    ):
        return

    var local_hit: Vector3 = (
        to_local(
            global_hit_point
        )
    )

    var vertices: PackedVector3Array = (
        _face_vertices[
            face_index
        ]
    )

    var uv_values: PackedVector2Array = (
        _face_uv2[
            face_index
        ]
    )

    var barycentric := (
        _calculate_barycentric(
            local_hit,
            vertices[0],
            vertices[1],
            vertices[2]
        )
    )

    if barycentric.x < -0.01:
        return

    if barycentric.y < -0.01:
        return

    if barycentric.z < -0.01:
        return

    var uv: Vector2 = (
        uv_values[0]
            * barycentric.x
        + uv_values[1]
            * barycentric.y
        + uv_values[2]
            * barycentric.z
    )

    uv.x = clampf(
        uv.x,
        0.0,
        1.0
    )

    uv.y = clampf(
        uv.y,
        0.0,
        1.0
    )

    var center_x := clampi(
        int(
            round(
                uv.x
                * float(
                    _mask_width - 1
                )
            )
        ),
        0,
        _mask_width - 1
    )

    var center_y := clampi(
        int(
            round(
                uv.y
                * float(
                    _mask_height - 1
                )
            )
        ),
        0,
        _mask_height - 1
    )

    var group_id: int = (
        _face_groups[
            face_index
        ]
    )

    if (
        group_id < 0
        or group_id
            >= _group_bounds.size()
    ):
        return

    var bounds: Rect2i = (
        _group_bounds[
            group_id
        ]
    )

    var changed := _paint_brush(
        center_x,
        center_y,
        delta,
        bounds
    )

    if not changed:
        return

    _runtime_texture.update(
        _runtime_mask
    )

    _report_progress_if_needed()
    _check_completion()


func _paint_brush(
    center_x: int,
    center_y: int,
    delta: float,
    bounds: Rect2i
) -> bool:
    var changed := false

    var removal_amount: float = (
        CLEAN_RATE_PER_SECOND
        * delta
    )

    var radius_squared: int = (
        _brush_radius_px
        * _brush_radius_px
    )

    var bounds_max_x: int = (
        bounds.position.x
        + bounds.size.x
        - 1
    )

    var bounds_max_y: int = (
        bounds.position.y
        + bounds.size.y
        - 1
    )

    var min_x := maxi(
        bounds.position.x,
        center_x
            - _brush_radius_px
    )

    var max_x := mini(
        bounds_max_x,
        center_x
            + _brush_radius_px
    )

    var min_y := maxi(
        bounds.position.y,
        center_y
            - _brush_radius_px
    )

    var max_y := mini(
        bounds_max_y,
        center_y
            + _brush_radius_px
    )

    for y in range(
        min_y,
        max_y + 1
    ):
        for x in range(
            min_x,
            max_x + 1
        ):
            var dx: int = (
                x - center_x
            )

            var dy: int = (
                y - center_y
            )

            if (
                dx * dx
                + dy * dy
                > radius_squared
            ):
                continue

            var old_value: float = (
                _runtime_mask
                .get_pixel(
                    x,
                    y
                )
                .r
            )

            if old_value <= 0.0:
                continue

            var new_value: float = maxf(
                0.0,
                old_value
                    - removal_amount
            )

            if new_value >= old_value:
                continue

            _runtime_mask.set_pixel(
                x,
                y,
                Color(
                    new_value,
                    new_value,
                    new_value,
                    1.0
                )
            )

            _current_dirt_amount -= (
                old_value
                - new_value
            )

            changed = true

    if _current_dirt_amount < 0.0:
        _current_dirt_amount = 0.0

    return changed


func _calculate_barycentric(
    point: Vector3,
    a: Vector3,
    b: Vector3,
    c: Vector3
) -> Vector3:
    var v0: Vector3 = b - a
    var v1: Vector3 = c - a
    var v2: Vector3 = point - a

    var d00: float = v0.dot(v0)
    var d01: float = v0.dot(v1)
    var d11: float = v1.dot(v1)
    var d20: float = v2.dot(v0)
    var d21: float = v2.dot(v1)

    var denominator: float = (
        d00 * d11
        - d01 * d01
    )

    if (
        absf(denominator)
        <= 0.000001
    ):
        return Vector3(
            -1.0,
            -1.0,
            -1.0
        )

    var v: float = (
        d11 * d20
        - d01 * d21
    ) / denominator

    var w: float = (
        d00 * d21
        - d01 * d20
    ) / denominator

    var u: float = (
        1.0 - v - w
    )

    return Vector3(
        u,
        v,
        w
    )


func _sum_dirt(
    image: Image
) -> float:
    var total: float = 0.0

    for y in range(
        image.get_height()
    ):
        for x in range(
            image.get_width()
        ):
            total += (
                image.get_pixel(
                    x,
                    y
                ).r
            )

    return total


func get_clean_fraction() -> float:
    if _initial_dirt_amount <= 0.0:
        return 0.0

    return clampf(
        1.0
        - (
            _current_dirt_amount
            / _initial_dirt_amount
        ),
        0.0,
        1.0
    )


func _report_progress_if_needed() -> void:
    var percent := int(
        floor(
            get_clean_fraction()
            * 100.0
        )
    )

    var bucket := int(
        percent / 10
    )

    if bucket <= _last_progress_bucket:
        return

    _last_progress_bucket = bucket

    print(
        _target_id,
        " progress: ",
        mini(
            percent,
            100
        ),
        "%"
    )


func _check_completion() -> void:
    if _completed:
        return

    if (
        get_clean_fraction()
        < COMPLETE_THRESHOLD
    ):
        return

    _completed = true

    _runtime_mask.fill(
        Color(
            0.0,
            0.0,
            0.0,
            1.0
        )
    )

    _current_dirt_amount = 0.0

    _runtime_texture.update(
        _runtime_mask
    )

    print(
        "CLEANABLE COMPLETE: ",
        _target_id,
        " at shared 95% threshold"
    )

    cleaning_completed.emit(
        _target_id
    )


func is_completed() -> bool:
    return _completed


func is_inspection_eligible() -> bool:
    return not _completed


func set_inspection_highlight(
    enabled: bool
) -> void:
    if _mesh_instance == null:
        return

    var material := (
        _mesh_instance.material_override
        as ShaderMaterial
    )

    if material == null:
        return

    material.set_shader_parameter(
        "inspection_strength",
        0.24 if enabled else 0.0
    )


func reset_cleanable() -> void:
    if _initial_mask == null:
        return

    if _runtime_mask == null:
        return

    _runtime_mask.copy_from(
        _initial_mask
    )

    _current_dirt_amount = (
        _initial_dirt_amount
    )

    _completed = false
    _last_progress_bucket = 0

    _runtime_texture.update(
        _runtime_mask
    )

    set_inspection_highlight(
        false
    )
