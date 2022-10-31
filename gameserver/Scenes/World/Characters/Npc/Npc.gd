extends Surrounding
class_name Npc

var quest_giver: bool = false
var tasks: Array[Task] = []

func Interact(_player: Player) -> void:
	var new_task: Task = GameManager.GetTask("test")
	new_task.Start(name, "test")
	if _player.AddTask(new_task):
		print("Task added")

func _Interaction_Entered(_area: Area2D) -> void:
	pass

func _Interaction_Exited(_area: Area2D) -> void:
	pass
