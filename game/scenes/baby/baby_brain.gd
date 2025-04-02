extends Brain

signal filled

@export var add_scale_per_food : float = 0.25
@export var food_needed : int = 3
var _food_fed : int
var food_fed : int :
	get: return _food_fed
	set(value):
		value = clampi(value, 0, food_needed)
		if _food_fed == value: return
		_food_fed = value

		pawn.scale = Vector2.ONE + Vector2.ONE * add_scale_per_food * _food_fed

		if _food_fed == food_needed:
			filled.emit()


var is_able_to_eat : bool :
	get: return food_fed < food_needed


var is_grown : bool :
	get: return not is_able_to_eat


func consume(other: Node2D) -> void:
	if not is_able_to_eat: return
	food_fed += 1
	other.queue_free()
	pawn.sprite.play(&"consume_start")


func _on_other_entered_our_zone(other: Pawn) -> void:
	if pawn.is_phased: return
	match other.species_id:
		&"marmot":
			consume(other)
