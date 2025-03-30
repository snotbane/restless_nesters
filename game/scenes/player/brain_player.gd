extends Brain

signal pecked

func _ready() -> void:
	super._ready()
	Pawn.PLAYER = self.pawn


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if self.get_tree().get_node_count_in_group(&"debug_ghost") > 0: return

	pawn.walk_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"peck"):
		peck()


func peck() -> void:
	if pawn.grabbed_pawn:
		pawn.grabbed_pawn = null
	else:
		if pawn.pawns_in_zone:
			pawn.grabbed_pawn = pawn.pawns_in_zone[0]

		pecked.emit()


func _on_home_reached() -> void:
	print("Hi honey I'm home")

