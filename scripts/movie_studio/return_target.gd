extends Area3D

enum TargetKind {
	HAT_RACK,
	LANTERN_HOOK,
	STOOL_SPOT,
	MUG_SHELF
}

@export var target_id: StringName = &"return_target"
@export var target_kind: TargetKind = TargetKind.HAT_RACK
@export var tint: Color = Color(0.72, 0.46, 0.20, 1.0)

var _occupied: bool = false

var _visual_root: Node3D
var _material: StandardMaterial3D
var _collision_shape: CollisionShape3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	_build_visual()
	_build_collision()


func _build_visual() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "Visual"
	add_child(_visual_root)

	_material = StandardMaterial3D.new()
	_material.albedo_color = Color(
		tint.r,
		tint.g,
		tint.b,
		0.46
	)
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	var visual := MeshInstance3D.new()
	visual.name = "DestinationMarker"
	visual.material_override = _material

	match target_kind:
		TargetKind.HAT_RACK:
			var rack_mesh := CylinderMesh.new()
			rack_mesh.top_radius = 0.25
			rack_mesh.bottom_radius = 0.25
			rack_mesh.height = 0.035
			visual.mesh = rack_mesh
			visual.position.y = 0.03

		TargetKind.LANTERN_HOOK:
			var hook_mesh := BoxMesh.new()
			hook_mesh.size = Vector3(
				0.34,
				0.34,
				0.05
			)
			visual.mesh = hook_mesh
			visual.position.y = 0.17

		TargetKind.STOOL_SPOT:
			var stool_mesh := CylinderMesh.new()
			stool_mesh.top_radius = 0.26
			stool_mesh.bottom_radius = 0.26
			stool_mesh.height = 0.035
			visual.mesh = stool_mesh
			visual.position.y = 0.03

		TargetKind.MUG_SHELF:
			var shelf_mesh := BoxMesh.new()
			shelf_mesh.size = Vector3(
				0.34,
				0.035,
				0.34
			)
			visual.mesh = shelf_mesh
			visual.position.y = 0.03

	_visual_root.add_child(visual)


func _build_collision() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		0.70,
		0.45,
		0.70
	)

	_collision_shape = CollisionShape3D.new()
	_collision_shape.name = "CollisionShape3D"
	_collision_shape.position.y = 0.22
	_collision_shape.shape = shape

	add_child(_collision_shape)


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
		== target_id
	)


func mark_occupied() -> void:
	_occupied = true

	if _visual_root != null:
		_visual_root.visible = false


func is_occupied() -> bool:
	return _occupied


func reset_target() -> void:
	_occupied = false

	if _visual_root != null:
		_visual_root.visible = true


func get_snap_transform() -> Transform3D:
	var result := global_transform

	match target_kind:
		TargetKind.HAT_RACK:
			result.origin.y += 0.13

		TargetKind.LANTERN_HOOK:
			result.origin.y += 0.23

		TargetKind.STOOL_SPOT:
			result.origin.y += 0.25

		TargetKind.MUG_SHELF:
			result.origin.y += 0.13

	return result
