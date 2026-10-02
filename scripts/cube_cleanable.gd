extends "res://scripts/cleanable_base.gd"

const MASK_WIDTH: int = 192
const MASK_HEIGHT: int = 128
const TILE_SIZE: int = 64
const HALF: float = 0.5


func _get_geometry_config() -> Dictionary:
    var vertices := PackedVector3Array()
    var uv2 := PackedVector2Array()
    var face_groups := PackedInt32Array()

    # FRONT: +Z
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(-HALF, -HALF, HALF),
        Vector3(HALF, -HALF, HALF),
        Vector3(HALF, HALF, HALF),
        Vector3(-HALF, HALF, HALF),
        0,
        0,
        0
    )

    # BACK: -Z
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(HALF, -HALF, -HALF),
        Vector3(-HALF, -HALF, -HALF),
        Vector3(-HALF, HALF, -HALF),
        Vector3(HALF, HALF, -HALF),
        1,
        0,
        1
    )

    # LEFT: -X
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(-HALF, -HALF, -HALF),
        Vector3(-HALF, -HALF, HALF),
        Vector3(-HALF, HALF, HALF),
        Vector3(-HALF, HALF, -HALF),
        2,
        0,
        2
    )

    # RIGHT: +X
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(HALF, -HALF, HALF),
        Vector3(HALF, -HALF, -HALF),
        Vector3(HALF, HALF, -HALF),
        Vector3(HALF, HALF, HALF),
        0,
        1,
        3
    )

    # TOP: +Y
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(-HALF, HALF, HALF),
        Vector3(HALF, HALF, HALF),
        Vector3(HALF, HALF, -HALF),
        Vector3(-HALF, HALF, -HALF),
        1,
        1,
        4
    )

    # BOTTOM: -Y
    # Geometry remains present for collision/visual completeness,
    # but its two triangles are excluded from designated dirt.
    _append_face(
        vertices,
        uv2,
        face_groups,
        Vector3(-HALF, -HALF, -HALF),
        Vector3(HALF, -HALF, -HALF),
        Vector3(HALF, -HALF, HALF),
        Vector3(-HALF, -HALF, HALF),
        2,
        1,
        5
    )

    var group_bounds: Array = []

    for row in range(2):
        for column in range(3):
            group_bounds.append(
                Rect2i(
                    column * TILE_SIZE,
                    row * TILE_SIZE,
                    TILE_SIZE,
                    TILE_SIZE
                )
            )

    return {
        "target_id": &"cube_target",
        "mask_width": MASK_WIDTH,
        "mask_height": MASK_HEIGHT,
        "vertices": vertices,
        "uv2": uv2,
        "face_groups": face_groups,

        # Two triangles per cube face.
        # The final two triangles are the inaccessible bottom face.
        "face_dirt_enabled": PackedByteArray([
            1, 1,
            1, 1,
            1, 1,
            1, 1,
            1, 1,
            0, 0
        ]),

        "group_bounds": group_bounds
    }


func _append_face(
    vertices: PackedVector3Array,
    uv2: PackedVector2Array,
    face_groups: PackedInt32Array,
    a: Vector3,
    b: Vector3,
    c: Vector3,
    d: Vector3,
    column: int,
    row: int,
    group_id: int
) -> void:
    vertices.append(a)
    vertices.append(b)
    vertices.append(c)

    vertices.append(a)
    vertices.append(c)
    vertices.append(d)

    var min_x: int = (
        column * TILE_SIZE
    )

    var min_y: int = (
        row * TILE_SIZE
    )

    var max_x: int = (
        min_x + TILE_SIZE - 1
    )

    var max_y: int = (
        min_y + TILE_SIZE - 1
    )

    var uv_a := _pixel_to_uv(
        min_x,
        max_y
    )

    var uv_b := _pixel_to_uv(
        max_x,
        max_y
    )

    var uv_c := _pixel_to_uv(
        max_x,
        min_y
    )

    var uv_d := _pixel_to_uv(
        min_x,
        min_y
    )

    uv2.append(uv_a)
    uv2.append(uv_b)
    uv2.append(uv_c)

    uv2.append(uv_a)
    uv2.append(uv_c)
    uv2.append(uv_d)

    face_groups.append(
        group_id
    )

    face_groups.append(
        group_id
    )


func _pixel_to_uv(
    x: int,
    y: int
) -> Vector2:
    return Vector2(
        float(x)
            / float(MASK_WIDTH - 1),
        float(y)
            / float(MASK_HEIGHT - 1)
    )
