extends Control
class_name ShopModal

@onready var items_view: HFlowContainer = $NinePatchRect/HSplitContainer/Panel/Items
@onready var item_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/ItemName
@onready var description_label: RichTextLabel = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/Description
@onready var vibe_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Vibe
@onready var flex_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Flex
@onready var price_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Price
@onready var stock_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer2/Stock

var packed_item = preload("res://Scenes/UI/Interface/UserInterface/Item.tscn")

var player: Player
var shop: Shop
var selected_item: Item

func Initialize(_player: Player):
	player = _player

func SetView() -> void:
	if (shop != null && shop.inventory != null):
		for entry in shop.inventory:
			AddItem(entry)
			

func AddItem(item: Item) -> void:
	var instance = packed_item.instantiate()
	items_view.add_child(instance)
	instance.connect("pressed", instance.ItemSelected)
	instance.connect("item_selected", SelectItem)
	instance.Initialize(item)

func SelectItem(item: Item) -> void:
	selected_item = item
	item_label.text = item.item_name
	description_label.text = item.description
	price_label.text = "Price\n%s" % str(item.value)
	stock_label.text = "Stock\n%sx" % str(shop.inventory[item])
	if item is Consumable:
		vibe_label.text = "Vibe\n%s" % str(item.potency)
		flex_label.text = "Flex\n%s" % str(item.score)

func Open(_shop: Shop):
	shop = _shop
	SetView()
	visible = true

func Close():
	visible = false
	selected_item = null
	item_label.text = ""
	description_label.text = ""
	price_label.text = ""
	stock_label.text = ""
	vibe_label.text = ""
	flex_label.text = ""
	# Empty the shop variable
	var items: Array = items_view.get_children()
	for entry in items:
		entry.queue_free()
	shop = null

func _Buy_Pressed() -> void:
	if !selected_item:
		description_label.text = "Select an item first!"
		return
	var result: int = shop.Buy(selected_item, player)
	if result != 1:
		description_label.text = "Sorry! There's no stock left. Come check later!" if result == 2 else "You can't buy that! Come back with more money and/or inventory space"
	else:
		stock_label.text = "Stock\n%sx" % str(shop.inventory[selected_item])
