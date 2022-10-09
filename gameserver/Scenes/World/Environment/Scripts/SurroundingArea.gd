extends Area2D
class_name SurroundingArea

signal interaction(_player: Player)
signal surrounding_exiting(surrounding: SurroundingArea)

var auto_pickup: bool = false

func Interact(_player: Player):
	emit_signal("interaction", _player)


func _On_Surrounding_Exiting():
	emit_signal("surrounding_exiting", self)
