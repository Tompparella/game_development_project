extends RefCounted
class_name Inventory

var items: Array[Item] = Array() as Array[Item] # TODO: Setters and getters
var returnables: Array[Returnable] = Array() as Array[Returnable]
var maxReturnables: int = 10 # Default carry size
var currency: float = 0.0
var score: int = 0

func _init(_items: Array[Item], _returnables: Array[Item], _currency: float, _score: int) -> void:
	# The items maybe need to be parsed to distinct returnables from other items. This can be implemented here.
	items = _items
	returnables = _returnables
	currency = _currency
	score = _score
