extends Node2D

@export var powerup_resource: PowerupResource
@export var bomb_resource: BombType
@export var float_amplitude: float = 5.0  # How high it floats
@export var float_speed: float = 2.0  # Speed of floating animation

var initial_position: Vector2
var time_passed: float = 0.0

#Sounds
@onready var powerup_pickup: AudioStreamPlayer2D = $PowerupPickup

func _ready() -> void:
	# Store initial position for floating animation
	initial_position = position
	
	# Randomize starting point in animation cycle
	time_passed = randf() * TAU  # Random phase offset
	
	if bomb_resource:
		# You may also want to set a bomb-specific texture
		$Sprite2D.texture = bomb_resource.texture
	elif powerup_resource:
		# Use the resource properties
		$Sprite2D.texture = powerup_resource.texture
		$Sprite2D.modulate = powerup_resource.color_tint

	print("Powerup SPAWNED at:", global_position)


func _process(delta: float) -> void:
	# Update the animation timer
	time_passed += delta * float_speed
	
	# Apply floating motion using sine wave
	position.y = initial_position.y + sin(time_passed) * float_amplitude
	
	# Add subtle rotation for extra effect
	$Sprite2D.rotation = sin(time_passed * 0.5) * 0.05


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		# Handle movement powerups
		if powerup_resource:
			var movement_manager = body.get_node_or_null("MovementManager")
			if movement_manager:
				# Pass the powerup's custom duration
				var duration = powerup_resource.duration
				movement_manager.change_movement_mode(powerup_resource.movement_type, duration)
				body.powerup_activated(powerup_resource.id_name, duration)
				print("Player collected movement powerup: " + powerup_resource.display_name + 
					  " (Duration: " + str(duration) + "s)")
		
		# Handle bomb powerups
		elif bomb_resource:
			var duration = bomb_resource.duration
			body.change_bomb_type(bomb_resource, duration)
			body.powerup_activated(bomb_resource.id_name, duration)
			
		
		# Remove after collection
		queue_free()
