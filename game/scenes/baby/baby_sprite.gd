extends MySprite

func _process_looping(delta: float) -> void:
	var anim : StringName = &"idle"

	match pawn.brain.hunger:
		0: anim = &"dead"
		1: anim = &"starving"
		2: anim = &"whine"
		3: anim = &"idle"

	if pawn.is_phased and pawn.grabbed_by:
		match pawn.grabbed_by.species_id:
			&"griptor": anim = &"scream"
	else:
		pass

	if pawn.brain.is_grown and self.sprite_frames.has_animation(anim + "_grown"):
		anim += "_grown"

	self.play(anim)
