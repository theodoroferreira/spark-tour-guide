extends Control

signal messages_finished

@onready var dialog_text = $DialogText
@onready var next_button = $NextButton
@onready var spark_icon = $SparkIcon

var message_queue = []

func _ready():
	next_button.pressed.connect(_on_next_button_pressed)
	load_spark_icon()
	hide()

func load_spark_icon():
	var icon_path = "res://assets/characters/spark.png"
	if ResourceLoader.exists(icon_path):
		spark_icon.texture = load(icon_path)

func show_messages(messages):
	show()
	message_queue = messages.duplicate()
	display_next_message()

	# Return a signal that will be emitted when all messages are shown
	return messages_finished

func display_next_message():
	if message_queue.size() == 0:
		hide()
		messages_finished.emit()
		return

	dialog_text.text = message_queue.pop_front()

func _on_next_button_pressed():
	display_next_message()
