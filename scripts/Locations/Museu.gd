extends Node2D

func _ready():
	if has_node("VoltarButton"):
		$VoltarButton.pressed.connect(_on_voltar_button_pressed)
	if has_node("EntrarButton"):
		$EntrarButton.pressed.connect(_on_entrar_button_pressed)

func _on_voltar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/CaminhoMuseu.tscn")
	GameManager.current_location = "CaminhoMuseu"

func _on_entrar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/DentroDoMuseu.tscn")
	GameManager.current_location = "DentroDoMuseu"
