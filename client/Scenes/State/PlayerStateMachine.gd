extends StateMachine

func _ready() -> void:
	state_map = {
		"idle": get_node("Idle"),
		"move": get_node("Move"),
	}
	start_state = state_map["idle"]
