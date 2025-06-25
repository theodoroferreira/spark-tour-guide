extends Node2D

@onready var dialog_box = $UI/DialogBox

var dialog_data = [
	{
		"name": "Spark",
		"en": "This here is the Diretor Pestana Anthropological Museum, partner! Let's take a look at our culture, come on in!",
		"pt": "Aqui é o Museu Antropológico Diretor Pestana, tchê! Vamos dar uma olhada na nossa cultura, vai entrando, guri(a)!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	
	# Only show intro dialog if it hasn't been shown before
	if not GameManager.caminho_museu_dialog_shown:
		start_location_dialog()
		GameManager.caminho_museu_dialog_shown = true
	
	if has_node("VoltarButton"):
		$VoltarButton.pressed.connect(_on_voltar_button_pressed)
	if has_node("EntrarButton"):
		$EntrarButton.pressed.connect(_on_entrar_button_pressed)

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)

func _on_voltar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/CaminhoMuseu.tscn")
	GameManager.current_location = "CaminhoMuseu"

func _on_entrar_button_pressed():
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/DentroDoMuseu.tscn")
	GameManager.current_location = "DentroDoMuseu"
