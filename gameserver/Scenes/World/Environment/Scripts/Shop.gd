extends Surrounding
class_name Shop

# TODO: Shop title is supposed to make up the inventory of the store. Make this happen when logic is moved to the server.
@export var shop_title: String
var players: Array[Player] = []
var inventory: Dictionary

func _init() -> void:
	if shop_title:
		# TODO: Shop specific handling here
		pass
	SetInventory()

func Interact(_player: Player) -> void:
	if !(_player in players):
		players.append(_player)
	GameManager.OpenShop(_player.name, {"inventory": inventory, "shop_id": name})

func Initialize(_item: Item = null, _texture: String = "", _inventory: Dictionary = {}) -> void:
	inventory = _inventory
	super.Initialize(_item, _texture)

func SetInventory() -> void:
	var shop_items: Array[String] = GameManager.GetShopInventory()
	var _inventory: Dictionary = {}
	for entry in shop_items:
		randomize()
		_inventory[entry] = randi_range(1, 10)
	inventory = _inventory

func Buy(_item: Item, _player: Player) -> int:
	var result: int = 1 # Result code. 1 = Good
	if (inventory[_item.item_id] <= 0):
		result =  2 # = Insufficient supply
	if (!_player.CanBuy(_item.value)):
		result = 3 # = Player can't buy
	if result == 1:
		_player.TakeCurrency(_item.value)
		_player.AddItem(_item)
		inventory[_item.item_id] -= 1
		GameManager.UpdateShopInventory(players, _item.item_id, inventory[_item.item_id])
	return result

func _Body_Exited(body: Node2D) -> void:
	if (body is Player && body in players):
		players.erase(body)
		GameManager.CloseShop(name)
		# TODO: When transferring to server, this has to be an client specific rpc call
		# UIControl.CloseShopModal()
		
