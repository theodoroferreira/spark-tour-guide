extends Control

signal dialog_ended

@onready var text_label = $Panel/TextLabel
@onready var name_label = $Panel/NameLabel
@onready var portrait = $Panel/Portrait
@onready var animation_player = $AnimationPlayer
@onready var dialog_sound = $DialogSound

var dialog_queue = []
var is_dialog_active = false
var is_animating = false
var input_enabled = false
var current_state = { "is_en": true }
var current_texts = { "en": "", "pt": "" }

func _ready():
	hide()
	_setup_dialog_sound()

func reset():
	dialog_queue.clear()
	hide()
	is_dialog_active = false
	is_animating = false
	input_enabled = false
	animation_player.stop()
	current_state.is_en = true
	current_texts = { "en": "", "pt": "" }

func start_dialog(dialog_data):
	dialog_queue = dialog_data
	show()
	is_dialog_active = true
	is_animating = false
	input_enabled = false
	# Set Portrait2 texture
	if has_node("Panel/Portrait2"):
		$Panel/Portrait2.texture = load("res://assets/backgrounds/spark_face_dft_1.png")
	display_next_dialog()
	await get_tree().process_frame
	await get_tree().process_frame # aguarda 2 frames pra garantir que o input anterior passou
	input_enabled = true

func display_next_dialog():
	if dialog_queue.size() == 0:
		end_dialog()
		return
		
	var current_dialog = dialog_queue.pop_front()
	name_label.text = current_dialog.name
	
	# Handle both single text and dual language texts
	if current_dialog.has("en") and current_dialog.has("pt"):
		current_texts.en = current_dialog.en
		current_texts.pt = current_dialog.pt
		text_label.text = current_texts.en if current_state.is_en else current_texts.pt
		_add_language_toggle()
	else:
		text_label.text = current_dialog.text
		_remove_language_toggle()
	
	if current_dialog.has("portrait"):
		if ResourceLoader.exists(current_dialog.portrait):
			portrait.texture = load(current_dialog.portrait)
		else:
			portrait.texture = null
	
	text_label.visible_ratio = 0
	is_animating = true
	_play_dialog_sound()
	animation_player.play("text_appear")
	await animation_player.animation_finished
	is_animating = false

func _add_language_toggle():
	# Remove existing toggle button if any
	_remove_language_toggle()
	
	# Create new toggle button
	var toggle_btn = Button.new()
	toggle_btn.text = "Translate"
	toggle_btn.size = Vector2(32, 32)
	toggle_btn.position = Vector2($Panel.size.x - 48, 8)
	toggle_btn.focus_mode = Control.FOCUS_NONE
	toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	$Panel.add_child(toggle_btn)
	toggle_btn.move_to_front()
	
	toggle_btn.pressed.connect(func():
		current_state.is_en = !current_state.is_en
		if text_label:
			text_label.text = current_texts.en if current_state.is_en else current_texts.pt
	)

func _remove_language_toggle():
	for child in $Panel.get_children():
		if child is Button and child.text == "*":
			child.queue_free()
			break

func end_dialog():
	if not is_dialog_active:
		return
	print("Escondendo dialog box")
	is_dialog_active = false
	is_animating = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	is_animating = false
	hide()
	emit_signal("dialog_ended")

func _input(event):
	if not is_dialog_active or not input_enabled:
		return

	if event.is_action_pressed("ui_accept"):
		if is_animating:
			animation_player.stop()
			text_label.visible_ratio = 1.0
			is_animating = false
		else:
			display_next_dialog()

func _setup_dialog_sound():
	if not has_node("DialogSound"):
		var audio_player = AudioStreamPlayer.new()
		audio_player.name = "DialogSound"
		add_child(audio_player)
		dialog_sound = audio_player
	
	var sound_path = "res://assets/sounds/sfx/dialog_sound.wav"
	if ResourceLoader.exists(sound_path):
		dialog_sound.stream = load(sound_path)

func _play_dialog_sound():
	if dialog_sound and dialog_sound.stream:
		dialog_sound.play()
