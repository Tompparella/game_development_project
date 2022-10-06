extends Control
class_name ItemsView

signal item_unselected(emitter: Node)

@onready var items_container: HBoxContainer = $Foreground/Margin/ItemsBox
var packed_item = preload("res://Scenes/UI/Interface/UserInterface/Item.tscn")

var selected_item: ItemEntry

func AddItem(item: Item) -> void:
	var instance: ItemEntry = packed_item.instantiate()
	items_container.add_child(instance)
	instance.connect("pressed", instance.ItemSelected)
	instance.connect("item_selected", SelectItem)
	instance.connect("item_highlighted", ShowItemHint)
	instance.connect("mouse_exited", HideItemHint)
	instance.Initialize(item)
	if !selected_item:
		instance.ItemSelected()

func RemoveItem(item: Item) -> void:
	var items = items_container.get_children()
	if selected_item.item == item && items.has(selected_item):
		selected_item.queue_free()
		selected_item = null
	else:
		for entry in items:
			if (entry is ItemEntry && entry.item == item):
				entry.queue_free()
				selected_item = null
	NextItem()

func SelectItem(item_entry: ItemEntry) -> void:
	if item_entry != selected_item:
		selected_item = item_entry
		emit_signal('item_unselected', self)
		connect('item_unselected', item_entry.UnSelected)

func GetSelectedItem() -> Item:
	if (selected_item && selected_item.item):
		return selected_item.item
	else:
		return null

func NextItem() -> void:
	var items: Array[Node] = items_container.get_children()
	if items.size() < 2:
		return
	var index: int = 0
	if selected_item:
		index = items.find(selected_item)
	if index == -1:
		return
	index += 1
	if index < items.size():
		items[index].ItemSelected()
	else:
		items.front().ItemSelected()

func PreviousItem() -> void:
	var items: Array[Node] = items_container.get_children()
	if items.size() < 2:
		return
	var index: int = 0
	if selected_item:
		index = items.find(selected_item)
	if index == -1:
		return
	elif index == 0:
		items.back().ItemSelected()
	else:
		items[index-1].ItemSelected()

func ShowItemHint(item: Item) -> void:
	if item:
		UIControl.ShowItemHint(item)

func HideItemHint() -> void:
	UIControl.HideItemHint()
