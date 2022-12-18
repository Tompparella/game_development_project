extends CharacterBody2D
class_name Player

signal items_added(player_id: String, item_id_array: Array[String])
signal items_removed(player_id: String, item_id_array: Array[String])
signal items_recycled(player_id: String, recycled_items: Array[Item], returnable_size: int)
signal values_changed(player_id: String, values: Dictionary)
signal currency_changed(player_id: String, currency: float)
signal task_added(player_id: String, task: Task)
signal task_updated(player_id: String, task: Task)
signal task_removed(player_id: String, task: Task, completed: bool)
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
		var item_array: Array[String] = [item.item_id]
		items_added.emit(name, item_array)
		return true
	return false

func AddItemArray(item_array: Array[Item]) -> bool:
	var item_id_array: Array[String] = []
	for entry in item_array:
		if inventory.AddItem(entry):
			item_id_array.append(entry.item_id)
	if !item_id_array.is_empty():
		items_added.emit(name, item_id_array)
		return true
	return false

func RemoveItem(item: Item) -> bool:
	if inventory.RemoveItem(item):
		var item_array: Array[String] = [item.item_id]
		items_removed.emit(name, item_array)
		return true
	return false

# Removes array of removed item id's
func RemoveItemArray(item_array: Array[Item]) -> Array[String]:
	var item_id_array: Array[String] = []
	for entry in item_array:
		if inventory.RemoveItem(entry):
			item_id_array.append(entry.item_id)
	if !item_id_array.is_empty():
		items_removed.emit(name, item_id_array)
	return item_id_array

# items: {item_id: amount}
func HasItems(items: Dictionary) -> bool:
	return inventory.HasItems(items)

func AddCurrency(currency: float, send_results: bool = true) -> float:
	var new_currency: float = inventory.AddCurrency(currency)
	if send_results:
		currency_changed.emit(name, new_currency)
	return new_currency

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

func RemoveTask(task: Task, completed: bool = false) -> bool:
	if inventory.RemoveTask(task):
		task_removed.emit(name, task, completed)
		return true
	else:
		return false

func AddValues(flex: int = 0, vibe: float = 0.0, currency: float = 0.0, send_results: bool = true) -> Dictionary:
	var result: Dictionary = { "flex": null, "vibe": null }
	var new_vibe: float = -1.0
	if flex != 0:
		result["flex"] = AddFlex(flex)
	if vibe != 0.0:
		new_vibe = AddVibe(vibe, !send_results)
		result["vibe"] = new_vibe
	if currency != 0.0:
		result["currency"] = AddCurrency(currency)
	if send_results:
		values_changed.emit(name, result)
		if new_vibe != -1.0:
			VibeCheck(new_vibe)
	return result

func AddFlex(flex: int) -> int:
	return inventory.AddFlex(flex)

func AddVibe(vibe: float, send_result: bool = true) -> float:
	var new_vibe: float = inventory.AddVibe(vibe)
	if send_result:
		VibeCheck(new_vibe)
	return new_vibe

func VibeCheck(vibe: float) -> void:
	if vibe <= 0 || vibe > 100:
		game_over.emit(name)

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
