extends Area2D
class_name Surrounding

@onready var body: PhysicsBody2D = get_parent()
@export var texture: Texture2D = Texture2D.new()
@export var item_name: String = ""

var item: Item

signal surrounding_removed(surrounding: Surrounding)

func _ready() -> void:
	if !item_name.is_empty():
		item = GameManager.GetItem(item_name)

func Initialize(_texture: Texture2D, _item: Item) -> void:
	texture = _texture
	var sprite: Sprite2D = $Sprite
	sprite.set_texture(texture)
	sprite.scale = Vector2(0.2, 0.2)

func Interact(_player: Player) -> void:
	pass

func Remove() -> void:
	emit_signal("surrounding_removed", self)
	body.queue_free()
