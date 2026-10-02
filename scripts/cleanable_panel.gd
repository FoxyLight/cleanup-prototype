extends "res://scripts/cleanable_base.gd"

const PANEL_SIZE_M: float = 3.0


func _get_geometry_config() -> Dictionary:
    var half: float = PANEL_SIZE_M * 0.5

    var vertices := PackedVector3Array([
        Vector3(-half, 0.0, -half),
        Vector3(-half, 0.0,  half),
        Vector3( half, 0.0,  half),

        Vector3(-half, 0.0, -half),
        Vector3( half, 0.0,  half),
        Vector3( half, 0.0, -half)
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
        "target_id": &"horizontal_panel",
        "mask_width": 192,
        "mask_height": 192,
        "vertices": vertices,
        "uv2": uv2,

        # Both triangles belong to one UV island.
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
