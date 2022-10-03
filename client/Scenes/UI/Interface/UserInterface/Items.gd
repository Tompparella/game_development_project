extends Control
class_name ItemsView

@onready var items_container: HBoxContainer = $Foreground/Margin/ItemsBox
var packed_item = preload("res://Scenes/UI/Interface/UserInterface/Item.tscn")

func AddItem(item: Item) -> void:
	var instance = packed_item.instantiate()
	items_container.add_child(instance)
	instance.Initialize(item)

func RemoveItem(item: Item) -> void:
	# TODO: Add item removal logic
	print(item)
