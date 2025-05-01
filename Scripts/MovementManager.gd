extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 800  # pixels per second

var moving : bool = false
var target_position : Vector2
@onready var BombMarker = $"../BombSpawnLocation"

func _ready():
	target_position = player_body.global_position
	update_bomb_marker()  # place marker initially

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
		player_body.last_move_direction = input_vector
		var new_target = player_body.global_position + input_vector * grid_size
		target_position = new_target
		moving = true
		start_action_cooldown()
		update_bomb_marker()  # move the bomb marker after moving direction changes

	#elif Input.is_action_just_pressed("ui_accept"):
		#place_bomb()

#func place_bomb():
	#BombManager.place_bomb(BombMarker.global_position)

func start_action_cooldown():
	player_body.action_cooldown_timer = player_body.action_cooldown_duration

func update_bomb_marker():
	# move marker relative to player’s current position + last_move_direction
	var new_marker_pos = player_body.global_position + player_body.last_move_direction * grid_size
	BombMarker.global_position = new_marker_pos
