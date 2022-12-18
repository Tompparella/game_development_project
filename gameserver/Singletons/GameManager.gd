extends Node

const VIBE_TIMEOUT_TIME: float = 10.0
# The amount of game time ticks required to trigger a re-stock for shops
const SHOP_RESTOCK_TICKS: int = 10
const TASK_TYPES: Array[String] = ["fetch", "interact", "hybrid"]

var surroundings: Node2D
var npcs: Node2D
var players_container: Node2D
var players: Dictionary = {}
var shops: Dictionary = {}
var game_timer: Timer
var player_scene: PackedScene = load("res://Scenes/World/Characters/Player.tscn")
var pickable_scene: PackedScene = load("res://Scenes/World/Environment/Assets/Pickable.tscn")
var returnables_on_map: int = 0
var returnables_per_player: int = 10
var vibe_tick: float = -1.5
var vibe_tick_limit: float = 25.0
var current_restock_ticks: int = 0
# Run server sync only if GameManager has successfully initialized the game world on the client
var initialized: bool = false

# This is shit and will be reworked
const BaseTasks: Dictionary = {
	"fetch": {
		"description": "Bring the required items to %s",
		"conditions": {
			"items": {
				"bottle_liquor": 3,
				"bottle_wine": 3,
			},
			"goals": {}
		},
		"rewards": {
			"items": {},
				"currency": 10.0,
				"flex": 100
		}
	},
	"interact": {
		"description": "Go pull a prank on '%s's' friend",
		"conditions": {
			"items": {},
			"goals": {
				"1": {
					"target": "Blue Dude",
					"description": "%s annoyed",
					"completed": false
				}
			}
		},
		"rewards": {
			"items": {},
			"currency": 10.0,
			"flex": 25
		}
	},
	"hybrid": {
		"description": "Bring %s the required items and say hi to his friend",
		"conditions": {
			"items": {
				"bottle_liquor": 2
			},
			"goals": {
				"1": {
					"target": "Blue Dude",
					"description": "Say hi to %s",
					"completed": false
				}
			}
		},
		"rewards": {
			"items": {
				"liqueur_bitter": 1
			},
			"currency": 10.0,
			"flex": 75
		},
	}
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

func GenerateTask() -> Task:
	randomize()
	var task_index: int = randi() % 3
	var task_type: String = TASK_TYPES[task_index]
	var task_base: Dictionary = BaseTasks[task_type].duplicate(true)
	var rewards: Dictionary = task_base.get("rewards")
	var reward_pool: Array[String]
	match task_type:
		"fetch":
			reward_pool = GameItems.GetMediumRewardPool()
			rewards["items"] = { reward_pool[randi() % reward_pool.size()]: randi_range(1,2) }
		"hybrid":
			reward_pool = GameItems.GetHighRewardPool()
			rewards["items"] = { reward_pool[randi() % reward_pool.size()]: 1 }
		_:
			reward_pool = GameItems.GetLowRewardPool()
			rewards["items"] = { reward_pool[randi() % reward_pool.size()]: randi_range(2, 3) }
	return Task.new(task_base.get("description"), task_base.get("conditions"), rewards)

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
	game_data["items"] = GameItems.GetItemsData()
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
		if entry.is_in_group("red"):
			type = "red"
		elif entry.is_in_group("blue"):
			type = "blue"
		characters.append({"id": entry.get_instance_id(), "position": position, "texture": entry.texture, "type": type})
	game_data["characters"] = characters
	GameServer.ReturnGameData(game_data, player_id)

func SpawnReturnables(returnable_amount: int = 5 * (players.size() + 1)) -> Array:
	if returnables_on_map >= (returnables_per_player * (players.size() + 1)):
		return []
	var returnables: Dictionary = { 1: GameItems.GetItem("can"), 2: GameItems.GetItem("bottle"), 3: GameItems.GetItem("bottle_big"), 4: GameItems.GetItem("bottle_liquor"), 5: GameItems.GetItem("bottle_wine")} # TODO: Better handling
	var returnable_weights: Array[int] = [1,1,1,1,1,2,2,2,3,4,5] # TODO: Same here
	var item_data: Array = []
	var screen_size = get_viewport().get_visible_rect().size # TODO: ...and here
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
	var item: Item = GameItems.GetItem(item_id)
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

func PlayerAddItems(player_id: String, item_id_array: Array[String]) -> void:
	GameServer.PlayerAddItems(player_id.to_int(), item_id_array)

func PlayerRemoveItems(player_id: String, item_id_array: Array[String]) -> void:
	GameServer.PlayerRemoveItems(player_id.to_int(), item_id_array)

func PlayerUseItem(player_id: int, item_id: String) -> void:
	var item: Item = GameItems.GetItem(item_id)
	if item && players.has(player_id):
		item.Use(players[player_id])

# Stats come as { "flex": int, "vibe": float }
func PlayerUpdateStats(player_id: String, stats: Dictionary) -> void:
	stats["id"] = player_id
	GameServer.PlayerUpdateStats(stats)

func PlayerChangeCurrency(player_id: String, currency: float) -> void:
	GameServer.PlayerChangeCurrency(player_id.to_int(), currency)

func PlayerRecycledItems(player_id: String, recycled_items: Array[Item], returnable_size: int) -> void:
	var item_ids: Array[String] = []
	for entry in recycled_items:
		item_ids.append(entry.item_id)
	GameServer.PlayerRecycledItems(player_id.to_int(), item_ids, returnable_size)

func SpawnNewPlayer(player_id: int, spawn_location: Vector2 = Vector2(0,0)) -> void:
	# TODO: Add player specific visual things to show on the clientside
	var new_player: Player = player_scene.instantiate()
	new_player.position = spawn_location
	new_player.name = str(player_id)
	players_container.add_child(new_player)
	players[player_id] = new_player
	new_player.items_added.connect(PlayerAddItems)
	new_player.items_removed.connect(PlayerRemoveItems)
	new_player.values_changed.connect(PlayerUpdateStats)
	new_player.currency_changed.connect(PlayerChangeCurrency)
	new_player.items_recycled.connect(PlayerRecycledItems)
	new_player.task_added.connect(StartPlayerTask)
	new_player.task_removed.connect(RemovePlayerTask)
	new_player.task_updated.connect(UpdatePlayerTask)
	new_player.game_over.connect(PlayerGameOver)
	# TODO: Connect the rest of player signals
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

# Tasks

func StartPlayerTask(player_id: String, task: Task) -> void:
	GameServer.StartPlayerTask(task.GetAsDictionary(), player_id.to_int())

func UpdatePlayerTask(player_id: String, task: Task) -> void:
	GameServer.UpdatePlayerTask(task.GetAsDictionary(), player_id.to_int())

func RemovePlayerTask(player_id: String, task: Task, completed: bool) -> void:
	GameServer.RemovePlayerTask(task.GetAsDictionary(), completed, player_id.to_int())

## Triggers

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
			var new_vibe: float = player.AddVibe(vibe_reduction)
			if new_vibe > 0:
				stats_data.append({"id": str(player.name), "vibe": new_vibe})
	game_data["stats_data"] = stats_data
	GameServer.GameTimerTimeout(game_data)

func _Returnable_Picked() -> void:
	returnables_on_map -= 1
