extends Item
class_name Consumable

func _init(_item_name: String, _description: String, _value: float, _texture: String, _vibe: float, _flex: int) -> void:
	vibe = _vibe
	flex = _flex
	consumable = true
	super._init(_item_name, _description, _value, _texture)

# Use item only if they have it in their inventory
func Use(_player: Player) -> void:
	if _player.RemoveItem(self):
		_player.AddVibe(vibe)
		_player.AddFlex(flex)
