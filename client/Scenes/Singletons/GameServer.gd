extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip : String = "localhost" # For Development
var port : int = 1105

var token: String

func ConnectToServer() -> void:
	if (network.create_client(ip, port)):
		print("Client creation failed")
		return
	multiplayer.set_multiplayer_peer(network)
	if (network.connection_failed.connect(self._OnConnectionFailed) || network.connection_succeeded.connect(self._OnConnectionSucceeded)):
		print("Signal connection failed")
		return
	
@rpc(authority)
func FetchToken() -> void:
	ReturnToken()
	
@rpc(any_peer)
func ReturnToken() -> void:
	rpc_id(1, "ReturnToken", token)
	
@rpc(authority)
func ReturnTokenVerificationResult(result: bool) -> void:
	if result:
		UIControl.HideLoginScreen()
		print("Successful token verification")
	else:
		print("Login failed, please try again")
		UIControl.EnableLoginButtons()
			
func _OnConnectionFailed() -> void:
	print("Failed to connect to server")

func _OnConnectionSucceeded() -> void:
	print("Connection successfully established")
