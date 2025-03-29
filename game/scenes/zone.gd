extends Area2D

@onready var pawn : Pawn = self.get_parent().get_parent()

func _on_body_entered(other: Node2D) -> void:
	if other is Pawn and other != pawn:
		pawn.pawns_in_zone.push_back(other)
		other.brain._on_entered_zone(self.pawn)


func _on_body_exited(other: Node2D) -> void:
	if other is Pawn and other != pawn:
		pawn.pawns_in_zone.erase(other)
		other.brain._on_exited_zone(self.pawn)
