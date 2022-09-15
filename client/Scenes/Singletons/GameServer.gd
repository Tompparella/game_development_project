extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var ip : String = "localhost" # For Development
var port : int = 1105

func ConnectToServer() -> void:
	if (network.create_client(ip, port)):
		print("Client creation failed")
		return
	get_tree().set_network_peer(network)
	
	if (network.connect("connection_failed", self, "_OnConnectionFailed") || network.connect("connection_succeeded", self, "_OnConnectionSucceeded")):
		print("Signal connection failed")
		return
	
func _OnConnectionFailed() -> void:
	print("Failed to connect to server")

func _OnConnectionSucceeded() -> void:
	print("Connection successfully established")
