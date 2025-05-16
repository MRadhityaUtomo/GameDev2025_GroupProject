extends Area2D

enum PowerupType { DIAGONAL_MODE, SPEED_BOOST, EXTRA_BOMB }

@export var type: PowerupType = PowerupType.DIAGONAL_MODE
@export var effect_duration: float = 20.0  # Duration in seconds (0 = permanent)


func _ready():
	# Set up collision detection
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body is CharacterBody2D:  # If it's a player
		apply_effect(body)
		queue_free()


func apply_effect(player):
	match type:
		PowerupType.DIAGONAL_MODE:
			player.diagonal_mode_active = true
			if effect_duration > 0:
				# Start a timer to remove the effect
				var timer = Timer.new()
				timer.one_shot = true
				timer.wait_time = effect_duration
				timer.timeout.connect(func(): _on_effect_timeout(player, PowerupType.DIAGONAL_MODE))
				add_child(timer)
				timer.start()

		PowerupType.SPEED_BOOST:
			# Implement speed boost logic in the future
			pass

		PowerupType.EXTRA_BOMB:
			# Implement extra bomb logic in the future
			pass

	print("Player ", player.id, " collected powerup: ", PowerupType.keys()[type])


func _on_effect_timeout(player, effect_type):
	if not is_instance_valid(player):
		return

	match effect_type:
		PowerupType.DIAGONAL_MODE:
			player.diagonal_mode_active = false
			print("Player ", player.id, " lost diagonal mode powerup")
