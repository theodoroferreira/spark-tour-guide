extends Node2D

@onready var player = $Player
@onready var spark = $Spark

var dialog_data = [
	{
		"name": "Spark",
		"en": "Welcome to the Train Station! The Ijuí railway station was inaugurated in 1911 and played a crucial role in the city's development, contributing to its emancipation in 1912.",
		"pt": "Bem-vindo à Estação de Trem! A estação ferroviária de Ijuí foi inaugurada em 1911 e teve papel crucial no desenvolvimento da cidade, contribuindo para sua emancipação em 1912.",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	},
	{
		"name": "Spark",
		"en": "It operated passenger trains until the 1980s and continues to be used for cargo. Today, the site houses the Sady Strapazzon Culture and Leisure Station, with museum, events and thematic wagons. Next to the station is the historic Itaí metal bridge, a landmark of engineering from that time.",
		"pt": "Operou com trens de passageiros até os anos 1980 e continua sendo usada para cargas. Hoje, o local abriga a Estação de Cultura e Lazer Sady Strapazzon, com museu, eventos e vagões temáticos. Próxima à estação está a histórica ponte metálica do Itaí, marco da engenharia da época.",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	
	# Only show intro dialog if it hasn't been shown before
	if not GameManager.train_station_dialog_shown:
		start_location_dialog()
		GameManager.train_station_dialog_shown = true

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)
	await dialog_box.dialog_ended
	#start_minigame()

#func start_minigame():
	#var minigame_name = GameManager.minigame_to_load
	#if minigame_name != "":
		#var minigame_scene = load("res://scenes/Minigames/" + minigame_name + ".tscn").instantiate()
		#add_child(minigame_scene)
		#minigame_scene.start()
		#minigame_scene.connect("minigame_completed", _on_minigame_completed)

#func _on_minigame_completed(success):
	#if success:
		#GameManager.give_feedback("Great job!")
	#
	## Wait before returning to home
	#await get_tree().create_timer(2.0).timeout
	#GameManager.load_home_scene()
#
func _on_home_button_pressed():
	print("Botão Home clicado!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
	GameManager.current_location = "Home"
