extends Node

var player: Player
var camera: Camera
var placeholder_texture: String = "res://Assets/Media/Images/placeholder.png"

# Temporary. In the end product, item data will be fetched from the server, and textures will be either also fetched from server, or referenced locally.
var ItemsList: Dictionary = {
	# Default
	"trash": Item.new("Trash" , 0.0, placeholder_texture),
	# Returnables
	"bottle": Returnable.new("Bottle", 0.2, placeholder_texture, 1),
	"can": Returnable.new("Can", 0.15, placeholder_texture, 1),
	"bottle_big": Returnable.new("Big Bottle", 0.4, placeholder_texture, 2),
	"bottle_liquor": Returnable.new("Liquor Bottle", 0.1, placeholder_texture, 2),
	"bottle_wine": Returnable.new("Wine Bottle", 0.1, placeholder_texture, 1),
	# Consumables
		# Mild
	"drink_red": Consumable.new("Hobo Delight", 0.9, placeholder_texture, 4.2, 5),
	"drink_copper": Consumable.new("Can O' Copper", 1.0, placeholder_texture, 4.3, 4),
	"drink_blue": Consumable.new("Friska & Njutbara", 1.15, placeholder_texture, 4.5, 6),
	"drink_teddy": Consumable.new("Teddy Malt Smoothie", 2.0, placeholder_texture, 5.3, 10),
	"drink_piss": Consumable.new("Reindeer Piss", 2.1, placeholder_texture, 5.2, 10),
	"drink_kangaroo": Consumable.new("Kangaroo's Choice", 1.6, placeholder_texture, 4.5, 10),
	"drink_hipster": Consumable.new("Artsy Drink", 4.5 , placeholder_texture, 5.0, 25),
		# Medium
	"wine_white": Consumable.new("White Stuff", 12.5, placeholder_texture, 12.0, 100),
	"wine_red": Consumable.new("Headache Malbec", 10.0, placeholder_texture, 12.5, 100),
	"liqueur_bitter": Consumable.new("The Ol' Bittersweet", 14.5, placeholder_texture, 21.0, 175),
	"liqueur_ruby": Consumable.new("Rubinrot", 14.5, placeholder_texture, 21.0, 175),
		# High
	"liquor_clear": Consumable.new("White-Water's Ear", 20.0, placeholder_texture, 38.0, 400),
	"liquor_german": Consumable.new("German Sunrise", 24.0, placeholder_texture, 35.0, 500),
	"liquor_pirate": Consumable.new("Yarrr-Liquid", 30.0, placeholder_texture, 40.0, 750),
	"liquor_oak": Consumable.new("Scottish Malt Juice", 55.0, placeholder_texture, 40.0, 1150),
	"liquor_herbal": Consumable.new("The Green Fairy", 60.0, placeholder_texture, 80.0, 1750),
		# Non-Potent
	"soda_hippo": Consumable.new("Hippo Soda Pop", 2.5, placeholder_texture, 0.0, 20),
	"soda_mystery": Consumable.new("Big Bottle of Weird Coloured Stuff", 3.0, placeholder_texture, 0.0, 30 ), # Randomize score
	"soda_cola": Consumable.new("Cola", 2.5, placeholder_texture, 0.0, 15),
	"soda_yellow": Consumable.new("Jeffe", 3.0, placeholder_texture, 0.0, 20)
}

func Initialize() -> void:
	player = get_node("../Game/Map/TileMap/Player")
	camera = get_node("../Game/Map/Camera")
	camera.Initialize(player)
	player.Initialize()
	UIControl.HideLoginScreen()

func GetItem(item_name: String) -> Item:
	return ItemsList.get(item_name, ItemsList.get("default"))
