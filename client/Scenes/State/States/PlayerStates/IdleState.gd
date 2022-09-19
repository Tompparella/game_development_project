extends State

func HandleInput(event: InputEvent) -> void:
	if event is InputEventAction:
		print("Received action input")
		if event.is_action_pressed("MoveUp") || event.is_action_pressed("MoveRight") || event.is_action_pressed("MoveLeft") || event.is_action_pressed("MoveDown"):
			emit_signal("Finished", "move")
