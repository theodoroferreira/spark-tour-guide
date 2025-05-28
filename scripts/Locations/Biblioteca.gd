extends Node2D

# Cena da Biblioteca
@onready var quadro_clickable = $QuadroClickable
@onready var player = $Player

var dialog_data = [
	{
		"name": "Spark",
		"text": "Bem-vindo à Biblioteca! Aqui você pode aprender novas palavras em inglês.",
		"portrait": "res://assets/characters/spark.png"
	},
	{
		"name": "Spark",
		"text": "Clique no quadro para jogar um jogo de palavras cruzadas!",
		"portrait": "res://assets/characters/spark.png"
	}
]

func _ready():
	# Conecta o evento de clique no quadro
	quadro_clickable.pressed.connect(_on_quadro_clicked)
	$ReturnButton.pressed.connect(_on_return_button_clicked)

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

func _on_quadro_clicked():
	print("Quadro clicado!")
	# Carrega a cena do quadro da biblioteca usando o método direto
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/BibliotecaQuadro.tscn")

	# Atualiza o estado no GameManager
	GameManager.current_location = "BibliotecaQuadro"

func _on_return_button_clicked():
	print("Botão Voltar clicado!")
	# Volta para a tela Home usando o método direto
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")

	# Atualiza o estado no GameManager
	GameManager.current_location = "Home"

func _on_home_button_clicked():
	print("Botão Home clicado!")
	# Volta para a tela Home usando o método direto
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")

	# Atualiza o estado no GameManager
	GameManager.current_location = "Home"
