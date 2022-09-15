extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var gateway_api: MultiplayerAPI = MultiplayerAPI.new()
var port : int = 1107
var max_players: int = 100

func _ready():
	StartServer()
	
func _process(_delta: float) -> void:
	if !custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func StartServer() -> void:
	if (network.create_server(port, max_players)):
		print("Error while starting gateway server")
		return
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway server started")
	if (network.connect("peer_connected", self, "_PeerConnected") || network.connect("peer_disconnected", self, "_PeerDisconnected")):
		print("Error while authentication starting server")
		return
	
func _PeerConnected(player_id: int) -> void:
	print("User %s connected" % str(player_id))

func _PeerDisconnected(player_id: int) -> void:
	print("User %s disconnected" % str(player_id))

remote func LoginRequest(username: String, password: String) -> void:
	print("Request for login with username %s" % username)
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.AuthenticatePlayer(username, password, player_id)

func ReturnLoginRequest(result: bool, player_id: int) -> void:
	rpc_id(player_id, "ReturnLoginRequest", result)
	network.disconnect_peer(player_id)
