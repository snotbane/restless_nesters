class_name PawnAudio extends AudioStreamPlayer2D

@export var sprite : AnimatedSprite2D
@export var animation_sounds : Dictionary


func _on_sprite_animation_changed() -> void:
	if animation_sounds.has(sprite.animation):
		self.stream = animation_sounds[sprite.animation]
		if not self.visible: return
		self.play()
	else:
		self.stop()


func _on_visibility_changed() -> void:
	self.volume_db = 0.0 if self.visible else -80.0
