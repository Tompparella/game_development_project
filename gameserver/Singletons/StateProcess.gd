extends Node

var world_state: Dictionary = {}

# Currently physics process is limited to 20 times a second (in project settings).
# This can be either increased (reduces performance) or reduced (increases performance).
func _physics_process(_delta: float) -> void:
	if !GameServer.player_states_collection.is_empty():
		world_state["players"] = GameServer.player_states_collection.duplicate(true)
		world_state["timestamp"] = Time.get_unix_time_from_system()
		GameServer.UpdateWorldState(world_state)
