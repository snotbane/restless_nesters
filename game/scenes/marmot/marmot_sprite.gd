extends MySprite

func _process_looping(delta: float) -> void:
	var anim : StringName = &"idle"

	if pawn.is_phased and pawn.brain.state != 3: anim = &"squirm"
	else:
		match pawn.brain.state:
			0: anim = &"idle" if pawn.velocity_last_frame.is_zero_approx() else &"walk"
			1: anim = &"alert"
			2: anim = &"walk_flee"
			_: anim = &"idle"

	self.play(anim)
