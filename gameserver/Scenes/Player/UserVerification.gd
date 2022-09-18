extends Node

@onready var container_scene = preload("res://Scenes/Player/UserContainer.tscn")

var awaiting_verification = {}

func Initiate(player_id: int) -> void:
	# Authentication token
	awaiting_verification[player_id] = {"Timestamp": int(Time.get_unix_time_from_system())}
	GameServer.FetchToken(player_id)
	
func Verify(player_id: int, token: String) -> void:
	var verification: bool = false
	while int(Time.get_unix_time_from_system()) - GetTokenTimestamp(token) <= 30:
		if GameServer.expected_tokens.has(token):
			verification = true
			CreateUserContainer(player_id)
			awaiting_verification.erase(player_id)
			GameServer.expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	GameServer.ReturnTokenVerificationResult(player_id, verification)
	if !verification:
		awaiting_verification.erase(player_id)
		GameServer.emit_signal("peer_disconnected", player_id)
	
func CreateUserContainer(player_id: int) -> void:
	var new_container = container_scene.instantiate()
	new_container.name = str(player_id)
	get_node("../UserContainer").add_child(new_container, true)
	var user_container: Node = get_node("../UserContainer/" + str(player_id))
	FillUserContainer(user_container)

func FillUserContainer(_user_container: Node) -> void:
	# TODO: Set player stats here
	print("Player stats set")

func GetTokenTimestamp(token: String) -> int:
	return token.right(10).to_int()

func _Verification_Expiration_Timeout():
	# If a player gets stuck in the token Verify loop (for example, sets the token timestamp as something ridiculously high -> unix_system_time - timestamp = -1000000)
	# the player is kept forever on the server, taking a space from other users. This timer checks that if a token is kept for more than x seconds, the user will get disconnected
	var current_time: int = int(Time.get_unix_time_from_system())
	var start_time: int
	if awaiting_verification != {}:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 30: # TODO: Move this to a constants file
				awaiting_verification.erase(key)
				var connected_peers: Array = Array(multiplayer.get_peers())
				if connected_peers.has(key):
					GameServer.ReturnTokenVerificationResult(key, false)
					GameServer.emit_signal("peer_disconnected", key)
	#print("Awaiting verification:")
	#print(awaiting_verification)
