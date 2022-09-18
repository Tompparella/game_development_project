extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port : int = 1108
var max_servers : int = 3

var gameserver_list = {}

func _ready():
	StartServer()
	
func StartServer() -> void:
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), self.get_path())
	if (network.create_server(port, max_servers)):
		print("Error while starting game server")
		return
	self.multiplayer.set_multiplayer_peer(network)
	print("Game server started")
	if (network.peer_connected.connect(self._Peer_Connected) || network.peer_disconnected.connect(self._Peer_Disconnected)):
		print("Error while connecting signals")
		return
	
func _Peer_Connected(gameserver_id : int) -> void:
	print("Game server %s connected" % str(gameserver_id))
	gameserver_list["GameServer1"] = gameserver_id

func _Peer_Disconnected(gameserver_id : int) -> void:
	print("Game server %s disconnected" % str(gameserver_id))

@rpc(authority)
func HandleToken(token: String, gameserver: String) -> void: # gameserver parameter is reserved for possible load balancing
	var gameserver_peer_id: int = gameserver_list[gameserver]
	if gameserver_peer_id:
		var error: int = rpc_id(gameserver_peer_id, "HandleToken", token)
		if error:
			print("HandleToken RPC call failed: %s" % error_string(error))
	else:
		print("No valid gameserver found")
