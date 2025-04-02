class_name PawnAudio extends AudioStreamPlayer2D

@export var sprite : AnimatedSprite2D
@export var animation_sounds : Dictionary

func _on_sprite_animation_changed() -> void:
	if animation_sounds.has(sprite.animation):
		self.stream = animation_sounds[sprite.animation]
		self.play()
	else:
		self.stop()
