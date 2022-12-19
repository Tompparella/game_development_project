extends Node

const INTERPOLATION_OFFSET: float = 0.1

var surroundings: Node2D
var other_players: Node2D
var npcs: Node2D
var player: Player
var camera: Camera

# Scenes
var player_scene: PackedScene = load("res://Scenes/Characters/Player.tscn")
var player_template: PackedScene = load("res://Scenes/Characters/PlayerTemplate.tscn")
var surrounding_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Surrounding.tscn")
var interactable_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Interactable/Interactable.tscn")
var shop_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Interactable/Shop.tscn")
var obstacle_scene: PackedScene = load("res://Scenes/Environment/Obstacles/Obstacle.tscn")
var pickable_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Pickable/Pickable.tscn")
var returnmachine_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Interactable/ReturnMachine.tscn")

var world_state_buffer: Array = []
# Run server sync only if GameManager has successfully initialized the game world on the client
var initialized: bool = false

func _ready() -> void:
	surroundings = get_node("../Game/Main/TileMap/Surroundings")
	other_players = get_node("../Game/Main/TileMap/OtherPlayers")
	npcs = get_node("../Game/Main/TileMap/Npcs")
	AudioManager.Initialize()
	set_physics_process(false)

func _physics_process(_delta) -> void:
	HandleWorldUpdate()
	HandlePlayerUpdate()

func Initialize(game_data: Dictionary) -> void:
	GameItems.LoadItems(game_data["items"])
	LoadEnvironment(game_data["environment"])
	LoadCharacters(game_data["characters"])
	UIControl.HideLoginScreen()
	Restart()
	initialized = true

func Restart() -> void:
	EnablePlayer()
	camera = get_node("../Game/Main/Camera")
	camera.Initialize(player)
	UIControl.Initialize(player)
	AudioManager.NextTrack()
	set_physics_process(true)

func RequestRestart() -> void:
	GameServer.PlayerRestartRequest()

func LoadEnvironment(environment_data: Array) -> void:
	for entry in environment_data:
		var scene: Obstacle
		match entry["type"]:
			"surrounding":
				scene = surrounding_scene.instantiate()
			"interactable":
				scene = interactable_scene.instantiate()
			"shop":
				scene = shop_scene.instantiate()
			"pickable":
				scene = pickable_scene.instantiate()
			"returnmachine":
				scene = returnmachine_scene.instantiate()
			_:
				scene = obstacle_scene.instantiate()
		scene.Initialize(entry["texture"], entry["position"])
		surroundings.add_child(scene)
		scene.name = str(entry["id"])

func LoadCharacters(characters_data: Array) -> void:
	for entry in characters_data:
		var scene: PlayerTemplate
		# TODO: Actual character type handling
		match entry["type"]:
			"red":
				# TODO: Change PlayerTemplate to Npc scene
				scene = player_template.instantiate()
				scene.modulate = Color(Color.RED)
			"blue":
				scene = player_template.instantiate()
				scene.modulate = Color(Color.BLUE)
			_:
				scene = player_template.instantiate()
		#scene.Initialize(entry["texture"], entry["position"])
		scene.global_position = entry["position"]
		npcs.add_child(scene)
		scene.name = str(entry["id"])

func EnablePlayer() -> void:
	player = player_scene.instantiate()
	get_node("../Game/Main/TileMap").add_child(player)
	player.interact.connect(Interact)
	player.item_used.connect(UseItem)
	player.Initialize()

func DisablePlayer() -> void:
	UIControl.ShowGameoverModal(player)
	if has_node("../Game/Main/TileMap/Player"):
		player.queue_free()
	player = null

func AddItems(item_id_array: Array) -> void:
	for entry in item_id_array:
		player.AddItem(GameItems.GetItem(entry))

func RemoveItems(item_id_array: Array) -> void:
	for entry in item_id_array:
		player.RemoveItem(GameItems.GetItem(entry))

func ChangeCurrency(currency: float) -> void:
	player.SetCurrency(currency)

func Interact() -> void:
	GameServer.PlayerInteract()

func RemoveSurrounding(id: String) -> void:
	if surroundings.has_node(id):
		surroundings.get_node(id).queue_free()
		
func SpawnReturnables(returnables: Array) -> void:
	for entry in returnables:
		var pickable: Pickable = pickable_scene.instantiate()
		pickable.Initialize(entry["texture"], entry["position"])
		surroundings.add_child(pickable)
		pickable.name = str(entry["id"])

func UpdateStats(stats_data: Array) -> void:
	for entry in stats_data:
		var player_id = entry.get("id")
		var vibe = entry.get("vibe")
		var flex = entry.get("flex")
		var currency = entry.get("currency")
		if player_id != null:
			if other_players.has_node(player_id):
				var peer: PlayerTemplate = other_players.get_node(player_id)
				peer.UpdateStats(vibe, flex)
			elif str(multiplayer.get_unique_id()) == player_id:
				if vibe != null:
					player.SetVibe(vibe)
				if flex != null:
					player.SetFlex(flex)
				if currency != null:
					player.SetCurrency(currency)

func GameTimerTimeout(game_data: Dictionary) -> void:
	SpawnReturnables(game_data["returnable_data" ])
	UpdateStats(game_data["stats_data"])

# Shop Logic

func OpenShop(shop_data: Dictionary) -> void:
	UIControl.OpenShopModal(shop_data)

func BuyItem(item_id: String, shop_id: String) -> void:
	GameServer.BuyItem(item_id, shop_id)

# Item logic

# TODO: This is a placeholder. Shop inventories are supposed to be returned depending on shop brand.
func GetShopInventory() -> Array[Item]:
	return []

func UseItem(item_id: String) -> void:
	GameServer.PlayerUseItem(item_id)

# Tasks

func NewTask(task: Dictionary) -> void:
	player.AddTask(Task.new(task))

func UpdateTask(task: Dictionary) -> void:
	player.UpdateTask(Task.new(task))

func RemoveTask(task: Dictionary, complete: bool) -> void:
	# TODO: Completion and interception handling
	player.RemoveTask(Task.new(task), complete)

# Sync functions

func UpdateWorldState(world_state: Dictionary) -> void:
	if initialized:
		world_state_buffer.append(world_state)

func HandleWorldUpdate() -> void:
	var render_time: float = GameServer.client_clock - INTERPOLATION_OFFSET
	if world_state_buffer.size() > 1:
		while (world_state_buffer.size() > 2) && (render_time > world_state_buffer[2]["timestamp"]):
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			InterpolateWorld(render_time)
		elif render_time > world_state_buffer[1]["timestamp"]:
			ExtrapolateWorld(render_time)

func HandlePlayerUpdate() -> void:
	if player:
		var player_state: Dictionary = {"position": player.global_position}
		GameServer.UpdatePlayerState(player_state)

func HandleItemsRecycled(item_ids: Array, returnable_size: int) -> void:
	if player:
		for entry in item_ids:
			var item: Item = GameItems.GetItem(entry)
			if item:
				player.RemoveItem(item)
		player.SetReturnableSize(returnable_size)

func InterpolateWorld(render_time: float) -> void:
	var recent_past: Dictionary = world_state_buffer[1]
	var nearest_future: Dictionary = world_state_buffer[2]
	var interpolation_factor = float(render_time - nearest_future["timestamp"]) / float(nearest_future["timestamp"] - recent_past["timestamp"])
	for player_id in nearest_future["players"].keys():
		# If the current entry is timestamp, the client's character, or if it doesn't exist in the past world state, continue
		if (player_id == multiplayer.get_unique_id() || !recent_past["players"].has(player_id)):
			continue
		if other_players.has_node(str(player_id)):
			var entry: PlayerTemplate = other_players.get_node(str(player_id))
			var new_position: Vector2 = lerp(recent_past["players"][player_id]["position"], nearest_future["players"][player_id]["position"], interpolation_factor)
			entry.MovePlayer(new_position)
		else:
			SpawnNewPlayer(player_id, nearest_future["players"][player_id]["position"])
	for surrounding_id in nearest_future["surroundings"].keys():
		if !recent_past["surroundings"].has(surrounding_id):
			continue
		if surroundings.has_node(str(surrounding_id)):
			var entry: Node2D = surroundings.get_node(str(surrounding_id))
			var new_position: Vector2 = lerp(recent_past["surroundings"][surrounding_id]["position"], nearest_future["surroundings"][surrounding_id]["position"], interpolation_factor)
			entry.global_position = new_position

func ExtrapolateWorld(render_time: float) -> void:
	var old_past: Dictionary = world_state_buffer[0]
	var recent_past: Dictionary = world_state_buffer[1]
	var extrapolation_factor: float = (float(render_time - old_past["timestamp"]) / float(recent_past["timestamp"] - old_past["timestamp"])) - INTERPOLATION_OFFSET
	for player_id in recent_past["players"].keys():
		# If the current entry is timestamp, the client's character, or if it doesn't exist in the past world state, continue
		if (player_id == multiplayer.get_unique_id() || !old_past["players"].has(player_id)):
			continue
		if other_players.has_node(str(player_id)):
			var entry: PlayerTemplate = other_players.get_node(str(player_id))
			var position_delta: Vector2 = recent_past["players"][player_id]["position"] - old_past["players"][player_id]["position"]
			var new_position: Vector2 = recent_past["players"][player_id]["position"] + (position_delta * extrapolation_factor)
			entry.MovePlayer(new_position)
	for surrounding_id in recent_past["surroundings"].keys():
		if !old_past["surroundings"].has(surrounding_id):
			continue
		if surroundings.has_node(str(surrounding_id)):
			var entry: Node2D = surroundings.get_node(str(surrounding_id))
			var position_delta: Vector2 = recent_past["surroundings"][surrounding_id]["position"] - old_past["surroundings"][surrounding_id]["position"]
			var new_position: Vector2 = recent_past["surroundings"][surrounding_id]["position"] + (position_delta * extrapolation_factor)
			entry.global_position = new_position

func SpawnNewPlayer(player_id: int, spawn_location: Vector2) -> void:
	# Check if the rpc call is for this player. If yes, do nothing
	if multiplayer.get_unique_id() == player_id:
		return
	# TODO: Add player specific visual things to show on the clientside
	var new_player: PlayerTemplate = player_template.instantiate()
	new_player.position = spawn_location
	new_player.name = str(player_id)
	other_players.add_child(new_player)
	print("Player %s spawned" % str(player_id))

func PlayerDespawned() -> void:
	DisablePlayer()

func DespawnPlayer(player_id: int) -> void:
	if other_players.has_node(str(player_id)):
		var despawned_player: Node = other_players.get_node(str(player_id))
		# We need to await for a time in order to wait for the world state to empty its references to the despawned player.
		# Without this, the player would despawn for a few milliseconds before being spawned again in the next world state update.
		await get_tree().create_timer(1.0).timeout
		despawned_player.queue_free()
