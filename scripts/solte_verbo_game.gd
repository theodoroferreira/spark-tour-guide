extends Node2D

func _ready():
	# Inicialização do jogo
	pass

func _on_home_button_pressed():
	# Função que será chamada quando o botão "Home" for pressionado
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
