extends Control
class_name ReturnablesView

@onready var returnable_container = $Container
var packed_returnable = preload("res://Scenes/UI/Interface/UserInterface/Returnable.tscn")
var returnable_entries: Dictionary = Dictionary()

# TODO: Initialization based on player  values
func Initialize(_player: Player) -> void:
	for entry in returnable_container.get_children():
		entry.queue_free()
	returnable_entries.clear()

func AddItem(returnable: Returnable) -> void:
	var instance: ReturnableEntry = packed_returnable.instantiate()
	returnable_container.add_child(instance)
	returnable_entries[instance.name] = returnable.item_name
	instance.Initialize(returnable)
	instance.connect("item_highlighted", ShowItemHint)
	instance.connect("mouse_exited", HideItemHint)

func RemoveItem(returnable: Returnable) -> void:
	var instance_name: String = returnable_entries.find_key(returnable.item_name)
	if (instance_name != null):
		returnable_entries.erase(instance_name)
		if returnable_container.has_node(instance_name):
			returnable_container.get_node(instance_name).queue_free()

func ShowItemHint(returnable: Returnable) -> void:
	if returnable:
		UIControl.ShowItemHint(returnable)

func HideItemHint() -> void:
	UIControl.HideItemHint()
