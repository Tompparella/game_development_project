extends Node

var filepath: String = "user://PlayerIDs.json"

var PlayerIDs: Dictionary

func _ready():
	if (!FileAccess.file_exists(filepath)):
		var new_file: FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
		new_file.close()
	var file: FileAccess = FileAccess.open(filepath, FileAccess.READ)
	var playerIDs_json: JSON = JSON.new()
	var parse_error: int = playerIDs_json.parse(file.get_as_text())
	if parse_error:
		print(error_string(parse_error))
	else:
		PlayerIDs = playerIDs_json.get_data()
	file = null

func SavePlayerIDs() -> bool:
	var savefile: FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	if savefile == null:
		print("!! URGENT ERROR: FAILED TO OPEN PLAYERID FILE !!")
		print(FileAccess.get_open_error())
		if savefile.is_open():
			savefile = null
		return false
	savefile.store_line(JSON.stringify(PlayerIDs))
	savefile = null
	return true

func AddPlayerID(username: String, password: String, salt: String) -> bool:
	PlayerData.PlayerIDs[username] = { "password": password, "salt": salt }
	return SavePlayerIDs()

# Returns true if username exists
func CheckUsername(username: String) -> bool:
	return PlayerIDs.has(username)

func CheckPassword(username: String, password: String) -> bool:
	return PlayerIDs[username].password == password
