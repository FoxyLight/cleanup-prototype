extends StaticBody3D

signal placement_completed(target_id: StringName)

const REQUIRED_TARGET_ID: StringName = &"movable_slot_a"
const PROGRESS_ID: StringName = &"movable_placement"

const OBJECT_SIZE := Vector3(0.5, 0.5, 0.5)

const BASE_COLOR := Color(
    0.82,
    0.42,
    0.12,
    1.0
)

const INSPECTION_COLOR := Color(
    1.0,
    0.82,
    0.20,
    1.0
)

var _carried: bool = false
var _placed: bool = false

var _visual: MeshInstance3D
var _collision_shape: CollisionShape3D
var _material: StandardMaterial3D

var _initial_global_transform: Transform3D


func _ready() -> void:
    _initial_global_transform = global_transform

    _build_visual()
    _build_collision()


func _build_visual() -> void:
    var mesh := BoxMesh.new()
    mesh.size = OBJECT_SIZE

    _material = StandardMaterial3D.new()
    _material.albedo_color = BASE_COLOR

    _visual = MeshInstance3D.new()
    _visual.name = "Visual"
    _visual.mesh = mesh
    _visual.material_override = _material

    add_child(_visual)


func _build_collision() -> void:
    var shape := BoxShape3D.new()
    shape.size = OBJECT_SIZE

    _collision_shape = CollisionShape3D.new()
    _collision_shape.name = "CollisionShape3D"
    _collision_shape.shape = shape

    add_child(_collision_shape)


func get_required_target_id() -> StringName:
    return REQUIRED_TARGET_ID


func is_carried() -> bool:
    return _carried


func is_placed() -> bool:
    return _placed


func is_inspection_eligible() -> bool:
    return not _placed


func set_inspection_highlight(enabled: bool) -> void:
    if _material == null:
        return

    if enabled:
        _material.albedo_color = INSPECTION_COLOR
    else:
        _material.albedo_color = BASE_COLOR


func begin_carry() -> bool:
    if _placed:
        return false

    if _carried:
        return false

    _carried = true

    set_inspection_highlight(false)

    collision_layer = 0
    collision_mask = 0

    print("Picked up movable object.")

    return true


func update_carried_transform(
    carry_transform: Transform3D
) -> void:
    if not _carried:
        return

    global_transform = carry_transform


func free_drop(
    drop_transform: Transform3D
) -> void:
    if not _carried:
        return

    global_transform = drop_transform

    _carried = false
    _placed = false

    collision_layer = 2
    collision_mask = 0

    set_inspection_highlight(false)

    print("Movable object safely dropped.")


func place_at_target(
    target_transform: Transform3D
) -> void:
    if not _carried:
        return

    global_transform = target_transform

    _carried = false
    _placed = true

    collision_layer = 2
    collision_mask = 0

    set_inspection_highlight(false)

    print(
        "Movable object placed at target: ",
        REQUIRED_TARGET_ID
    )

    placement_completed.emit(
        PROGRESS_ID
    )


func get_drop_query_shape() -> BoxShape3D:
    var shape := BoxShape3D.new()

    shape.size = Vector3(
        0.46,
        0.46,
        0.46
    )

    return shape


func get_drop_half_height() -> float:
    return OBJECT_SIZE.y * 0.5


func reset_movable() -> void:
    global_transform = (
        _initial_global_transform
    )

    _carried = false
    _placed = false

    collision_layer = 2
    collision_mask = 0

    set_inspection_highlight(false)
