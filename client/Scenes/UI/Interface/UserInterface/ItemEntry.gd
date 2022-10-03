extends TextureButton
class_name ItemEntry

signal item_selected(_item: Item)

var item: Item

func Initialize(_item: Item) -> void:
	item = _item
	texture_normal = item.texture

func ItemSelected() -> void:
	emit_signal("item_selected", item)
