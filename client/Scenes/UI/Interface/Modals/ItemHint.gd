extends Control
class_name ItemHint

@onready var item_name: Label = $Panel/MarginContainer/VBoxContainer/ItemName
@onready var description: Label = $Panel/MarginContainer/VBoxContainer/Description
@onready var property1: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Property1
@onready var property2: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Property2 

func _ready() -> void:
	set_physics_process(false)

func SetFields(_item_name: String = "", _description: String = "", _property1: String = "", _property2: String = ""):
	item_name.text = _item_name
	description.text = _description
	property1.text = _property1
	property2.text = _property2

func Show(item: Item) -> void:
	if item is Returnable:
		SetFields(item.item_name, item.description, "Value: %s" % str(item.value), "Size: %s" % str(item.size))
	elif item is Consumable:
		SetFields(item.item_name, item.description, "Vibe: %s" % str(item.vibe), "Flex: %s" % str(item.flex))
	else:
		SetFields(item.item_name, item.description)
	set_physics_process(true)
	show()

func Hide() -> void:
	set_physics_process(false)
	SetFields()
	hide()

func _physics_process(_delta: float) -> void:
	position = get_global_mouse_position()
