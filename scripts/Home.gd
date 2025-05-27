extends Node2D

@onready var player = $Player
@onready var spark = $Spark

var dialog_data = [
	{
		"name": "Spark",
		"text": "Hi there! Welcome to Ijuí. I'm Spark, your guide!",
		"portrait": "res://assets/characters/spark.png"
	},
	{
		"name": "Spark",
		"text": "Click on any of the signs to visit a location in town!",
		"portrait": "res://assets/characters/spark.png"
	}
]

func _ready():
	await get_tree().create_timer(0.5).timeout
	start_intro_dialog()
	# Connect Train Station sign to load location scene directly
	$LocationSigns/TrainStationSign.pressed.connect(_on_train_station_sign_pressed)

func start_intro_dialog():
	var dialog_box = $UI/DialogBox
	dialog_box.start_dialog(dialog_data)

func _on_location_sign_pressed(location_name, minigame_name, target_position):
	# Disable all signs while moving
	for sign in get_tree().get_nodes_in_group("location_signs"):
		sign.disabled = true
	
	player.move_to(target_position)
	await player.destination_reached
	
	# Wait a moment before transition
	await get_tree().create_timer(0.5).timeout
	
	# Store minigame to load with location
	if minigame_name != "":
		GameManager.minigame_to_load = minigame_name
	
	# Load location scene
	GameManager.load_location_scene(location_name)
 
func _on_train_station_sign_pressed():
	# Set the Train Station minigame before loading the location
	GameManager.minigame_to_load = "PackUpMinigame"
	GameManager.load_location_scene("TrainStation")
