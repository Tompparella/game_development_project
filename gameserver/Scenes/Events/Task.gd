extends Object

class_name Task

var task_giver: String
var description: String
var time_left: float	# Some tasks might have a limited amount of time to complete
var conditions: Dictionary = {
	"items": {},	# Item id's required for the completion of the task: {"item_id": number}
	"goals": {},	# Goals that are granted from interacting with the world: {"goal_id": true | false}
}
var rewards: Dictionary = {
	"items": [], 	# String array of item_ids
	"currency": 0.0
}

func _init(_description: String, _conditions: Dictionary, _rewards: Dictionary) -> void:
	# TODO: Rewards could be randomized based on task difficulty
	conditions = _conditions
	rewards = _rewards
	description = _description

func Start(_task_giver: String, time_given: float = -1.0) -> void:
	if time_given > 0:
		# TODO: Handle timer here
		time_left = time_given
		pass
	task_giver = _task_giver

func CheckConditions(player: Player) -> void:
	var required_items: Dictionary = conditions.get("items")
	var required_goals: Dictionary = conditions.get("goals")
	# TODO: Actual condition check logic
	if required_items != null:
		pass
	if required_goals != null:
		pass

func GiveReward(player: Player) -> void:
	# TODO: Actual reward gifting function
	pass
