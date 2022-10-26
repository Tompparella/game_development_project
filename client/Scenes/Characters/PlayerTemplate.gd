extends CharacterBody2D
class_name PlayerTemplate

func MovePlayer(new_position: Vector2) -> void:
	global_position = new_position

# No static typing, because types aren't nullable in godot
func UpdateStats(_vibe, _flex) -> void:
	# TODO: Add visual indicator for high and low vibe for players
	pass
