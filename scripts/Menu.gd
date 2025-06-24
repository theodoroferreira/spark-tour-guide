extends Control

func _ready():
	AudioManager.play_music("res://assets/sounds/music/home_theme.mp3")
	# Connect the Play button to the function that loads the Home scene
	$VBoxContainer/PlayButton.pressed.connect(_on_play_button_pressed)
	$VBoxContainer/ChooseCharButton.pressed.connect(_on_choose_char_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_play_button_pressed():
	AudioManager.play_click_sound()
	print("Play button pressed, loading Home scene...")
	# Load the Home scene
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

func _on_choose_char_button_pressed():
	AudioManager.play_click_sound()
	get_tree().change_scene_to_file("res://scenes/ChooseCharacter.tscn")

func _on_exit_button_pressed():
	AudioManager.play_click_sound()
	print("Exit button pressed, closing the game...")
	get_tree().quit() 
