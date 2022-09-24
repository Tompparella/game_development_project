extends RefCounted
class_name Inventory

var items: Array[Item] # TODO: Setters and getters
var returnables: Array[Returnable]
var maxReturnables: int = 10 # Default carry size
var currency: float = 0.0
var score: int = 0

func AddItem(item: Item) -> bool:
	var result: bool = false
	if item is Returnable:
		if maxReturnables > returnables.size():
			returnables.append(item)
			result = true
			print("Added returnable %s. Current returnables: %s" % [item.item_name, returnables.size()])
	elif items.size() < 9: # Max length
		items.append(item)
		result = true
		print("Added item %s. Current items: %s" % [item.item_name, items.size()])
	return result

func AddCurrency(_currency: float) -> void:
	currency += _currency
	print(currency)

func GetReturnables() -> Array[Returnable]:
	print("Before return: %s" % returnables.size())
	return returnables

func _init(_items: Array[Item], _returnables: Array[Returnable], _currency: float = 0.0, _score: int = 0) -> void:
	# The items maybe need to be parsed to distinct returnables from other items. This can be implemented here (Maybe actually before this?).
	items = _items
	returnables = _returnables
	currency = _currency
	score = _score
