extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var ip: String = "localhost" # Development
var port : int = 1106

func _ready():
	ConnectToServer()
	
func ConnectToServer() -> void:
	if (network.create_client(ip, port)):
		print("Error while creating authentication client")
		return
	get_tree().set_network_peer(network)
	if (network.connect("connection_failed", self, "_OnConnectionFailed") || network.connect("connection_succeeded", self, "_OnConnectionSucceeded")):
		print("Signal connection failed")
		return
	
func _OnConnectionSucceeded() -> void:
	print("Connected to authentication server")

func _OnConnectionFailed() -> void:
	print("Failed to connect to authentication server")

func AuthenticatePlayer(username: String, password: String, player_id: int) -> void:
	print("Sending authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)

remote func AuthenticationResults(result: bool, player_id: int) -> void:
	print("Results received. Replying to user login request")
	Gateway.ReturnLoginRequest(result, player_id)
