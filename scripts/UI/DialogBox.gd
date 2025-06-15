extends Control

signal dialog_ended

@onready var text_label = $Panel/TextLabel
@onready var name_label = $Panel/NameLabel
@onready var portrait = $Panel/Portrait
@onready var animation_player = $AnimationPlayer

var dialog_queue = []
var is_dialog_active = false
var is_animating = false
var input_enabled = false

func _ready():
	hide()

func reset():
	dialog_queue.clear()
	hide()
	is_dialog_active = false
	is_animating = false
	input_enabled = false
	animation_player.stop()

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
	text_label.text = current_dialog.text
	
	if current_dialog.has("portrait"):
		if ResourceLoader.exists(current_dialog.portrait):
			portrait.texture = load(current_dialog.portrait)
		else:
			portrait.texture = null
	
	text_label.visible_ratio = 0
	is_animating = true
	animation_player.play("text_appear")
	await animation_player.animation_finished
	is_animating = false

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
