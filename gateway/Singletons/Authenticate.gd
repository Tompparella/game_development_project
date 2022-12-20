extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip: String = "localhost" # Development
var port : int = 1106

func _ready():
	ConnectToServer()
	
func ConnectToServer() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), self.get_path())
	if (network.create_client(ip, port)):
		print("Error while creating authentication client")
		return
	self.multiplayer.set_multiplayer_peer(network)
	if (multiplayer.connection_failed.connect(self._OnConnectionFailed) || multiplayer.connected_to_server.connect(self._OnConnectionSucceeded)):
		print("Signal connection failed")
		return
	
func _OnConnectionSucceeded() -> void:
	print("Connected to authentication server")

func _OnConnectionFailed() -> void:
	print("Failed to connect to authentication server")

@rpc(any_peer)
func AuthenticateUser(username: String, password: String, player_id: int) -> void:
	print("Sending authentication request for user %s" % player_id)
	var error: int = self.rpc_id(1, StringName("AuthenticateUser"), username, password, player_id)
	if error:
		print("Authentication RPC request failed: %s" % error_string(error))

@rpc(authority)
func AuthenticationResult(result: bool, player_id: int, token: String) -> void:
	print("Results received. Replying to user login request")
	Gateway.ReturnLoginRequest(result, player_id, token)

@rpc(any_peer)
func RegisterAccount(username: String, password: String, player_id: int) -> void:
	print("Sending registration request")
	rpc_id(1, "RegisterAccount", username, password, player_id)

@rpc(authority)
func RegistrationResults(result: bool, player_id: int, message: int) -> void:
	Gateway.ReturnRegistrationRequest(result, player_id, message)
