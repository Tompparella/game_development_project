extends Object

class_name Task

var task_giver: String
var description: String
var time_left: float	# Some tasks might have a limited amount of time to complete
var conditions: Dictionary = {
	"items": {},	# Item id's required for the completion of the task: {"item_id": number}
	"goals": {},	# Goals that are granted from interacting with the world: {"goal_id": {"description": string, "target": string, "completed": bool }}
}
var rewards: Dictionary = {
	"items": {}, 	# Item_ids: {"item_id": number}
	"currency": 0.0,
	"flex": 0,
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
	description = description % task_giver
	var goals: Dictionary = conditions.get("goals")
	for entry in goals.keys():
		var goal: Dictionary = goals[entry]
		goal["description"] = goal["description"] % goal["target"]

func ValidateConditions(id: String, player: Player) -> bool:
	var goals: Dictionary = conditions.get("goals")
	var validated: bool = false
	for entry in goals.keys():
		var goal: Dictionary = goals[entry]
		if goal["target"] == id && !goal["completed"]:
			goal["completed"] = true
			validated = true
	if validated:
		player.task_updated.emit(player.name, self)
	return validated

# Checks tasks progress by first taking all possible required items from player,
# then checking whether the player has brought all required items to the guest giver,
# and lastly checking whether the tasks' goals are met. If task is deemed complete,
# finish it and give the player their reward.
func CheckProgress(player: Player) -> void:
	var required_items: Dictionary = conditions.get("items")
	var required_goals: Dictionary = conditions.get("goals")
	var completed: bool = true
	for entry in TakeRequiredItems(player, required_items):
		required_items[entry] -= 1
	for entry in required_items.keys():
		if required_items[entry] != 0:
			completed = false
	for entry in required_goals.keys():
		if !required_goals[entry]["completed"]:
			completed = false
	if completed:
		Finish(player)
	else:
		player.task_updated.emit(player.name, self)

func Finish(player: Player) -> bool:
	# TODO: Handle player not receiving reward items due to full inventory
	GiveReward(player)
	player.RemoveTask(self, true)
	return true

func TakeRequiredItems(player: Player, required_items: Dictionary) -> Array[String]:
	var removed_items: Array[Item] = []
	for entry in required_items.keys():
		var item: Item = GameItems.GetItem(entry)
		for i in range(required_items[entry]):
			removed_items.append(item)
	return player.RemoveItemArray(removed_items)

func GiveReward(player: Player) -> void:
	var items: Dictionary = rewards["items"]
	var currency: float = rewards["currency"]
	var flex: int = rewards["flex"]
	player.AddValues(flex, 0.0, currency)
	var reward_items: Array[Item] = []
	for entry in items.keys():
		var item: Item = GameItems.GetItem(entry)
		for i in range(items[entry]):
			reward_items.append(item)
	player.AddItemArray(reward_items)

func GetAsDictionary() -> Dictionary:
	return {
		"task_giver": task_giver,
		"description": description,
		"time_left": time_left,
		"conditions": conditions,
		"rewards": rewards,
	}
