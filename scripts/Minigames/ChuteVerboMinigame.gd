extends "res://scripts/Minigames/MinigameBase.gd"

@onready var sentence_label = $Control/SentenceLabel
@onready var balls_container = $BallsContainer
@onready var dialog_box = $UI/DialogBox
@onready var back_button = $Control/BackButton
@onready var home_button = $Control/HomeButton
@onready var score_label = $Control/ScoreLabel

var verbs_data = []
var current_question = {}
var correct_answers = 0
var total_questions_answered = 0
var current_options = []
var balls_clicked = [false, false, false]
var dialog_open = false
var waiting_for_dialog_end = false
var should_load_new_question = false
var score = 0
var points_per_correct = 10
var points_per_incorrect = -2

# Posições iniciais das bolas
var initial_ball_positions = [
	Vector2(-350, 0),
	Vector2(0, 0),
	Vector2(350, 0)
]

var success_dialog = [
	{
		"name": "Spark",
		"en": "Goal! Well done, partner!",
		"pt": "Gol, bah tche mandou bem!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

var error_dialog = [
	{
		"name": "Spark",
		"en": "Wrong, partner! That's not the correct verb!",
		"pt": "Errou tche, este não é o verbo correto!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

var intro_dialog = [
	{
		"name": "Spark",
		"en": "Let's go, partner! Choose the right ball and hit the verb! If you do well, it goes in the goal, if you miss, the ball goes out of bounds! Let's see if you're sharp with verbs!",
		"pt": "Vamos lá, guri! Escolha a bola certa e acerte o verbo! Se tu mandar bem, vai pro gol, se errar, a bola sai de campo! Vamos ver se tu tá afiado nos verbos!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

func _ready():
	# Aguarda um frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame

	# Verifica se todos os nós necessários existem
	if not sentence_label:
		push_error("SentenceLabel não encontrado!")
		return
	if not balls_container:
		push_error("BallsContainer não encontrado!")
		return
	if not dialog_box:
		push_error("DialogBox não encontrado!")
		return
	if not back_button:
		push_error("BackButton não encontrado!")
		return
	if not home_button:
		push_error("HomeButton não encontrado!")
		return
	if not score_label:
		push_error("ScoreLabel não encontrado!")
		return

	super._ready()
	load_verbs_data()
	connect_ball_signals()
	back_button.pressed.connect(_on_back_button_pressed)
	home_button.pressed.connect(_on_home_button_pressed)
	update_score()  # Inicializa o display do score

	# Verifica se o GameManager existe antes de conectar
	if GameManager:
		minigame_completed.connect(GameManager.on_minigame_completed)

	start()

func load_verbs_data():
	var file = FileAccess.open("res://assets/data/verbs.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			verbs_data = json.data
		file.close()

func connect_ball_signals():
	for i in range(1, 4):
		var ball = balls_container.get_node("Ball" + str(i))
		if ball:
			ball.pressed.connect(_on_ball_pressed.bind(i))

func start():
	super.start()
	show_intro_dialog()

func show_intro_dialog():
	dialog_open = true
	dialog_box.start_dialog(intro_dialog)
	await dialog_box.dialog_ended
	dialog_open = false
	load_new_question()

func load_new_question():
	# Seleciona uma questão aleatória
	var random_index = randi() % verbs_data.size()
	current_question = verbs_data[random_index]
	balls_clicked = [false, false, false]
	# Copia as opções para uso local
	current_options = current_question.options.duplicate()
	if not current_options.has(current_question.correct):
		current_options[0] = current_question.correct
	current_options.shuffle()
	sentence_label.text = current_question.sentence
	reset_balls_to_initial_positions()
	update_ball_labels()

func reset_balls_to_initial_positions():
	for i in range(1, 4):
		var ball = balls_container.get_node("Ball" + str(i))
		if ball:
			ball.position = initial_ball_positions[i - 1]
			ball.scale = Vector2(0.15, 0.15)
			ball.visible = true

func update_ball_labels():
	for i in range(1, 4):
		var ball = balls_container.get_node("Ball" + str(i))
		if ball:
			var label = ball.get_node("Ball" + str(i) + "Label")
			if label:
				label.text = current_options[i - 1].strip_edges()
			ball.visible = not balls_clicked[i-1]

func update_score():
	score_label.text = "Score: " + str(score)

func add_score(points):
	score += points
	score = max(0, score)  # Score não pode ser negativo
	update_score()

func _on_ball_pressed(ball_index):
	if balls_clicked[ball_index-1]:
		return
	balls_clicked[ball_index-1] = true
	var ball = balls_container.get_node("Ball" + str(ball_index))
	if not ball:
		return
	var label = ball.get_node("Ball" + str(ball_index) + "Label")
	if not label:
		return
	var selected_answer = label.text.strip_edges().to_lower()
	var correct_answer = current_question.correct.strip_edges().to_lower()

	if selected_answer == correct_answer:
		# Resposta correta - bola vai para o gol
		correct_answers += 1
		total_questions_answered += 1
		add_score(points_per_correct)
		animate_ball_to_goal(ball)
		await get_tree().create_timer(1.2).timeout  # Ajustado para 1.2s
		_show_dialog(success_dialog, true)  # true = acertou
		ball.visible = false
	else:
		# Resposta incorreta - bola vai para fora
		total_questions_answered += 1
		add_score(points_per_incorrect)
		animate_ball_out(ball)
		await get_tree().create_timer(1.4).timeout  # Ajustado para 1.4s
		_show_dialog(error_dialog, false)  # false = errou
		ball.visible = false

func animate_ball_to_goal(ball):
	if not ball:
		return

	# Cria uma curva suave para simular um chute real
	var tween = create_tween()
	tween.set_parallel(true)

	# Animação da posição - movimento original para o gol
	var duration = 1.0
	tween.tween_property(ball, "position", Vector2(0, -300), duration)
	tween.parallel().tween_property(ball, "scale", Vector2(0.07, 0.07), duration)  # Reduz para 7% do tamanho

func animate_ball_out(ball):
	if not ball:
		return

	# Escolhe um lado aleatório (esquerda ou direita)
	var random_side = randi() % 2
	var target_x = 800 if random_side == 0 else -800

	# Cria uma curva para bolas que vão para fora
	var tween = create_tween()
	tween.set_parallel(true)

	# Animação da posição - movimento original para fora
	var duration = 1.2
	tween.tween_property(ball, "position", Vector2(target_x, 0), duration)
	tween.parallel().tween_property(ball, "scale", Vector2(0.07, 0.07), duration)  # Reduz para 7% do tamanho

func _on_back_button_pressed():
	print("Voltando para o estádio...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Estadio.tscn")

func _on_home_button_pressed():
	print("Voltando para o home...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")

func reset():
	super.reset()
	correct_answers = 0
	total_questions_answered = 0
	score = 0
	update_score()
	reset_balls_to_initial_positions()

func _on_dialog_ended():
	dialog_open = false
	if should_load_new_question:
		await get_tree().create_timer(0.5).timeout
		load_new_question()
		should_load_new_question = false

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# Garantir que o sinal é desconectado quando o nó é destruído
		if dialog_box and dialog_box.dialog_ended.is_connected(_on_dialog_ended):
			dialog_box.dialog_ended.disconnect(_on_dialog_ended)

func _show_dialog(dialog_data, is_correct):
	if dialog_open or dialog_box.is_dialog_active or dialog_box.is_animating:
		print("Diálogo já está aberto ou animando, ignorando.")
		return
	dialog_open = true

	# Se acertou, sempre carrega nova questão
	# Se errou, só carrega se todas as bolas foram chutadas
	if is_correct:
		should_load_new_question = true
	else:
		should_load_new_question = (balls_clicked[0] and balls_clicked[1] and balls_clicked[2])

	# Garantir que o sinal anterior foi desconectado
	if dialog_box.dialog_ended.is_connected(_on_dialog_ended):
		dialog_box.dialog_ended.disconnect(_on_dialog_ended)

	# Resetar DialogBox antes de iniciar
	dialog_box.reset()
	# Conectar o novo sinal
	dialog_box.dialog_ended.connect(_on_dialog_ended)
	dialog_box.start_dialog(dialog_data)
