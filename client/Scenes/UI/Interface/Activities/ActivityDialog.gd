extends Control
class_name ActivityDialog

@onready var task_container: VBoxContainer = $VBoxContainer
var tasks: Dictionary = {} # {task_giver: task}

var packed_task = preload("res://Scenes/UI/Interface/Activities/TaskPanel.tscn")

# TODO: Initialize based on player values
func Initialize(_player: Player) -> void:
	for entry in task_container.get_children():
		entry.queue_free()
	tasks.clear()

func _Task_Updated(task: Task, removed: bool, complete: bool) -> void:
	var existing_task: Task = tasks.get(task.task_giver)
	if existing_task:
		if removed:
			tasks.erase(task.task_giver)
			RemoveTask(task, complete)
		else:
			tasks[task.task_giver] = task
			UpdateTask(task)
		return
	tasks[task.task_giver] = task
	NewTask(task)

func NewTask(task: Task) -> void:
	var new_task: TaskPanel = packed_task.instantiate()
	task_container.add_child(new_task)
	new_task.name = task.task_giver
	new_task.Update(task)
	AudioManager.PlayEffect(AudioManager.task_started)

func UpdateTask(task: Task) -> void:
	var task_node: TaskPanel = task_container.get_node(task.task_giver)
	task_node.Update(task)
	AudioManager.PlayEffect(AudioManager.task_updated)

func RemoveTask(task: Task, complete: bool) -> void:
	var task_node: TaskPanel = task_container.get_node(task.task_giver)
	task_node.queue_free()
	tasks.erase(task.task_giver)
	if complete:
		AudioManager.PlayEffect(AudioManager.task_finished)
	else:
		AudioManager.PlayEffect(AudioManager.interact) # TODO: Change 'interact' to a designated task interception audio
