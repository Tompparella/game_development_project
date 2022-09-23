extends Surrounding
class_name Pickable

func Interact(player: Player) -> void:
	if item:
		if player.AddItem(item):
			# TODO: Play sound effect / Animation
			Remove()
