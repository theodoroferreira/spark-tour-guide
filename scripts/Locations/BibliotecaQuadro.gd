extends Node2D

# Cena do Quadro da Biblioteca que contém o minigame
@onready var start_minigame_button = $StartMinigameButton
@onready var player = $Player

var dialog_data = [
	{
		"name": "Spark",
		"text": "Este é o nosso jogo de palavras cruzadas em inglês!",
		"portrait": "res://assets/characters/spark.png"
	},
	{
		"name": "Spark",
		"text": "Clique no botão para começar a jogar e aprender novas palavras!",
		"portrait": "res://assets/characters/spark.png"
	}
]

func _ready():
	# Conecta o botão para iniciar o minigame
	start_minigame_button.pressed.connect(_on_start_minigame)

	# Conecta o botão para retornar à Biblioteca
	if has_node("ReturnButton"):
		$ReturnButton.pressed.connect(_on_return_button_clicked)
	else:
		print("ERRO: ReturnButton não encontrado!")

	# Conecta o botão para retornar ao Home
	if has_node("HomeButton"):
		$HomeButton.pressed.connect(_on_home_button_clicked)
	else:
		print("ERRO: HomeButton não encontrado!")

	# Inicia o diálogo após um breve atraso
	await get_tree().create_timer(0.5).timeout
	start_location_dialog()

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)
	await dialog_box.dialog_ended

func _on_start_minigame():
	print("Iniciando minigame Crossword...")
	# Inicia o minigame de Crossword usando o método direto
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Minigames/crossword/CrosswordMinigame.tscn")

	# Atualiza o estado no GameManager
	GameManager.minigame_to_load = "crossword/CrosswordMinigame"

func _on_return_button_clicked():
	print("Voltando para a Biblioteca...")
	# Volta para a cena da biblioteca da forma mais direta
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Biblioteca.tscn")

	# Atualiza o estado no GameManager
	GameManager.current_location = "Biblioteca"

func _on_home_button_clicked():
	print("Voltando para o Home...")
	# Volta para a tela inicial da forma mais direta
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")

	# Atualiza o estado no GameManager
	GameManager.current_location = "Home"
