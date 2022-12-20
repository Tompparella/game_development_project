extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "localhost" # For Development
var port : int = 1108

@onready var gameserver: GameServer = get_node("../GameServer")

func _ready() -> void:
	ConnectToServer()

func ConnectToServer() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), get_path())
	if (network.create_client(ip, port)):
		print("Hub creation failed")
		return
	multiplayer.set_multiplayer_peer(network)
	
	if (multiplayer.connection_failed.connect(self._OnConnectionFailed) || multiplayer.connected_to_server.connect(self._OnConnectionSucceeded)):
		print("Signal connection failed")
		return
	
func _OnConnectionFailed() -> void:
	print("Failed to connect to hub")

func _OnConnectionSucceeded() -> void:
	print("Hub connection successfully established")

@rpc(authority)
func HandleToken(token: String) -> void:
	gameserver.expected_tokens.append(token)
