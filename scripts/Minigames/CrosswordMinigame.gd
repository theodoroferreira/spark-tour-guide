extends "res://scripts/Minigames/MinigameBase.gd"

# Crossword Minigame - Jogo de palavras cruzadas com arrastar letras
# Baseado no gameplan e código existente

@onready var crossword_grid = $CrosswordGrid
@onready var letter_wheel = $LetterWheel
@onready var word_clue_label = $UI/WordClueLabel
@onready var feedback_label = $UI/FeedbackLabel
@onready var current_word_highlight = $UI/CurrentWordHighlight
@onready var spark_dialog = $UI/DialogBox
@onready var progress_bar = $UI/ProgressBar
@onready var line_drawer = $UI/LineDrawer
@onready var pause_button = $UI/PauseButton

# Dados do crossword
var crossword_data = null
var current_word_index = 0
var completed_words = []
var grid_size = Vector2(13, 13)
var cell_size = 40

# Sistema de arrastar letras
var available_letters = []
var selected_letters = []
var is_selecting = false
var letter_buttons = []

# Controle do jogo
var total_words = 0
var completed_count = 0
var is_paused = false

# Carrega palavras do JSON
var word_data = []

var dialog_data = [
	{
		"name": "Spark",
		"en": "Well howdy, buddy! Let's solve some English crosswords, shall we?",
		"pt": "Bah, tchê! Vamos resolver umas palavras cruzadas em inglês!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	},
	{
		"name": "Spark",
		"en": "Slide your finger over them letters to build the words, partner!",
		"pt": "Arrasta teu dedo por cima das letras pra formar as palavras, vivente!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	},
	{
		"name": "Spark",
		"en": "Alrighty then, let's get started, folks!",
		"pt": "Vamos dar início, gurizada!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

var completion_dialog = [
	{
		"name": "Spark",
		"en": "Wow, dude! You nailed it!",
		"pt": "Bah tchê! Tirou de letra!",
		"portrait": "res://assets/characters/spark_face_dft_1.png"
	}
]

var can_interact = false

func _ready():
	# Connect the minigame completion signal to GameManager
	minigame_completed.connect(GameManager.on_minigame_completed)

	# Conecta o botão de pausa
	pause_button.pressed.connect(_on_pause_button_pressed)
	pause_button.text = "Pause"

	# Inicializa o line drawer
	if !line_drawer:
		var line = Line2D.new()
		line.name = "LineDrawer"
		line.width = 5
		line.default_color = Color(1.0, 0.3, 0.3, 0.3)
		$UI.add_child(line)
		line_drawer = line

	load_words_from_json()
	setup_crossword()
	setup_ui()
	start_minigame()

func _on_pause_button_pressed():
	AudioManager.play_click_sound()
	is_paused = !is_paused
	if is_paused:
		pause_button.text = "Continue"
		show_pause_menu()
	else:
		pause_button.text = "Pause"
		hide_pause_menu()

func show_pause_menu():
	# Cria um painel de pausa
	var pause_panel = Panel.new()
	pause_panel.name = "PausePanel"
	pause_panel.size = Vector2(400, 300)
	pause_panel.position = Vector2(568, 362)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(50, 50)
	vbox.size = Vector2(300, 200)
	
	var title = Label.new()
	title.text = "Game Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	
	var continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.pressed.connect(_on_pause_button_pressed)
	
	var restart_button = Button.new()
	restart_button.text = "Restart"
	restart_button.pressed.connect(_on_restart_button_pressed)
	
	var quit_button = Button.new()
	quit_button.text = "Quit"
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	vbox.add_child(title)
	vbox.add_child(continue_button)
	vbox.add_child(restart_button)
	vbox.add_child(quit_button)
	
	pause_panel.add_child(vbox)
	$UI.add_child(pause_panel)

func hide_pause_menu():
	if has_node("UI/PausePanel"):
		$UI/PausePanel.queue_free()

func _on_restart_button_pressed():
	AudioManager.play_click_sound()
	# Limpa o grid atual
	for child in crossword_grid.get_children():
		child.queue_free()
	
	# Reseta variáveis
	completed_words.clear()
	completed_count = 0
	current_word_index = 0
	progress_bar.value = 0
	
	# Configura novo crossword
	setup_crossword()
	setup_next_word()
	
	# Fecha o menu de pausa
	_on_pause_button_pressed()

func _on_quit_button_pressed():
	AudioManager.play_click_sound()
	# Volta para a tela inicial do crossword
	get_tree().change_scene_to_file("res://scenes/Locations/BibliotecaQuadro.tscn")

func load_words_from_json():
	var file_path = "res://assets/data/words.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_text = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_text)

		if parse_result == OK:
			var json_result = json.get_data()
			if json_result and json_result is Array:
				word_data = json_result
				print("Carregadas " + str(word_data.size()) + " palavras do arquivo JSON")
			else:
				push_error("Erro ao carregar palavras: formato JSON inválido")
		else:
			push_error("Erro ao analisar JSON: " + json.get_error_message())
	else:
		push_error("Arquivo de palavras não encontrado: " + file_path)

func setup_crossword():
	# Converte dados do JSON para formato do crossword
	var word_list = []
	# Limita a quantidade de palavras para garantir bom desempenho
	var max_words = min(word_data.size(), 8)

	for i in range(max_words):
		word_list.append([word_data[i].word.to_upper(), word_data[i].hint])

	# Cria o crossword usando a classe existente
	var crossword = Crossword.new(grid_size.x, grid_size.y, '-', 5000, word_list)
	crossword.compute_crossword(2.0)

	crossword_data = {
		"grid": crossword.grid,
		"words": crossword.current_word_list,
		"rows": crossword.rows,
		"cols": crossword.cols
	}

	total_words = crossword_data.words.size()
	create_visual_grid()

func create_visual_grid():
	# Cria a grid visual do crossword
	for i in range(grid_size.y):
		for j in range(grid_size.x):
			var cell = Panel.new()
			cell.size = Vector2(cell_size, cell_size)
			cell.position = Vector2(j * cell_size, i * cell_size)

			var grid_value = crossword_data.grid[i][j]
			if grid_value != '-':
				# Adiciona label para a letra
				var letter_label = Label.new()
				letter_label.text = ""  # Inicialmente vazio
				letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				letter_label.size = Vector2(cell_size, cell_size)
				letter_label.modulate = Color(0,0,0) # Letras pretas
				var style = StyleBoxFlat.new()
				style.bg_color = Color.WHITE
				style.border_color = Color(0.2, 0.2, 0.2, 0.7)
				style.border_width_left = 2
				style.border_width_top = 2
				style.border_width_right = 2
				style.border_width_bottom = 2
				cell.add_theme_stylebox_override("panel", style)

				cell.add_child(letter_label)
				cell.set_meta("letter", grid_value)
				cell.set_meta("revealed", false)
			else:
				var style = StyleBoxFlat.new()
				style.bg_color = Color(0.2, 0.1, 0.18, 0.0)
				style.border_color = Color(0, 0, 0, 0) # borda totalmente transparente
				style.border_width_left = 0
				style.border_width_top = 0
				style.border_width_right = 0
				style.border_width_bottom = 0
				cell.add_theme_stylebox_override("panel", style)

			crossword_grid.add_child(cell)

func setup_ui():

	feedback_label.visible = false
	progress_bar.max_value = 100
	progress_bar.value = 0

func start_minigame():
	can_interact = false
	start_location_dialog()
	setup_next_word()

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)

func setup_next_word():
	if current_word_index >= crossword_data.words.size():
		# Todas as palavras da lista atual foram completadas
		if completed_count >= total_words:
			# Remove as palavras já usadas do word_data
			for word in completed_words:
				var idx = word_data.find(func(w): return w.word.to_upper() == word.word)
				if idx != -1:
					word_data.remove_at(idx)
		else:
			complete_minigame()
		return

	var current_word = crossword_data.words[current_word_index]
	word_clue_label.text = "Hint: " + current_word.clue

	# Destaca a palavra atual no grid
	highlight_current_word(current_word)

	# Cria a roleta de letras
	create_letter_wheel(current_word.word)

func highlight_current_word(word):
	# Remove highlight anterior
	for child in current_word_highlight.get_children():
		child.queue_free()

func create_letter_wheel(word):
	# Limpa roleta anterior
	for button in letter_buttons:
		button.queue_free()
	letter_buttons.clear()

	# Limpa todos os filhos do letter_wheel para garantir
	for child in letter_wheel.get_children():
		child.queue_free()

	# Cria letras embaralhadas - apenas as letras da palavra
	available_letters = []
	for letter in word:
		available_letters.append(letter)

	# Embaralha as letras
	available_letters.shuffle()

	# Cria um Control como container para os botões
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.position = Vector2.ZERO
	container.size = Vector2(400, 400)
	letter_wheel.add_child(container)

	# Ajusta o raio do círculo baseado no tamanho da palavra
	var base_radius = 60  # Raio base para palavras curtas
	var radius = base_radius + (available_letters.size() * 5)  # Aumenta o raio para palavras maiores

	# Ajusta o tamanho dos botões baseado no tamanho da palavra
	var base_button_size = 65  # Tamanho base para palavras curtas
	var button_size = max(45, base_button_size - (available_letters.size() * 2))  # Diminui o tamanho para palavras maiores

	# Ajusta a posição do círculo mais para a esquerda e para cima
	var center = Vector2(container.size.x * 0.3, container.size.y * 0.4)  # Ajusta para 30% da largura e 40% da altura

	var angle_step = 2 * PI / available_letters.size()

	for i in range(available_letters.size()):
		var angle = i * angle_step - PI/2  # Começa do topo (-PI/2)
		var pos = center + Vector2(cos(angle), sin(angle)) * radius

		# Cria o botão
		var letter_button = Button.new()
		letter_button.set_script(load("res://scripts/Minigames/DraggableLetter.gd"))
		container.add_child(letter_button)

		# Configura o botão
		letter_button.size = Vector2(button_size, button_size)
		letter_button.position = pos - letter_button.size/2
		letter_button.text = available_letters[i]
		letter_button.clip_contents = false
		letter_button.mouse_filter = Control.MOUSE_FILTER_STOP

		# Configura o estilo
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 100, 0.0)
		style.corner_radius_top_left = button_size/2
		style.corner_radius_top_right = button_size/2
		style.corner_radius_bottom_left = button_size/2
		style.corner_radius_bottom_right = button_size/2
		letter_button.add_theme_stylebox_override("normal", style)

		# Inicializa o botão
		letter_button.setup(available_letters[i], self)
		letter_buttons.append(letter_button)

		print("Criado botão para letra: " + available_letters[i] + " na posição: " + str(pos))

func start_letter_selection(button, letter):
	if not is_selecting:
		is_selecting = true
		selected_letters.clear()
		add_letter_to_selection(button, letter)
		print("Iniciando seleção com letra: " + letter)

func continue_letter_selection(global_pos):
	if not is_selecting:
		return

	# Encontra o botão mais próximo do mouse que ainda não foi selecionado
	var closest_button = null
	var closest_distance = 50.0  # Reduzido para melhor precisão

	for button in letter_buttons:
		if not button in selected_letters.map(func(x): return x.button):
			var button_center = button.global_position + button.size/2
			var distance = button_center.distance_to(global_pos)

			if distance < closest_distance:
				closest_distance = distance
				closest_button = button

	if closest_button != null:
		add_letter_to_selection(closest_button, closest_button.letter)
		print("Adicionando letra à seleção: " + closest_button.letter)

func add_letter_to_selection(button, letter):
	# Verifica se o botão já foi selecionado
	for selected in selected_letters:
		if selected.button == button:
			return

	selected_letters.append({
		"button": button,
		"letter": letter
	})

	button.select()

	# Atualiza a linha de conexão
	var points = []
	for item in selected_letters:
		var btn_pos = item.button.global_position + item.button.size/2
		points.append(btn_pos)
	line_drawer.points = points

	# Feedback visual e sonoro
	feedback_label.text = get_current_word()
	feedback_label.modulate = Color.WHITE
	feedback_label.visible = true

func get_current_word():
	var word = ""
	for item in selected_letters:
		word += item.letter
	return word

func end_letter_selection():
	if not is_selecting:
		return

	is_selecting = false
	var formed_word = get_current_word()

	# Verifica se está correta
	check_word_answer(formed_word)

	# Reseta seleção
	for item in selected_letters:
		item.button.deselect()
	selected_letters.clear()

	# Limpa a linha de conexão
	line_drawer.clear_points()

	# Esconde o feedback da palavra formada
	feedback_label.visible = false

func check_word_answer(formed_word):
	var current_word = crossword_data.words[current_word_index]

	if formed_word == current_word.word:
		# Resposta correta!
		show_positive_feedback()
		fill_word_in_grid(current_word)
		completed_words.append(current_word)
		completed_count += 1

		# Atualiza progresso
		progress_bar.value = float(completed_count) / float(total_words) * 100

		# Verifica se completou todas as palavras
		if completed_count >= total_words:
			# Pequeno delay antes de mostrar a mensagem de conclusão
			await get_tree().create_timer(1.5).timeout
			complete_minigame()
		else:
			# Próxima palavra após delay
			await get_tree().create_timer(1.5).timeout
			current_word_index += 1
			setup_next_word()
	else:
		# Resposta incorreta
		show_negative_feedback()

func fill_word_in_grid(word):
	var start_row = word.row - 1
	var start_col = word.col - 1

	# Animação de preenchimento
	for i in range(word.length):
		var row = start_row
		var col = start_col

		if word.vertical:
			row += i
		else:
			col += i

		var cell_index = row * grid_size.x + col
		var cell = crossword_grid.get_child(cell_index)

		if cell.has_method("get_children") and cell.get_child_count() > 0:
			var letter_label = cell.get_child(0)

			# Cria uma animação para cada letra
			var tween = create_tween()
			tween.tween_property(letter_label, "modulate", Color(0, 0, 0, 1), 0.2)
			tween.tween_callback(func(): letter_label.text = word.word[i])
			tween.tween_property(letter_label, "modulate", Color(0, 0, 0, 1), 0.3)

			cell.set_meta("revealed", true)

			# Pequeno delay entre cada letra
			await get_tree().create_timer(0.1).timeout

func show_positive_feedback():
	AudioManager.play_correct_answer()
	var messages = ["Nice!", "Super Cool!", "Parabéns!", "Muito bem!", "Excellent!"]
	feedback_label.text = messages[randi() % messages.size()]
	feedback_label.modulate = Color.GREEN
	feedback_label.visible = true

	# Animação simples
	var tween = create_tween()
	tween.tween_property(feedback_label, "scale", Vector2(1.2, 1.2), 0.3).from(Vector2(0.5, 0.5))
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Opcional: tocar som de acerto
	# var sound = load("res://assets/sounds/correct-and-incorrect-chime.wav")
	# if sound:
	#     $AudioPlayer.stream = sound
	#     $AudioPlayer.play()

	await get_tree().create_timer(1.5).timeout
	feedback_label.visible = false

func show_negative_feedback():
	AudioManager.play_failure_sound()
	var messages = ["Try again!", "Tente novamente!", "Quase lá!", "You can do it!"]
	feedback_label.text = messages[randi() % messages.size()]
	feedback_label.modulate = Color.ORANGE
	feedback_label.visible = true

	# Animação de shake (opcional)
	var tween = create_tween()
	var original_position = feedback_label.position
	tween.tween_property(feedback_label, "position", original_position + Vector2(5, 0), 0.1).from(original_position - Vector2(5, 0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Opcional: tocar som de erro
	# Usar o mesmo som mas em outro timestamp ou outro som

	await get_tree().create_timer(1.0).timeout
	feedback_label.visible = false

func complete_minigame():
	can_interact = false
	show_completion_message()

func show_completion_message():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(completion_dialog)
	await dialog_box.dialog_ended
	can_interact = true

	# Emite sinal de conclusão para o GameManager
	minigame_completed.emit(true)
	
	# Volta para a tela inicial do jogo
	get_tree().change_scene_to_file("res://scenes/Home.tscn")

# Classe Word adaptada do código original
class Word:
	var word
	var clue
	var length
	var row
	var col
	var vertical
	var number
	var solved

	func _init(word, clue, solved = false):
		self.word = word.to_upper().replace(" ", "")
		self.clue = clue
		self.length = self.word.length()
		self.row = null
		self.col = null
		self.vertical = null
		self.number = null
		self.solved = solved

	func down_across():
		if self.vertical:
			return 'down'
		else:
			return 'across'

# Classe Crossword simplificada do código original
class Crossword:
	var cols
	var rows
	var empty
	var maxloops
	var available_words
	var current_word_list
	var grid

	func _init(cols, rows, empty = '-', maxloops = 2000, available_words = []):
		self.cols = cols
		self.rows = rows
		self.empty = empty
		self.maxloops = maxloops
		self.available_words = available_words
		self.current_word_list = []
		self.clear_grid()
		self.randomize_word_list()

	func clear_grid():
		self.grid = []
		for i in range(self.rows):
			var ea_row = []
			for j in range(self.cols):
				ea_row.append(self.empty)
			self.grid.append(ea_row)

	func randomize_word_list():
		var temp_list = []
		for word in self.available_words:
			temp_list.append(Word.new(word[0], word[1]))

		temp_list.shuffle()
		# Ordena por comprimento (palavras maiores primeiro)
		temp_list.sort_custom(Callable(self, "_sort_by_length"))
		self.available_words = temp_list

	func _sort_by_length(a, b):
		return a.length > b.length

	func compute_crossword(time_permitted = 1.0):
		# Layout real de palavras cruzadas para: apple, banana, grape, orange, pear, peach, lemon, lime
		# apple: (3,2) horizontal
		var apple = available_words.filter(func(w): return w.word == "APPLE")
		if apple.size() > 0:
			apple = apple[0]
			apple.row = 8
			apple.col = 6
			apple.vertical = true
			current_word_list.append(apple)
			place_word_in_grid(apple)

		# lemon: (1,4) horizontal
		var lemon = available_words.filter(func(w): return w.word == "LEMON")
		if lemon.size() > 0:
			lemon = lemon[0]
			lemon.row = 3
			lemon.col = 4
			lemon.vertical = true
			current_word_list.append(lemon)
			place_word_in_grid(lemon)

		# banana: (3,6) vertical
		var banana = available_words.filter(func(w): return w.word == "BANANA")
		if banana.size() > 0:
			banana = banana[0]
			banana.row = 8
			banana.col = 5
			banana.vertical = false
			current_word_list.append(banana)
			place_word_in_grid(banana)

		# orange: (8,6) vertical
		var orange = available_words.filter(func(w): return w.word == "ORANGE")
		if orange.size() > 0:
			orange = orange[0]
			orange.row = 6
			orange.col = 4
			orange.vertical = false
			current_word_list.append(orange)
			place_word_in_grid(orange)

		# lime: (12,6) vertical
		var lime = available_words.filter(func(w): return w.word == "LIME")
		if lime.size() > 0:
			lime = lime[0]
			lime.row = 3
			lime.col = 4
			lime.vertical = false
			current_word_list.append(lime)
			place_word_in_grid(lime)

		# pear: (3,4) vertical
		var pear = available_words.filter(func(w): return w.word == "PEAR")
		if pear.size() > 0:
			pear = pear[0]
			pear.row = 4
			pear.col = 3
			pear.vertical = false
			current_word_list.append(pear)
			place_word_in_grid(pear)

		# peach: (5,2) horizontal
		var peach = available_words.filter(func(w): return w.word == "PEACH")
		if peach.size() > 0:
			peach = peach[0]
			peach.row = 12
			peach.col = 5
			peach.vertical = false
			current_word_list.append(peach)
			place_word_in_grid(peach)

		# grape: (5,7) horizontal
		var grape = available_words.filter(func(w): return w.word == "GRAPE")
		if grape.size() > 0:
			grape = grape[0]
			grape.row = 6
			grape.col = 8
			grape.vertical = true
			current_word_list.append(grape)
			place_word_in_grid(grape)

	func place_first_word():
		pass  # Não é mais necessário pois as palavras são colocadas em compute_crossword

	func place_remaining_words():
		pass  # Não é mais necessário pois as palavras são colocadas em compute_crossword

	func try_place_word(word):
		pass  # Não é mais necessário pois as palavras são colocadas em compute_crossword

	func place_word_in_grid(word):
		for i in range(word.length):
			var row = word.row - 1
			var col = word.col - 1

			if word.vertical:
				row += i
			else:
				col += i

			if row >= 0 and row < rows and col >= 0 and col < cols:
				grid[row][col] = word.word[i]

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if not can_interact:
			can_interact = true
			$UI/DialogBox.hide()
			return
		if $UI/DialogBox.visible:
			$UI/DialogBox.hide()
