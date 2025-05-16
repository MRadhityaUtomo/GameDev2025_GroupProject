extends Node2D

@export var movement_type: MovementMode.Type = MovementMode.Type.REVERSED_MOVEMENT

var type_colors = {
	MovementMode.Type.KING_MOVEMENT: Color.YELLOW,
	MovementMode.Type.BISHOP_MOVEMENT: Color.PURPLE,
	MovementMode.Type.QUEEN_MOVEMENT: Color.RED,
	MovementMode.Type.DOUBLE_STEP_MOVEMENT: Color.GREEN,
	MovementMode.Type.REVERSED_MOVEMENT: Color.BLUE
}


func _ready() -> void:
	# Randomize the movement type
	var types = MovementMode.Type.values()
	movement_type = types[randi() % types.size()]

	# Set visual appearance based on randomly selected movement type
	if movement_type in type_colors:
		$Sprite2D.modulate = type_colors[movement_type]

	print(
		"Powerup SPAWNED at:",
		global_position,
		" with type:",
		MovementMode.Type.keys()[movement_type]
	)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var mode_name = MovementMode.Type.keys()[movement_type]
		print("Player collected " + mode_name + " powerup!")

		if body.has_method("get_movement_manager"):
			var movement_manager = body.get_movement_manager()
			if movement_manager:
				# Pass the enum value directly
				movement_manager.change_movement_mode(movement_type)

		queue_free()
