extends Node2D

signal minigame_completed(success)

# Called when the minigame starts
func start():
	pass

# Called when the minigame ends
func end(success):
	emit_signal("minigame_completed", success)

# Reset the minigame to its initial state
func reset():
	pass

# Override this in child classes to implement specific game logic
func _ready():
	pass
