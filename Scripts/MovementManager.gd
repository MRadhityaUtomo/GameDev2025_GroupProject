extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 800  # pixels per second

var moving : bool = false
var target_position : Vector2
@onready var BombMarker = $"../BombSpawnLocation"
@onready var BombManager = $"../BombManager"
@onready var Raycast = $"../RayCast2D"

func _ready():
	target_position = player_body.global_position
	Raycast.target_position = Vector2(grid_size, 0)

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

func can_move_to(input_vector: Vector2) -> bool:
	# Set raycast direction with shorter length (2/3 of grid size)
	Raycast.target_position = input_vector * (grid_size * 2 / 3)
	
	# Force the raycast to update
	Raycast.force_raycast_update()
	
	# Return true if no collision detected
	if Raycast.is_colliding():
		player_body.CanPlace = false
	else:
		player_body.CanPlace = true
		
	return !Raycast.is_colliding()

func handle_input():
	var input_vector = Vector2.ZERO
	# Check if bomb placement is valid
	if Input.is_action_pressed(str(player_body.up_action)):
		input_vector.y = -1
	elif Input.is_action_pressed(str(player_body.down_action)):
		input_vector.y = 1
	elif Input.is_action_pressed(str(player_body.left_action)):
		input_vector.x = -1
	elif Input.is_action_pressed(str(player_body.right_action)):
		input_vector.x = 1

	if input_vector != Vector2.ZERO:
		if can_move_to(input_vector):
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
	
	# Check if we can place a bomb at the marker position
	check_bomb_placement_valid()

func check_bomb_placement_valid():
	# Set raycast direction with shorter length
	Raycast.target_position = player_body.last_move_direction * (grid_size * 2 / 3)
	
	# Force the raycast to update
	Raycast.force_raycast_update()
	
	# Update the CanPlace flag
	player_body.CanPlace = !Raycast.is_colliding()
