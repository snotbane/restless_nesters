extends Brain

enum {
	STATE_WANDER,
	STATE_FREEZE,
	STATE_FLEE,
	STATE_HIDE,
	STATE_RESURFACE,
}

@export var walk_speed_fast : float = 1000.0
@export var flee_delay : float = 0.4

@onready var walk_speed_normal : float = pawn.walk_speed


func _ready() -> void:
	await wait(0.1)
	start_wandering()


func _on_state_changed() -> void:
	pawn.walk_speed = walk_speed_fast if _state == STATE_FLEE else walk_speed_normal
	match state:
		STATE_WANDER:
			start_wandering()
		STATE_FLEE:
			self.target_node = pawn.home_area
		STATE_HIDE:
			pawn.is_phased = true
			pawn.visible = false
		STATE_RESURFACE:
			pawn.is_phased = false
			pawn.visible = true
			state = STATE_WANDER


func _physics_process_unblocked(delta: float) -> void:
	match state:
		STATE_WANDER, STATE_FLEE:
			physics_process_walk_to_target(delta)


func _on_other_entered_our_zone(other: Pawn) -> void:
	match other.species_id:
		&"player":
			state = STATE_FREEZE
			await wait(flee_delay)
			state = STATE_FLEE


func _on_target_reached() -> void:
	match state:
		STATE_FLEE:
			state = STATE_HIDE
			await wait(20)
			state = STATE_RESURFACE
