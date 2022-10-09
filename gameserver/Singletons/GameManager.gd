extends Node

const VIBE_TIMEOUT_TIME: float = 4.0

var surroundings: Node2D
var players_container: Node2D
var players: Dictionary = {}
var game_timer: Timer
var placeholder_texture: String = "res://Assets/Items/Can.png"
var player_scene: PackedScene = load("res://Scenes/World/Characters/Player.tscn")
var pickable_scene: PackedScene = load("res://Scenes/World/Environment/Assets/Pickable.tscn")
var returnables_on_map: int = 0
var returnables_per_player: int = 75
# Run server sync only if GameManager has successfully initialized the game world on the client
var initialized: bool = false

# Temporary. In the end product, item data will be fetched from the server, and textures will be either also fetched from server, or referenced locally.
var ItemsList: Dictionary = {
	# Default
	"trash": Item.new("Trash", "Why did I pick this up?" , 0.0, placeholder_texture),
	# Returnables
	"bottle": Returnable.new("Bottle", "Ah, deposit bottle. The backbone of civilizations", 0.2, placeholder_texture, 1),
	"can": Returnable.new("Can", "Cool, it's not wrinkled.. that bad", 0.15, "res://Assets/Items/Can.png", 1),
	"bottle_big": Returnable.new("Big Bottle", "The lord truly is bountiful with their blessings!", 0.4, placeholder_texture, 2),
	"bottle_liquor": Returnable.new("Liquor Bottle", "A ghost of memories past", 0.1, placeholder_texture, 2),
	"bottle_wine": Returnable.new("Wine Bottle", "I can still feel the headache", 0.1, placeholder_texture, 2),
	# Consumables
		# Mild
	"drink_red": Consumable.new("Hobo Delight", "A drink deemed worthy only for the true professionals of the arts", 0.9, placeholder_texture, 4.2, 5),
	"drink_copper": Consumable.new("Can O' Copper", "The ol' reliable!", 1.0, "res://Assets/Items/Copper.png", 4.3, 4),
	"drink_blue": Consumable.new("Friska & Njutbara", "The cheapest option from the more expensive shop. What's the point?", 1.15, placeholder_texture, 4.5, 6),
	"drink_teddy": Consumable.new("Teddy Malt Smoothie", "Kindles feelings of happiness in most students", 2.0, placeholder_texture, 5.3, 10),
	"drink_piss": Consumable.new("Reindeer Piss", "Stories are told that it actually once tasted pretty okay", 2.1, placeholder_texture, 5.2, 10),
	"drink_kangaroo": Consumable.new("Kangaroo's Choice", "Oi' cunt! You're few stubbies short a' six-pac", 1.6, placeholder_texture, 4.5, 10),
	"drink_hipster": Consumable.new("Artsy Drink", "Tis' the one that's more expensive than most, but you'll still buy it 'cause of the pretty label", 4.5 , placeholder_texture, 5.0, 25),
		# Medium
	"wine_white": Consumable.new("White Stuff", "Tastes like grapes and bad decisions", 12.5, placeholder_texture, 12.0, 100),
	"wine_red": Consumable.new("Headache Malbec", "I know you're trying to look fancy, but this one's always a mistake", 10.0, placeholder_texture, 12.5, 100),
	"liqueur_bitter": Consumable.new("The Ol' Bittersweet", "Some people say to never touch this stuff. Some people say it's drinkable if you mix it with orange juice. Some people drink it raw. You stay away from the last kind of people", 14.5, placeholder_texture, 21.0, 175),
	"liqueur_ruby": Consumable.new("Rubinrot", "Its ruby waves beckon you with their froth. Let the moot begin", 14.5, placeholder_texture, 21.0, 175),
		# High
	"liquor_clear": Consumable.new("White-Water's Ear", "It's clear, so it counts as drinking water, right?", 20.0, placeholder_texture, 38.0, 400),
	"liquor_german": Consumable.new("German Sunrise", "It's made with herbs, so it's basically a salad", 24.0, placeholder_texture, 35.0, 500),
	"liquor_pirate": Consumable.new("Yarrr-Liquid", "It's told that if you drink the whole bottle in one go, you'll actually learn to speak pirate", 30.0, placeholder_texture, 40.0, 750),
	"liquor_scottish": Consumable.new("Scottish Malt Juice", "For the last time, it's not 'getting wasted', it's called 'tasting', and it's a fine scottish label!", 55.0, placeholder_texture, 40.0, 1150),
	"liquor_herbal": Consumable.new("The Green Fairy", "It's told that people have gone insane because of this stuff. It's been banned multiple times in history due to it generally not being very good for you. But drinking the whole bottle in four chugs? You do you buddy", 60.0, placeholder_texture, 80.0, 1750),
		# Non-Potent
	"soda_hippo": Consumable.new("Hippo Soda Pop", "Forest berry soda with your favorite white hippos on the label! What's not to like?", 2.5, placeholder_texture, 0.0, 20),
	"soda_mystery": Consumable.new("Big Bottle of Weird Coloured Stuff", "I think the shopkeeper just had this lying in some hole for the last decade. Wonder how it'll taste like", 3.0, placeholder_texture, 0.0, 30 ), # Randomize flex
	"soda_cola": Consumable.new("Cola", "Good old cola", 2.5, placeholder_texture, 0.0, 15),
	"soda_yellow": Consumable.new("Jeffe", "My name a' Jeffe", 3.0, placeholder_texture, 0.0, 20)
}

func Initialize() -> void:
	surroundings = get_node("../Server/Map/TileMap/Surroundings")
	players_container = get_node("../Server/Map/TileMap/Players")
	SpawnReturnables(returnables_per_player)
	CreateGameTimer()
	initialized = true

func CreateGameTimer() -> void:
	game_timer = Timer.new()
	game_timer.one_shot = false
	game_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	game_timer.wait_time = VIBE_TIMEOUT_TIME
	game_timer.timeout.connect(SpawnReturnables)
	add_child(game_timer)
	game_timer.start()

func SpawnReturnables(returnable_amount: int = 5) -> void:
	if returnables_on_map >= (returnables_per_player * players.size()):
		return
	var returnables: Dictionary = { 1: ItemsList["can"], 2: ItemsList["bottle"], 3: ItemsList["bottle_big"], 4: ItemsList["bottle_liquor"], 5: ItemsList["bottle_wine"] }
	var returnable_weights: Array[int] = [1,1,1,1,1,2,2,2,3,4,5]
	var screen_size = get_viewport().get_visible_rect().size
	for i in range(0, returnable_amount):
		# TODO: Rework pickable spawning to work on certain areas
		randomize()
		var pickable: Pickable = pickable_scene.instantiate()
		pickable.Initialize(returnables[returnable_weights[randi() % returnable_weights.size()]])
		pickable.position = Vector2(randf_range(-screen_size.x, screen_size.x), randf_range(-screen_size.y, screen_size.y))
		surroundings.add_child(pickable)
		pickable.returnable_picked.connect(_Returnable_Picked)
		returnables_on_map += 1
	print("Spawned returnables: %s" % returnables_on_map)

func GetItem(item_name: String) -> Item:
	return ItemsList.get(item_name, ItemsList.get("default"))

# TODO: This is a placeholder. Shop inventories are supposed to be returned depending on shop brand.
func GetShopInventory() -> Array[Item]:
	return [
		ItemsList["drink_copper"],
		ItemsList["drink_teddy"],
		ItemsList["drink_kangaroo"],
		ItemsList["soda_hippo"],
		ItemsList["soda_cola"],
		ItemsList["soda_yellow"],
	]

func _Returnable_Picked() -> void:
	returnables_on_map -= 1

# Gameplay management functions

func MovePlayer(player_id: int, new_position: Vector2) -> void:
	players[player_id].global_position = new_position

func SpawnNewPlayer(player_id: int, spawn_location: Vector2) -> void:
	# TODO: Add player specific visual things to show on the clientside
	var new_player: Player = player_scene.instantiate()
	new_player.position = spawn_location
	new_player.name = str(player_id)
	players_container.add_child(new_player)
	players[player_id] = new_player
	game_timer.timeout.connect(new_player._Vibe_Timeout)
	print("Player %s spawned" % str(player_id))
	GameServer.SpawnNewPlayer(player_id, spawn_location)

func DespawnPlayer(player_id: int) -> void:
	if players_container.has_node(str(player_id)):
		var despawned_player: Node = players_container.get_node(str(player_id))
		# We need to await for a time in order to wait for the world state to empty its references to the despawned player.
		# Without this, the player would despawn for a few milliseconds before being spawned again in the next world state update.
		await get_tree().create_timer(0.2).timeout
		players.erase(despawned_player)
		despawned_player.queue_free()
