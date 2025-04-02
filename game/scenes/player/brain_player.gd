extends Brain

signal pecked

func _ready() -> void:
	super._ready()
	Pawn.PLAYER = self.pawn


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if self.get_tree().get_node_count_in_group(&"debug_ghost") > 0: return
	if self.pawn.sprite.animation == &"peck": return

	pawn.walk_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"peck"):
		peck()


func peck() -> void:
	if pawn.grabbed_pawn:
		match pawn.grabbed_pawn.species_id:
			&"marmot": pawn.grabbed_pawn = null
			&"baby": pawn.grabbed_pawn = null
	else:
		for i in pawn.pawns_in_zone:
			match i.species_id:
				&"marmot": pawn.grabbed_pawn = i; break
				&"baby": pawn.grabbed_pawn = i; break # IF outside home
				&"griptor":
					# i.brain.state = STUNNED
					if i.grabbed_pawn:
						var baby := i.grabbed_pawn
						i.grabbed_pawn = null
						pawn.grabbed_pawn = baby
		pecked.emit()


func _on_home_reached() -> void:
	print("Hi honey I'm home")

