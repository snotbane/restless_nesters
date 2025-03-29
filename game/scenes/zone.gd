extends Area2D

@onready var pawn : Pawn = self.get_parent().get_parent()

func _on_body_entered(other: Node2D) -> void:
	if other is Pawn and other != pawn:
		pawn.pawns_in_zone.push_back(other)
		pawn.brain._on_other_entered_our_zone(other)
		other.brain._on_entered_others_zone(self.pawn)


func _on_body_exited(other: Node2D) -> void:
	if other is Pawn and other != pawn:
		pawn.pawns_in_zone.erase(other)
		pawn.brain._on_other_exited_our_zone(other)
		other.brain._on_exited_others_zone(self.pawn)
