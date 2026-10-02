extends Area3D

const TARGET_ID: StringName = &"movable_slot_a"

var _occupied: bool = false


func _ready() -> void:
    collision_layer = 4
    collision_mask = 0

    _build_visual()
    _build_collision()


func _build_visual() -> void:
    var mesh := BoxMesh.new()

    mesh.size = Vector3(
        0.7,
        0.05,
        0.7
    )

    var material := StandardMaterial3D.new()

    material.albedo_color = Color(
        0.15,
        0.75,
        0.25,
        1.0
    )

    var visual := MeshInstance3D.new()

    visual.name = "Visual"
    visual.mesh = mesh
    visual.material_override = material

    add_child(visual)


func _build_collision() -> void:
    var shape := BoxShape3D.new()

    shape.size = Vector3(
        0.7,
        0.20,
        0.7
    )

    var collision := CollisionShape3D.new()

    collision.name = "CollisionShape3D"
    collision.position.y = 0.10
    collision.shape = shape

    add_child(collision)


func accepts_object(
    object: Object
) -> bool:
    if _occupied:
        return false

    if object == null:
        return false

    if not object.has_method(
        "get_required_target_id"
    ):
        return false

    return (
        object.call(
            "get_required_target_id"
        )
        == TARGET_ID
    )


func mark_occupied() -> void:
    _occupied = true


func is_occupied() -> bool:
    return _occupied


func reset_target() -> void:
    _occupied = false


func get_snap_transform() -> Transform3D:
    var result := global_transform

    result.origin.y += 0.25

    return result
