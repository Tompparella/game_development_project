extends MotionState

var movement_speed: float = 300.0 # TODO: Get this value from the player in an Initialize function
var acceleration: float = 15.0

func Enter() -> void:
	moving = true
	
func Exit() -> void:
	moving = false

func Update(delta: float) -> void:
	var new_velocity = Vector2(
		int(Input.is_action_pressed("MoveRight")) - int(Input.is_action_pressed("MoveLeft")),
		int(Input.is_action_pressed("MoveDown")) - int(Input.is_action_pressed("MoveUp"))
		).normalized() * movement_speed
	if new_velocity.length():
		moving = true
		motion = motion.move_toward(new_velocity, acceleration)
	else:
		moving = false
	super.Update(delta)
