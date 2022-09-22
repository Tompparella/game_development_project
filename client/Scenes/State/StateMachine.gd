
#
# A base for player state machine,
# that could be later implemented for an npc state machine
#

extends Node
class_name StateMachine #,[logo path here]

signal state_changed(new_state)

var start_state: State
var current_state: State
var state_stack: Array[State] = []
var state_map: Dictionary

var _active: bool

func _ready() -> void:
	SetActive(false)
	
func _process(delta: float) -> void:
	current_state.Update(delta)
	
func _unhandled_input(event: InputEvent) -> void:
	current_state.HandleInput(event)

func Initialize(_character: Node) -> void:
	for state in state_map.values():
		state.Initialize(self, _character)
	state_stack.insert(0, start_state)
	current_state = state_stack[0]
	current_state.Enter()
	SetActive(true)

func SetActive(value: bool) -> void:
	_active = value
	set_process(value)
	set_process_unhandled_input(value)
	if !_active:
		state_stack.clear()
		current_state = null

func MoveCharacter() -> void:
	return

func _Animation_Finished(animation_name: String) -> void:
	if _active:
		current_state._Animation_Finished(animation_name)

func _ChangeState(state_name: String):
	if !_active:
		return
	current_state.Exit()
	if state_name == "previous":
		state_stack.remove_at(0)
		current_state = state_stack[0]
	else:
		state_stack[0] = state_map[state_name]
		current_state = state_stack[0]
		current_state.Enter()
	print(current_state.name)

