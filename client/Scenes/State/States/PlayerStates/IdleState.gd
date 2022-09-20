extends State

func HandleInput(event: InputEvent) -> void:
	var next_state: String
	if event.is_action("MoveDown")\
	|| event.is_action("MoveUp")\
	|| event.is_action("MoveRight")\
	|| event.is_action("MoveLeft"):
		next_state = "move"
	if next_state:
		emit_signal("finished", next_state)
