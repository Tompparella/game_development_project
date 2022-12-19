extends Control
class_name CurrencyView

@onready var currency_counter: Label = $CurrencyCounter

func Initialize(player: Player) -> void:
	currency_counter.text = str(player.GetCurrency())

func _Currency_Changed(currency: float) -> void:
	var currency_string: String = str(currency)
	if currency_counter.text != currency_string:
		currency_counter.text = currency_string
		AudioManager.PlayEffect(AudioManager.currency)
