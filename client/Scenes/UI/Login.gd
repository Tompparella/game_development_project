extends NinePatchRect

var special_characters = RegEx.new()
var capital_letters = RegEx.new()

func _ready() -> void:
	special_characters.compile("[^A-Za-z0-9]")
	capital_letters.compile("[A-Z]")
	UIControl.ToggleLoginScreen()

func _Login_Button_Pressed() -> void:
	var username: String = UIControl.username_input.text.strip_edges()
	var password: String = UIControl.password_input.text.strip_edges()
	if username.is_empty() || password.is_empty():
		# TODO: Better handling here
		print("Missing field")
	else:
		UIControl.DisableLoginButtons()
		print("Logging in...")
		Gateway.ConnectToServer(username, password)
		
func _Register_Button_Pressed() -> void:
	UIControl.ToggleRegisterScreen()
		
func _Confirm_Button_Pressed() -> void:
	var username: String = UIControl.create_username_input.text.strip_edges()
	var password: String = UIControl.create_password_input.text.strip_edges()
	var password_repeat: String = UIControl.create_repeat_input.text.strip_edges()
	if username.is_empty() || password.is_empty() || password_repeat.is_empty():
		# TODO: Better handling here
		print("Missing field")
	elif password.length() < 6 || !special_characters.search(password) || !capital_letters.search(password):
		print("Please enter a password with at least 6 characters that includes at least one special character and a capital letter")
	elif password != password_repeat:
		print("The repeated password doesn't match the original one. Please check and try again")
	else:
		UIControl.DisableLoginButtons()
		print("Creating a new user account")
		Gateway.ConnectToServer(username, password, true)
	
func _Back_Button_Pressed() -> void:
	UIControl.ToggleLoginScreen()
