extends Surrounding
class_name Shop

# TODO: Shop title is supposed to make up the inventory of the store. Make this happen when logic is moved to the server.
@export var shop_title: String
var players: Array[Player] = []
var inventory: Dictionary

func _init() -> void:
	if shop_title:
		pass
	SetInventory()

func Interact(_player: Player) -> void:
	players.append(_player)
	UIControl.OpenShopModal(self)

func SetInventory() -> void:
#	var shop_items: Array[Item] = GameManager.GetShopInventory()
	var _inventory: Dictionary = {}
#	for entry in shop_items:
#		randomize()
#		_inventory[entry] = randi_range(1, 10)
	inventory = _inventory

func Buy(_item: Item, _player: Player) -> int:
	var result: int = 3
#	var result: int = 1 # Result code. 1 = Good
#	if (inventory[_item] <= 0):
#		result =  2 # = Insufficient supply
#	if (!_player.CanBuy(_item.value)):
#		result = 3 # = Player can't buy
#	if result == 1:
#		_player.AddCurrency(-(_item.value))
#		_player.AddItem(_item)
#		inventory[_item] -= 1
	return result

func _Body_Exited(body: Node2D) -> void:
	if (body is Player && body in players):
		players.erase(body)
		# TODO: When transferring to server, this has to be an client specific rpc call
		UIControl.CloseShopModal()
		
