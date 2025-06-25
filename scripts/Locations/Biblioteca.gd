extends Node2D

# Cena da Biblioteca
@onready var quadro_clickable = $QuadroClickable
@onready var player = $Player

var dialog_data = [
	{
		"name": "Spark",
		"en": "Welcome to the Library, partner! This here's the place to learn yerself some fine English words!",
		"pt": "Bem-vindo à Biblioteca, tchê! Aqui tu vai aprender umas palavras em inglês de responsa!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	},
	{
		"name": "Spark",
		"en": "Give that frame a click and let's rustle up a good ol' crossword game!",
		"pt": "Clique nesse quadro e vamos fazer um bom e velho jogo de palavras cruzadas!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

func _ready():
	# Conecta o evento de clique no quadro
	quadro_clickable.pressed.connect(_on_quadro_clicked)
	$ReturnButton.pressed.connect(_on_return_button_clicked)
	
	# Conecta os eventos de hover do quadro
	quadro_clickable.mouse_entered.connect(_on_quadro_mouse_entered)
	quadro_clickable.mouse_exited.connect(_on_quadro_mouse_exited)

	# Conecta o botão para retornar ao Home
	if has_node("HomeButton"):
		$HomeButton.pressed.connect(_on_home_button_clicked)
	else:
		print("ERRO: HomeButton não encontrado!")

	# Inicia o diálogo após um breve atraso
	await get_tree().create_timer(0.5).timeout
	
	# Only show intro dialog if it hasn't been shown before
	if not GameManager.biblioteca_dialog_shown:
		start_location_dialog()
		GameManager.biblioteca_dialog_shown = true

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

func _on_quadro_mouse_entered():
	var tween = create_tween()
	tween.tween_property(quadro_clickable, "modulate", Color(1.2, 1.2, 1.2), 0.2)
	
	# Adiciona uma borda sutil
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(1, 1, 1, 0.8)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	quadro_clickable.add_theme_stylebox_override("hover", style)

func _on_quadro_mouse_exited():
	var tween = create_tween()
	tween.tween_property(quadro_clickable, "modulate", Color(1, 1, 1), 0.2)
	
	# Remove a borda
	quadro_clickable.remove_theme_stylebox_override("hover")
