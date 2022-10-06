extends CharacterBody2D
class_name Player

signal use_selected_item(player: Player)
signal item_added(item: Item)
signal item_removed(item: Item)
signal vibe_changed(vibe: float)
signal currency_changed(currency: float)
signal flex_changed(flex: int)

var timer: PlayerTimer
var state_machine: PlayerStateMachine
var inventory: Inventory = Inventory.new([], [])

# Make sure that only interactable items are set on the same layer as Interaction area's layer
var surroundings: Array[SurroundingArea] = Array()

# TODO: Initiate player inventory
# TODO: Create an initialization function that runs when the user connects to a game
func Initialize():
	# TODO: Inventory initialization with data
	state_machine = $PlayerStateMachine
	timer = $Timer
	state_machine.Initialize(self)
	timer.Initialize(self)

func Interact() -> void:
	if surroundings.size():
		var entry: SurroundingArea = surroundings.back()
		entry.Interact(self)
		surroundings.shuffle()

# Returns true if item add successful. False if not (inventory full, etc.)
func AddItem(item: Item) -> bool:
	if inventory.AddItem(item):
		item_added.emit(item)
		return true
	return false

func RemoveItem(item: Item) -> bool:
	if inventory.RemoveItem(item):
		item_removed.emit(item)
		return true
	return false

# Use the item given as parameter. If no item is given, get selected item from UI
func UseItem(_item: Item = null) -> void:
	var item: Item = _item if _item != null else use_selected_item.emit(self)
	if item:
		timer.StartUseItemTimer(item)

func AddCurrency(currency: float) -> void:
	currency_changed.emit(inventory.AddCurrency(currency))

func TakeCurrency(currency: float) -> void:
	currency_changed.emit(inventory.TakeCurrency(currency))

func AddFlex(flex: int) -> void:
	flex_changed.emit(inventory.AddFlex(flex))

func AddVibe(vibe: float) -> void:
	vibe_changed.emit(inventory.AddVibe(vibe))

func GetVibe() -> float:
	return inventory.GetVibe()

func CanBuy(price: float) -> bool:
	return inventory.CanBuy(price)

func Recycle() -> Returnable:
	var returnable: Returnable = inventory.PopReturnable()
	if returnable:
		item_removed.emit(returnable)
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
