extends Timer
class_name PlayerTimer

var base_wait_time: float
var item: Item
var player: Player

func _ready() -> void:
	set_process_unhandled_key_input(false)

func Initialize(_player: Player) -> void:
	player = _player
	# wait_time can be set to match user's global consumption time
	base_wait_time = 0.5
	one_shot = true
	# TODO: If adding more timed functions, transfer to dynamically changing timeout connection
	timeout.connect(UseItem)

func StartUseItemTimer(_item: Item) -> void:
	item = _item
	if item is Consumable:
		StartConsumableTimer()
	else:
		start(base_wait_time)
	set_process_unhandled_key_input(true)
	print("Timer started")

func StartConsumableTimer() -> void:
	# TODO: Play consume audio, etc.
	start(base_wait_time + ((item as Consumable).vibe) / 10)

func UseItem() -> void:
	print("Item used")
	item.Use(player)
	set_process_unhandled_key_input(false)

func FailUseItem():
	print("Item use stopped")
	stop()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("Use1"):
		FailUseItem()
