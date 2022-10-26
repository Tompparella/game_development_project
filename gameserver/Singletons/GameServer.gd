extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int = 1105
var max_players : int = 100


var expected_tokens: Array = ["dfsfdsa"] # This is just here to check that token verification works as supposed to
var player_states_collection: Dictionary = {}
var surrounding_states_collection: Dictionary = {}

@onready var user_verification: Node = get_node("../Server/UserVerification")
@onready var token_timer: Timer = get_node("../Server/TokenExpiration")

func _ready():
	StartServer()

func StartServer() -> void:
	if (network.create_server(port, max_players)):
		print("Error while starting server")
		return
	multiplayer.set_multiplayer_peer(network)
	print("Server started")
	if (network.peer_connected.connect(self._Peer_Connected) || network.peer_disconnected.connect(self._Peer_Disconnected) || token_timer.timeout.connect(self._Token_Expiration_Timeout)):
		print("Error while connecting gameserver signals")
		return
	GameManager.Initialize()

func _Peer_Connected(player_id : int) -> void:
	# The timeout is set here because in some cases the peer doesn't get registered in time before initiating this function
	await get_tree().create_timer(.5).timeout
	print("Player %s connected" % player_id)
	user_verification.Initiate(player_id)

func _Peer_Disconnected(player_id : int) -> void:
	print("Player %s disconnected" % player_id)
	var player_container_path: String = "../Server/UserContainer/" + str(player_id)
	if (has_node(player_container_path)):
		get_node(player_container_path).queue_free()
	GameManager.DespawnPlayer(player_id, false)

func _Token_Expiration_Timeout() -> void:
	var current_time: int = int(Time.get_unix_time_from_system())
	var token_time
	if !expected_tokens.is_empty():
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = user_verification.GetTokenTimestamp(expected_tokens[i]) # Timestamp from token
			if current_time - token_time >= 30:
				expected_tokens.remove_at(i)

## Authentication

@rpc(authority)
func FetchToken(player_id: int):
	rpc_id(player_id, "FetchToken")
	
@rpc(any_peer)
func ReturnToken(token: String):
	var player_id: int = multiplayer.get_remote_sender_id()
	user_verification.Verify(player_id, token)
	
@rpc(authority)
func ReturnTokenVerificationResult(player_id: int, result: bool) -> void:
	rpc_id(player_id, "ReturnTokenVerificationResult", result)
	if result:
		# TODO: Spawn player to their instance coordinates, otherwise to default (such as 0,0)
		GameManager.SpawnNewPlayer(player_id, Vector2(0,0))

## Clock synchronization

@rpc(any_peer)
func FetchServerTime(client_time: float) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	ReturnServerTime(client_time, player_id)

@rpc(authority)
func ReturnServerTime(client_time: float, player_id: int) -> void:
	rpc_id(player_id, "ReturnServerTime", Time.get_unix_time_from_system(), client_time)

@rpc(any_peer)
func DetermineLatency(client_time: float) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	ReturnLatency(client_time, player_id)

@rpc(authority)
func ReturnLatency(client_time: float, player_id: int) -> void:
	rpc_id(player_id, "ReturnLatency", client_time)

## Player UI functions

@rpc(authority)
func OpenShop(player_id: int, shop_data: Dictionary) -> void:
	rpc_id(player_id, "OpenShop", shop_data)

@rpc(authority)
func CloseShop(player_id: int) -> void:
	rpc_id(player_id, "CloseShop")

@rpc(authority)
func UpdateShopInventory(player_id: String, updated_items: Dictionary):
	rpc_id(player_id.to_int(), "UpdateShopInventory", updated_items)

## Shop functions

@rpc(any_peer)
func BuyItem(item_id: String, shop_id: String) -> void:
	GameManager.PlayerBuyItem(multiplayer.get_remote_sender_id() ,item_id, shop_id)

## Game functions

@rpc(any_peer)
func FetchGameData() -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	GameManager.FetchGameData(player_id)

@rpc(authority)
func ReturnGameData(game_data: Dictionary, player_id: int) -> void:
	rpc_id(player_id, "ReturnGameData", game_data)

@rpc(any_peer, unreliable_ordered)
func UpdatePlayerState(player_state: Dictionary) -> void:
	# Since this is an ordered rpc call, packets are automatically discarded if they're not the most recent to arrive
	var player_id: int = multiplayer.get_remote_sender_id()
	player_states_collection[player_id] = player_state
	GameManager.MovePlayer(player_id, player_state["position"])

@rpc(authority, unreliable_ordered)
func UpdateWorldState(world_state: Dictionary) -> void:
	rpc_id(0, "UpdateWorldState", world_state)

@rpc(authority)
func SpawnNewPlayer(player_id: int, spawn_location: Vector2) -> void:
	rpc_id(0, "SpawnNewPlayer", player_id, spawn_location)

@rpc(authority)
func PlayerDespawned(player_id: int) -> void:
	rpc_id(player_id, "PlayerDespawned")

@rpc(authority)
func DespawnPlayer(player_id: int) -> void:
	player_states_collection.erase(player_id)
	rpc_id(0, "DespawnPlayer", player_id)

@rpc(any_peer)
func PlayerInteract() -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	GameManager.PlayerInteract(player_id)

@rpc(authority)
func PlayerAddItem(player_id: int, item_id: String) -> void:
	rpc_id(player_id, "PlayerAddItem", item_id)

@rpc(authority)
func PlayerChangeCurrency(player_id: int, currency: float) -> void:
	rpc_id(player_id, "PlayerChangeCurrency", currency)

@rpc(authority)
func PlayerUpdateStats(player_stats: Dictionary) -> void:
	rpc_id(0, "PlayerUpdateStats", player_stats)

@rpc(authority)
func PlayerRecycledItems(player_id: int, item_ids: Array[String], returnable_size: int) -> void:
	rpc_id(player_id, "PlayerRecycledItems", item_ids, returnable_size)

@rpc(any_peer)
func PlayerUseItem(item_id: String) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	GameManager.PlayerUseItem(player_id, item_id)

@rpc(authority)
func PlayerRemoveItem(player_id: int, item_id: String) -> void:
	rpc_id(player_id, "PlayerRemoveItem", item_id)

@rpc(authority)
func SpawnReturnables(returnables: Array) -> void:
	rpc_id(0, "SpawnReturnables", returnables)

@rpc(authority)
func GameTimerTimeout(game_data: Dictionary) -> void:
	rpc_id(0, "GameTimerTimeout", game_data)

@rpc(authority)
func RemoveSurrounding(id: int) -> void:
	rpc_id(0, "RemoveSurrounding", id)
