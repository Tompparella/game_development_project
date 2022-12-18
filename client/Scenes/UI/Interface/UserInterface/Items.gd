extends Control
class_name ItemsView

signal item_unselected(emitter: Node)

@onready var items_container: HBoxContainer = $Foreground/Margin/ItemsBox
@onready var use_progress: UseProgress = $Foreground/Margin/UseProgress
var packed_item = preload("res://Scenes/UI/Interface/UserInterface/Item.tscn")

var selected_item: ItemEntry

# TODO: Initialization based on player values
func Initialize(player: Player) -> void:
	var items = items_container.get_children()
	for entry in items:
		entry.queue_free()
	selected_item = null
	player.update_use_progress.connect(UpdateUseProgress)

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
	var item_index: int
	if selected_item.item == item && items.has(selected_item):
		item_index = items.find(selected_item)
		selected_item.queue_free()
		items.erase(selected_item)
	else:
		for entry in items:
			if (entry is ItemEntry && entry.item == item):
				item_index = items.find(entry)
				entry.queue_free()
				items.erase(entry)
				break
	if items.size() > 0:
		if items.size() == item_index:
			items[items.size()-1].ItemSelected()
		else:
			items[item_index].ItemSelected()
	else:
		selected_item = null

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

func UpdateUseProgress(wait_time: float) -> void:
	if wait_time != -1.0:
		StartUseProgress(wait_time)
	else:
		StopUseProgress()

func StartUseProgress(wait_time: float) -> void:
	if selected_item:
		use_progress.global_position = selected_item.global_position
	use_progress.StartUseProgress(wait_time)

func StopUseProgress() -> void:
	use_progress.StopUseProgress()
