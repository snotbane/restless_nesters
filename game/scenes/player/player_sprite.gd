extends MySprite

func _process_anim_loop(delta: float) -> void:
	self.play(&"idle" if pawn.velocity_last_frame.is_zero_approx() else &"walk")
