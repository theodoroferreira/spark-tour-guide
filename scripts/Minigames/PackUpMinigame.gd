extends "res://scripts/Minigames/MinigameBase.gd"

@onready var items_container = $Items
@onready var suitcase = $Suitcase
@onready var feedback_label = $FeedbackLabel

var required_items = ["shirt", "pants", "toothbrush", "book"]
var current_items = []
var correct_items = 0
var total_required = 0

func _ready():
	super._ready()
	total_required = required_items.size()
	
	# Connect draggable items signals
	for item in items_container.get_children():
		if item.has_method("connect_signals"):
			item.connect_signals(self)

func start():
	super.start()
	$Instructions.show()
	$StartButton.show()

func _on_start_button_pressed():
	$Instructions.hide()
	$StartButton.hide()
	$Timer.start()

func check_item(item_name):
	if required_items.has(item_name) and not current_items.has(item_name):
		current_items.append(item_name)
		correct_items += 1
		feedback_label.text = "Correct! " + item_name.capitalize() + " goes in the suitcase!"
		feedback_label.modulate = Color(0, 1, 0)
		feedback_label.show()
		
		if correct_items >= total_required:
			await get_tree().create_timer(1.0).timeout
			end(true)
	else:
		feedback_label.text = "Try again! This doesn't go in the suitcase."
		feedback_label.modulate = Color(1, 0.5, 0)
		feedback_label.show()

func _on_timer_timeout():
	# If time runs out, end with partial success based on items collected
	var success = correct_items > (total_required / 2)
	end(success)

func reset():
	super.reset()
	current_items.clear()
	correct_items = 0
	$Timer.stop()
	feedback_label.hide()