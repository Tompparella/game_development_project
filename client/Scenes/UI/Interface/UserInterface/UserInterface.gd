extends Node
class_name UserInterface

@onready var vibe: VibeView = $Vibe
@onready var items: ItemsView = $Items
@onready var score: ScoreView = $Score
@onready var returnables: ReturnablesView = $Returnables
@onready var currency: CurrencyView = $Currency

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("NextItem"):
		items.NextItem()
	elif event.is_action_pressed("PreviousItem"):
		items.PreviousItem()

func Initialize(player: Player):
	# TODO: Could do a more thorough initialization for other UI elements as well (take example from vibe)
	player.item_added.connect(_Item_Added)
	player.item_removed.connect(_Item_Removed)
	player.flex_changed.connect(score._Score_Changed)
	player.currency_changed.connect(currency._Currency_Changed)
	vibe.Initialize(player)

func GetSelectedItem() -> Item:
	return items.GetSelectedItem()

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
