class_name MySprite extends AnimatedSprite2D

@export var initial_animation : StringName

@export var animation_transitions : Dictionary

@onready var pawn : Pawn = self.get_parent()

func _ready() -> void:
	self.play(initial_animation)


func _process(delta: float) -> void:
	if self.sprite_frames.get_animation_loop(self.animation):
		self._process_looping(delta)


func _process_looping(delta: float) -> void:
	pass


func _on_animation_finished() -> void:
	if animation_transitions.has(self.animation):
		self.play(animation_transitions[self.animation])
