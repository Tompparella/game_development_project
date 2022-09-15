extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var port : int = 1106
var max_servers : int = 3

func _ready():
	StartServer()
	
func StartServer() -> void:
	if (network.create_server(port, max_servers)):
		print("Error while starting authentication server")
		return
	get_tree().set_network_peer(network)
	print("Authentication server started")
	if (network.connect("peer_connected", self, "_Peer_Connected") || network.connect("peer_disconnected", self, "_Peer_Disconnected")):
		print("Error while authentication starting server")
		return
	
func _Peer_Connected(gateway_id : int) -> void:
	print("Gateway %s connected" % str(gateway_id))

func _Peer_Disconnected(gateway_id : int) -> void:
	print("Gateway %s disconnected" % str(gateway_id))

remote func AuthenticatePlayer(username: String, password: String, player_id: int) -> void:
	var gateway_id = get_tree().get_rpc_sender_id()
	var result: bool = false
	# TODO! Add a check for actual playerdata
	if !["test"].has(username):
		print("User doesn't exist")
	elif !"test" == password:
		print("Incorrect password")
	else:
		print("Successful authentication")
		result = true
	print("Authentication result sent to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id)
