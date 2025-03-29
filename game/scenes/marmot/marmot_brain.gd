extends Brain

func _on_entered_zone(other: Pawn) -> void:
	match other.species_id:
		&"baby":
			other.brain.feed()
			pawn.queue_free()
		&"player":
			pass # flee
