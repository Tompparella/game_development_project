extends CharacterBody2D
class_name Player

var state_machine: PlayerStateMachine

func _ready():
	state_machine = $PlayerStateMachine
	state_machine.Initialize(self)
