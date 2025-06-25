extends Control

func _ready():
	self.theme = preload("res://assets/themes/main_theme.tres")
	AudioManager.play_music("res://assets/sounds/music/home_theme.ogg")
	# Connect the Play button to the function that loads the Home scene
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/ChooseCharButton.pressed.connect(_on_choose_char_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)
	
	# Connect hover sounds
	$VBoxContainer/PlayButton.mouse_entered.connect(_on_button_hover)
	$VBoxContainer/ChooseCharButton.mouse_entered.connect(_on_button_hover)
	$VBoxContainer/ExitButton.mouse_entered.connect(_on_button_hover)

func _on_play_button_pressed():
	AudioManager.play_click_sound()
	print("Play button pressed, loading Home scene...")
	
	# Reset all dialog flags so they show when coming from menu
	GameManager.welcome_dialog_shown = false
	GameManager.train_station_dialog_shown = false
	GameManager.biblioteca_dialog_shown = false
	GameManager.biblioteca_quadro_dialog_shown = false
	GameManager.caminho_museu_dialog_shown = false
	GameManager.estadio_dialog_shown = false
	
	# Load the Home scene
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

func _on_choose_char_button_pressed():
	AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/ChooseCharacter.tscn")

func _on_exit_button_pressed():
	AudioManager.play_click_sound()
	print("Exit button pressed, closing the game...")
	get_tree().quit() 

func _on_button_hover():
	AudioManager.play_hover_sound()
