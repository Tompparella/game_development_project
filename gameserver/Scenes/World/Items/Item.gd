extends RefCounted
class_name Item

var texture: String
var value: float
var consumable: bool = false
var returnable: bool = false
var item_name: String = ""
var description: String = ""

	
func _init(_item_name: String, _description: String ,_value: float, _texture: String) -> void:
	texture = _texture
	item_name = _item_name
	description = _description
	value = _value

func Use(_player: Player) -> void:
	return
