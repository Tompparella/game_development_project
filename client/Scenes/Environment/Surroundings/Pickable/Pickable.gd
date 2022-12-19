extends Surrounding
class_name Pickable

signal returnable_picked()

func Interact(_player: Player) -> void:
	pass
#	if item:
#		if player.AddItem(item):
#			if item is Returnable:
#				returnable_picked.emit()
#			# TODO: Play sound effect / Animation
#			Remove()
