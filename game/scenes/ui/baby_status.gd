class_name BabyStatus extends Control

enum {
	DEAD,
	KIDNAPPED,
	STARVING,
	HUNGRY,
	HAPPY,
}

@export var baby : Pawn

func _ready() -> void:
	baby.died.connect($tab_container.set.bind(&"current_tab", DEAD))
	baby.died.connect($death_audio.play.bind())

	baby.sprite.animation_changed.connect(_on_animation_changed)
	$tab_container.current_tab = HAPPY
	# for i in get_child(0).get_children():
	# 	i.material = self.material

func _on_animation_changed() -> void:
	match baby.sprite.animation:
		&"idle", &"idle_grown", &"consume_start":
			$tab_container.current_tab = HAPPY
		&"starving":
			$tab_container.current_tab = STARVING
		&"scream", &"scream_grown":
			$tab_container.current_tab = KIDNAPPED
		&"whine":
			$tab_container.current_tab = HUNGRY