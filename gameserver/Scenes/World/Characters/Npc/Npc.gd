extends Surrounding
class_name Npc

@export var quest_giver: bool = false

func Interact(player: Player) -> void:
	if quest_giver:
		HandleTask(player)
	for entry in player.GetTasks():
		entry.ValidateConditions(name, player)

func HandleTask(player: Player) -> void:
	for entry in player.GetTasks():
		if entry.task_giver == name:
			entry.CheckProgress(player)
			return
	NewTask(player)

func NewTask(player: Player) -> void:
	var new_task: Task = GameManager.GenerateTask()
	new_task.Start(name)
	player.AddTask(new_task)

func _Interaction_Entered(_area: Area2D) -> void:
	pass

func _Interaction_Exited(_area: Area2D) -> void:
	pass
