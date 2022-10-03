extends Control
class_name ScoreView

@onready var score_counter: Label = $ScoreCounter

func _Score_Changed(score: int) -> void:
	score_counter.text = str(score)
