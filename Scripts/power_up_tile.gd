extends Node2D

@export var powerup_resource: PowerupResource
@export var bomb_resource: BombType
@export var float_amplitude: float = 5.0  # How high it floats
@export var float_speed: float = 2.0  # Speed of floating animation

var initial_position: Vector2
var time_passed: float = 0.0


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
	if body.has_method("get_movement_manager"):
		var movement_manager = body.get_movement_manager()
		if movement_manager:
			if powerup_resource:
				var movement_type = powerup_resource.movement_type
				var duration = powerup_resource.duration
				movement_manager.change_movement_mode(movement_type, duration)
			if bomb_resource:
				body.change_bomb_type_to(bomb_resource)
			
		# Add collection effect
		create_collection_effect()
		
		# Remove after collection
		queue_free()


func create_collection_effect() -> void:
	# Optional: You could add particles or sound effects here
	pass
