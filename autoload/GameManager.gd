extends Node

var current_scene = null
var player = null
var current_location = "Home"
var minigame_to_load = ""
var player_character = null
var welcome_dialog_shown = false
var train_station_dialog_shown = false
var biblioteca_dialog_shown = false
var biblioteca_quadro_dialog_shown = false
var caminho_museu_dialog_shown = false
var estadio_dialog_shown = false

func _ready():
	pass

func load_home_scene():
	change_scene("res://scenes/Home.tscn")

func load_location_scene(location_name):
	print("Tentando carregar a localização: " + location_name)
	current_location = location_name
	var path = "res://scenes/Locations/%s.tscn" % location_name
	print("Caminho da cena: " + path)

	# Verificar se o arquivo existe em tempo de execução
	var file_check = FileAccess.file_exists(path)
	print("Arquivo existe: " + str(file_check))

	if location_name == "Biblioteca":
		print("Carregando Biblioteca especificamente...")

	# Carrega a cena diretamente
	change_scene(path)

func start_minigame(minigame_name):
	print("Iniciando minigame: " + minigame_name)
	var path = "res://scenes/Minigames/%s.tscn" % minigame_name
	change_scene(path)

func change_scene(scene_path):
	print("Tentando mudar para a cena: " + scene_path)

	# Verifica recursos antes de carregar
	print("Verificando se o recurso existe...")
	if ResourceLoader.exists(scene_path):
		print("Recurso existe no caminho: " + scene_path)
	else:
		print("ALERTA: Recurso NÃO encontrado no caminho: " + scene_path)
		# Tentamos ajustar o caminho para incluir "res://" se não estiver presente
		if not scene_path.begins_with("res://"):
			scene_path = "res://" + scene_path
			print("Tentando com caminho ajustado: " + scene_path)

	# Remover a cena atual
	if current_scene:
		print("Removendo cena atual...")
		current_scene.queue_free()

	# Carregar e instanciar a nova cena
	print("Carregando recurso: " + scene_path)
	var scene_resource = load(scene_path)
	if scene_resource == null:
		push_error("Falha ao carregar a cena: " + scene_path)
		return
	else:
		print("Recurso carregado com sucesso.")

	print("Cena carregada com sucesso, instanciando...")
	current_scene = scene_resource.instantiate()
	if current_scene:
		print("Cena instanciada com sucesso.")
	else:
		push_error("Falha ao instanciar a cena.")
		return

	get_tree().get_root().call_deferred("add_child", current_scene)
	call_deferred("_set_current_scene")
	print("Cena trocada para: " + scene_path)

func _set_current_scene():
	get_tree().current_scene = current_scene

# Método alternativo que usa o get_tree().change_scene_to_file
func change_scene_direct(scene_path):
	print("Tentando carregar cena diretamente: " + scene_path)
	var result = get_tree().change_scene_to_file(scene_path)

	if result == OK:
		print("Mudança de cena bem-sucedida para: " + scene_path)
		current_location = scene_path.get_file().get_basename()
	else:
		push_error("Falha ao mudar cena para: " + scene_path + " (Código de erro: " + str(result) + ")")

func give_feedback(text):
	var feedback = load("res://scenes/UI/FeedbackLabel.tscn").instantiate()
	feedback.set_text(text)
	get_tree().get_root().call_deferred("add_child", feedback)
	feedback.call_deferred("show_feedback")

func on_minigame_completed(success):
	if success:
		give_feedback("Nice!")
	# Return to home after a short delay
	await get_tree().create_timer(1.5).timeout
	load_home_scene()
