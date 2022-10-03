extends Surrounding

@onready var body: PhysicsBody2D = get_node(".")
# Could be extended t.ex. Carriable, for player to carry
func Interact(player: Player) -> void:
	# Do cool stuff. Can be extended to suit many needs.
	if body is RigidBody2D:
		var impulse_vector: Vector2 = Vector2(65, 65) * player.global_position.direction_to(global_position)
		body.apply_central_impulse(impulse_vector)
