extends RefCounted
class_name Item

var texture: String
var value: float
var vibe: float
var flex: int
var size: int
var consumable: bool = false
var returnable: bool = false
var item_id: String = ""
var item_name: String = ""
var description: String = ""

func _init(_item_id: String, _item_name: String, _description: String ,_value: float, _texture: String) -> void:
	texture = _texture
	item_id = _item_id
	item_name = _item_name
	description = _description
	value = _value

func Use(_player: Player) -> void:
	return
