extends Node2D

@export var movement_type: MovementMode.Type = MovementMode.Type.REVERSED_MOVEMENT
@export var float_amplitude: float = 5.0  # How high it floats
@export var float_speed: float = 2.0  # Speed of floating animation

var type_colors = {
	MovementMode.Type.KING_MOVEMENT: Color.YELLOW,
	MovementMode.Type.BISHOP_MOVEMENT: Color.PURPLE,
	MovementMode.Type.QUEEN_MOVEMENT: Color.RED,
	MovementMode.Type.DOUBLE_STEP_MOVEMENT: Color.GREEN,
	MovementMode.Type.REVERSED_MOVEMENT: Color.BLUE
}

var initial_position: Vector2
var time_passed: float = 0.0


func _ready() -> void:
	# Store initial position for floating animation
	initial_position = position
	
	# Randomize starting point in animation cycle
	time_passed = randf() * TAU  # Random phase offset
	
	# Randomize the movement type
	var types = MovementMode.Type.values()
	movement_type = types[randi() % types.size()]

	# Set visual appearance based on randomly selected movement type
	if movement_type in type_colors:
		$Sprite2D.modulate = type_colors[movement_type]

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
			movement_manager.change_movement_mode(movement_type)
			
		# Add collection effect
		create_collection_effect()
		
		# Remove after collection
		queue_free()


func create_collection_effect() -> void:
	# Optional: You could add particles or sound effects here
	pass
