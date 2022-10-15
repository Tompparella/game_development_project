extends Node2D
class_name Obstacle

@export var texture: String = ""

func Remove() -> void:
	GameServer.RemoveSurrounding(get_instance_id())
	queue_free()
