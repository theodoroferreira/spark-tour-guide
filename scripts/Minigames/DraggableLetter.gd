extends Button

var letter = ""
var is_selected = false
var minigame_ref = null
var is_being_dragged = false
var drag_started = false

func _ready():
	# Configurações básicas do botão letra
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Garante que o botão pode receber eventos
	set_process_input(true)
	set_process_unhandled_input(true)

func setup(letter_text, minigame):
	text = letter_text
	letter = letter_text
	minigame_ref = minigame

	# Garante que o botão está configurado corretamente
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE

	# Reconecta os sinais (evita conexões duplicadas)
	if gui_input.is_connected(_on_gui_input):
		gui_input.disconnect(_on_gui_input)
	if mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.disconnect(_on_mouse_entered)
	if mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.disconnect(_on_mouse_exited)

	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Configura estilo visual do botão
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 1.0)
	style.corner_radius_top_left = size.x/2
	style.corner_radius_top_right = size.x/2
	style.corner_radius_bottom_left = size.x/2
	style.corner_radius_bottom_right = size.x/2
	add_theme_stylebox_override("normal", style)

	print("Setup concluído para letra: " + letter + " - Botão clicável: " + str(mouse_filter == Control.MOUSE_FILTER_STOP))

func _process(_delta):
	# Verifica continuamente se o mouse está pressionado e movendo
	if is_being_dragged and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_viewport().get_mouse_position()
		minigame_ref.continue_letter_selection(mouse_pos)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_pos = get_local_mouse_position()
			if Rect2(Vector2.ZERO, size).has_point(local_pos):
				_start_drag()
		else:
			_end_drag()

func _start_drag():
	if minigame_ref != null:
		print("Iniciando arraste na letra: " + letter)
		is_being_dragged = true
		drag_started = true
		minigame_ref.start_letter_selection(self, letter)

func _end_drag():
	if is_being_dragged:
		print("Finalizando arraste na letra: " + letter)
		is_being_dragged = false
		drag_started = false
		minigame_ref.end_letter_selection()

func _on_gui_input(event):
	if minigame_ref == null:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("Letra " + letter + " pressionada via gui_input")
				_start_drag()
				get_viewport().set_input_as_handled()
			else:
				print("Letra " + letter + " solta")
				_end_drag()
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		if is_being_dragged or minigame_ref.is_selecting:
			print("Movimento do mouse sobre letra: " + letter)
			minigame_ref.continue_letter_selection(event.global_position)
			get_viewport().set_input_as_handled()

func _on_mouse_entered():
	if minigame_ref != null:
		if minigame_ref.is_selecting:
			print("Mouse entrou na letra: " + letter)
			minigame_ref.continue_letter_selection(get_global_mouse_position())

		# Feedback visual ao passar o mouse
		if not is_selected:
			modulate = Color(1.1, 1.1, 1.1)

func _on_mouse_exited():
	if minigame_ref != null:
		if minigame_ref.is_selecting:
			print("Mouse saiu da letra: " + letter)

		# Remove feedback visual se não estiver selecionada
		if not is_selected:
			modulate = Color(1, 1, 1)

func select():
	if is_selected:
		return

	is_selected = true
	modulate = Color(1.2, 1.2, 0.8)  # Destaque amarelado

	# Feedback visual de seleção
	var style = get_theme_stylebox("normal").duplicate()
	if style is StyleBoxFlat:
		style.bg_color = Color(1.0, 0.8, 0.0)
		add_theme_stylebox_override("normal", style)

	# Animação de seleção - ajustada para ser mais sutil com botões menores
	var scale_factor = 1.1
	if size.x < 50:  # Para botões menores, reduz a escala da animação
		scale_factor = 1.05

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(scale_factor, scale_factor), 0.1)

func deselect():
	if not is_selected:
		return

	is_selected = false
	modulate = Color(1, 1, 1)

	# Restaura estilo original
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 1.0)
	style.corner_radius_top_left = size.x/2
	style.corner_radius_top_right = size.x/2
	style.corner_radius_bottom_left = size.x/2
	style.corner_radius_bottom_right = size.x/2
	add_theme_stylebox_override("normal", style)

	# Animação de deseleção
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
