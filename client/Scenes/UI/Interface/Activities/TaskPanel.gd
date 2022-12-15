extends Control

class_name TaskPanel

@onready var task_description: RichTextLabel = $Panel/VBoxContainer/RichTextLabel
@onready var task_goals: RichTextLabel = $Panel/VBoxContainer/RichTextLabel2

var decsription_string: String = "[fill]%s[/fill]"
var goal_string: String = "[color=navy][center][b]Target:[/b] [i][u]%s[/u][/i][/center][/color]\n%s - [b]%s[/b]"

func _ready() -> void:
	task_description.bbcode_enabled = true
	task_goals.bbcode_enabled = true
	

func Update(task: Task) -> void:
	task_description.text = decsription_string % task.description # TODO: Error here
	var goals_string: String = ""
	var items: Dictionary = task.conditions.get("items")
	var goals: Dictionary = task.conditions.get("goals")
	for entry in items.keys():
		var item: Item = GameItems.GetItem(entry)
		goals_string += "%s: %s\n" % [item.item_name, items[entry]]
	for entry in goals.keys():
		var goal: Dictionary = goals[entry]
		goals_string += goal_string % [goal["target"], goal["description"], goal["completed"]]
	task_goals.text = goals_string
