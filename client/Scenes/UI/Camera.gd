extends Camera2D
class_name Camera

var player: Player
var gamesize: Vector2 = Vector2(1280, 720)

func Initialize(_player) -> void:
	player = _player
	player.tree_exiting.connect(Disable)
	Enable()

func Disable() -> void:
	set_process(false)
	player = null
	global_position = Vector2(0,0)
	zoom = Vector2(.5, .5)

func Enable() -> void:
	current = true
	set_process(true)
	zoom = Vector2(1.5, 1.5)

func _ready():
	Disable()
	
func _process(delta) -> void:
	var camera_position: Vector2 = lerp(player.global_position, get_global_mouse_position(), 0.3)
	global_position = lerp(global_position, camera_position, delta * 5)
