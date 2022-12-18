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
	var final_wait_time: float = base_wait_time
	if item is Consumable:
		final_wait_time = final_wait_time + ((item as Consumable).vibe) / 10
	start(final_wait_time)
	set_process_unhandled_key_input(true)
	player.update_use_progress.emit(final_wait_time)

func UseItem() -> void:
	player.item_used.emit(item.item_id)
	set_process_unhandled_key_input(false)

func FailUseItem():
	player.update_use_progress.emit(-1.0)
	stop()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("Use1"):
		FailUseItem()
