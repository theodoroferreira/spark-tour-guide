extends Node2D

@onready var dialog_box = $UI/DialogBox

var dialog_data = [
	{
		"name": "Spark",
		"en": "Hey there, my friend! This here is the 19 de Outubro Stadium, home of Esporte Clube São Luiz. Let's take a look at the stadium, partner!",
		"pt": "E aí, meu bagual! Aqui é o Estádio 19 de Outubro, do Esporte Clube São Luiz. Vamos lá dar uma olhada no estádio, tchê!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	
	# Only show intro dialog if it hasn't been shown before
	if not GameManager.estadio_dialog_shown:
		start_location_dialog()
		GameManager.estadio_dialog_shown = true
	
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

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)

func _on_enter_button_pressed():
	print("Entrando no estádio, carregando minigame...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Minigames/ChuteVerboMinigame.tscn")

func _on_back_button_pressed():
	print("Voltando para o menu inicial...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
