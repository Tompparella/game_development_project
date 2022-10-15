extends Surrounding

@onready var replenish_timer: Timer = $Timer
@export var max_returnables: int = 100
@export var replenish_amount: int = 10
var current_returnables: int = 0

func Interact(player: Player) -> void:
	player.AddCurrency(ReturnReturnables(player))

func ReturnReturnables(player: Player) -> float:
	var value: float = 0.0
	if current_returnables >= max_returnables:
		return value
	var recycled_items: Array[Item] = []
	var returnable: Returnable = player.PopReturnable()
	while(returnable):
		recycled_items.append(returnable)
		value += returnable.value
		returnable = player.PopReturnable()
	if !recycled_items.is_empty():
		player.RecyclingFinished(recycled_items)
	return value

func _Replenish_Timer() -> void:
	if current_returnables >= replenish_amount:
		current_returnables -= replenish_amount
