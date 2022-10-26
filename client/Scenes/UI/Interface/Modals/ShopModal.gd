extends Control
class_name ShopModal

@onready var items_view: HFlowContainer = $NinePatchRect/HSplitContainer/Panel/Items
@onready var item_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/ItemName
@onready var description_label: RichTextLabel = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/Description
@onready var vibe_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Vibe
@onready var flex_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Flex
@onready var price_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer/Price
@onready var stock_label: Label = $NinePatchRect/HSplitContainer/Panel2/VBoxContainer/HBoxContainer2/Stock

signal item_unselected(emitter: Node)

var packed_item = preload("res://Scenes/UI/Interface/UserInterface/Item.tscn")

var shop_id: String
var player: Player
var inventory: Dictionary
var selected_item: Item

func Initialize(_player: Player):
	player = _player

func SetView() -> void:
	if (inventory != null):
		for entry in inventory:
			AddItem(entry)

func AddItem(item_id: String) -> void:
	var instance = packed_item.instantiate()
	items_view.add_child(instance)
	instance.connect("pressed", instance.ItemSelected)
	instance.connect("item_selected", SelectItem)
	instance.Initialize(GameManager.GetItem(item_id))

func SelectItem(item_entry: ItemEntry) -> void:
	if item_entry.item != selected_item:
		emit_signal('item_unselected', self)
		connect('item_unselected', item_entry.UnSelected)
		selected_item = item_entry.item
		item_label.text = selected_item.item_name
		description_label.text = selected_item.description
		price_label.text = "Price\n%s" % str(selected_item.value)
		stock_label.text = "Stock\n%sx" % str(inventory[selected_item.item_id])
		if selected_item is Consumable:
			vibe_label.text = "Vibe\n%s" % str(selected_item.vibe)
			flex_label.text = "Flex\n%s" % str(selected_item.flex)

func UpdateInventory(updated_items: Dictionary) -> void:
	for entry in updated_items:
		inventory[entry] = updated_items[entry]
		if selected_item != null && entry == selected_item.item_id:
			stock_label.text = "Stock\n%sx" % str(updated_items[entry])
	

func Open(shop_data: Dictionary):
	inventory = shop_data["inventory"]
	shop_id = shop_data["shop_id"]
	SetView()
	visible = true

func Close():
	emit_signal('item_unselected', self)
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
	inventory = {}

func _Buy_Pressed() -> void:
	if (!selected_item || shop_id.is_empty()):
		description_label.text = "Select an item first!"
		return
	elif inventory[selected_item.item_id] == 0:
		description_label.text = "Sorry! We're sold out!"
	elif selected_item.value > player.GetCurrency():
		description_label.text = "Hey! You don't have money for that!"
	else:
		GameManager.BuyItem(selected_item.item_id, shop_id)
	# TODO: Buy logic here
	#var result: int = shop.Buy(selected_item, player)
	#if result != 1:
	#	description_label.text = "Sorry! There's no stock left. Come check later!" if result == 2 else "You can't buy that! Come back with more money and/or inventory space"
	#else:
	#	stock_label.text = "Stock\n%sx" % str(shop.inventory[selected_item])
