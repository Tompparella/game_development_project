extends Camera2D
class_name Camera

var player: Player
var gamesize: Vector2 = Vector2(1280, 720)

func Initialize(_player) -> void:
	player = _player
	current = true
	set_process(true)
	
func _ready():
	set_process(false)
	
func _process(delta) -> void:
	var camera_position: Vector2 = lerp(player.global_position, get_global_mouse_position(), 0.3)
	global_position = lerp(global_position, camera_position, delta * 5)
