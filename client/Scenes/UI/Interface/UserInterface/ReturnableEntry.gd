extends Control
class_name ReturnableEntry

signal item_highlighted(_returnable: Returnable)

@onready var texture: TextureRect = $Texture

var returnable: Returnable

func Initialize(_returnable: Returnable) -> void:
	returnable = _returnable
	texture.texture = returnable.texture

func _On_Mouse_Enter() -> void:
	emit_signal("item_highlighted", returnable)
