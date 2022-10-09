extends Item
class_name Returnable

var size: int

func _init(_item_name: String, _description: String, _value: float, _texture_path: String, _size: int) -> void:
	size = _size
	returnable = true
	super._init(_item_name, _description, _value, _texture_path)
