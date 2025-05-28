extends "res://scripts/Minigames/MinigameBase.gd"

# Crossword Minigame - Jogo de palavras cruzadas com arrastar letras
# Baseado no gameplan e código existente

@onready var crossword_grid = $CrosswordGrid
@onready var letter_wheel = $LetterWheel
@onready var word_clue_label = $UI/WordClueLabel
@onready var feedback_label = $UI/FeedbackLabel
@onready var current_word_highlight = $UI/CurrentWordHighlight
@onready var spark_dialog = $UI/SparkDialog
@onready var progress_bar = $UI/ProgressBar

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

# Carrega palavras do JSON
var word_data = []

func _ready():
	# Connect the minigame completion signal to GameManager
	minigame_completed.connect(GameManager.on_minigame_completed)

	load_words_from_json()
	setup_crossword()
	setup_ui()
	start_minigame()

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
				_load_fallback_words()
		else:
			push_error("Erro ao analisar JSON: " + json.get_error_message())
			_load_fallback_words()
	else:
		push_error("Arquivo de palavras não encontrado: " + file_path)
		_load_fallback_words()

func _load_fallback_words():
	# Palavras de fallback caso o JSON não seja carregado
	word_data = [
		{"word": "apple", "hint": "A red or green fruit"},
		{"word": "banana", "hint": "A long yellow fruit"},
		{"word": "cat", "hint": "Says 'meow'"},
		{"word": "dog", "hint": "A loyal animal that barks"},
		{"word": "sun", "hint": "Shines in the sky"},
		{"word": "moon", "hint": "You see it at night"}
	]
	print("Usando " + str(word_data.size()) + " palavras de fallback")

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
			var cell = ColorRect.new()
			cell.size = Vector2(cell_size, cell_size)
			cell.position = Vector2(j * cell_size, i * cell_size)

			var grid_value = crossword_data.grid[i][j]
			if grid_value != '-':
				cell.color = Color.WHITE

				# Adiciona label para a letra
				var letter_label = Label.new()
				letter_label.text = ""  # Inicialmente vazio
				letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				letter_label.size = Vector2(cell_size, cell_size)

				# Verifica se a fonte existe antes de usá-la
				var font_res = load("res://assets/fonts/game_font.tres")
				if font_res:
					letter_label.add_theme_font_override("font", font_res)

				cell.add_child(letter_label)
				cell.set_meta("letter", grid_value)
				cell.set_meta("revealed", false)
			else:
				cell.color = Color(0.1, 0.1, 0.1, 1.0)  # Cor mais escura para células vazias

			crossword_grid.add_child(cell)

func setup_ui():
	# Configura elementos da UI
	var font_res = load("res://assets/fonts/game_font.tres")
	if font_res:
		word_clue_label.add_theme_font_override("font", font_res)
		feedback_label.add_theme_font_override("font", font_res)

	feedback_label.visible = false
	progress_bar.max_value = 100
	progress_bar.value = 0

func start_minigame():
	show_spark_introduction()
	setup_next_word()

func show_spark_introduction():
	var messages = [
		"Olá! Eu sou o Spark! 🐕",
		"Vamos resolver palavras cruzadas em inglês!",
		"Arraste seu dedo sobre as letras para formar as palavras!",
		"Vamos começar!"
	]
	spark_dialog.show_messages(messages)
	await spark_dialog.messages_finished

func setup_next_word():
	if current_word_index >= crossword_data.words.size():
		complete_minigame()
		return

	var current_word = crossword_data.words[current_word_index]
	word_clue_label.text = "Dica: " + current_word.clue

	# Destaca a palavra atual no grid
	highlight_current_word(current_word)

	# Cria a roleta de letras
	create_letter_wheel(current_word.word)

func highlight_current_word(word):
	# Remove highlight anterior
	for child in current_word_highlight.get_children():
		child.queue_free()

	# Cria novo highlight para a palavra atual
	var highlight_rect = ColorRect.new()
	highlight_rect.color = Color(1, 1, 0, 0.3)  # Amarelo transparente

	if word.vertical:
		highlight_rect.size = Vector2(cell_size, cell_size * word.length)
		highlight_rect.position = Vector2(
			(word.col - 1) * cell_size,
			(word.row - 1) * cell_size
		)
	else:
		highlight_rect.size = Vector2(cell_size * word.length, cell_size)
		highlight_rect.position = Vector2(
			(word.col - 1) * cell_size,
			(word.row - 1) * cell_size
		)

	current_word_highlight.add_child(highlight_rect)
	current_word_highlight.visible = true

func create_letter_wheel(word):
	# Limpa roleta anterior
	for button in letter_buttons:
		button.queue_free()
	letter_buttons.clear()

	# Cria letras embaralhadas
	available_letters = []
	for letter in word:
		available_letters.append(letter)

	# Embaralha as letras
	available_letters.shuffle()

	# Cria botões de letras em círculo
	var center = Vector2(200, 200)
	var radius = 120
	var angle_step = 2 * PI / available_letters.size()

	for i in range(available_letters.size()):
		var angle = i * angle_step
		var pos = center + Vector2(cos(angle), sin(angle)) * radius

		var letter_button = create_letter_button(available_letters[i], pos)
		letter_wheel.add_child(letter_button)
		letter_buttons.append(letter_button)

func create_letter_button(letter, position):
	var button = Button.new()
	button.text = letter
	button.size = Vector2(50, 50)
	button.position = position - Vector2(25, 25)  # Centraliza o botão

	var font_res = load("res://assets/fonts/game_font.tres")
	if font_res:
		button.add_theme_font_override("font", font_res)

	# Estilo do botão
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 1.0)
	style.corner_radius_top_left = 25
	style.corner_radius_top_right = 25
	style.corner_radius_bottom_left = 25
	style.corner_radius_bottom_right = 25
	button.add_theme_stylebox_override("normal", style)

	# Conecta sinais para touch/mouse
	button.gui_input.connect(_on_letter_button_input.bind(button, letter))

	return button

func _on_letter_button_input(event, button, letter):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			start_letter_selection(button, letter)
		elif is_selecting:  # Garante que só termina se já estava selecionando
			end_letter_selection()
	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if is_selecting and event.button_mask > 0:  # Verifica se botão está pressionado
			continue_letter_selection(event.position)

func start_letter_selection(button, letter):
	is_selecting = true
	selected_letters.clear()
	add_letter_to_selection(button, letter)

	# Feedback visual e sonoro
	button.modulate = Color(1.2, 1.2, 0.8)

	# Opcional: tocar som de seleção

func continue_letter_selection(global_pos):
	if not is_selecting:
		return

	# Verifica se está sobre outro botão de letra
	for i in range(letter_buttons.size()):
		var button = letter_buttons[i]
		var rect = Rect2(button.global_position, button.size)

		if rect.has_point(global_pos):
			var letter = available_letters[i]

			# Verifica se este botão já foi selecionado
			var already_selected = false
			for selection in selected_letters:
				if selection.button == button:
					already_selected = true
					break

			if not already_selected:
				add_letter_to_selection(button, letter)

func add_letter_to_selection(button, letter):
	selected_letters.append({
		"button": button,
		"letter": letter
	})

	# Feedback visual
	button.modulate = Color(1.2, 1.2, 0.8)

	# Feedback visual do caminho (opcional)
	if selected_letters.size() >= 2:
		# Pode-se adicionar uma linha entre os botões aqui
		pass

	# Atualiza a palavra formada na UI
	update_formed_word()

func update_formed_word():
	var formed_word = ""
	for item in selected_letters:
		formed_word += item.letter

	# Pode-se mostrar a palavra sendo formada em uma label

func end_letter_selection():
	if not is_selecting:
		return

	is_selecting = false

	# Forma a palavra selecionada
	var formed_word = ""
	for item in selected_letters:
		formed_word += item.letter

	# Verifica se está correta
	check_word_answer(formed_word)

	# Reset visual dos botões
	for button in letter_buttons:
		button.modulate = Color.WHITE

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
			letter_label.text = word.word[i]
			cell.set_meta("revealed", true)

func show_positive_feedback():
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
	show_completion_message()

func show_completion_message():
	var final_messages = [
		"Parabéns! Você completou o crossword! 🎉",
		"Você aprendeu " + str(completed_count) + " palavras em inglês!",
		"Spark está muito orgulhoso de você!",
		"Vamos para o próximo desafio!"
	]

	spark_dialog.show_messages(final_messages)
	await spark_dialog.messages_finished

	# Emite sinal de conclusão para o GameManager
	minigame_completed.emit(true)

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
		# Implementação simplificada para o minigame
		# Coloca palavras em posições fixas para garantir funcionalidade
		if available_words.size() > 0:
			place_first_word()
			place_remaining_words()

	func place_first_word():
		if available_words.size() == 0:
			return

		var first_word = available_words[0]
		first_word.row = 7
		first_word.col = 3
		first_word.vertical = false
		current_word_list.append(first_word)

		# Coloca no grid
		for i in range(first_word.length):
			if first_word.col - 1 + i < cols:
				grid[first_word.row - 1][first_word.col - 1 + i] = first_word.word[i]

	func place_remaining_words():
		for i in range(1, min(8, available_words.size())):  # Máximo 8 palavras para simplicidade
			var word = available_words[i]
			var placed = try_place_word(word)
			if placed:
				current_word_list.append(word)

	func try_place_word(word):
		# Tenta colocar palavra cruzando com palavras existentes
		for existing_word in current_word_list:
			for i in range(existing_word.length):
				for j in range(word.length):
					if existing_word.word[i] == word.word[j]:
						# Encontrou uma letra em comum
						if existing_word.vertical:
							# Palavra existente é vertical, nova será horizontal
							word.vertical = false
							word.row = existing_word.row + i
							word.col = existing_word.col - j
						else:
							# Palavra existente é horizontal, nova será vertical
							word.vertical = true
							word.row = existing_word.row - j
							word.col = existing_word.col + i

						if is_valid_placement(word):
							place_word_in_grid(word)
							return true
		return false

	func is_valid_placement(word):
		if word.row < 1 or word.col < 1:
			return false

		if word.vertical:
			return word.row + word.length - 1 <= rows
		else:
			return word.col + word.length - 1 <= cols

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
