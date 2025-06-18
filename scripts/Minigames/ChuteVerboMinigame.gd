extends "res://scripts/Minigames/MinigameBase.gd"

@onready var sentence_label = $Control/SentenceLabel
@onready var balls_container = $BallsContainer
@onready var dialog_box = $UI/DialogBox
@onready var back_button = $Control/BackButton
@onready var home_button = $Control/HomeButton

var verbs_data = []
var current_question = {}
var correct_answers = 0
var total_questions_answered = 0
var current_options = []
var balls_clicked = [false, false, false]

# Posições iniciais das bolas
var initial_ball_positions = [
	Vector2(-350, 0),
	Vector2(0, 0),
	Vector2(350, 0)
]

var success_dialog = [
	{
		"name": "Spark",
		"text": "Gol, bah tche mandou bem!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

var error_dialog = [
	{
		"name": "Spark",
		"text": "Errou tche, este não é o verbo correto!",
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

	super._ready()
	load_verbs_data()
	connect_ball_signals()
	back_button.pressed.connect(_on_back_button_pressed)
	home_button.pressed.connect(_on_home_button_pressed)

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
		animate_ball_to_goal(ball)
		await get_tree().create_timer(1.0).timeout
		if dialog_box:
			dialog_box.start_dialog(success_dialog)
			await dialog_box.dialog_ended
		ball.visible = false
		# Troca de frase quando acerta
		await get_tree().create_timer(0.5).timeout
		load_new_question()
	else:
		# Resposta incorreta - bola vai para fora
		total_questions_answered += 1
		animate_ball_out(ball)
		await get_tree().create_timer(1.0).timeout
		if dialog_box:
			dialog_box.start_dialog(error_dialog)
			await dialog_box.dialog_ended
		ball.visible = false
		# Só muda de frase quando todas as bolas forem chutadas (erradas)
		if balls_clicked[0] and balls_clicked[1] and balls_clicked[2]:
			await get_tree().create_timer(0.5).timeout
			load_new_question()

func animate_ball_to_goal(ball):
	if not ball:
		return
	var tween = create_tween()
	tween.tween_property(ball, "position", Vector2(0, -300), 1.0)
	tween.parallel().tween_property(ball, "scale", Vector2(0.05, 0.05), 1.0)

func animate_ball_out(ball):
	if not ball:
		return
	var tween = create_tween()
	var random_side = randi() % 2
	var target_x = 800 if random_side == 0 else -800
	tween.tween_property(ball, "position", Vector2(target_x, 0), 1.0)
	tween.parallel().tween_property(ball, "scale", Vector2(0.05, 0.05), 1.0)

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
	reset_balls_to_initial_positions()
