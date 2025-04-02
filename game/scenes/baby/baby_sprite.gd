extends MySprite

func _process_looping(delta: float) -> void:
	var anim : StringName = &"idle"

	if pawn.is_phased:
		match pawn.grabbed_by.species_id:
			&"griptor": anim = &"scream"
	else:
		pass

	if pawn.brain.is_grown and self.sprite_frames.has_animation(anim + "_grown"):
		anim += "_grown"

	self.play(anim)
