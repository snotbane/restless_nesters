extends Brain

enum {
	STATE_WANDER,
	STATE_AVOID,
	STATE_LURK,
	STATE_FREEZE,
	STATE_FLEE,
	STATE_HIDE,
	STATE_RESURFACE,
	STATE_STUNNED,
}

@export var lurk_duration_min : float = 30.0
@export var lurk_duration_max : float = 60.0
var lurk_duration_random : float :
	get: return randf_range(lurk_duration_min, lurk_duration_max)

@export var walk_speed_fast : float = 1000.0
@export var safe_distance : float = 400.0
@export var flee_delay : float = 1.0

@onready var walk_speed_normal : float = pawn.walk_speed
@onready var lurk_timer : Timer = $lurk_timer

func _ready() -> void:
	super._ready()
	await wait(0.1)
	_on_state_changed()


func _on_state_changed() -> void:
	pawn.walk_speed = walk_speed_fast if _state == STATE_FLEE else walk_speed_normal
	match state:
		STATE_WANDER:
			start_wandering()
			if lurk_timer.is_stopped():
				lurk_timer.wait_time = lurk_duration_random
				lurk_timer.start()
			else:
				lurk_timer.paused = false
		STATE_AVOID:
			self.target_node = null
			lurk_timer.paused = true
		STATE_LURK:
			var target := select_random_target()
			if target: self.target_node = target
			else: state = STATE_WANDER
			wander_timer.stop()
		STATE_FREEZE:
			await wait(flee_delay)
			state = STATE_FLEE
		STATE_FLEE:
			self.target_node = pawn.home_area
		STATE_HIDE:
			pawn.is_phased = true
			pawn.visible = false
			await wait(20)
			state = STATE_RESURFACE
		STATE_RESURFACE:
			pawn.is_phased = false
			pawn.visible = true
			state = STATE_WANDER
		STATE_STUNNED:
			pawn.is_phased = true
			await wait(10)
			state = STATE_WANDER


func _physics_process_unblocked(delta: float) -> void:
	match state:
		STATE_LURK:
			if self.target_node is Pawn and self.target_node.is_phased:
				state = STATE_WANDER
				return
			physics_process_walk_to_target(delta)
		STATE_WANDER, STATE_FLEE:
			physics_process_walk_to_target(delta)
		STATE_AVOID:
			self.target_position = Pawn.PLAYER.global_position + (pawn.global_position - Pawn.PLAYER.global_position).normalized() * safe_distance
			physics_process_walk_to_target(delta)


func _on_other_entered_our_zone(other: Pawn) -> void:
	match other.species_id:
		# &"player":
		# 	if state > STATE_WANDER: return
		# 	state = STATE_AVOID

		&"baby":
			if other.brain.hunger <= 1: state = STATE_WANDER; return
			if state > STATE_LURK: return
			pawn.grabbed_pawn = other
			state = STATE_FREEZE


func _on_target_reached() -> void:
	match state:
		STATE_AVOID:
			state = STATE_WANDER
		STATE_LURK:
			pass # See _on_other_entered_our_zone
		STATE_FLEE:
			if pawn.grabbed_pawn:
				pawn.grabbed_pawn.queue_free()
				pawn.grabbed_pawn.is_dead = true
				pawn.grabbed_pawn.died.emit()
				pawn.grabbed_pawn = null
			state = STATE_HIDE


func select_random_target() -> Node2D:
	var potential_targets := self.get_tree().get_nodes_in_group(&"baby")
	potential_targets.shuffle()
	for i in potential_targets:
		if i.is_phased or not i.visible or i.brain.hunger <= 1: continue
		return i
	return null

