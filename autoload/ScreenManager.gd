extends Node

func _ready():
	# Opcional: conectar redimensionamento, mas sem alterar elementos manualmente
	get_tree().root.size_changed.connect(_on_window_resize)

func _on_window_resize():
	# Exibe resolução atual no console (debug)
	print("Nova resolução:", get_viewport().get_visible_rect().size)

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
