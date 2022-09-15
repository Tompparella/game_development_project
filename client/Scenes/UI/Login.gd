extends NinePatchRect

onready var username_input: LineEdit = get_node("Fields/Username")
onready var password_input: LineEdit = get_node("Fields/Password")
onready var login_button: BaseButton = get_node("Fields/LoginButton")
var lol : TextureButton
func _OnLoginButtonPressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	if username == "" || password == "":
		# TODO: Better handling here
		print("Missing field")
	else:
		login_button.disabled = true
		print("Logging in...")
		print(username, password)
		Gateway.ConnectToServer(username, password)
func _OnRegisterButtonPressed() -> void:
	print("Register now plz")
