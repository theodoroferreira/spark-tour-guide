extends Control

signal dialog_ended

@onready var text_label = $Panel/TextLabel
@onready var name_label = $Panel/NameLabel
@onready var portrait = $Panel/Portrait
@onready var animation_player = $AnimationPlayer

var dialog_queue = []
var is_dialog_active = false

func _ready():
	hide()

func start_dialog(dialog_data):
	dialog_queue = dialog_data
	show()
	is_dialog_active = true
	display_next_dialog()

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
	
	animation_player.play("text_appear")

func end_dialog():
	is_dialog_active = false
	animation_player.play("fade_out")
	await animation_player.animation_finished
	hide()
	emit_signal("dialog_ended")

func _input(event):
	if is_dialog_active and event.is_action_pressed("ui_accept"):
		if animation_player.is_playing():
			animation_player.stop()
			text_label.visible_ratio = 1.0
		else:
			display_next_dialog()
