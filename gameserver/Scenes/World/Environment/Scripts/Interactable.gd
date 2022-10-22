extends Surrounding
class_name Interactable

@onready var body: RigidBody2D = get_node(".")
# Could be extended t.ex. Carriable, for player to carry
var last_velocity: float = -1.0

func _ready() -> void:
	Freeze()
	super._ready()

func _physics_process(_delta: float) -> void:
	var current_velocity: float = body.linear_velocity.length()
	if current_velocity < last_velocity:
		if current_velocity < 20.0:
			Freeze()
	last_velocity = current_velocity
	update_position.emit(self)

func Interact(player: Player) -> void:
	# Do cool stuff. Can be extended to suit many needs.
	var impulse_vector: Vector2 = Vector2(65, 65) * player.global_position.direction_to(global_position)
	body.freeze = false
	body.apply_central_impulse(impulse_vector)
	set_physics_process(true)

func Freeze() -> void:
	last_velocity = -1.0
	body.freeze = true
	set_physics_process(false)
