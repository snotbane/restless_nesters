extends MySprite

func _process_looping(delta: float) -> void:
	self.play(&"idle" if pawn.velocity_last_frame.is_zero_approx() else &"walk")
