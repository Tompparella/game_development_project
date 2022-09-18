extends Node

var filepath: String = "user://PlayerIDs.json"

var PlayerIDs: Dictionary

func _ready():
	var playerIDs_file: File = File.new()
	if (!playerIDs_file.file_exists(filepath)):
		playerIDs_file.open(filepath, File.WRITE)
		playerIDs_file.close()
	playerIDs_file.open(filepath, File.READ)
	var playerIDs_json: JSON = JSON.new()
	var parse_error: int = playerIDs_json.parse(playerIDs_file.get_as_text())
	if parse_error:
		print(error_string(parse_error))
	else:
		PlayerIDs = playerIDs_json.get_data()
	playerIDs_file.close()

func SavePlayerIDs() -> bool:
	var savefile = File.new()
	if savefile.open(filepath, File.WRITE):
		print("!! URGENT ERROR: FAILED TO OPEN PLAYERID FILE !!")
		if savefile.is_open():
			savefile.close()
		return false
	savefile.store_line(JSON.stringify(PlayerIDs))
	savefile.close()
	return true

func AddPlayerID(username: String, password: String, salt: String) -> bool:
	PlayerData.PlayerIDs[username] = { "password": password, "salt": salt }
	return SavePlayerIDs()

# Returns true if username exists
func CheckUsername(username: String) -> bool:
	return PlayerIDs.has(username)

func CheckPassword(username: String, password: String) -> bool:
	return PlayerIDs[username].password == password
