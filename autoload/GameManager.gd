extends Node

var current_scene = null
var player = null
var current_location = "Home"

func _ready():
	load_home_scene()

func load_home_scene():
	change_scene("res://scenes/Home.tscn")

func load_location_scene(location_name):
	current_location = location_name
	var path = "res://scenes/Locations/%s.tscn" % location_name
	change_scene(path)

func start_minigame(minigame_name):
	var path = "res://scenes/Minigames/%s.tscn" % minigame_name
	change_scene(path)

func change_scene(scene_path):
	if current_scene:
		current_scene.queue_free()
	var scene_resource = load(scene_path)
	current_scene = scene_resource.instantiate()
	get_tree().get_root().add_child(current_scene)
	get_tree().current_scene = current_scene

func give_feedback(text):
	var feedback = load("res://scenes/UI/FeedbackLabel.tscn").instantiate()
	feedback.set_text(text)
	get_tree().get_root().add_child(feedback)
	feedback.show_feedback()

func on_minigame_completed(success):
	if success:
		give_feedback("Nice!")
	# Return to home after a short delay
	await get_tree().create_timer(1.5).timeout
	load_home_scene()