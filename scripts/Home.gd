extends Node2D

@onready var player = $Player
@onready var spark = $Spark

var dialog_data = [
	{
		"name": "Spark",
		"en": "Well howdy, partner! Welcome to Ijuí! I'm Spark, your trusty guide 'round these parts!",
		"pt": "Bah, mas que alegria te ver por aqui! Bem-vindo a Ijuí, tchê! Eu sou o Spark, teu guia nessa querência!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	},
	{
		"name": "Spark",
		"en": "Just click on any o' them signs to mosey on over to a spot in town!",
		"pt": "Dá um clique em qualquer uma das placas pra dar uma voltinha pela cidade!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	
	# Only show welcome dialog if it hasn't been shown before
	if not GameManager.welcome_dialog_shown:
		start_intro_dialog()
		GameManager.welcome_dialog_shown = true
	
	# Connect Train Station sign to load location scene directly
	$LocationSigns/TrainStationSign.pressed.connect(_on_train_station_sign_pressed)
	# Connect Crossword sign to load the crossword minigame
	$LocationSigns/CrosswordSign.pressed.connect(_on_crossword_sign_pressed)
	# Connect Museu sign to load the Caminho do Museu location
	$LocationSigns/MuseuSign.pressed.connect(_on_museu_sign_pressed)
	# Connect Chute o Verbo sign to load the Estádio location
	$LocationSigns/ChuteVerboSign.pressed.connect(_on_chute_verbo_sign_pressed)
	# Connect Menu button to return to menu
	$MenuButton.pressed.connect(_on_menu_button_pressed)
	
	# Connect hover sounds for signs
	$LocationSigns/TrainStationSign.mouse_entered.connect(_on_sign_hover)
	$LocationSigns/CrosswordSign.mouse_entered.connect(_on_sign_hover)
	$LocationSigns/MuseuSign.mouse_entered.connect(_on_sign_hover)
	$LocationSigns/ChuteVerboSign.mouse_entered.connect(_on_sign_hover)
	$MenuButton.mouse_entered.connect(_on_sign_hover)
	# Connect hover effects for location signs
	connect_hover_effects()

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
	AudioManager.play_click_sound()
	print("Clicou em Train Station, carregando cena...")

	# Configura o minigame antes de carregar a localização
	GameManager.minigame_to_load = "PackUpMinigame"

	# Usamos a forma mais simples e direta possível
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/TrainStation.tscn")

	# Atualiza o estado no GameManager para referência
	GameManager.current_location = "TrainStation"

func _on_crossword_sign_pressed():
	AudioManager.play_click_sound()
	print("Clicou em Biblioteca, carregando cena...")

	# Usamos a forma mais simples e direta possível
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Biblioteca.tscn")

	# Atualiza o estado no GameManager para referência
	GameManager.current_location = "Biblioteca"

func _on_museu_sign_pressed():
	AudioManager.play_click_sound()
	print("Clicou em Museu, carregando cena...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/CaminhoMuseu.tscn")
	GameManager.current_location = "CaminhoMuseu"

func _on_chute_verbo_sign_pressed():
	AudioManager.play_click_sound()
	print("Clicou em Estádio, carregando cena...")
	print("Verificando se o arquivo do estádio existe...")

	# Verifica se o arquivo existe antes de tentar carregar
	var file_check = FileAccess.file_exists("res://scenes/Locations/Estadio.tscn")
	print("Arquivo do estádio existe: " + str(file_check))

	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Estadio.tscn")
	GameManager.current_location = "Estadio"

func _on_menu_button_pressed():
	AudioManager.play_click_sound()
	print("Clicou em Menu, retornando ao menu...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Menu.tscn")

func _on_sign_hover():
	AudioManager.play_hover_sound()
func connect_hover_effects():
	var signs = [
		$LocationSigns/TrainStationSign,
		$LocationSigns/CrosswordSign,
		$LocationSigns/MuseuSign,
		$LocationSigns/ChuteVerboSign
	]
	
	for sign in signs:
		sign.mouse_entered.connect(_on_sign_mouse_entered.bind(sign))
		sign.mouse_exited.connect(_on_sign_mouse_exited.bind(sign))

func _on_sign_mouse_entered(sign):
	# Add white shadow effect
	sign.modulate = Color(1.4, 1.5, 1.3, 1.0)  # Brighter white effect

func _on_sign_mouse_exited(sign):
	# Remove shadow effect
	sign.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal color
