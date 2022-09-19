extends State
class_name MotionState

var motion: Vector2

func Update(_delta: float) -> void:
	if motion == Vector2.ZERO:
		emit_signal("finished", "idle")
		return
	player.velocity = motion
	player.move_and_slide()
