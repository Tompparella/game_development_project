extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var port : int = 1105
var max_players : int = 100

func _ready():
	StartServer()
	
func StartServer() -> void:
	if (network.create_server(port, max_players)):
		print("Error while starting server")
		return
	get_tree().set_network_peer(network)
	print("Server started")
	if (network.connect("peer_connected", self, "_Peer_Connected") || network.connect("peer_disconnected", self, "_Peer_Disconnected")):
		print("Error while starting server")
		return
	
func _Peer_Connected(player_id : int) -> void:
	print("Player %s connected" % player_id)

func _Peer_Disconnected(player_id : int) -> void:
	print("Player %s disconnected" % player_id)
