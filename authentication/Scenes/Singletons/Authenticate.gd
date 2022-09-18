extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int = 1106
var max_servers : int = 3

func _ready():
	StartServer()
	
func StartServer() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), self.get_path())
	if (network.create_server(port, max_servers)):
		print("Error while starting authentication server")
		return
	self.multiplayer.set_multiplayer_peer(network)
	print("Authentication server started")
	if (network.peer_connected.connect(self._Peer_Connected) || network.peer_disconnected.connect(self._Peer_Disconnected)):
		print("Error while authentication starting server")
		return
	
func _Peer_Connected(gateway_id : int) -> void:
	print("Gateway %s connected" % str(gateway_id))

func _Peer_Disconnected(gateway_id : int) -> void:
	print("Gateway %s disconnected" % str(gateway_id))

func CreateToken() -> String:
	randomize()
	return str(randi()).sha256_text() + str(int(Time.get_unix_time_from_system()))
	
func GetSalt() -> String:
	randomize()
	return str(randi()).sha256_text()

# Salting the simple sha256 hash a gazillion times to make decrypting it slow
func GetHashed(text: String, salt: String) -> String:
	var hashed: String = text
	var rounds: float = pow(2,18)
	while rounds > 0:
		hashed = (hashed + salt).sha256_text()
		rounds -= 1
	return hashed

@rpc(any_peer)
func AuthenticateUser(username: String, password: String, player_id: int) -> void:
	var gateway_id = self.multiplayer.get_remote_sender_id()
	print("Authentication request received from gateway %s" % gateway_id)
	var hashed: String
	var result: bool = false
	var token: String
	if !PlayerData.CheckUsername(username):
		print("User doesn't exist")
	else:
		var user_salt: String = PlayerData.PlayerIDs[username].salt
		hashed = GetHashed(password, user_salt)
		if !PlayerData.CheckPassword(username, hashed):
			print("Incorrect password")
		else:
			print("Successful authentication")
			result = true
			token = CreateToken()
			GameServer.HandleToken(token, "GameServer1") # GameServer1 is here as a placeholder for possible load balancing
	AuthenticationResult(result, player_id, token, gateway_id)
	
@rpc(authority)
func AuthenticationResult(result: bool, player_id: int, token: String, gateway_id: int) -> void:
	print("Authentication result sent to gateway server")
	var error: int = self.rpc_id(gateway_id, StringName("AuthenticationResult"), result, player_id, token)
	if error:
		print("Authentication result RPC request failed: %s" % error_string(error))

@rpc(any_peer)
func RegisterAccount(username: String, password: String, player_id: int) -> void:
	var gateway_id: int = multiplayer.get_remote_sender_id()
	var result: bool = false
	var message: int
	if PlayerData.CheckUsername(username):
		message = 2
	else:
		result = true
		message = 3
		var salt: String = GetSalt()
		var hashed: String = GetHashed(password, salt)
		PlayerData.AddPlayerID(username, hashed, salt)
	RegistrationResults(result, gateway_id, player_id, message)

@rpc(authority)
func RegistrationResults(result: bool, gateway_id: int, player_id: int, message: int) -> void:
	rpc_id(gateway_id, "RegistrationResults", result, player_id, message)
