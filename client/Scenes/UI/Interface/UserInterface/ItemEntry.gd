extends Button
class_name ItemEntry

signal item_selected(_item_entry: ItemEntry)
signal item_highlighted(_item: Item)

@onready var texture: TextureRect = $TextureRect

var item: Item

func Initialize(_item: Item) -> void:
	item = _item
	texture.texture = item.texture

func ItemSelected() -> void:
	texture.scale = Vector2(1.2, 1.2)
	# This is to disable space from triggering further presses
	emit_signal("item_selected", self)

func UnSelected(emitter: Node) -> void:
	if emitter.is_connected("item_unselected", UnSelected):
		emitter.disconnect("item_unselected", UnSelected)
	texture.scale = Vector2(1, 1)

func _On_Mouse_Enter() -> void:
	emit_signal("item_highlighted", item)
