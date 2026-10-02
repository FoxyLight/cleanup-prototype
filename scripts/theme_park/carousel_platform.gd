extends "res://scripts/theme_park/theme_park_cleanable_base.gd"

const WIDTH_M: float = 5.0
const DEPTH_M: float = 4.0

const MASK_WIDTH: int = 320
const MASK_HEIGHT: int = 256


func _get_geometry_config() -> Dictionary:
    var half_width: float = WIDTH_M * 0.5
    var half_depth: float = DEPTH_M * 0.5

    var vertices := PackedVector3Array([
        Vector3(-half_width, 0.0, -half_depth),
        Vector3(-half_width, 0.0,  half_depth),
        Vector3( half_width, 0.0,  half_depth),

        Vector3(-half_width, 0.0, -half_depth),
        Vector3( half_width, 0.0,  half_depth),
        Vector3( half_width, 0.0, -half_depth)
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
        "target_id": &"carousel_platform",
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
