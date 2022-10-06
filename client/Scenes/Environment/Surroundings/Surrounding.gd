extends Node2D
class_name Surrounding

@export var texture: Texture2D
@export var item_name: String = ""

var item: Item

func _ready() -> void:
	var area: SurroundingArea = get_node("Area2d")
	area.connect("interaction", Interact)
	if !item_name.is_empty():
		item = GameManager.GetItem(item_name)
		if !texture && item.texture:
			texture = item.texture
			$Sprite.set_texture(texture)
	if item is Returnable:
		area.auto_pickup = true

func Initialize(_item: Item = null, _texture: Texture2D = null) -> void:
	item = _item
	if _texture:
		texture = _texture
	elif item && item.texture:
		texture = item.texture
	if texture:
		$Sprite.set_texture(texture)

func Interact(_player: Player) -> void:
	pass

func Remove() -> void:
	queue_free()
