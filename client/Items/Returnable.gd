extends Item
class_name Returnable

var size: int

func _init(_itemName: String, _value: float, _texture: String, _size: int) -> void:
	itemName = _itemName
	size = _size
	value = _value
	texture = _texture
	returnable = true
