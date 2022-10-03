extends Control
class_name ItemName

@onready var texture: TextureRect = $Texture

var item: Item

func Initialize(_item: Item) -> void:
	item = _item
	texture.texture = item.texture
