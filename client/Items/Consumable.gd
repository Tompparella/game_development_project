extends Item
class_name Consumable

var potency: float
var score: int

func _init(_itemName: String, _value: float, _texture: String, _potency: float, _score: int) -> void:
	itemName = _itemName
	value = _value
	texture = _texture
	potency = _potency
	score = _score
	consumable = true
