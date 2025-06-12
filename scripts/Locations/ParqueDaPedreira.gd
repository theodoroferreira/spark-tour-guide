extends Node2D

func _ready():
	if has_node("HomeButton"):
		$HomeButton.pressed.connect(_on_home_button_pressed)
	else:
		print("ERRO: HomeButton não encontrado!")

	if has_node("DeckButton"):
		$DeckButton.pressed.connect(_on_deck_button_pressed)
	else:
		print("ERRO: DeckButton não encontrado!")

func _on_home_button_pressed():
	print("Botão Home clicado!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
	GameManager.current_location = "Home"

func _on_deck_button_pressed():
	print("Botão Deck clicado!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/DeckGame.tscn")
	GameManager.current_location = "DeckGame" 