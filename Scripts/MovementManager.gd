extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 800  # pixels per second

var moving : bool = false
var target_position : Vector2
@onready var BombMarker = $"../BombSpawnLocation"
@onready var BombManager = $"../BombManager"

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
			
			# Notify about movement completion - call this when the player completes a move
			player_body.GlobalBombs.on_player_move(player_body.id)
			print("Player ", player_body.id, " completed movement")
		else:
			player_body.velocity = direction * travel_speed
			player_body.move_and_slide()
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()

func can_move_to(target_pos: Vector2) -> bool:
	var motion = target_pos - player_body.global_position
	return not player_body.test_move(player_body.transform, motion)

func handle_input():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed(str(player_body.up_action)):
		input_vector.y = -1
	elif Input.is_action_pressed(str(player_body.down_action)):
		input_vector.y = 1
	elif Input.is_action_pressed(str(player_body.left_action)):
		input_vector.x = -1
	elif Input.is_action_pressed(str(player_body.right_action)):
		input_vector.x = 1

	if input_vector != Vector2.ZERO:
		player_body.last_move_direction = input_vector
		var new_target = player_body.global_position + input_vector * grid_size
		target_position = new_target
		moving = true
		start_action_cooldown()
		update_bomb_marker()  
		
func start_action_cooldown():
	player_body.action_cooldown_timer = player_body.action_cooldown_duration

func update_bomb_marker():
	var new_marker_pos = player_body.global_position + player_body.last_move_direction * grid_size
	BombMarker.global_position = new_marker_pos
