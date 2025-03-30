class_name Pawn extends CharacterBody2D

static var PLAYER : Pawn

@export var species_id : StringName
@export var home_area : Area2D
@export var walk_speed : float = 256.0

@onready var sprite : AnimatedSprite2D = self.find_child("sprite")
@onready var brain : Brain = self.find_child("brain")
@onready var grabber : Node2D = self.find_child("grabber")

var pawns_in_zone : Array[Pawn]

var grabbed_by : Pawn
var _grabbed_pawn : Pawn
var grabbed_pawn : Pawn :
	get: return _grabbed_pawn
	set(value):
		if _grabbed_pawn == value: return

		if _grabbed_pawn:
			var p : Vector2 = _grabbed_pawn.global_position
			grabber.remove_child(_grabbed_pawn)
			self.get_tree().get_first_node_in_group(&"stuff").add_child(_grabbed_pawn)
			_grabbed_pawn.global_position = p
			_grabbed_pawn.grabbed_by = null
			_grabbed_pawn.is_phased = false

		_grabbed_pawn = value

		if _grabbed_pawn:
			pawns_in_zone.erase(_grabbed_pawn)

			grabber.global_position = _grabbed_pawn.global_position
			_grabbed_pawn.get_parent().remove_child(_grabbed_pawn)
			grabber.add_child(_grabbed_pawn)
			_grabbed_pawn.position = Vector2.ZERO
			_grabbed_pawn.grabbed_by = self
			_grabbed_pawn.is_phased = true


var walk_vector : Vector2

var temp_collision_layer : int
var temp_collision_mask : int
var _is_phased : bool
## When phased, a pawn has no collision and does not use physics.
var is_phased : bool :
	get: return _is_phased
	set(value):
		if _is_phased == value: return
		_is_phased = value

		velocity = Vector2.ZERO
		if _is_phased:
			temp_collision_layer = self.collision_layer
			temp_collision_mask = self.collision_mask
			self.collision_layer = 0
			self.collision_mask = 0
		else:
			self.collision_layer = temp_collision_layer
			self.collision_mask = temp_collision_mask


func _ready() -> void:
	if home_area:
		home_area.body_entered.connect(_on_home_body_entered)
	pass


func _process(delta: float) -> void:
	grabber.position = lerp(grabber.position, Vector2.ZERO, 10.0 * delta)


func _physics_process(delta: float) -> void:
	if is_phased: return

	velocity += walk_vector * walk_speed
	walk_vector = Vector2.ZERO

	if absf(velocity.x) > 1.0:
		sprite.scale.x = signf(velocity.x)

	# velocity *= Vector2(1.0, 0.5)
	self.move_and_slide()
	velocity = Vector2.ZERO


func _on_home_body_entered(other: Node2D) -> void:
	if other == self: brain._on_home_reached()
