extends Control

class_name TaskPanel

@onready var task_description: RichTextLabel = $Panel/RichTextLabel
@onready var task_goals: RichTextLabel = $Panel/RichTextLabel2

func Update(task: Task) -> void:
	task_description.text = task.description # TODO: Error here
	var goals_string: String = ""
	var items: Dictionary = task.conditions.get("items")
	var goals: Dictionary = task.conditions.get("goals")
	for entry in items.keys():
		print(entry)
		goals_string += "%s: %s\n" % [entry, items[entry]]
	for entry in goals.keys():
		var goal: Dictionary = goals[entry]
		goals_string += "Target: %s\n%s - %s" % [goal["target"], goal["description"], goal["completed"]]
	task_goals.text = goals_string
