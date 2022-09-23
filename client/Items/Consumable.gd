extends Item
class_name Consumable

var potency: float
var score: int

func _init(_item_name: String, _value: float, _texture_path: String, _potency: float, _score: int) -> void:
	item_name = _item_name
	value = _value
	texture = load(_texture_path)
	potency = _potency
	score = _score
	consumable = true
