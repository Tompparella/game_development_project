extends Node

@onready var bottle_open: AudioStream = preload("res://Assets/Media/Audio/bottle_open.mp3")
@onready var can_open: AudioStream = preload("res://Assets/Media/Audio/can_open.mp3")
@onready var returnable_picked: AudioStream = preload("res://Assets/Media/Audio/returnable_picked.mp3")
@onready var gameover_effect: AudioStream = preload("res://Assets/Media/Audio/gameover_effect.mp3")
@onready var gameover_track: AudioStream = preload("res://Assets/Media/Audio/gameover_track.mp3")
@onready var sip_swallow: AudioStream = preload("res://Assets/Media/Audio/sip_swallow.mp3")
@onready var swallow: AudioStream = preload("res://Assets/Media/Audio/swallow.mp3")
@onready var task_started: AudioStream = preload("res://Assets/Media/Audio/task_started.mp3")
@onready var task_updated: AudioStream = preload("res://Assets/Media/Audio/task_updated.mp3")
@onready var task_finished: AudioStream = preload("res://Assets/Media/Audio/task_finished.mp3")
@onready var currency: AudioStream = preload("res://Assets/Media/Audio/currency.mp3")

@onready var track_1: AudioStream = preload("res://Assets/Media/Audio/track_1.mp3")
@onready var track_2: AudioStream = preload("res://Assets/Media/Audio/track_2.mp3")
@onready var track_3: AudioStream = preload("res://Assets/Media/Audio/track_3.mp3")

var global_audio: AudioStreamPlayer = AudioStreamPlayer.new()
var drink_progress: AudioStreamPlayer = AudioStreamPlayer.new()
var global_effect_pool: Array[AudioStreamPlayer]
var positional_effect_pool: Array[AudioStreamPlayer2D]

var background_tracks: Array[AudioStream] = []
var drink_use_effects: Array[AudioStream] = []

# Audio buses are Master, Effect, Audio TODO: Better handling

func Initialize() -> void:
	global_audio.bus = "Audio"
	drink_progress.bus = "Effect"
	drink_progress.stream = swallow
	background_tracks = [track_1, track_2, track_3]
	drink_use_effects = [bottle_open, can_open]
	add_child(global_audio)
	add_child(drink_progress)
	NextTrack()

func PlayAudio(audio_stream: AudioStream) -> void:
	global_audio.stop()
	global_audio.stream = audio_stream
	global_audio.play()

func NextTrack() -> void:
	global_audio.stop()
	if !global_audio.finished.is_connected(NextTrack):
		global_audio.finished.connect(NextTrack)
	randomize()
	global_audio.stream = background_tracks[randi_range(0, background_tracks.size()-1)]
	global_audio.play()

func PlayEffect(audio_stream: AudioStream) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.bus = "Effect"
	global_effect_pool.append(audio_player)
	audio_player.stream = audio_stream
	add_child(audio_player)
	audio_player.play()
	await audio_player.finished
	StopEffect(audio_player)

func PlayPositionalEffect(audio_stream: AudioStream, _position: Vector2 = Vector2(0,0)) -> void:
	var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	audio_player.bus = "Effect"
	positional_effect_pool.append(audio_player)
	audio_player.stream = audio_stream
	add_child(audio_player)
	audio_player.global_position = _position
	audio_player.play()
	await audio_player.finished
	StopPositionalEffect(audio_player)

func StopEffect(audio_player: AudioStreamPlayer) -> void:
	audio_player.stop()
	global_effect_pool.erase(audio_player)
	audio_player.queue_free()

func StopPositionalEffect(audio_player: AudioStreamPlayer2D) -> void:
	audio_player.stop()
	positional_effect_pool.erase(audio_player)
	audio_player.queue_free()

func PlayDrinkProgress() -> void:
	var drink_effect: AudioStream = drink_use_effects[randi_range(0, drink_use_effects.size()-1)]
	PlayEffect(drink_effect)
	drink_progress.finished.connect(drink_progress.play)
	drink_progress.play()

func StopDrinkProgress() -> void:
	if drink_progress.finished.is_connected(drink_progress.play):
		drink_progress.finished.disconnect(drink_progress.play)
	drink_progress.stop()
	PlayEffect(sip_swallow)

func GameOver(_position: Vector2 = Vector2(0,0)) -> void:
	if global_audio.finished.is_connected(NextTrack):
		global_audio.finished.disconnect(NextTrack)
	global_audio.stop()
	for entry in global_effect_pool:
		StopEffect(entry)
	for entry in positional_effect_pool: # TODO: See if clearing positional effects is necessary
		StopPositionalEffect(entry)
	global_effect_pool.clear()
	positional_effect_pool.clear()
	PlayEffect(gameover_effect)
	await get_tree().create_timer(1.0).timeout
	PlayAudio(gameover_track)
