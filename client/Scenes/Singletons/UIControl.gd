extends Node

@onready var login_screen: Control = get_node("../GameManager/UILayer/LoginScreen")
@onready var login: VBoxContainer = login_screen.get_node("Menu/Login")
@onready var register: VBoxContainer = login_screen.get_node("Menu/Register")
@onready var username_input: LineEdit = login.get_node("Username")
@onready var password_input: LineEdit = login.get_node("Password")
@onready var login_button: BaseButton = login.get_node("LoginButton")
@onready var register_button: BaseButton = login.get_node("RegisterButton")
@onready var create_username_input: LineEdit = register.get_node("Username")
@onready var create_password_input: LineEdit = register.get_node("Password")
@onready var create_repeat_input: LineEdit = register.get_node("Repeat")
@onready var confirm_button: BaseButton = register.get_node("ConfirmButton")
@onready var back_button: BaseButton = register.get_node("BackButton")

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
	
func HideLoginScreen() -> void:
	login_screen.hide()
	
func ShowLoginScreen() -> void:
	login_screen.show()
