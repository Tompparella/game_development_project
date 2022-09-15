extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var gateway_api: MultiplayerAPI = MultiplayerAPI.new()
var ip : String = "localhost" # For Development
var port : int = 1107

var username: String
var password: String

func _process(_delta: float) -> void:
	if get_custom_multiplayer() == null || !custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func ConnectToServer(_username: String, _password: String) -> void:
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	username = _username
	password = _password
	if (network.create_client(ip, port)):
		print("Gateway client creation failed")
		return
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	if (network.connect("connection_failed", self, "_OnConnectionFailed") || network.connect("connection_succeeded", self, "_OnConnectionSucceeded")):
		print("Signal connection failed")
		return
	
func _OnConnectionFailed() -> void:
	print("Failed to connect to login server")
	# TODO: Popup or something to notify the user + Enable login button

func _OnConnectionSucceeded() -> void:
	print("Connection successfully established to login server")
	RequestLogin()
	
func RequestLogin() -> void:
	print("Requesting login from gateway...")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""
	
remote func ReturnLoginRequest(results) -> void:
	print("Results received")
	if results:
		GameServer.ConnectToServer()
		get_node("../SceneHandler/Map/LoginScreen").queue_free()
	else:
		print("Failed to login. Please provide correct username and password")
		get_node("../SceneHandler/Map/LoginScreen/Login/Fields/LoginButton").disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
