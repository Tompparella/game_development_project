extends Surrounding
class_name Npc

var quest_giver: bool = false
var tasks: Array[Task] = []

func Interact(_player: Player) -> void:
	var new_task: Task = GameManager.TasksList["test"]
	new_task.Start(name, "test")
	_player.AddTask(new_task)
	print(new_task)
	print("Task added")
