extends Obstacle
class_name Surrounding

signal update_position(node: Node2D)
@export var item_name: String = ""

var item: Item

func _ready() -> void:
	update_position.connect(GameManager.UpdateSurrounding)
	var area: SurroundingArea = get_node("Area2d")
	area.interaction.connect(Interact)
	if !item_name.is_empty():
		item = GameItems.GetItem(item_name)
	if item is Returnable:
		area.auto_pickup = true
	if item:
		texture = item.texture

func Initialize(_item: Item = null, _texture: String = "") -> void:
	item = _item
	texture = _texture

func Interact(_player: Player) -> void:
	pass
