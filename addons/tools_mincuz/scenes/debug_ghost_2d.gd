extends Camera2D

@export var unlock_mouse_mode : bool = false

@export var speed : float = 500.0
@export var speed_mouse : float = 50.0
@export var sprint_multiplier : float = 5.0

@export var turn_speed : float = 90.0
@export_range(0.0, 90.0, 5.0, "or_greater") var turn_interval_degrees : float = 0.0

var use_turn_interval : bool :
	get: return not is_zero_approx(turn_interval_degrees)

var revert_mouse_mode : Input.MouseMode
var move_input_vector_mouse : Vector2

var is_sprinting : bool :
	get: return Input.is_action_pressed(&"ghost_sprint")


func _ready() -> void:

	## Needs to copy existing directly instead of borrowing
	var existing := self.get_viewport().get_camera_2d()
	self.global_transform = existing.global_transform
	self.zoom = existing.zoom

	self.make_current()

	revert_mouse_mode = Input.mouse_mode
	if unlock_mouse_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
	if unlock_mouse_mode:
		Input.mouse_mode = revert_mouse_mode


func _process(delta: float) -> void:
	if not use_turn_interval:
		var turn_axis := Input.get_axis(&"ghost_move_up", &"ghost_move_down")
		self.global_rotation_degrees += turn_axis * turn_speed * delta

	var move_vector := Vector2.ZERO
	move_vector += (Input.get_vector(&"ghost_move_left", &"ghost_move_right", &"ghost_move_forward", &"ghost_move_back") + Input.get_vector(&"ghost_camera_left", &"ghost_camera_right", &"ghost_camera_up", &"ghost_camera_down")) * speed

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		move_vector += move_input_vector_mouse * speed_mouse
	move_input_vector_mouse = Vector2.ZERO

	self.global_position += move_vector.rotated(self.global_rotation) * (sprint_multiplier if is_sprinting else 1.0) * delta



func _input(event: InputEvent) -> void:
	if use_turn_interval:
		if event.is_action_pressed(&"ghost_move_up"):
			self.global_rotation_degrees += turn_interval_degrees
		elif event.is_action_pressed(&"ghost_move_down"):
			self.global_rotation_degrees -= turn_interval_degrees
	if event is InputEventMouseMotion:
		move_input_vector_mouse += event.relative