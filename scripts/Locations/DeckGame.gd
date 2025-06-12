extends Node2D

func _ready():
	if has_node("HomeButton"):
		$HomeButton.pressed.connect(_on_home_button_pressed)
	else:
		print("ERRO: HomeButton não encontrado!")

func _on_home_button_pressed():
	print("Botão Home clicado!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/ParqueDaPedreira.tscn")
	GameManager.current_location = "ParqueDaPedreira" 