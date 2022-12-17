extends RefCounted
class_name Inventory

const MAX_TASKS: int = 3

var tasks: Array[Task] = []
var items: Array[Item] = [] # TODO: Setters and getters
var returnables: Array[Returnable] = []
var returnables_size: int = 0
var maxReturnables: int = 10 # Default carry size
var currency: float = 0.0
var vibe: float = 0.0
var flex: int = 0

# Checks if new item is a normal item or a recyclable, and adds it accordingly
func AddItem(item: Item) -> bool:
	var result: bool = false
	if item is Returnable:
		if maxReturnables >= (returnables_size + item.size):
			returnables_size += item.size
			returnables.append(item)
			result = true
	elif items.size() < 9: # Max length
		items.append(item)
		result = true
	return result

func RemoveItem(item: Item) -> bool:
	var result: bool = items.has(item)
	if item.returnable:
		result = returnables.has(item)
		if result:
			returnables_size -= item.size
			returnables.erase(item)
	else:
		result = items.has(item)
		if result:
			items.erase(item)
	return result

# items: { item_id: amount }
func HasItems(_items: Dictionary) -> bool:
	for entry in _items.keys():
		var item: Item = GameItems.GetItem(entry)
		var amount: int = 0
		if item.returnable:
			amount = returnables.count(item)
		else:
			amount = items.count(item)
		if _items[entry] > amount:
			return false
	return true

func AddTask(_task: Task) -> bool:
	if tasks.size() < MAX_TASKS && !tasks.has(_task):
		tasks.append(_task)
		return true
	return false

func RemoveTask(_task: Task) -> bool:
	if tasks.has(_task):
		tasks.erase(_task)
		return true
	return false

# Returns new total currency
func AddCurrency(_currency: float) -> float:
	currency += _currency
	return currency

func TakeCurrency(_currency: float) -> float:
	currency -= _currency
	return currency

func AddFlex(_flex: int) -> int:
	flex += _flex
	return flex

func AddVibe(_vibe: float) -> float:
	vibe += _vibe
	return vibe

func GetVibe() -> float:
	return vibe

func CanBuy(price: float) -> bool:
	# The 0.001 here is due to a float inaccuracy problem with godot 4.0 beta
	return (items.size() < 9 && (currency + 0.001) >= price)

func PopReturnable() -> Returnable:
	var returnable: Returnable = returnables.pop_back()
	if returnable:
		returnables_size -= returnable.size
	return returnable

func GetReturnables() -> Array[Returnable]:
	return returnables

func _init(_items: Array[Item], _returnables: Array[Returnable], _currency: float = 0.0, _vibe: float = 25.00, _flex: int = 0) -> void:
	# The items maybe need to be parsed to distinct returnables from other items. This can be implemented here (Maybe actually before this?).
	items = _items
	returnables = _returnables
	currency = _currency
	vibe = _vibe
	flex = _flex
