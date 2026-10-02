extends Area3D

signal loose_mess_completed(target_id: StringName)

const CLEAR_DELAY_SECONDS: float = 0.35

@export var target_id: StringName = &"debris_test"

var _completed: bool = false
var _clearing: bool = false

var _visual_root: Node3D
var _collision_shape: CollisionShape3D
var _clear_timer: Timer


func _ready() -> void:
	collision_layer = 4
	collision_mask = 0

	_create_visual()
	_create_collision()
	_create_timer()


func _create_visual() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "Visual"

	add_child(_visual_root)

	_add_debris_piece(
		Vector3(-0.16, 0.04, -0.08),
		Vector3(0.24, 0.08, 0.16)
	)

	_add_debris_piece(
		Vector3(0.10, 0.06, 0.04),
		Vector3(0.20, 0.12, 0.18)
	)

	_add_debris_piece(
		Vector3(-0.02, 0.035, 0.16),
		Vector3(0.28, 0.07, 0.12)
	)


func _add_debris_piece(
	local_position: Vector3,
	size: Vector3
) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(
		0.38,
		0.25,
		0.14,
		1.0
	)

	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = local_position
	instance.material_override = material

	_visual_root.add_child(instance)


func _create_collision() -> void:
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		0.62,
		0.18,
		0.52
	)

	_collision_shape = CollisionShape3D.new()
	_collision_shape.name = "InteractionCollision"
	_collision_shape.position = Vector3(
		0.0,
		0.09,
		0.02
	)
	_collision_shape.shape = shape

	add_child(_collision_shape)


func _create_timer() -> void:
	_clear_timer = Timer.new()
	_clear_timer.name = "ClearTimer"
	_clear_timer.one_shot = true
	_clear_timer.wait_time = CLEAR_DELAY_SECONDS

	_clear_timer.timeout.connect(
		_on_clear_timer_timeout
	)

	add_child(_clear_timer)


func begin_carry() -> bool:
	if _completed:
		return false

	if _clearing:
		return false

	_clearing = true
	_clear_timer.start()

	print(
		"Debris clearing: ",
		target_id
	)

	# Prevent the frozen player from carrying this object.
	return false


func _on_clear_timer_timeout() -> void:
	if _completed:
		return

	_completed = true
	_clearing = false

	if _visual_root != null:
		_visual_root.visible = false

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			true
		)

	loose_mess_completed.emit(
		target_id
	)

	print(
		"Debris completed: ",
		target_id
	)


func is_completed() -> bool:
	return _completed


func is_clearing() -> bool:
	return _clearing


func reset_loose_mess() -> void:
	if _clear_timer != null:
		_clear_timer.stop()

	_completed = false
	_clearing = false

	if _visual_root != null:
		_visual_root.visible = true

	if _collision_shape != null:
		_collision_shape.set_deferred(
			"disabled",
			false
		)