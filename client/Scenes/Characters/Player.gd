extends CharacterBody2D
class_name Player

@onready var state_machine: PlayerStateMachine = $PlayerStateMachine

func _ready():
	state_machine.Initialize(self)
