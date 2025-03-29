extends Brain

func feed() -> void:
	pawn.scale += Vector2.ONE * 0.2


func _on_other_entered_our_zone(other: Pawn) -> void:
	match other.species_id:
		&"marmot":
			feed()
			other.queue_free()
