extends "res://scripts/cleanable_base.gd"

const WIDTH_M: float = 3.0
const HEIGHT_M: float = 3.0


func _get_geometry_config() -> Dictionary:
    var half_width: float = WIDTH_M * 0.5

    # Vertical XY plane.
    # Local Z stays zero.
    var vertices := PackedVector3Array([
        # Triangle 0
        Vector3(-half_width, 0.0, 0.0),
        Vector3( half_width, HEIGHT_M, 0.0),
        Vector3(-half_width, HEIGHT_M, 0.0),

        # Triangle 1
        Vector3(-half_width, 0.0, 0.0),
        Vector3( half_width, 0.0, 0.0),
        Vector3( half_width, HEIGHT_M, 0.0)
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
        "target_id": &"vertical_panel",
        "mask_width": 192,
        "mask_height": 192,
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
                192,
                192
            )
        ]
    }
