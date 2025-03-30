class_name Brain extends NavigationAgent2D

const MAX_NAVIGATION_ATTEMPTS : int = 8


static func get_random_vector2(min_length: float, max_length: float) -> Vector2:
	return Vector2(randf_range(min_length, max_length) * (1.0 if randi() % 2 else -1.0), randf_range(min_length, max_length) * (1.0 if randi() % 2 else -1.0))


@export var wander_distance_min : float = 5.0
@export var wander_distance_max : float = 10.0

@export var wander_duration_min : float = 5.0
@export var wander_duration_max : float = 10.0

var _state : int
var state : int :
	get: return _state
	set(value):
		if _state == value: return
		_state = value
		_on_state_changed()


var _target_node : Node2D
@export var target_node : Node2D :
	get: return _target_node
	set(value):
		if _target_node == value: return
		_target_node = value

		if _target_node:
			wander_timer.stop()


@onready var pawn : Pawn = get_parent()
@onready var nav_timer : Timer = $nav_timer
@onready var wander_timer : Timer = $wander_timer

func _on_state_changed() -> void: pass
func _on_home_reached() -> void: pass
func _on_target_reached() -> void: pass
func _on_other_entered_our_zone(other: Pawn) -> void: pass
func _on_other_exited_our_zone(other: Pawn) -> void: pass
func _on_entered_others_zone(other: Pawn) -> void: pass
func _on_exited_others_zone(other: Pawn) -> void: pass


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if pawn.is_phased: return
	_physics_process_unblocked(delta)
func _physics_process_unblocked(delta: float) -> void: pass


func _get_walk_direction() -> Vector2:
	return (self.get_next_path_position() - pawn.global_position).normalized()

func _get_wander_position() -> Vector2:
	return get_random_nearby_position()

func update_target_position() -> void:
	if target_node == null: return
	self.target_position = target_node.global_position


func physics_process_walk_to_target(delta: float) -> void:
	if self.is_target_reached(): return
	pawn.walk_vector = _get_walk_direction()


func start_wandering() -> void:
	wander_timer.wait_time = randf_range(wander_duration_min, wander_duration_max)
	wander_timer.start()
	self.target_node = null
	self.target_position = _get_wander_position()


func get_random_nearby_position() -> Vector2:
	var result : Vector2
	var map := self.pawn.get_world_2d().navigation_map

	for i in MAX_NAVIGATION_ATTEMPTS:
		result = pawn.global_position + get_random_vector2(wander_distance_min, wander_distance_max)
		var closest := NavigationServer2D.map_get_closest_point(map, result)
		if (closest - result).is_zero_approx(): return closest
	return result


func wait(delay: float) :
	await self.get_tree().create_timer(delay).timeout


func _on_nav_timer_timeout() -> void:
	update_target_position()


func _on_wander_timer_timeout() -> void:
	if target_node: return
	start_wandering()
