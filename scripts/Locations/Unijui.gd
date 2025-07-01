extends Node2D

func _on_back_button_pressed():
	AudioManager.play_click_sound()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Menu.tscn")

func _on_enter_button_pressed():
	AudioManager.play_click_sound()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Locations/Biblioteca.tscn") 