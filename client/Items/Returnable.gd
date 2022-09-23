extends Item
class_name Returnable

var size: int

func _init(_item_name: String, _value: float, _texture_path: String, _size: int) -> void:
	item_name = _item_name
	size = _size
	value = _value
	texture = load(_texture_path)
	returnable = true
