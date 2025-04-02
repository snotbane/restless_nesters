extends MySprite

func _process_looping(delta: float) -> void:
	match pawn.brain.state:
		0, 1, 2: self.play(&"idle" if pawn.velocity_last_frame.is_zero_approx() else &"walk")
		3: self.play(&"stun")
		4: self.play(&"walk_flee")
		_: self.play(&"idle")
