extends StaticBody3D

signal return_completed(target_id: StringName)

enum PropKind {
	HAT,
	LANTERN,
	STOOL,
	MUG
}

@export var prop_id: StringName = &"return_prop"
@export var required_target_id: StringName = &"return_target"
@export var prop_kind: PropKind = PropKind.HAT
@export var tint: Color = Color(0.72, 0.46, 0.20, 1.0)

var _carried: bool = false
var _placed: bool = false

var _visual_root: Node3D
var _collision_shape: CollisionShape3D
var _material: StandardMaterial3D

var _initial_global_transform: Transform3D


func _ready() -> void:
	_initial_global_transform = global_transform

	_build_visual()
	_build_collision()


func _build_visual() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "Visual"

	add_child(_visual_root)

	_material = StandardMaterial3D.new()
	_material.albedo_color = tint
	_material.roughness = 0.7

	var main_mesh := MeshInstance3D.new()
	main_mesh.name = "Main"

	match prop_kind:
		PropKind.HAT:
			var brim := CylinderMesh.new()
			brim.top_radius = 0.24
			brim.bottom_radius = 0.24
			brim.height = 0.05
			main_mesh.mesh = brim
			main_mesh.position.y = 0.05

			var crown_mesh := CylinderMesh.new()
			crown_mesh.top_radius = 0.11
			crown_mesh.bottom_radius = 0.14
			crown_mesh.height = 0.18

			var crown := MeshInstance3D.new()
			crown.name = "Crown"
			crown.mesh = crown_mesh
			crown.position.y = 0.16
			crown.material_override = _material

			_visual_root.add_child(crown)

		PropKind.LANTERN:
			var body := CylinderMesh.new()
			body.top_radius = 0.11
			body.bottom_radius = 0.13
			body.height = 0.28
			main_mesh.mesh = body
			main_mesh.position.y = 0.16

			var top_mesh := CylinderMesh.new()
			top_mesh.top_radius = 0.06
			top_mesh.bottom_radius = 0.10
			top_mesh.height = 0.09

			var top := MeshInstance3D.new()
			top.name = "Top"
			top.mesh = top_mesh
			top.position.y = 0.34
			top.material_override = _material

			_visual_root.add_child(top)

		PropKind.STOOL:
			var seat := CylinderMesh.new()
			seat.top_radius = 0.22
			seat.bottom_radius = 0.22
			seat.height = 0.08
			main_mesh.mesh = seat
			main_mesh.position.y = 0.42

			for x in [-0.14, 0.14]:
				for z in [-0.14, 0.14]:
					var leg_mesh := BoxMesh.new()
					leg_mesh.size = Vector3(
						0.05,
						0.42,
						0.05
					)

					var leg := MeshInstance3D.new()
					leg.mesh = leg_mesh
					leg.position = Vector3(
						x,
						0.21,
						z
					)
					leg.material_override = _material

					_visual_root.add_child(leg)

		PropKind.MUG:
			var mug_mesh := CylinderMesh.new()
			mug_mesh.top_radius = 0.11
			mug_mesh.bottom_radius = 0.11
			mug_mesh.height = 0.20
			main_mesh.mesh = mug_mesh
			main_mesh.position.y = 0.11

	main_mesh.material_override = _material
	_visual_root.add_child(main_mesh)


func _build_collision() -> void:
	var shape := BoxShape3D.new()

	match prop_kind:
		PropKind.HAT:
			shape.size = Vector3(0.52, 0.26, 0.52)

		PropKind.LANTERN:
			shape.size = Vector3(0.34, 0.46, 0.34)

		PropKind.STOOL:
			shape.size = Vector3(0.52, 0.50, 0.52)

		PropKind.MUG:
			shape.size = Vector3(0.30, 0.26, 0.30)

	_collision_shape = CollisionShape3D.new()
	_collision_shape.name = "CollisionShape3D"
	_collision_shape.shape = shape
	_collision_shape.position.y = (
		shape.size.y * 0.5
	)

	add_child(_collision_shape)


func get_required_target_id() -> StringName:
	return required_target_id


func get_progress_id() -> StringName:
	return prop_id


func is_carried() -> bool:
	return _carried


func is_placed() -> bool:
	return _placed


func is_inspection_eligible() -> bool:
	return not _placed


func set_inspection_highlight(
	enabled: bool
) -> void:
	if _material == null:
		return

	_material.emission_enabled = enabled
	_material.emission = Color(
		1.0,
		0.82,
		0.20,
		1.0
	)
	_material.emission_energy_multiplier = (
		0.65 if enabled else 0.0
	)


func begin_carry() -> bool:
	if _placed:
		return false

	if _carried:
		return false

	_carried = true

	set_inspection_highlight(false)

	collision_layer = 0
	collision_mask = 0

	print(
		"Movie Studio RETURN prop picked up: ",
		prop_id
	)

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

	return_completed.emit(
		prop_id
	)

	print(
		"Movie Studio RETURN prop placed: ",
		prop_id,
		" -> ",
		required_target_id
	)


func get_drop_query_shape() -> BoxShape3D:
	var shape := BoxShape3D.new()

	match prop_kind:
		PropKind.HAT:
			shape.size = Vector3(0.48, 0.22, 0.48)

		PropKind.LANTERN:
			shape.size = Vector3(0.30, 0.42, 0.30)

		PropKind.STOOL:
			shape.size = Vector3(0.48, 0.46, 0.48)

		PropKind.MUG:
			shape.size = Vector3(0.26, 0.22, 0.26)

	return shape


func get_drop_half_height() -> float:
	return (
		get_drop_query_shape().size.y
		* 0.5
	)


func reset_return_prop() -> void:
	global_transform = (
		_initial_global_transform
	)

	_carried = false
	_placed = false

	collision_layer = 2
	collision_mask = 0

	set_inspection_highlight(false)
