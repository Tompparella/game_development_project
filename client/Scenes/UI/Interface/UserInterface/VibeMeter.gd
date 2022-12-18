extends Control
class_name VibeView

signal pulse() # TODO: Connect pulse signal to somewhere that plays pulse audio

@onready var vibe_over: TextureProgressBar = $VibeOver
@onready var vibe_under: TextureProgressBar = $VibeUnder

@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color.YELLOW
@export var danger_color: Color = Color.RED
@export var pulse_color: Color = Color.DARK_RED
@export var warning_zone: float = 0.3
@export var danger_zone: float = 0.15

var pulse_tween: Tween
var vibe_tween: Tween
var pulsing: bool = false

func Initialize(player: Player) -> void:
	var player_vibe: float = player.GetVibe()
	vibe_over.value = player_vibe
	vibe_under.value = player_vibe
	player.vibe_changed.connect(_Vibe_Changed)
	_Vibe_Changed(player_vibe)

func _Vibe_Changed(vibe: float) -> void:
	# Select which progress to be interpolated depending on whether we're adding or taking vibe
	if vibe_over.value > vibe:
		vibe_over.value = vibe
		TweenVibeAmount(vibe_under, vibe)
	else:
		vibe_under.value = vibe
		TweenVibeAmount(vibe_over, vibe)
	AssignColor(vibe)

func EmitPulseSignal() -> void:
	emit_signal('pulse')

func TweenVibeAmount(progress_bar: TextureProgressBar, vibe: float) -> void:
	vibe_tween = create_tween()
	vibe_tween.tween_property(progress_bar, "value", vibe, 1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func PulseOn() -> void:
	if !pulse_tween || !pulse_tween.is_running():
		pulse_tween = create_tween().set_loops()
		pulse_tween.tween_property(vibe_over, "tint_progress", pulse_color, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse_tween.tween_callback(EmitPulseSignal)

func PulseOff() -> void:
	if pulse_tween:
		pulse_tween.kill()

func AssignColor(vibe: float) -> void:
	if vibe == 0 && pulse_tween:
		pulse_tween.kill()
		return
	var max_vibe: float = vibe_over.max_value
	if ((danger_zone * max_vibe > vibe) || ((1 - danger_zone) * max_vibe < vibe)):
		vibe_over.tint_progress = danger_color
		PulseOn()
		return
	elif ((warning_zone * max_vibe > vibe) || ((1 - warning_zone) * max_vibe < vibe)):
		vibe_over.tint_progress = warning_color
	else:
		vibe_over.tint_progress = normal_color
	PulseOff()
