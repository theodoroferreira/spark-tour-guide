extends Node2D

func _ready():
	if has_node("VoltarButton"):
		$VoltarButton.pressed.connect(_on_voltar_button_pressed)
	if has_node("MuseuButton"):
		$MuseuButton.pressed.connect(_on_museu_button_pressed)

func _on_voltar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
	GameManager.current_location = "Home"

func _on_museu_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Museu.tscn")
	GameManager.current_location = "Museu" 