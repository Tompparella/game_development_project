extends CharacterBody2D
class_name PlayerTemplate

func MovePlayer(new_position: Vector2) -> void:
	global_position = new_position

func UpdateStats(_vibe: float) -> void:
	# TODO: Add visual indicator for high and low vibe for players
	pass
