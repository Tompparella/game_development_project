extends Surrounding
class_name Interactable

@onready var body: RigidBody2D = get_node(".")
# Could be extended t.ex. Carriable, for player to carry

func _ready() -> void:
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if body.linear_velocity.length()<= 2.0:
		body.sleeping = true
		_Sleeping_Changed()
	else:
		update_position.emit(self)

func Interact(player: Player) -> void:
	# Do cool stuff. Can be extended to suit many needs.
	set_physics_process(true)
	var impulse_vector: Vector2 = Vector2(65, 65) * player.global_position.direction_to(global_position)
	body.apply_central_impulse(impulse_vector)

func _Sleeping_Changed():
	if body.sleeping:
		set_physics_process(false)
