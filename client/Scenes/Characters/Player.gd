extends CharacterBody2D
class_name Player

var state_machine: PlayerStateMachine
var inventory: Inventory

# TODO: Initiate player inventory
# TODO: Create an initialization function that runs when the user connects to a game
func Initialize():
	inventory = Inventory.new([], [])
	state_machine = $PlayerStateMachine
	state_machine.Initialize(self)
