
class_name DebugGhostAutoload extends Node

const ALLOWED_IN_RELEASE_BUILDS : bool = false

static var GHOST_2D_SCENE_PATH := "res://addons/tools_mincuz/scenes/debug_ghost_2d.tscn"
static var GHOST_2D_SCENE : PackedScene :
	get: return load(GHOST_2D_SCENE_PATH)

static var GHOST_3D_SCENE_PATH := "res://addons/tools_mincuz/scenes/debug_ghost_3d.tscn"
static var GHOST_3D_SCENE : PackedScene :
	get: return load(GHOST_3D_SCENE_PATH)

static var inst : DebugGhostAutoload

static var debug_ghost_exists : bool :
	get: return inst.get_tree().get_node_count_in_group(&"debug_ghost") > 0

var ghost : Node
var previous_camera : Node

func _ready():
	if ALLOWED_IN_RELEASE_BUILDS or OS.is_debug_build():
		inst = self
	else:
		queue_free()


func _input(event: InputEvent):
	if event.is_action_pressed("ghost_toggle"):
		toggle_ghost()


func toggle_ghost() -> void:
	if ghost:
		ghost.queue_free()
		ghost = null
		return

	if self.get_tree().current_scene is Node2D:
		ghost = GHOST_2D_SCENE.instantiate()
	elif self.get_tree().current_scene is Node3D:
		ghost = GHOST_3D_SCENE.instantiate()
	else:
		return

	self.get_tree().root.add_child(ghost)
