extends Node
class_name UserInterface

@onready var vibe: VibeView = $Vibe
@onready var items: ItemsView = $Items
@onready var score: ScoreView = $Score
@onready var returnables: ReturnablesView = $Returnables
@onready var currency: CurrencyView = $Currency

func Initialize(player: Player):
	player.connect("item_added", _Item_Added)
	player.connect("item_removed", _Item_Removed)
	player.connect("vibe_changed", vibe._Vibe_Changed)
	player.connect("score_changed", score._Score_Changed)
	player.connect("currency_changed", currency._Currency_Changed)
	
func _Item_Added(item: Item):
	if item is Returnable:
		returnables.AddItem(item)
	else:
		items.AddItem(item)

func _Item_Removed(item: Item):
	if item is Returnable:
		returnables.RemoveItem(item)
	else:
		items.RemoveItem(item)
