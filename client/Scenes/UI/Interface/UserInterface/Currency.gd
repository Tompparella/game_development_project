extends Control
class_name CurrencyView

@onready var currency_counter: Label = $CurrencyCounter

func _Currency_Changed(currency: float) -> void:
	currency_counter.text = str(currency)
