extends Node2D

@onready var player = $Player
@onready var spark = $Spark

var dialog_data = [
	{
		"name": "Spark",
		"text": "Hi there! Welcome to Ijuí. I'm Spark, your guide!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	},
	{
		"name": "Spark",
		"text": "Click on any of the signs to visit a location in town!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	start_intro_dialog()
	# Connect Train Station sign to load location scene directly
	$LocationSigns/TrainStationSign.pressed.connect(_on_train_station_sign_pressed)
	# Connect Crossword sign to load the crossword minigame
	$LocationSigns/CrosswordSign.pressed.connect(_on_crossword_sign_pressed)
	# Connect Museu sign to load the Caminho do Museu location
	$LocationSigns/MuseuSign.pressed.connect(_on_museu_sign_pressed)

func start_intro_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)

func _on_location_sign_pressed(location_name, minigame_name, target_position):
	# Disable all signs while moving
	for location_sign in get_tree().get_nodes_in_group("location_signs"):
		location_sign.disabled = true

	player.move_to(target_position)
	await player.destination_reached

	# Wait a moment before transition
	await get_tree().create_timer(0.5).timeout

	# Store minigame to load with location
	if minigame_name != "":
		GameManager.minigame_to_load = minigame_name

	# Load location scene
	GameManager.load_location_scene(location_name)

func _on_train_station_sign_pressed():
	print("Clicou em Train Station, carregando cena...")

	# Configura o minigame antes de carregar a localização
	GameManager.minigame_to_load = "PackUpMinigame"

	# Usamos a forma mais simples e direta possível
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/TrainStation.tscn")

	# Atualiza o estado no GameManager para referência
	GameManager.current_location = "TrainStation"

func _on_crossword_sign_pressed():
	print("Clicou em Biblioteca, carregando cena...")

	# Usamos a forma mais simples e direta possível
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Biblioteca.tscn")

	# Atualiza o estado no GameManager para referência
	GameManager.current_location = "Biblioteca"

func _on_museu_sign_pressed():
	print("Clicou em Museu, carregando cena...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/CaminhoMuseu.tscn")
	GameManager.current_location = "CaminhoMuseu"
