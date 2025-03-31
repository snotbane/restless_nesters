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

@export var walk_speed_fast : float = 1000.0
@export var safe_distance : float = 400.0
@export var flee_delay : float = 1.0

@onready var walk_speed_normal : float = pawn.walk_speed
@onready var lurk_timer : Timer = $lurk_timer

func _ready() -> void:
	await wait(0.1)
	_on_state_changed()


func _on_state_changed() -> void:
	pawn.walk_speed = walk_speed_fast if _state == STATE_FLEE else walk_speed_normal
	match state:
		STATE_WANDER:
			start_wandering()
			lurk_timer.start()
		STATE_AVOID:
			self.target_node = null
		STATE_LURK:
			self.target_node = select_random_target()
			wander_timer.stop()
		STATE_FLEE:
			self.target_node = pawn.home_area
		STATE_HIDE:
			pawn.is_phased = true
			pawn.visible = false
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
		STATE_WANDER, STATE_LURK, STATE_FLEE:
			physics_process_walk_to_target(delta)
		STATE_AVOID:
			self.target_position = Pawn.PLAYER.global_position + (pawn.global_position - Pawn.PLAYER.global_position).normalized() * safe_distance
			physics_process_walk_to_target(delta)


func _on_other_entered_our_zone(other: Pawn) -> void:
	match other.species_id:
		&"player":
			if state > STATE_WANDER: return
			state = STATE_AVOID

		&"baby":
			if state > STATE_LURK: return
			pawn.grabbed_pawn = other
			state = STATE_FREEZE
			await wait(flee_delay)
			state = STATE_FLEE


func _on_target_reached() -> void:
	match state:
		STATE_AVOID:
			state = STATE_WANDER
		STATE_LURK:
			pass # See _on_other_entered_our_zone
		STATE_FLEE:
			if pawn.grabbed_pawn:
				pawn.grabbed_pawn.died.emit()
				pawn.grabbed_pawn.queue_free()
				pawn.grabbed_pawn = null
			state = STATE_HIDE
			await wait(20)
			state = STATE_RESURFACE


func select_random_target() -> Node2D:
	var potential_targets := self.get_tree().get_nodes_in_group(&"baby")
	if potential_targets.size() == 0: return
	return potential_targets[randi_range(0, potential_targets.size() - 1)]

