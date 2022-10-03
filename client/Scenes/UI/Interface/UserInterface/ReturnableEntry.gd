extends Control
class_name ReturnableEntry

@onready var texture: TextureRect = $Texture

var returnable: Returnable

func Initialize(_returnable: Returnable) -> void:
	returnable = _returnable
	texture.texture = returnable.texture
