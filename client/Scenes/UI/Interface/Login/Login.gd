extends Control
class_name LoginScreen

@onready var login: VBoxContainer = get_node("Menu/Login")
@onready var register: VBoxContainer = get_node("Menu/Register")
@onready var username_input: LineEdit = login.get_node("Username")
@onready var password_input: LineEdit = login.get_node("Password")
@onready var login_button: BaseButton = login.get_node("LoginButton")
@onready var register_button: BaseButton = login.get_node("RegisterButton")
@onready var create_username_input: LineEdit = register.get_node("Username")
@onready var create_password_input: LineEdit = register.get_node("Password")
@onready var create_repeat_input: LineEdit = register.get_node("Repeat")
@onready var confirm_button: BaseButton = register.get_node("ConfirmButton")
@onready var back_button: BaseButton = register.get_node("BackButton")

var special_characters = RegEx.new()
var capital_letters = RegEx.new()

func _ready() -> void:
	special_characters.compile("[^A-Za-z0-9]")
	capital_letters.compile("[A-Z]")
	ToggleLoginScreen()

func DisableLoginButtons() -> void:
	login_button.disabled = true
	register_button.disabled = true
	confirm_button.disabled = true
	back_button.disabled = true

func EnableLoginButtons() -> void:
	login_button.disabled = false
	register_button.disabled = false
	confirm_button.disabled = false
	back_button.disabled = false

func ToggleRegisterScreen() -> void:
	login.hide()
	register.show()
	
func ToggleLoginScreen() -> void:
	register.hide()
	login.show()


func _Login_Button_Pressed() -> void:
	var username: String = username_input.text.strip_edges()
	var password: String = password_input.text.strip_edges()
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
	var username: String = create_username_input.text.strip_edges()
	var password: String = create_password_input.text.strip_edges()
	var password_repeat: String = create_repeat_input.text.strip_edges()
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
