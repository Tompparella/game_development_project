extends Item
class_name Consumable

var potency: float
var score: int

func _init(_item_name: String, _description: String, _value: float, _texture_path: String, _potency: float, _score: int) -> void:
	potency = _potency
	score = _score
	consumable = true
	super._init(_item_name, _description, _value, _texture_path)
