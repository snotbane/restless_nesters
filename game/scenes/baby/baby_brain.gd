extends Brain

enum {
	DEAD,
	STARVING,
	HUNGRY,
	HAPPY,
}

signal filled

@export var audio : AudioStreamPlayer2D
@export var add_scale_per_food : float = 0.25
@export var food_needed : int = 3
var _food_fed : int
var food_fed : int :
	get: return _food_fed
	set(value):
		value = clampi(value, 0, food_needed)
		if _food_fed == value: return
		_food_fed = value

		pawn.scale = Vector2.ONE + Vector2.ONE * add_scale_per_food * _food_fed
		audio.pitch_scale = 1.0 - (_food_fed * 0.05)

		if _food_fed == food_needed:
			filled.emit()


var is_able_to_eat : bool :
	get: return food_fed < food_needed


var is_grown : bool :
	get: return not is_able_to_eat


func _ready() -> void:
	super._ready()
	state = HAPPY
	await wait(1)
	# start_wandering() ## Doesn't work on all babies for some reason
	$chirp_timer.wait_time = randf_range(8.0, 25.0)
	$chirp_timer.start()


func _physics_process_unblocked(delta: float) -> void:
	match pawn.sprite.animation:
		&"idle", &"idle_grown":
			physics_process_walk_to_target(delta)
		pass


func _get_wander_position() -> Vector2:
	return pawn.global_position + Vector2.LEFT.rotated(pawn.sprite.global_rotation) * (self.target_desired_distance + 1.0)


func consume(other: Node2D) -> void:
	if not is_able_to_eat: return
	food_fed += 1
	other.queue_free()
	pawn.sprite.play(&"consume_start")


func _on_other_entered_our_zone(other: Pawn) -> void:
	if pawn.is_phased: return
	match other.species_id:
		&"marmot":
			consume(other)


func _on_chirp_timer_timeout() -> void:
	match pawn.sprite.animation:
		&"idle":
			pawn.sprite.play(&"chirp")
			$chirp_timer.wait_time = randf_range(8.0, 25.0)
			$chirp_timer.start()
