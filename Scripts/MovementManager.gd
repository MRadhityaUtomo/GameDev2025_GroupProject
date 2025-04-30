extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 500  # pixels per second

var moving : bool = false
var target_position : Vector2

func _ready():
	target_position = player_body.global_position

func _physics_process(delta):
	if player_body.action_cooldown_timer > 0:
		player_body.action_cooldown_timer -= delta
		
	if moving:
		var direction = (target_position - player_body.global_position).normalized()
		var distance = travel_speed * delta
		if player_body.global_position.distance_to(target_position) <= distance:
			player_body.global_position = target_position
			moving = false
		else:
			player_body.velocity = direction * travel_speed
			player_body.move_and_slide()
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()

func handle_input():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input_vector.y = -1
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1
	elif Input.is_action_pressed("ui_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("ui_right"):
		input_vector.x = 1

	if input_vector != Vector2.ZERO:
		var new_target = player_body.global_position + input_vector * grid_size
		target_position = new_target
		moving = true
		start_action_cooldown()

func start_action_cooldown():
	player_body.action_cooldown_timer = player_body.action_cooldown_duration
