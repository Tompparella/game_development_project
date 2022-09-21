extends Item
class_name Consumable

var potency: float
var score: int

func _init(_value: float, _texture: String, _potency: float, _score: int) -> void:
	value = _value
	texture = _texture
	potency = _potency
	score = _score
	consumable = true
