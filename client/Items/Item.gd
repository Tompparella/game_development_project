extends RefCounted
class_name Item

var texture: String
var value: float
var consumable: bool = false
var returnable: bool = false

	
func _init(_value: float, _texture: String) -> void:
	texture = _texture
	value = _value
