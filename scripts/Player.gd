extends CharacterBody2D

signal destination_reached

@export var move_speed = 150.0
var target_position = Vector2.ZERO
var is_moving = false
var path = []

@onready var navigation_agent = $NavigationAgent2D
@onready var animation_player = $AnimationPlayer

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

func _physics_process(delta):
	if is_moving:
		var next_path_position = navigation_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_position)
		velocity = direction * move_speed
		
		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false
		
		if velocity.length() > 0:
			animation_player.play("walk")
		else:
			animation_player.play("idle")
		
		move_and_slide()
		
		if navigation_agent.is_navigation_finished():
			is_moving = false
			velocity = Vector2.ZERO
			animation_player.play("idle")
			emit_signal("destination_reached")

func move_to(target_pos):
	target_position = target_pos
	navigation_agent.target_position = target_position
	is_moving = true