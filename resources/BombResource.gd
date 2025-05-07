class_name BombType
extends Resource

## Base class for different bomb types


#still 1st ver, change for more modular approacj
# Core Properties
@export var name: String = "Standard Bomb"
@export var countdown_time: int = 3
@export var explosion_radius: int = 2
@export var explosion_scene: PackedScene

# Visual Properties
@export var bomb_texture: Texture2D
@export var explosion_color: Color = Color.ORANGE_RED

# Special Properties
@export var chain_reaction: bool = true  # Whether this bomb can trigger other bombs

# Pattern Definition
enum ExplosionPattern { CROSS, SQUARE, X_SHAPE, STAR, SINGLE }
@export var pattern: ExplosionPattern = ExplosionPattern.CROSS

# Optional effects
@export var has_particles: bool = false
@export var particle_effect: PackedScene

# Get direction vectors based on the pattern
func get_explosion_directions() -> Array:
	match pattern:
		ExplosionPattern.CROSS:
			return [
				Vector2.UP,
				Vector2.DOWN,
				Vector2.LEFT,
				Vector2.RIGHT
			]
		ExplosionPattern.SQUARE:
			return [
				Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
				Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)
			]
		ExplosionPattern.X_SHAPE:
			return [
				Vector2(1, 1),
				Vector2(1, -1),
				Vector2(-1, 1),
				Vector2(-1, -1)
			]
		ExplosionPattern.STAR:
			return [
				Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
				Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)
			]
		ExplosionPattern.SINGLE:
			return []
	
	# Default
	return [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

# Handle special effect setup for this bomb type
func apply_effects(explosion_instance: Node2D) -> void:
	# Apply color modulation
	if explosion_instance.has_node("Sprite2D"):
		explosion_instance.get_node("Sprite2D").modulate = explosion_color
	
	# Add particles if needed
	if has_particles and particle_effect != null:
		var particles = particle_effect.instantiate()
		explosion_instance.add_child(particles)
