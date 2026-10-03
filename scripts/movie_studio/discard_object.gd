extends Area3D

signal discard_completed(target_id: StringName)

enum DiscardKind {
	BROKEN_BOTTLE,
	TORN_PAPER,
	RUINED_FOOD,
	BROKEN_PLATE
}

@export var target_id: StringName = &"discard_test"
@export var discard_kind: DiscardKind = DiscardKind.TORN_PAPER
@export var tint: Color = Color(0.68, 0.58, 0.34, 1.0)

var _completed: bool = false
var _visual_root: Node3D
var _material: StandardMaterial3D
var _collision_shape: CollisionShape3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	_create_visual()
	_create_collision()


func _create_visual() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "Visual"
	add_child(_visual_root)

	_material = StandardMaterial3D.new()
	_material.albedo_color = tint
	_material.roughness = 0.72

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "DiscardMesh"
	mesh_instance.material_override = _material

	match discard_kind:
		DiscardKind.BROKEN_BOTTLE:
			var bottle_mesh := CylinderMesh.new()
			bottle_mesh.top_radius = 0.045
			bottle_mesh.bottom_radius = 0.085
			bottle_mesh.height = 0.26
			mesh_instance.mesh = bottle_mesh
			mesh_instance.rotation_degrees.z = 68.0
			mesh_instance.position.y = 0.08

		DiscardKind.TORN_PAPER:
			var paper_mesh := BoxMesh.new()
			paper_mesh.size = Vector3(
				0.34,
				0.025,
				0.24
			)
			mesh_instance.mesh = paper_mesh
			mesh_instance.rotation_degrees.y = 18.0
			mesh_instance.position.y = 0.02

		DiscardKind.RUINED_FOOD:
			var food_mesh := SphereMesh.new()
			food_mesh.radius = 0.13
			food_mesh.height = 0.18
			mesh_instance.mesh = food_mesh
			mesh_instance.scale = Vector3(
				1.15,
				0.65,
				0.85
			)
			mesh_instance.position.y = 0.08

		DiscardKind.BROKEN_PLATE:
			var plate_mesh := CylinderMesh.new()
			plate_mesh.top_radius = 0.16
			plate_mesh.bottom_radius = 0.16
			plate_mesh.height = 0.035
			mesh_instance.mesh = plate_mesh
			mesh_instance.position.y = 0.025

	_visual_root.add_child(mesh_instance)


func _create_collision() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		0.42,
		0.28,
		0.34
	)

	_collision_shape = CollisionShape3D.new()
	_collision_shape.name = "InteractionCollision"
	_collision_shape.position = Vector3(
		0.0,
		0.12,
		0.0
	)
	_collision_shape.shape = shape

	add_child(_collision_shape)


func begin_carry() -> bool:
	if _completed:
		return false

	_complete_discard()

	# DISCARD is intentionally one-shot interaction, never carrying.
	return false


func _complete_discard() -> void:
	if _completed:
		return

	_completed = true

	if _visual_root != null:
		_visual_root.visible = false

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			true
		)

	discard_completed.emit(
		target_id
	)

	print(
		"Movie Studio discard completed: ",
		target_id
	)


func is_completed() -> bool:
	return _completed


func is_inspection_eligible() -> bool:
	return not _completed


func set_inspection_highlight(
	enabled: bool
) -> void:
	if _material == null:
		return

	_material.emission_enabled = enabled
	_material.emission = Color(
		1.0,
		0.82,
		0.22,
		1.0
	)
	_material.emission_energy_multiplier = (
		0.65 if enabled else 0.0
	)


func is_visual_active() -> bool:
	return (
		_visual_root != null
		and _visual_root.visible
	)


func reset_discard() -> void:
	_completed = false

	if _visual_root != null:
		_visual_root.visible = true

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			false
		)

	set_inspection_highlight(false)
