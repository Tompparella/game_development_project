extends Node
class_name State #,[logo path here]

signal finished(next_state_name: String)

var player: Player

func Initialize(state_machine: StateMachine, _player: Player):
	player = _player
	finished.connect(state_machine._Change_State)

func Enter() -> void:
	return
	
func Exit() -> void:
	return

func HandleInput(_event: InputEvent) -> void:
	return

func Update(_delta: float) -> void:
	return

func _Animation_Finished(_animation_name: String) -> void:
	return
