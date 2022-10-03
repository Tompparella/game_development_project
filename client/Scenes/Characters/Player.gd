extends CharacterBody2D
class_name Player

signal item_added(item: Item)
signal item_removed(item: Item)
signal vibe_changed(vibe: float)
signal currency_changed(currency: float)
signal score_changed(score: int)

var state_machine: PlayerStateMachine
var inventory: Inventory = Inventory.new([], [])

# Make sure that only interactable items are set on the same layer as Interaction area's layer
var surroundings: Array[SurroundingArea] = Array()

# TODO: Initiate player inventory
# TODO: Create an initialization function that runs when the user connects to a game
func Initialize():
	# TODO: Inventory initialization with data
	state_machine = $PlayerStateMachine
	state_machine.Initialize(self)

func Interact() -> void:
	if surroundings.size():
		var entry: SurroundingArea = surroundings.back()
		print(entry)
		entry.Interact(self)
		surroundings.shuffle()

# Returns true if item add successful. False if not (inventory full, etc.)
func AddItem(item: Item) -> bool:
	if inventory.AddItem(item):
		emit_signal("item_added", item)
		return true
	return false 

func AddCurrency(currency: float) -> void:
	emit_signal("currency_changed", inventory.AddCurrency(currency))

func TakeCurrency(currency: float) -> void:
	emit_signal("currency_changed", inventory.TakeCurrency(currency))

func AddScore(score: int) -> void:
	emit_signal("score_changed", inventory.AddScore(score))

func AddVibe(vibe: float) -> void:
	emit_signal("vibe_changed", inventory.AddVibe(vibe))

func CanBuy(price: float) -> bool:
	return inventory.CanBuy(price)

func Recycle() -> Returnable:
	var returnable: Returnable = inventory.PopReturnable()
	if returnable:
		emit_signal("item_removed", returnable)
	return returnable

func _Interaction_Entered(area: Area2D) -> void:
	# TODO: Handle instance unloading/freeing with a signal (node.free() -> node.emit_signal(node_freed) -> this._Interaction_Exited)
	var added: bool = false
	if area is SurroundingArea:
		surroundings.append(area)
		added = true
		# area.Interact(self)
	if added:
		area.connect("surrounding_exiting", _Interaction_Exited)
	# Other handling, t.ex. Npc: if area is Npc: do something

func _Interaction_Exited(area: Area2D) -> void:
	if area in surroundings:
		surroundings.erase(area)
	if area.is_connected("surrounding_exiting", _Interaction_Exited):
		area.disconnect("surrounding_exiting", _Interaction_Exited)
