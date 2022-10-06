extends State
class_name MotionState

var friction: float = 20.0
var motion: Vector2 = Vector2.ZERO
var moving: bool = false

func Update(_delta: float) -> void:
	if !moving:
		motion = motion.move_toward(Vector2.ZERO, friction)
	player.velocity = motion
	player.move_and_slide()
	if motion == Vector2.ZERO:
		emit_signal("finished", "idle")

func HandleInput(event: InputEvent) -> void:
	# Check for stun/immobilization, etc.
	if event.is_action_pressed("Interact"):
		player.Interact()
	elif event.is_action_pressed("Use1"):
		player.UseItem()
