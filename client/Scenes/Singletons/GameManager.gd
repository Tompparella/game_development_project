extends Node

const VIBE_TIMEOUT_TIME: float = 4.0
const INTERPOLATION_OFFSET: float = 0.1

var surroundings: Node2D
var other_players: Node2D
var player: Player
var camera: Camera

# Scenes
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

# Temporary. In the end product, item data will be fetched from the server, and textures will be either also fetched from server, or referenced locally.
var ItemsList: Dictionary = {}

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta) -> void:
	HandleWorldUpdate()
	HandlePlayerUpdate()

func Initialize(game_data: Dictionary) -> void:
	LoadItems(game_data["items"])
	LoadEnvironment(game_data["environment"])
	EnablePlayer()
	camera = get_node("../Game/Map/Camera")
	surroundings = get_node("../Game/Map/TileMap/Surroundings")
	other_players = get_node("../Game/Map/TileMap/OtherPlayers")
	camera.Initialize(player)
	UIControl.Initialize(player)
	UIControl.HideLoginScreen()
	set_physics_process(true)
	initialized = true

func LoadItems(items_data: Array) -> void:
	for entry in items_data:
		match entry["type"]:
			"consumable":
				ItemsList[entry["id"]] = Consumable.new(entry["name"], entry["description"], entry["value"], entry["texture"], entry["vibe"], entry["flex"])
			"returnable":
				ItemsList[entry["id"]] = Returnable.new(entry["name"], entry["description"], entry["value"], entry["texture"], entry["size"])
			_:
				ItemsList[entry["id"]] = Item.new(entry["name"], entry["description"], entry["value"], entry["texture"])

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
		print(entry["texture"])
		scene.Initialize(entry["texture"], entry["position"])

func EnablePlayer() -> void:
	if (has_node("../Game/Map/TileMap/Player")):
		player = get_node("../Game/Map/TileMap/Player")
		player.tree_exiting.connect(DisablePlayer)
		player.Initialize()

func DisablePlayer() -> void:
	player = null

#func SpawnItems() -> void:
#	# TODO: Change this so that returnables_per_player gets multiplied by the amount of players on the map.ist["bottle_liquor"], 5: ItemsList["bottle_wine"] }
#	var pickable_scene: PackedScene = load("res://Scenes/Environment/Surroundings/Pickable/Pickable.tscn")
#	var screen_size = get_viewport().get_visible_rect().size
#
#	var pickable: Pickable = pickable_scene.instantiate()
#	pickable.Initialize(returnables[returnable_weights[randi() % returnable_weights.size()]])
#	pickable.position = Vector2(randf_range(-screen_size.x, screen_size.x), randf_range(-screen_size.y, screen_size.y))
#	surroundings.add_child(pickable)
#	pickable.returnable_picked.connect(_Returnable_Picked)
#	returnables_on_map += 1

func GetItem(item_name: String) -> Item:
	return ItemsList.get(item_name, ItemsList.get("default"))

# TODO: This is a placeholder. Shop inventories are supposed to be returned depending on shop brand.
func GetShopInventory() -> Array[Item]:
	return []

# Sync functions

func UpdateWorldState(world_state: Dictionary) -> void:
	if initialized:
		world_state_buffer.append(world_state)

func HandleWorldUpdate() -> void:
	# TODO: Handle player despawning
	var render_time: float = GameServer.client_clock - INTERPOLATION_OFFSET
	if world_state_buffer.size() > 1:
		while (world_state_buffer.size() > 2) && (render_time > world_state_buffer[2]["timestamp"]):
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			InterpolatePlayers(render_time)
		elif render_time > world_state_buffer[1]["timestamp"]:
			ExtrapolatePlayers(render_time)

func HandlePlayerUpdate() -> void:
	if player:
		var player_state: Dictionary = {"position": player.global_position}
		GameServer.UpdatePlayerState(player_state)

func InterpolatePlayers(render_time: float) -> void:
	var recent_past: Dictionary = world_state_buffer[1]
	var nearest_future: Dictionary = world_state_buffer[2]
	var interpolation_factor = float(render_time - nearest_future["timestamp"]) / float(nearest_future["timestamp"] - recent_past["timestamp"])
	for player_id in nearest_future["players"].keys():
		# If the current entry is timestamp, the client's character, or if it doesn't exist in the past world state, continue
		if (player_id == multiplayer.get_unique_id() || !recent_past.has(player_id)):
			continue
		if other_players.has_node(str(player_id)):
			var entry: PlayerTemplate = other_players.get_node(str(player_id))
			var new_position: Vector2 = lerp(recent_past["players"][player_id]["position"], nearest_future["players"][player_id]["position"], interpolation_factor)
			entry.MovePlayer(new_position)
		else:
			SpawnNewPlayer(player_id, nearest_future["position"][player_id]["position"])
	
func ExtrapolatePlayers(render_time: float) -> void:
	var old_past: Dictionary = world_state_buffer[0]
	var recent_past: Dictionary = world_state_buffer[1]
	var extrapolation_factor: float = (float(render_time - old_past["timestamp"]) / float(recent_past["timestamp"] - old_past["timestamp"])) - INTERPOLATION_OFFSET
	for player_id in recent_past["players"].keys():
		# If the current entry is timestamp, the client's character, or if it doesn't exist in the past world state, continue
		if (player_id == multiplayer.get_unique_id() || !old_past.has(player_id)):
			continue
		if other_players.has_node(str(player_id)):
			var entry: PlayerTemplate = other_players.get_node(str(player_id))
			var position_delta: Vector2 = recent_past[player_id]["p"] - old_past[player_id]["p"]
			var new_position: Vector2 = recent_past[player_id]["p"] + (position_delta * extrapolation_factor)
			entry.MovePlayer(new_position)

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

func DespawnPlayer(player_id: int) -> void:
	if other_players.has_node(str(player_id)):
		var despawned_player: Node = other_players.get_node(str(player_id))
		# We need to await for a time in order to wait for the world state to empty its references to the despawned player.
		# Without this, the player would despawn for a few milliseconds before being spawned again in the next world state update.
		await get_tree().create_timer(0.2).timeout
		despawned_player.queue_free()
