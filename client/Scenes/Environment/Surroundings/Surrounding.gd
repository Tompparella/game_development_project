extends Obstacle
class_name Surrounding

@export var item_name: String = ""

var item: Item

func _ready() -> void:
	#var area: SurroundingArea = get_node("Area2d")
	#area.connect("interaction", Interact)
	if !item_name.is_empty():
		item = GameManager.GetItem(item_name)
		if item && item.texture:
			texture = item.texture
			$Sprite.set_texture(texture)
	#if item is Returnable:
	#	area.auto_pickup = true

func Initialize(_texture: String, _position: Vector2, _item: Item = null) -> void:
	item = _item
	if item && item.texture:
		texture = item.texture
	super.Initialize(_texture, _position)

func Interact(_player: Player) -> void:
	pass

func Remove() -> void:
	queue_free()
