extends CharacterBody3D

@export var move_speed: float = 4.5
@export var mouse_sensitivity: float = 0.002

const FREE_DROP_DISTANCE: float = 1.4

@onready var head: Node3D = $Head

@onready var camera: Camera3D = (
	$Head/Camera3D
)

@onready var interaction_ray: RayCast3D = (
	$Head/Camera3D/InteractionRay
)

@onready var carry_anchor: Marker3D = (
	$Head/Camera3D/CarryAnchor
)

var current_target: Object = null

var carried_object: StaticBody3D = null

var inspection_highlight_target: Object = null

var _initial_global_transform: Transform3D
var _initial_head_rotation: Vector3


func _ready() -> void:
	_initial_global_transform = global_transform
	_initial_head_rotation = head.rotation

	Input.mouse_mode = (
		Input.MOUSE_MODE_CAPTURED
	)

	interaction_ray.enabled = true


func _unhandled_input(
	event: InputEvent
) -> void:
	if event is InputEventMouseMotion:
		if (
			Input.mouse_mode
			== Input.MOUSE_MODE_CAPTURED
		):
			rotate_y(
				-event.screen_relative.x
				* mouse_sensitivity
			)

			head.rotation.x -= (
				event.screen_relative.y
				* mouse_sensitivity
			)

			head.rotation.x = clamp(
				head.rotation.x,
				deg_to_rad(-85.0),
				deg_to_rad(85.0)
			)

	if event is InputEventKey:
		if (
			event.pressed
			and event.keycode == KEY_ESCAPE
		):
			Input.mouse_mode = (
				Input.MOUSE_MODE_VISIBLE
			)

	if event is InputEventMouseButton:
		if (
			event.pressed
			and Input.mouse_mode
				!= Input.MOUSE_MODE_CAPTURED
		):
			Input.mouse_mode = (
				Input.MOUSE_MODE_CAPTURED
			)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_apply_movement()

	move_and_slide()

	_update_carried_object()
	_update_interaction_target()

	_update_inspection_highlight()

	if Input.is_action_just_pressed("interact"):
		_handle_interact()

	_apply_cleaning(delta)


func _apply_gravity(
	delta: float
) -> void:
	if not is_on_floor():
		velocity += (
			get_gravity()
			* delta
		)

	elif velocity.y < 0.0:
		velocity.y = 0.0


func _apply_movement() -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := (
		transform.basis.x
			* input_vector.x
		+ transform.basis.z
			* input_vector.y
	)

	direction.y = 0.0
	direction = direction.normalized()

	if direction != Vector3.ZERO:
		velocity.x = (
			direction.x
			* move_speed
		)

		velocity.z = (
			direction.z
			* move_speed
		)

	else:
		velocity.x = 0.0
		velocity.z = 0.0


func _update_carried_object() -> void:
	if carried_object == null:
		return

	if not carried_object.has_method(
		"update_carried_transform"
	):
		return

	carried_object.call(
		"update_carried_transform",
		carry_anchor.global_transform
	)


func _update_interaction_target() -> void:
	var new_target: Object = null

	if interaction_ray.is_colliding():
		new_target = (
			interaction_ray.get_collider()
		)

	if new_target == current_target:
		return

	current_target = new_target

	if current_target != null:
		print(
			"Target: ",
			current_target.name
		)

	else:
		print("Target: none")


func _update_inspection_highlight() -> void:
	var desired_target: Object = null

	if Input.is_action_pressed("inspect"):
		if interaction_ray.is_colliding():
			var collider: Object = (
				interaction_ray.get_collider()
			)

			if (
				collider != null
				and collider.has_method(
					"is_inspection_eligible"
				)
			):
				var eligible: bool = bool(
					collider.call(
						"is_inspection_eligible"
					)
				)

				if eligible:
					desired_target = collider

	if (
		desired_target
		== inspection_highlight_target
	):
		return

	if (
		inspection_highlight_target
		!= null
	):
		if inspection_highlight_target.has_method(
			"set_inspection_highlight"
		):
			inspection_highlight_target.call(
				"set_inspection_highlight",
				false
			)

	inspection_highlight_target = (
		desired_target
	)

	if (
		inspection_highlight_target
		!= null
	):
		inspection_highlight_target.call(
			"set_inspection_highlight",
			true
		)


func _handle_interact() -> void:
	if carried_object == null:
		_try_pickup()
		return

	if _try_place_at_target():
		return

	_try_safe_free_drop()


func _try_pickup() -> void:
	if not interaction_ray.is_colliding():
		return

	var collider: Object = (
		interaction_ray.get_collider()
	)

	if collider == null:
		return

	if not collider.has_method(
		"begin_carry"
	):
		return

	var pickup_succeeded: bool = bool(
		collider.call(
			"begin_carry"
		)
	)

	if not pickup_succeeded:
		return

	carried_object = collider

	carried_object.call(
		"update_carried_transform",
		carry_anchor.global_transform
	)


func _try_place_at_target() -> bool:
	if carried_object == null:
		return false

	if not interaction_ray.is_colliding():
		return false

	var collider: Object = (
		interaction_ray.get_collider()
	)

	if collider == null:
		return false

	if not collider.has_method(
		"accepts_object"
	):
		return false

	var accepted: bool = bool(
		collider.call(
			"accepts_object",
			carried_object
		)
	)

	if not accepted:
		return false

	if not collider.has_method(
		"get_snap_transform"
	):
		return false

	var snap_transform: Transform3D = (
		collider.call(
			"get_snap_transform"
		)
	)

	carried_object.call(
		"place_at_target",
		snap_transform
	)

	if collider.has_method(
		"mark_occupied"
	):
		collider.call(
			"mark_occupied"
		)

	carried_object = null

	return true


func _try_safe_free_drop() -> bool:
	if carried_object == null:
		return false

	var forward: Vector3 = (
		-global_transform.basis.z
	)

	forward.y = 0.0

	if (
		forward.length_squared()
		<= 0.0001
	):
		print(
			"Drop rejected: invalid forward direction."
		)

		return false

	forward = forward.normalized()

	var candidate_xz := (
		global_position
		+ forward
			* FREE_DROP_DISTANCE
	)

	var ray_from := Vector3(
		candidate_xz.x,
		global_position.y + 1.5,
		candidate_xz.z
	)

	var ray_to := Vector3(
		candidate_xz.x,
		global_position.y - 3.0,
		candidate_xz.z
	)

	var ray_query := (
		PhysicsRayQueryParameters3D.create(
			ray_from,
			ray_to,
			1,
			[get_rid()]
		)
	)

	ray_query.collide_with_bodies = true
	ray_query.collide_with_areas = false

	var space_state := (
		get_world_3d()
			.direct_space_state
	)

	var floor_hit := (
		space_state.intersect_ray(
			ray_query
		)
	)

	if floor_hit.is_empty():
		print(
			"Drop rejected: no safe floor."
		)

		return false

	var floor_normal: Vector3 = (
		floor_hit["normal"]
	)

	if (
		floor_normal.dot(Vector3.UP)
		< 0.75
	):
		print(
			"Drop rejected: surface is not floor-like."
		)

		return false

	var half_height: float = float(
		carried_object.call(
			"get_drop_half_height"
		)
	)

	var drop_position: Vector3 = (
		floor_hit["position"]
		+ Vector3.UP
			* half_height
	)

	var drop_transform := Transform3D(
		Basis.IDENTITY,
		drop_position
	)

	var query_shape: Shape3D = (
		carried_object.call(
			"get_drop_query_shape"
		)
	)

	var shape_query := (
		PhysicsShapeQueryParameters3D.new()
	)

	shape_query.shape = query_shape

	shape_query.transform = Transform3D(
		Basis.IDENTITY,
		drop_position
			+ Vector3.UP * 0.01
	)

	shape_query.collision_mask = 3
	shape_query.collide_with_bodies = true
	shape_query.collide_with_areas = false

	shape_query.exclude = [
		get_rid(),
		carried_object.get_rid()
	]

	var overlaps := (
		space_state.intersect_shape(
			shape_query,
			8
		)
	)

	if not overlaps.is_empty():
		print(
			"Drop rejected: location obstructed."
		)

		return false

	carried_object.call(
		"free_drop",
		drop_transform
	)

	carried_object = null

	return true


func _apply_cleaning(
	delta: float
) -> void:
	# Carrying disables cleaning.
	if carried_object != null:
		return

	if (
		Input.mouse_mode
		!= Input.MOUSE_MODE_CAPTURED
	):
		return

	if not Input.is_action_pressed(
		"clean"
	):
		return

	if not interaction_ray.is_colliding():
		return

	var collider: Object = (
		interaction_ray.get_collider()
	)

	if collider == null:
		return

	if not collider.has_method(
		"clean_at_hit"
	):
		return

	var hit_point: Vector3 = (
		interaction_ray.get_collision_point()
	)

	var face_index: int = (
		interaction_ray
			.get_collision_face_index()
	)

	collider.call(
		"clean_at_hit",
		hit_point,
		face_index,
		delta
	)


func reset_runtime_state() -> void:
	if (
		inspection_highlight_target
		!= null
	):
		if inspection_highlight_target.has_method(
			"set_inspection_highlight"
		):
			inspection_highlight_target.call(
				"set_inspection_highlight",
				false
			)

	inspection_highlight_target = null
	current_target = null
	carried_object = null

	velocity = Vector3.ZERO

	global_transform = (
		_initial_global_transform
	)

	head.rotation = (
		_initial_head_rotation
	)
