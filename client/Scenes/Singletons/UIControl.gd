extends Node

@onready var login_screen: LoginScreen = get_node("../Game/UILayer/LoginScreen")
@onready var user_ui: UserInterface = get_node("../Game/UILayer/UserInterface")
@onready var shop_modal: ShopModal = get_node("../Game/UILayer/ShopModal")
@onready var item_hint: ItemHint = get_node("../Game/UILayer/ItemHint")

# Initialize UI variables

func Initialize(player: Player) -> void:
	user_ui.Initialize(player) # This needs to be move somewhere else (UI gets initialized before player is fetched)
	shop_modal.Initialize(player)

# Login screen controls

func DisableLoginButtons() -> void:
	login_screen.DisableLoginButtons()
	
func EnableLoginButtons() -> void:
	login_screen.EnableLoginButtons()
	
func ToggleRegisterScreen() -> void:
	login_screen.ToggleRegisterScreen()
	
func ToggleLoginScreen() -> void:
	login_screen.ToggleLoginScreen()

func HideLoginScreen() -> void:
	login_screen.hide()
	
func ShowLoginScreen() -> void:
	login_screen.show()

# Shop UI controls

func OpenShopModal(shop: Shop) -> void:
	shop_modal.Open(shop)

func CloseShopModal() -> void:
	shop_modal.Close()

# Item hint controls

func ShowItemHint(item: Item) -> void:
	item_hint.Show(item)

func HideItemHint() -> void:
	item_hint.Hide()
