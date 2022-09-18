extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int = 1107
var max_players: int = 100
var cert: X509Certificate = load("res://Resources/Certificate/x509_cert.crt")
var key: CryptoKey = load("res://Resources/Certificate/x509_key.key")

func _ready():
	StartServer()
	
func _process(_delta: float) -> void:
	if !self.multiplayer.has_multiplayer_peer():
		return
	self.multiplayer.poll()
	
func StartServer() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), self.get_path())
	if (network.create_server(port, max_players)):
		print("Error while starting gateway server")
		return
	# Set certification for server
	network.get_host().dtls_server_setup(key, cert)
	self.multiplayer.set_multiplayer_peer(network)
	print("Gateway server started")
	if (network.peer_connected.connect(self._PeerConnected) || network.peer_disconnected.connect(self._PeerDisconnected)):
		print("Error while starting authentication server")
		return

func _PeerConnected(player_id: int) -> void:
	print("User %s connected" % str(player_id))

func _PeerDisconnected(player_id: int) -> void:
	print("User %s disconnected" % str(player_id))

@rpc(authority)
func ReturnLoginRequest(result: bool, player_id: int, token: String) -> void:
	var error: int = self.rpc_id(player_id, "ReturnLoginRequest", result, token)
	if error:
		print("Login RPC request failed: %s" % error_string(error))
	self.multiplayer.emit_signal("peer_disconnected", player_id)

@rpc(any_peer)
func RequestLogin(username: String, password: String) -> void:
	print("Request for login with username %s" % username)
	var player_id = self.multiplayer.get_remote_sender_id()
	Authenticate.AuthenticateUser(username, password, player_id)
	
@rpc(any_peer)
func RequestRegistration(username: String, password: String) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	if !username.is_empty() && !password.is_empty() && password.length() >= 6:
		Authenticate.RegisterAccount(username.to_lower(), password, player_id)
	else:
		ReturnRegistrationRequest(false, player_id, 1)

@rpc(authority)
func ReturnRegistrationRequest(result: bool, player_id: int, message: int):
	# message: 1 = Failed to create, 2 = Existing username, 3 = Success
	# TODO: Move these to constants files
	rpc_id(player_id, "ReturnRegistrationRequest", result, message)
	multiplayer.emit_signal("peer_disconnected", player_id)
