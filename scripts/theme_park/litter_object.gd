extends Area3D

signal loose_mess_completed(target_id: StringName)

@export var target_id: StringName = &"litter_test"

var _completed: bool = false
var _mesh_instance: MeshInstance3D
var _collision_shape: CollisionShape3D


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	_create_visual()
	_create_collision()


func _create_visual() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(
		0.32,
		0.06,
		0.22
	)

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(
		0.86,
		0.76,
		0.28,
		1.0
	)

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "Visual"
	_mesh_instance.mesh = mesh
	_mesh_instance.material_override = material

	add_child(_mesh_instance)


func _create_collision() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		0.34,
		0.08,
		0.24
	)

	_collision_shape = CollisionShape3D.new()
	_collision_shape.name = "InteractionCollision"
	_collision_shape.shape = shape

	add_child(_collision_shape)


func begin_carry() -> bool:
	if _completed:
		return false

	_complete()

	# Important:
	# Returning false prevents the frozen player from treating
	# this object as something that should actually be carried.
	return false


func _complete() -> void:
	if _completed:
		return

	_completed = true

	if _mesh_instance != null:
		_mesh_instance.visible = false

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			true
		)

	loose_mess_completed.emit(
		target_id
	)

	print(
		"Litter completed: ",
		target_id
	)


func is_completed() -> bool:
	return _completed


func reset_loose_mess() -> void:
	_completed = false

	if _mesh_instance != null:
		_mesh_instance.visible = true

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			false
		)