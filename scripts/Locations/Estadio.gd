extends Node2D

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	
	await get_tree().process_frame

	# Verifica se os botões existem antes de conectar
	var enter_button = $Control/EnterButton
	var back_button = $Control/BackButton

	if enter_button:
		enter_button.pressed.connect(_on_enter_button_pressed)
	else:
		push_error("EnterButton não encontrado!")

	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		push_error("BackButton não encontrado!")

func _on_enter_button_pressed():
	print("Entrando no estádio, carregando minigame...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Minigames/ChuteVerboMinigame.tscn")

func _on_back_button_pressed():
	print("Voltando para o menu inicial...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
