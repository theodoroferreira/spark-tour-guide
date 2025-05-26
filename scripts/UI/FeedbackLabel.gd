extends Control

@onready var label = $Label
@onready var animation_player = $AnimationPlayer

func _ready():
	hide()

func set_text(text):
	label.text = text

func show_feedback():
	show()
	animation_player.play("popup")
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	animation_player.play("fade_out")
	await animation_player.animation_finished
	queue_free()