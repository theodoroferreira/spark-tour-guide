extends Node

# Audio buses
enum AudioBus {
	MASTER,
	MUSIC,
	SFX,
	UI
}

# Audio players for different types
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

# Volume settings (0.0 to 1.0)
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ui_volume: float = 0.9

# Current music track
var current_music: AudioStream

func _ready():
	setup_audio_players()
	load_volume_settings()

func setup_audio_players():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	# Create UI player
	ui_player = AudioStreamPlayer.new()
	ui_player.name = "UIPlayer"
	ui_player.bus = "UI"
	add_child(ui_player)

func play_music(music_path: String, loop: bool = true):
	var music = load(music_path)
	if music:
		current_music = music
		music_player.stream = music
		if loop and music is AudioStreamOggVorbis:
			music.loop = true
		elif loop and music is AudioStreamWAV:
			music.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(sfx_path: String):
	var sfx = load(sfx_path)
	if sfx:
		sfx_player.stream = sfx
		sfx_player.play()

func play_ui_sound(ui_sound_path: String):
	var ui_sound = load(ui_sound_path)
	if ui_sound:
		ui_player.stream = ui_sound
		ui_player.play()

# Common UI sounds
func play_click_sound():
	play_ui_sound("res://assets/sounds/ui/click.wav")

func play_hover_sound():
	play_ui_sound("res://assets/sounds/ui/hover.wav")

func play_success_sound():
	play_sfx("res://assets/sounds/sfx/success.wav")

func play_failure_sound():
	play_sfx("res://assets/sounds/sfx/failure.wav")

func play_correct_answer():
	play_sfx("res://assets/sounds/sfx/correct-and-incorrect-chime.wav")

# Volume controls
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	save_volume_settings()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	save_volume_settings()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
	save_volume_settings()

func set_ui_volume(volume: float):
	ui_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear_to_db(ui_volume))
	save_volume_settings()

# Mute functions
func mute_master(muted: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func mute_music(muted: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), muted)

func mute_sfx(muted: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), muted)

func mute_ui(muted: bool):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("UI"), muted)

# Save/Load volume settings
func save_volume_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	config.save("user://audio_settings.cfg")

func load_volume_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 1.0)
		music_volume = config.get_value("audio", "music_volume", 0.7)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
		ui_volume = config.get_value("audio", "ui_volume", 0.9)
		
		# Apply loaded volumes
		set_master_volume(master_volume)
		set_music_volume(music_volume)
		set_sfx_volume(sfx_volume)
		set_ui_volume(ui_volume)
