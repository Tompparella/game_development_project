extends StateMachine
class_name PlayerStateMachine

func Initialize(_character: Node) -> void:
	state_map = {
		"idle": $Idle,
		"move": $Move,
		"motion": $Motion
	}
	start_state = state_map["idle"]
	super.Initialize(_character)
