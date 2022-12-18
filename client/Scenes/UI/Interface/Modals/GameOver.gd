extends Control

class_name GameOverModal

@onready var reason: Label = $VBoxContainer/VBoxContainer/Label2
@onready var flex: Label = $VBoxContainer/PanelContainer/VBoxContainer2/Stats/FlexContainer/Flex
@onready var currency: Label = $VBoxContainer/PanelContainer/VBoxContainer2/Stats/Currency/Currency

var GameoverReasons: Dictionary = {
	"blackout": "You blacked out",
	"boredom": "You got bored and went home"
}

func Initialize(player: Player) -> void:
	if player.GetVibe() > 10:
		reason.text = GameoverReasons["blackout"]
	else:
		reason.text = GameoverReasons["boredom"]
	flex.text = "%s" % player.GetFlex()
	currency.text = "%s" % player.GetCurrency()

func _On_Restart_Pressed() -> void:
	hide()
	GameManager.RequestRestart()