extends Brain

signal pecked

func _ready() -> void:
	super._ready()
	Pawn.PLAYER = self.pawn


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if pawn.grabbed_pawn and pawn.grabbed_pawn.species_id == &"baby" and pawn.is_near_origin:
		pawn.grabbed_pawn = null

	if self.get_tree().get_node_count_in_group(&"debug_ghost") > 0: return
	if self.pawn.sprite.animation == &"peck": return

	pawn.walk_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"peck"):
		peck()


func peck() -> void:
	if pawn.grabbed_pawn:
		match pawn.grabbed_pawn.species_id:
			&"marmot", &"egg": pawn.grabbed_pawn = null
			# &"baby": pawn.grabbed_pawn = null
	else:
		for i in pawn.pawns_in_zone:
			match i.species_id:
				&"marmot", &"egg": pawn.grabbed_pawn = i; break
				&"baby":
					if i.is_near_origin: continue
					pawn.grabbed_pawn = i; break
				&"griptor":
					i.brain.state = 3
					if i.grabbed_pawn:
						var baby := i.grabbed_pawn
						i.grabbed_pawn = null
						pawn.grabbed_pawn = baby
		pecked.emit()


func _on_home_reached() -> void:
	print("Hi honey I'm home")

