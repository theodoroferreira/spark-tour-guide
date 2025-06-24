extends Control

var selected_character = null

@onready var guri_button = $GuriButton
@onready var guria_button = $GuriaButton

func _ready():
	$BackButton.pressed.connect(_on_back_button_pressed)
	$SelectButton.pressed.connect(_on_select_button_pressed)
	guri_button.pressed.connect(_on_guri_button_pressed)
	guria_button.pressed.connect(_on_guria_button_pressed)
	
	# Connect hover sounds
	$BackButton.mouse_entered.connect(_on_button_hover)
	$SelectButton.mouse_entered.connect(_on_button_hover)
	guri_button.mouse_entered.connect(_on_button_hover)
	guria_button.mouse_entered.connect(_on_button_hover)
	
	# Initially disable select button until a character is chosen
	$SelectButton.disabled = true
	update_selection_visuals()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _on_select_button_pressed():
	if selected_character:
		GameManager.player_character = selected_character
		print("Character selected: ", GameManager.player_character)
		get_tree().change_scene_to_file("res://scenes/Menu.tscn")
	else:
		print("No character selected.")

func _on_guri_button_pressed():
	selected_character = "guri"
	$SelectButton.disabled = false
	update_selection_visuals()

func _on_guria_button_pressed():
	selected_character = "guria"
	$SelectButton.disabled = false
	update_selection_visuals()

func update_selection_visuals():
	if selected_character == "guri":
		guri_button.modulate = Color(1, 1, 1, 1) # Normal
		guria_button.modulate = Color(0.5, 0.5, 0.5, 1) # Dimmed
	elif selected_character == "guria":
		guri_button.modulate = Color(0.5, 0.5, 0.5, 1) # Dimmed
		guria_button.modulate = Color(1, 1, 1, 1) # Normal
	else:
		guri_button.modulate = Color(1, 1, 1, 1) # Normal
		guria_button.modulate = Color(1, 1, 1, 1) # Normal 

func _on_button_hover():
	AudioManager.play_hover_sound()