extends Node2D
class_name Obstacle

@export var texture: Texture2D

func Initialize(_texture: String, _position: Vector2) -> void:
	if _texture:
		texture = load(_texture)
	if texture:
		$Sprite.set_texture(texture)
	global_position = _position
