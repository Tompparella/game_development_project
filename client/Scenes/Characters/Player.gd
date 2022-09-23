extends CharacterBody2D
class_name Player

var state_machine: PlayerStateMachine
var inventory: Inventory = Inventory.new([], [])

# Make sure that only interactable items are set on the same layer as Interaction area's layer
var surroundings: Array[Surrounding] = Array()

# TODO: Initiate player inventory
# TODO: Create an initialization function that runs when the user connects to a game
func Initialize():
	# TODO: Inventory initialization with data
	state_machine = $PlayerStateMachine
	state_machine.Initialize(self)

func Interact() -> void:
	if surroundings.size():
		var entry: Surrounding = surroundings.back()
		entry.Interact(self)
		surroundings.shuffle()

# Returns true if item add successful. False if not (inventory full, etc.)
func AddItem(item: Item) -> bool:
	return inventory.AddItem(item)

func _Interaction_Entered(area: Area2D) -> void:
	# TODO: Handle instance unloading/freeing with a signal (node.free() -> node.emit_signal(node_freed) -> this._Interaction_Exited)
	var added: bool = false
	if area is Surrounding:
		surroundings.append(area)
		added = true
		# area.Interact(self)
	if added:
		area.connect("surrounding_removed", _Interaction_Exited)
	# Other handling, t.ex. Npc: if area is Npc: do something

func _Interaction_Exited(area: Area2D) -> void:
	if area in surroundings:
		surroundings.erase(area)
	if area.is_connected("surrounding_removed", _Interaction_Exited):
		area.disconnect("surrounding_removed", _Interaction_Exited)
