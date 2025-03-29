class_name Brain extends NavigationAgent2D

@onready var pawn : Pawn = get_parent()

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_other_entered_our_zone(other: Pawn) -> void:
	pass


func _on_other_exited_our_zone(other: Pawn) -> void:
	pass


func _on_entered_others_zone(other: Pawn) -> void:
	pass


func _on_exited_others_zone(other: Pawn) -> void:
	pass
