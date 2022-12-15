extends CharacterBody2D
class_name Player

signal item_added(player_id: String, item: Item)
signal item_removed(player_id: String, item: Item)
signal items_recycled(player_id: String, recycled_items: Array[Item], returnable_size: int)
signal vibe_changed(player_id: String, vibe: float)
signal currency_changed(player_id: String, currency: float)
signal flex_changed(player_id: String, flex: int)
signal task_added(player_id: String, task: Task)
signal game_over(player_id: String)

var inventory: Inventory = Inventory.new([], [])

# Make sure that only interactable items are set on the same layer as Interaction area's layer
var surroundings: Array[SurroundingArea] = Array()

# TODO: Initiate player inventory
# TODO: Create an initialization function that runs when the user connects to a game
func Initialize():
	# TODO: Inventory initialization with data
	pass

func Interact() -> void:
	if surroundings.size():
		var entry: SurroundingArea = surroundings.back()
		entry.Interact(self)
		surroundings.shuffle()

# Returns true if item add successful. False if not (inventory full, etc.)
func AddItem(item: Item) -> bool:
	if inventory.AddItem(item):
		item_added.emit(name, item)
		return true
	return false

func RemoveItem(item: Item) -> bool:
	if inventory.RemoveItem(item):
		item_removed.emit(name, item)
		return true
	return false

# Use the item given as parameter. If no item is given, get selected item from UI
func UseItem(item: Item) -> void:
	item.Use(self)

func AddCurrency(currency: float) -> void:
	currency_changed.emit(name, inventory.AddCurrency(currency))

func TakeCurrency(currency: float) -> void:
	currency_changed.emit(name, inventory.TakeCurrency(currency))

func GetTasks() -> Array[Task]:
	return inventory.tasks

func AddTask(task: Task) -> bool:
	if inventory.AddTask(task):
		task_added.emit(name, task)
		return true
	else:
		return false

func AddFlex(flex: int) -> int:
	var new_flex: int = inventory.AddFlex(flex)
	flex_changed.emit(new_flex)
	return new_flex

func AddVibe(vibe: float, send_results: bool = true) -> float:
	var new_vibe: float = inventory.AddVibe(vibe)
	if new_vibe <= 0:
		game_over.emit(name)
	#	rotation = 90.0
	#	queue_free()
	#vibe_changed.emit(new_vibe)
	if send_results:
		# TODO: Handle result broadcasting
		pass
	return new_vibe

func GetVibe() -> float:
	return inventory.GetVibe()

func CanBuy(price: float) -> bool:
	return inventory.CanBuy(price)

func PopReturnable() -> Returnable:
	return inventory.PopReturnable()

func RecyclingFinished(items: Array[Item]) -> void:
	items_recycled.emit(name, items, inventory.returnables_size)

func _Interaction_Entered(area: Area2D) -> void:
	# TODO: Handle instance unloading/freeing with a signal (node.free() -> node.emit_signal(node_freed) -> this._Interaction_Exited)
	var added: bool = false
	if area is SurroundingArea:
		if area.auto_pickup:
			area.Interact(self)
		else:
			surroundings.append(area)
			added = true
	if added:
		area.connect("surrounding_exiting", _Interaction_Exited)
	# Other handling, t.ex. Npc: if area is Npc: do something

func _Interaction_Exited(area: Area2D) -> void:
	if area is SurroundingArea:
		if area in surroundings:
			surroundings.erase(area)
		if area.is_connected("surrounding_exiting", _Interaction_Exited):
			area.disconnect("surrounding_exiting", _Interaction_Exited)
