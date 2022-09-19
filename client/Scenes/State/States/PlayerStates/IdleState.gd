extends State

func HandleInput(event: InputEvent) -> void:
	var next_state: String
	if event.is_action_pressed("MoveDown")\
	|| event.is_action_pressed("MoveUp")\
	|| event.is_action_pressed("MoveRight")\
	|| event.is_action_pressed("MoveLeft"):
		next_state = "move"
	if next_state:
		emit_signal("finished", next_state)
