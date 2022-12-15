extends Node

var ItemsList: Dictionary = {}

func GetItem(item_id: String) -> Item:
	return ItemsList.get(item_id, ItemsList.get("default"))
 
func LoadItems(items_data: Array) -> void:
	for entry in items_data:
		match entry["type"]:
			"consumable":	# TODO: Move object parsing to the constructors
				ItemsList[entry["id"]] = Consumable.new(entry["id"], entry["name"], entry["description"], entry["value"], entry["texture"], entry["vibe"], entry["flex"])
			"returnable":
				ItemsList[entry["id"]] = Returnable.new(entry["id"], entry["name"], entry["description"], entry["value"], entry["texture"], entry["size"])
			_:
				ItemsList[entry["id"]] = Item.new(entry["id"], entry["name"], entry["description"], entry["value"], entry["texture"])
