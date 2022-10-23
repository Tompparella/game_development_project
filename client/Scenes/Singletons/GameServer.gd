extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "localhost" # For Development
var port : int = 1105
var token: String
var latency: float = 0.0
var delta_latency: float = 0.0
var latency_array: Array[float] = []
var client_clock: float = 0.0

# Server connection functions

func ConnectToServer() -> void:
	if (network.create_client(ip, port)):
		print("Client creation failed")
		return
	multiplayer.set_multiplayer_peer(network)
	if (network.connection_failed.connect(self._OnConnectionFailed) || network.connection_succeeded.connect(self._OnConnectionSucceeded)):
		print("Signal connection failed")
		return

func _OnConnectionFailed() -> void:
	print("Failed to connect to server")

func _OnConnectionSucceeded() -> void:
	print("Connection successfully established")
	FetchServerTime()

@rpc(authority)
func FetchToken() -> void:
	ReturnToken()
	
@rpc(any_peer)
func ReturnToken() -> void:
	rpc_id(1, "ReturnToken", token)
	
@rpc(authority)
func ReturnTokenVerificationResult(result: bool) -> void:
	if result:
		print("Successful token verification")
		FetchGameData()
	else:
		print("Login failed, please try again")
		UIControl.EnableLoginButtons()

# UI functions

@rpc(authority)
func OpenShop(shop_data: Dictionary) -> void:
	GameManager.OpenShop(shop_data)

@rpc(authority)
func CloseShop() -> void:
	UIControl.CloseShopModal()

@rpc(any_peer)
func BuyItem(item_id: String, shop_id: String) -> void:
	rpc_id(1, "BuyItem", item_id, shop_id)

@rpc(authority)
func UpdateShopInventory(item_id: String, amount: int):
	UIControl.UpdateShopInventory(item_id, amount)

# Game functions

@rpc(any_peer)
func FetchGameData() -> void:
	rpc_id(1, "FetchGameData")

@rpc(authority)
func ReturnGameData(game_data: Dictionary) -> void:
	GameManager.Initialize(game_data)

@rpc(authority)
func SpawnNewPlayer(player_id: int, spawn_position: Vector2) -> void:
	GameManager.SpawnNewPlayer(player_id, spawn_position)

@rpc(authority)
func PlayerDespawned() -> void:
	GameManager.PlayerDespawned()

@rpc(authority)
func DespawnPlayer(player_id: int) -> void:
	GameManager.DespawnPlayer(player_id)

@rpc(any_peer, unreliable_ordered)
func UpdatePlayerState(player_state: Dictionary) -> void:
	rpc_id(1, "UpdatePlayerState", player_state)

@rpc(authority, unreliable_ordered)
func UpdateWorldState(world_state: Dictionary) -> void:
	GameManager.UpdateWorldState(world_state)

@rpc(authority)
func SpawnReturnables(returnables: Array) -> void:
	GameManager.SpawnReturnables(returnables)

@rpc(authority)
func GameTimerTimeout(game_data: Dictionary) -> void:
	GameManager.GameTimerTimeout(game_data)

@rpc(authority)
func RemoveSurrounding(id: int) -> void:
	GameManager.RemoveSurrounding(str(id))

@rpc(any_peer)
func PlayerInteract() -> void:
	rpc_id(1, "PlayerInteract")

@rpc(authority)
func PlayerAddItem(item_id: String) -> void:
	GameManager.AddItem(item_id)

@rpc(authority)
func PlayerRemoveItem(item_id: String) -> void:
	GameManager.RemoveItem(item_id)

@rpc(authority)
func PlayerChangeCurrency(currency: float) -> void:
	GameManager.ChangeCurrency(currency)

@rpc(authority)
func PlayerRecycledItems(item_ids: Array, returnable_size: int) -> void:
	GameManager.HandleItemsRecycled(item_ids, returnable_size)

# Clock synchronization

func _physics_process(delta: float) -> void:
	client_clock += delta + delta_latency
	delta_latency = 0.0

@rpc(any_peer)
func FetchServerTime() -> void:
	rpc_id(1, "FetchServerTime", Time.get_unix_time_from_system())
	var timer: Timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(DetermineLatency)
	add_child(timer)

@rpc(authority)
func ReturnServerTime(server_time: float, client_time: float) -> void:
	# Average one-way latency
	latency = (Time.get_unix_time_from_system() - client_time) / 2.0
	client_clock = server_time + latency

@rpc(any_peer)
func DetermineLatency() -> void:
	rpc_id(1, "DetermineLatency", Time.get_unix_time_from_system())

@rpc(authority)
func ReturnLatency(client_time: float) -> void:
	latency_array.append((Time.get_unix_time_from_system() - client_time) / 2)
	if latency_array.size() >= 9:
		var total_latency: float = 0.0
		var median_latency: float = latency_array[4]
		# Iterate backwards
		for i in range(latency_array.size() -1, -1, -1):
			var entry = latency_array[i]
			if (entry > (2 * median_latency)) && (entry > 0.02):
				latency_array.remove_at(i)
			else:
				total_latency += entry
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print("New latency: %s" % str(latency * 1000))
		latency_array.clear()
		
