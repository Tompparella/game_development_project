extends Control
class_name ScoreView

@onready var score_counter: Label = $ScoreCounter

func Initialize(player: Player) -> void:
	score_counter.text = str(player.GetFlex())

func _Score_Changed(score: int) -> void:
	score_counter.text = str(score)
