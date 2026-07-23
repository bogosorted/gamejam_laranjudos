extends Node

@export var background_music: AudioStream
@export_range(-80.0, 10.0) var bgm_volume: float = -20.0:
	set(value):
		bgm_volume = value
		if bgm_player:
			bgm_player.volume_db = value

@export var engine_sound: AudioStream
@export_range(-80.0, 10.0) var engine_volume: float = -5.0:
	set(value):
		engine_volume = value
		if engine_player:
			engine_player.volume_db = value

var bgm_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer

func _ready():
	add_to_group("audio_manager")
	
	if background_music:
		bgm_player = AudioStreamPlayer.new()
		bgm_player.stream = background_music
		bgm_player.volume_db = bgm_volume
		bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(bgm_player)
		bgm_player.play()
		
	if engine_sound:
		engine_player = AudioStreamPlayer.new()
		engine_player.stream = engine_sound
		engine_player.volume_db = engine_volume
		add_child(engine_player)

func play_engine(is_moving: bool):
	if not engine_player:
		return
		
	if is_moving:
		if not engine_player.playing:
			engine_player.play()
	else:
		if engine_player.playing:
			engine_player.stop()
