extends MotionState

var movement_speed: int = 400 # TODO: Get this value from the player in an Initialize function

func Enter() -> void:
	return

func Update(delta: float) -> void:
	# if (!moving) { EmitSignal(nameof(Finished), "idle")}
	super.Update(delta)

func HandleInput(event: InputEvent) -> void:
	motion = Vector2(
		int(event.is_action_pressed("MoveRight")) - int(event.is_action_pressed("MoveLeft")),
		int(event.is_action_pressed("MoveDown")) - int(event.is_action_pressed("MoveUp"))
		).normalized() * movement_speed
