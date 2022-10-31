extends Node

const VIBE_TIMEOUT_TIME: float = 10.0
# The amount of game time ticks required to trigger a re-stock for shops
const SHOP_RESTOCK_TICKS: int = 10

var surroundings: Node2D
var npcs: Node2D
var players_container: Node2D
var players: Dictionary = {}
var shops: Dictionary = {}
var game_timer: Timer
var placeholder_texture: String = "res://Assets/Items/Can.png"
var player_scene: PackedScene = load("res://Scenes/World/Characters/Player.tscn")
var pickable_scene: PackedScene = load("res://Scenes/World/Environment/Assets/Pickable.tscn")
var returnables_on_map: int = 0
var returnables_per_player: int = 10
var vibe_tick: float = -1.5
var vibe_tick_limit: float = 25.0
var current_restock_ticks: int = 0
# Run server sync only if GameManager has successfully initialized the game world on the client
var initialized: bool = false

# Temporary. In the end product, item data will be fetched from the server, and textures will be either also fetched from server, or referenced locally.
var ItemsList: Dictionary = {
	# Default
	"trash": Item.new("trash", "Trash", "Why did I pick this up?" , 0.0, placeholder_texture),
	# Returnables
	"bottle": Returnable.new("bottle", "Bottle", "Ah, deposit bottle. The backbone of civilizations", 0.2, placeholder_texture, 1),
	"can": Returnable.new("can", "Can", "Cool, it's not wrinkled.. that bad", 0.15, "res://Assets/Items/Can.png", 1),
	"bottle_big": Returnable.new("bottle_big", "Big Bottle", "The lord truly is bountiful with their blessings!", 0.4, placeholder_texture, 2),
	"bottle_liquor": Returnable.new("bottle_liquor", "Liquor Bottle", "A ghost of memories past", 0.1, placeholder_texture, 2),
	"bottle_wine": Returnable.new("bottle_wine", "Wine Bottle", "I can still feel the headache", 0.1, placeholder_texture, 2),
	# Consumables
		# Mild
	"drink_red": Consumable.new("drink_red", "Hobo Delight", "A drink deemed worthy only for the true professionals of the arts", 0.9, placeholder_texture, 4.2, 5),
	"drink_copper": Consumable.new("drink_copper", "Can O' Copper", "The ol' reliable!", 1.0, "res://Assets/Items/Copper.png", 4.3, 4),
	"drink_blue": Consumable.new("drink_blue", "Friska & Njutbara", "The cheapest option from the more expensive shop. What's the point?", 1.15, placeholder_texture, 4.5, 6),
	"drink_teddy": Consumable.new("drink_teddy", "Teddy Malt Smoothie", "Kindles feelings of happiness in most students", 2.0, placeholder_texture, 5.3, 10),
	"drink_piss": Consumable.new("drink_piss", "Reindeer Piss", "Stories are told that it actually once tasted pretty okay", 2.1, placeholder_texture, 5.2, 10),
	"drink_kangaroo": Consumable.new("drink_kangaroo", "Kangaroo's Choice", "Oi' cunt! You're few stubbies short a' six-pac", 1.6, placeholder_texture, 4.5, 10),
	"drink_hipster": Consumable.new("drink_hipster", "Artsy Drink", "Tis' the one that's more expensive than most, but you'll still buy it 'cause of the pretty label", 4.5 , placeholder_texture, 5.0, 25),
		# Medium
	"wine_white": Consumable.new("wine_white", "White Stuff", "Tastes like grapes and bad decisions", 12.5, placeholder_texture, 12.0, 100),
	"wine_red": Consumable.new("wine_red", "Headache Malbec", "I know you're trying to look fancy, but this one's always a mistake", 10.0, placeholder_texture, 12.5, 100),
	"liqueur_bitter": Consumable.new("liqueur_bitter", "The Ol' Bittersweet", "Some people say to never touch this stuff. Some people say it's drinkable if you mix it with orange juice. Some people drink it raw. You stay away from the last kind of people", 14.5, placeholder_texture, 21.0, 175),
	"liqueur_ruby": Consumable.new("liqueur_ruby", "Rubinrot", "Its ruby waves beckon you with their froth. Let the moot begin", 14.5, placeholder_texture, 21.0, 175),
		# High
	"liquor_clear": Consumable.new("liquor_clear", "White-Water's Ear", "It's clear, so it counts as drinking water, right?", 20.0, placeholder_texture, 38.0, 400),
	"liquor_german": Consumable.new("liquor_german", "German Sunrise", "It's made with herbs, so it's basically a salad", 24.0, placeholder_texture, 35.0, 500),
	"liquor_pirate": Consumable.new("liquor_pirate", "Yarrr-Liquid", "It's told that if you drink the whole bottle in one go, you'll actually learn to speak pirate", 30.0, placeholder_texture, 40.0, 750),
	"liquor_scottish": Consumable.new("liquor_scottish", "Scottish Malt Juice", "For the last time, it's not 'getting wasted', it's called 'tasting', and it's a fine scottish label!", 55.0, placeholder_texture, 40.0, 1150),
	"liquor_herbal": Consumable.new("liquor_herbal", "The Green Fairy", "It's told that people have gone insane because of this stuff. It's been banned multiple times in history due to it generally not being very good for you. But drinking the whole bottle in four chugs? You do you buddy", 60.0, placeholder_texture, 80.0, 1750),
		# Non-Potent
	"soda_hippo": Consumable.new("soda_hippo", "Hippo Soda Pop", "Forest berry soda with your favorite white hippos on the label! What's not to like?", 2.5, placeholder_texture, 0.0, 20),
	"soda_mystery": Consumable.new("soda_mystery", "Big Bottle of Weird Coloured Stuff", "I think the shopkeeper just had this lying in some hole for the last decade. Wonder how it'll taste like", 3.0, placeholder_texture, 0.0, 30 ), # Randomize flex
	"soda_cola": Consumable.new("soda_cola", "Cola", "Good old cola", 2.5, placeholder_texture, 0.0, 15),
	"soda_yellow": Consumable.new("soda_yellow", "Jeffe", "My name a' Jeffe", 3.0, placeholder_texture, 0.0, 20)
}
var TasksList: Dictionary = {
	"test": Task.new("This is a test task", {"items": {"liquor_clear": 1}, "goals": {}}, {"items": {}, "currency": 10.0}),
}

func Initialize() -> void:
	surroundings = get_node("../Server/Map/TileMap/Surroundings")
	for entry in surroundings.get_children():
		if entry.is_in_group("shop"):
			shops[entry.name] = entry
	npcs = get_node("../Server/Map/TileMap/Npcs")
	players_container = get_node("../Server/Map/TileMap/Players")
	SpawnReturnables(returnables_per_player)
	CreateGameTimer()
	initialized = true

func CreateGameTimer() -> void:
	game_timer = Timer.new()
	game_timer.one_shot = false
	game_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	game_timer.wait_time = VIBE_TIMEOUT_TIME
	game_timer.timeout.connect(_Timer_Timeout)
	add_child(game_timer)
	game_timer.start()

func GetItem(item_id: String) -> Item:
	return ItemsList.get(item_id, ItemsList.get("default"))

func GetTask(task_id: String) -> Task:
	return TasksList.get(task_id, TasksList.get("default"))

# TODO: This is a placeholder. Shop inventories are supposed to be returned depending on shop brand.
func GetShopInventory() -> Array[String]:
	return [
		"drink_copper",
		"drink_teddy",
		"drink_kangaroo",
		"soda_hippo",
		"soda_cola",
		"soda_yellow",
	]

func FetchGameData(player_id: int) -> void:
	var game_data: Dictionary = {}
	var environment: Array = []
	var characters: Array = []
	var items_data: Array = []
	for entry in ItemsList:
		var item: Item = ItemsList[entry]
		var item_data = {
			"id": entry,
			"name": item.item_name,
			"description": item.description,
			"texture": item.texture,
			"value": item.value,
			"vibe": item.vibe,
			"flex": item.flex,
			"size": item.size,
			"type": "consumable" if item.consumable else "returnable" if item.returnable else "default",
		}
		items_data.append(item_data)
	game_data["items"] = items_data
	for entry in surroundings.get_children():
		var position: Vector2 = entry.position
		var type: String = ""
		if entry.is_in_group("surrounding"):
			type = "surrounding"
		elif entry.is_in_group("interactable"):
			type = "interactable"
		elif entry.is_in_group("shop"):
			type = "shop"
		elif entry.is_in_group("obstacle"):
			type = "obstacle"
		elif entry.is_in_group("pickable"):
			type = "pickable"
		elif entry.is_in_group("returnmachine"):
			type = "returnmachine"
		environment.append({"id": entry.get_instance_id(), "position": position, "texture": entry.texture, "type": type})
	game_data["environment"] = environment
	for entry in npcs.get_children():
		var position: Vector2 = entry.position
		var type: String = ""
		if entry.is_in_group("hobo"):
			type = "hobo"
		characters.append({"id": entry.get_instance_id(), "position": position, "texture": entry.texture, "type": type})
	game_data["characters"] = characters
	GameServer.ReturnGameData(game_data, player_id)

func SpawnReturnables(returnable_amount: int = 5 * (players.size() + 1)) -> Array:
	if returnables_on_map >= (returnables_per_player * (players.size() + 1)):
		return []
	var returnables: Dictionary = { 1: ItemsList["can"], 2: ItemsList["bottle"], 3: ItemsList["bottle_big"], 4: ItemsList["bottle_liquor"], 5: ItemsList["bottle_wine"] }
	var returnable_weights: Array[int] = [1,1,1,1,1,2,2,2,3,4,5]
	var item_data: Array = []
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
		item_data.append({"id": pickable.get_instance_id(), "position": pickable.position, "texture": pickable.texture, "type": "pickable"})
	return item_data

# Gameplay management functions

func UpdateSurrounding(entry: Node2D) -> void:
	GameServer.surrounding_states_collection[entry.get_instance_id()] = {
		"position": entry.global_position
	}

## Shop functions

func OpenShop(player_id: String, shop_data: Dictionary) -> void:
	GameServer.OpenShop(player_id.to_int(), shop_data)

func CloseShop(player_id: String) -> void:
	GameServer.CloseShop(player_id.to_int())

func UpdateShopInventory(shop_players: Array[Player], updated_items: Dictionary) -> void:
	for entry in shop_players:
		GameServer.UpdateShopInventory(entry.name, updated_items)

func RestockShopInventories() -> void:
	for entry in shops:
		shops[entry].Restock(players.size())

func PlayerBuyItem(player_id: int, item_id: String, shop_id: String) -> void:
	var shop: Shop = shops.get(shop_id)
	var player: Player = players[player_id]
	var item: Item = ItemsList[item_id]
	if shop != null && item != null && player != null:
		shop.Buy(item, player)
	else:
		# TODO: Handle bad buy action
		print("Kakke")

## Player functions

func MovePlayer(player_id: int, new_position: Vector2) -> void:
	players[player_id].global_position = new_position

func PlayerInteract(player_id: int) -> void:
	players[player_id].Interact()

func PlayerAddItem(player_id: String, item: Item) -> void:
	var item_id: String = ItemsList.find_key(item)
	if item_id:
		GameServer.PlayerAddItem(player_id.to_int(), item_id)

func PlayerUseItem(player_id: int, item_id: String) -> void:
	if ItemsList.has(item_id) && players.has(player_id):
		players[player_id].UseItem(ItemsList[item_id])

func PlayerRemoveItem(player_id: String, item: Item) -> void:
	var item_id: String = ItemsList.find_key(item)
	if item_id:
		GameServer.PlayerRemoveItem(player_id.to_int(), item_id)

func PlayerUpdateStats(player_id: String, vibe: float, flex: int) -> void:
	var player_stats: Dictionary = {"id": player_id, "vibe": vibe, "flex": flex}
	GameServer.PlayerUpdateStats(player_stats)

func PlayerChangeCurrency(player_id: String, currency: float) -> void:
	GameServer.PlayerChangeCurrency(player_id.to_int(), currency)

func PlayerRecycledItems(player_id: String, recycled_items: Array[Item], returnable_size: int) -> void:
	var item_ids: Array[String] = []
	for entry in recycled_items:
		var item_id: String = ItemsList.find_key(entry)
		if item_id:
			item_ids.append(item_id)
	GameServer.PlayerRecycledItems(player_id.to_int(), item_ids, returnable_size)

func SpawnNewPlayer(player_id: int, spawn_location: Vector2) -> void:
	# TODO: Add player specific visual things to show on the clientside
	var new_player: Player = player_scene.instantiate()
	new_player.position = spawn_location
	new_player.name = str(player_id)
	players_container.add_child(new_player)
	players[player_id] = new_player
	new_player.item_added.connect(PlayerAddItem)
	new_player.item_removed.connect(PlayerRemoveItem)
	new_player.currency_changed.connect(PlayerChangeCurrency)
	new_player.items_recycled.connect(PlayerRecycledItems)
	new_player.game_over.connect(PlayerGameOver)
	# TODO: Connect the rest of player signals
	# TODO: Update game_timer timeout to a function that updates vibe for all players at the same time
	print("Player %s spawned" % str(player_id))
	GameServer.SpawnNewPlayer(player_id, spawn_location)

func DespawnPlayer(player_id: int, notify_player: bool = true) -> void:
	if players_container.has_node(str(player_id)):
		if notify_player:
			GameServer.PlayerDespawned(player_id)
		var despawned_player: Player = players_container.get_node(str(player_id))
		# We need to await for a time in order to wait for the world state to empty its references to the despawned player.
		# Without this, the player would despawn for a few milliseconds before being spawned again in the next world state update.
		await get_tree().create_timer(0.2).timeout
		GameServer.DespawnPlayer(player_id)
		players.erase(player_id)
		despawned_player.queue_free()
		print("Player %s despawned" % str(player_id))

func PlayerGameOver(player_id: String) -> void:
	DespawnPlayer(player_id.to_int())

func _Timer_Timeout() -> void:
	current_restock_ticks += 1
	var game_data: Dictionary = {}
	if current_restock_ticks >= SHOP_RESTOCK_TICKS:
		current_restock_ticks = 0
		RestockShopInventories()
		print("Shop inventories restocked")
	game_data["returnable_data"] = SpawnReturnables()
	var stats_data: Array = []
	for entry in players:
		var player = players.get(entry)
		if player != null:
			var vibe_reduction: float = vibe_tick
			if player.GetVibe() > vibe_tick_limit:
				vibe_reduction = (player.GetVibe() / vibe_tick_limit) * vibe_tick
			var new_vibe: float = player.AddVibe(vibe_reduction, false)
			if new_vibe > 0:
				stats_data.append({"id": str(player.name), "vibe": new_vibe})
	game_data["stats_data"] = stats_data
	GameServer.GameTimerTimeout(game_data)

func _Returnable_Picked() -> void:
	returnables_on_map -= 1
