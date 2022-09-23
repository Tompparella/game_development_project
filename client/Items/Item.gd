extends RefCounted
class_name Item

var texture: Texture2D
var value: float
var consumable: bool = false
var returnable: bool = false
var item_name: String = ""

	
func _init(_item_name: String ,_value: float, _texture_path: String) -> void:
	texture = load(_texture_path)
	item_name = _item_name
	value = _value
