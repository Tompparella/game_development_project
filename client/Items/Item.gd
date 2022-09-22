extends RefCounted
class_name Item

var texture: String
var value: float
var consumable: bool = false
var returnable: bool = false
var itemName: String = ""

	
func _init(_itemName: String ,_value: float, _texture: String) -> void:
	itemName = _itemName
	texture = _texture
	value = _value
