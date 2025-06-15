extends Node2D

@onready var player = $Player
@onready var spark = $Spark

var dialog_data = [
	{
		"name": "Spark",
		"text": "Welcome to the Train Station! This is where people travel to other cities.",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	},
	{
		"name": "Spark",
		"text": "Let's play a game to learn words about traveling!",
		"portrait": "res://assets/characters/spark_reborn_face.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	start_location_dialog()

func start_location_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)
	await dialog_box.dialog_ended
	#start_minigame()

#func start_minigame():
	#var minigame_name = GameManager.minigame_to_load
	#if minigame_name != "":
		#var minigame_scene = load("res://scenes/Minigames/" + minigame_name + ".tscn").instantiate()
		#add_child(minigame_scene)
		#minigame_scene.start()
		#minigame_scene.connect("minigame_completed", _on_minigame_completed)

#func _on_minigame_completed(success):
	#if success:
		#GameManager.give_feedback("Great job!")
	#
	## Wait before returning to home
	#await get_tree().create_timer(2.0).timeout
	#GameManager.load_home_scene()
#
func _on_home_button_pressed():
	print("Botão Home clicado!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Home.tscn")
	GameManager.current_location = "Home"
