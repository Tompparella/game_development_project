extends Object

class_name Task

var task_giver: String
var description: String
var time_left: float	# Some tasks might have a limited amount of time to complete
var conditions: Dictionary = {
	"items": {},	# Item id's required for the completion of the task: {"item_id": number}
	"goals": {},	# Goals that are granted from interacting with the world: {"goal_id": {"discription": string, "target": string, "completed": bool }}
}
var rewards: Dictionary = {
	"items": {}, 	# Item_ids: {"item_id": number}
	"currency": 0.0
}

func _init(task_data: Dictionary) -> void:
	task_giver = task_data["task_giver"]
	description = task_data["description"]
	time_left = task_data["time_left"]
	conditions = task_data["conditions"]
	rewards = task_data["rewards"]
