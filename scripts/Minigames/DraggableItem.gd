extends Area2D

var dragging = false
var drag_offset = Vector2()
var original_position = Vector2()
var item_name = ""
var minigame_reference = null

func _ready():
	original_position = global_position
	# Get item name from the Label child node
	if has_node("Label"):
		item_name = $Label.text.to_lower()
	input_pickable = true

func connect_signals(minigame):
	minigame_reference = minigame
	connect("input_event", _on_input_event)
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging = true
				drag_offset = global_position - get_global_mouse_position()
			else:
				# Stop dragging and handle drop logic
				dragging = false
				# Check if dropped on the suitcase
				var dropped_on_suitcase = false
				for area in get_overlapping_areas():
					if area.name == "Suitcase":
						if minigame_reference:
							minigame_reference.check_item(item_name)
						visible = false
						dropped_on_suitcase = true
						break
				# If not dropped on suitcase, reset position
				if not dropped_on_suitcase:
					global_position = original_position

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func _on_area_entered(area):
	if area.name == "Suitcase" and !dragging:
		# Item was dropped on the suitcase
		if minigame_reference:
			minigame_reference.check_item(item_name)
			# Hide the item after dropping it in the suitcase
			visible = false

func _on_area_exited(_area):
	if !dragging:
		# Return to original position if not in suitcase
		global_position = original_position
