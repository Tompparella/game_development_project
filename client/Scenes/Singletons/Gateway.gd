extends Node

var network: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var ip: String = "localhost" # For Development
var port: int = 1107
var cert: X509Certificate = load("res://Resources/Certificate/x509_cert.crt")

var username: String
var password: String
var register: bool

func ConnectToServer(_username: String, _password: String, _register: bool = false) -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), self.get_path())
	username = _username
	password = _password
	register = _register
	network = ENetMultiplayerPeer.new()
	if (network.create_client(ip, port)):
		print("Gateway client creation failed")
		return
	# Set certification for client
	network.get_host().dtls_client_setup(cert, "", false)
	self.multiplayer.set_multiplayer_peer(network)
	if (multiplayer.connection_failed.connect(self._OnConnectionFailed) || multiplayer.connected_to_server.connect(self._OnConnectionSucceeded)):
		print("Signal connection failed")
		return
	
func _OnConnectionFailed() -> void:
	print("Failed to connect to login server")
	UIControl.EnableLoginButtons()
	# TODO: Popup or something to notify the user

func _OnConnectionSucceeded() -> void:
	print("Connection successfully established to login server")
	if register:
		RequestRegistration()
	else:
		RequestLogin()
	
@rpc(any_peer)
func RequestLogin() -> void:
	print("Requesting login from gateway...")
	self.rpc_id(1, "RequestLogin", username, password.sha256_text())
	username = ""
	password = ""

@rpc(any_peer)
func RequestRegistration() -> void:
	print("Requesting registration")
	rpc_id(1, "RequestRegistration", username, password.sha256_text())
	username = ""
	password = ""

@rpc(authority)
func ReturnLoginRequest(results: bool, token: String) -> void:
	print("Results received")
	if results:
		print("Successfully logged in!")
		GameServer.token = token
		GameServer.ConnectToServer()
	else:
		print("Failed to login. Please provide correct username and password")
		UIControl.EnableLoginButtons()
	multiplayer.disconnect("connection_failed", self._OnConnectionFailed)
	multiplayer.disconnect("connected_to_server", self._OnConnectionSucceeded)

@rpc(authority)
func ReturnRegistrationRequest(results: bool, message: int) -> void:
	print("Registration results received")
	if results:
		print("Account created successfully. Please proceed logging in")
		UIControl.ToggleLoginScreen()
	else:
		if message == 1:
			print("Registration failed on server")
			# TODO: Message handling for creation fail
		elif message == 2:
			# TODO: Message handling for existing username
			print("That username already exists")
			pass
	UIControl.EnableLoginButtons()
	multiplayer.disconnect("connection_failed", self._OnConnectionFailed)
	multiplayer.disconnect("connected_to_server", self._OnConnectionSucceeded)
