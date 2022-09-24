extends Surrounding
class_name ReturnMachine

@onready var replenish_timer: Timer = get_node("../Timer")
@export var max_returnables: int = 100
@export var replenish_amount: int = 10
var current_returnables: int = 0

func Interact(player: Player) -> void:
	if current_returnables < max_returnables:
		var returnables: Array[Returnable] = player.GetReturnables()
		player.AddCurrency(ReturnReturnables(returnables))

func ReturnReturnables(returnables: Array[Returnable]) -> float:
	var value: float = 0.0
	for i in range(returnables.size()-1, -1, -1):
		print(i)
		if (current_returnables >= max_returnables):
			break
		value += returnables[i].value
		current_returnables += returnables[i].size
		returnables.remove_at(i)
	return value

func _Replenish_Timer() -> void:
	if current_returnables >= replenish_amount:
		current_returnables -= replenish_amount
