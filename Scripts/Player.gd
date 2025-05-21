class_name Player
extends CharacterBody2D

@export var id: int
@export var hp: int = 3
@export var state: String
@export var BombCount: int = 3
@export var action_cooldown_duration: float = 0.6 # seconds

@export var up_action: String
@export var down_action: String
@export var left_action: String
@export var right_action: String
@export var bomb_action: String

@onready var hurtBox = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var animations = $AnimatedSprite2D
@export var animationSet:SpriteFrames

var isInvincible = false
var CanPlace = true
var original_modulate := Color(1, 1, 1)
@export var current_bomb_type: BombType

@export var GlobalBombs: Node2D

var action_cooldown_timer: float = 0.0
var last_move_direction: Vector2 = Vector2.ZERO
var has_diagonal_movement: bool = false  # Added for diagonal movement powerup
var diagonal_mode_active: bool = false  # New variable for diagonal-only mode

# Add these variables for powerup management
@onready var powerup_timer: Timer = $PowerupTimer
@onready var bomb_powerup_timer: Timer = $BombPowerupTimer
var default_bomb_type: BombType
var default_movement_mode: MovementMode.Type = MovementMode.Type.KING_MOVEMENT
var has_active_powerup: bool = false

#Sounds
@onready var powerup_pickup: AudioStreamPlayer2D = $"PowerupPickup"

func _ready():
	animations.sprite_frames = animationSet
	animations.play("idle")
	add_to_group("player")
	default_bomb_type = current_bomb_type
	print("player ready at", global_position)
	
	# Setup powerup timer if it doesn't exist
	if not has_node("PowerupTimer"):
		var timer = Timer.new()
		timer.name = "PowerupTimer"
		timer.one_shot = true
		add_child(timer)
		powerup_timer = timer
	
	# Set up bomb powerup timer if it doesn't exist
	if not has_node("BombPowerupTimer"):
		var timer = Timer.new()
		timer.name = "BombPowerupTimer"
		timer.one_shot = true
		add_child(timer)
		bomb_powerup_timer = timer
	pass


func invincible():
	print("test")
	hurtBox.disabled = true
	isInvincible = true
	var flicker_count = 20 
	var flicker_interval = 0.1  
	var original_visibility = animations.modulate.a
	for i in range(flicker_count):
		animations.modulate.a = 0.2 if i % 2 == 0 else original_visibility
		await get_tree().create_timer(flicker_interval).timeout
	animations.modulate.a = original_visibility
	hurtBox.disabled = false
	isInvincible = false


func takedamage():
	hp -= 1
	if hp <= 0:
		die()
	self.invincible()
	animations.play("hurt")
	await animations.animation_finished
	animations.play("idle")

	
# Add this new function for grid-aligned push
func push_from_border_grid_aligned(push_direction: Vector2, dynamic_tiles: DynamicTiles):
	# Calculate the target position
	var current_tile_pos = dynamic_tiles.local_to_map(dynamic_tiles.to_local(global_position))
	
	# Try to find next valid cell in direction of center
	var grid_aligned_direction = Vector2i(
		round(push_direction.x),  # Round to -1, 0, or 1
		round(push_direction.y)   # Round to -1, 0, or 1
	)
	
	# If both components are non-zero (diagonal), choose the stronger one
	if grid_aligned_direction.x != 0 and grid_aligned_direction.y != 0:
		if abs(push_direction.x) > abs(push_direction.y):
			grid_aligned_direction.y = 0
		else:
			grid_aligned_direction.x = 0
	
	# If somehow both components became zero, default to a direction toward center
	if grid_aligned_direction == Vector2i.ZERO:
		var to_center = dynamic_tiles.center - current_tile_pos
		grid_aligned_direction = Vector2i(sign(to_center.x), sign(to_center.y))
		
		# Still need to choose one direction
		if grid_aligned_direction.x != 0 and grid_aligned_direction.y != 0:
			if abs(to_center.x) > abs(to_center.y):
				grid_aligned_direction.y = 0
			else:
				grid_aligned_direction.x = 0
	
	# Calculate target tile position (one tile in the grid direction)
	var target_tile_pos = current_tile_pos + grid_aligned_direction
	
	# Convert back to world position
	var target_world_pos = dynamic_tiles.to_global(dynamic_tiles.map_to_local(target_tile_pos))
	
	# Move directly to the grid-aligned position
	global_position = target_world_pos
	
	# Play hurt animation if not already playing
	if animations.animation != "hurt":
		animations.play("hurt")
		await animations.animation_finished
		animations.play("idle")

# Keep the old function for compatibility
func push_from_border(push_direction: Vector2, push_distance: float = 64.0):
	# Apply a fixed distance movement in the push direction
	print("pushed (deprecated function)")
	position += push_direction * push_distance
	
	# Play hurt animation if not already playing
	if animations.animation != "hurt":
		animations.play("hurt")
		await animations.animation_finished
		animations.play("idle")
	
func die():
	queue_free()

func get_movement_manager():
	return $MovementManager

func change_bomb_type_to(new_type: BombType):
	current_bomb_type = new_type

# Add this new function for handling any powerup
func powerup_activated(id_name: String):
	powerup_pickup.play()
	#DUMB AHH
	if id_name.begins_with("Move"):
		if id == 1:
			$"../CanvasLayer/play_ui".set_p1_move_icon(id_name)
		else:
			$"../CanvasLayer/play_ui".set_p2_move_icon(id_name)
	else:
		if id == 1:
			$"../CanvasLayer/play_ui".set_p1_powup_icon(id_name)
		else:
			$"../CanvasLayer/play_ui".set_p2_powup_icon(id_name)
	$"../CanvasLayer/play_ui".update_player_icons()

# Add this function to cancel any active powerup
func cancel_active_powerup():
	if has_active_powerup:
		# Stop the timer
		if powerup_timer.timeout.is_connected(_on_powerup_expired):
			powerup_timer.timeout.disconnect(_on_powerup_expired)
		powerup_timer.stop()
		
		# Reset to defaults
		current_bomb_type = default_bomb_type
		var movement_manager = get_movement_manager()
		if movement_manager:
			movement_manager.change_movement_mode(default_movement_mode)
		
		has_active_powerup = false
		print("Previous powerup canceled")

# Add this function for when the powerup expires
func _on_powerup_expired():
	print("Powerup expired, reverting to defaults")
	current_bomb_type = default_bomb_type
	var movement_manager = get_movement_manager()
	if movement_manager:
		movement_manager.change_movement_mode(default_movement_mode)
	
	has_active_powerup = false
	if powerup_timer.timeout.is_connected(_on_powerup_expired):
		powerup_timer.timeout.disconnect(_on_powerup_expired)

# Add this new function for bomb powerup management
func change_bomb_type(new_bomb_type: BombType, duration: float = 10.0):
	# Cancel any active bomb powerup timer
	if bomb_powerup_timer.time_left > 0:
		if bomb_powerup_timer.timeout.is_connected(_reset_bomb_type):
			bomb_powerup_timer.timeout.disconnect(_reset_bomb_type)
		bomb_powerup_timer.stop()
	
	# Change to new bomb type
	current_bomb_type = new_bomb_type
	print("Changed bomb type to: " + new_bomb_type.name + " (Duration: " + str(duration) + "s)")
	
	# Set up timer to revert
	bomb_powerup_timer.wait_time = duration
	bomb_powerup_timer.timeout.connect(_reset_bomb_type)
	bomb_powerup_timer.start()

func _reset_bomb_type():
	print("Bomb powerup expired, reverting to default")
	current_bomb_type = default_bomb_type
	if bomb_powerup_timer.timeout.is_connected(_reset_bomb_type):
		bomb_powerup_timer.timeout.disconnect(_reset_bomb_type)
