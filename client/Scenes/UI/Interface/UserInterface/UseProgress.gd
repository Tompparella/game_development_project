extends Control

class_name UseProgress
@onready var progress_bar: TextureProgressBar = $TextureProgressBar

var progress_tween: Tween

func StartUseProgress(wait_time: float) -> void:
	show()
	progress_tween = create_tween()
	progress_tween.tween_property(progress_bar, "value", 100, wait_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	progress_tween.tween_callback(StopUseProgress)

func StopUseProgress() -> void:
	hide()
	progress_bar.value = 0
	progress_tween.kill()
