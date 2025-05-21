class_name BombType
extends Resource

enum ExplosionPattern { CROSS, DIAG }

@export var grid_size: int = 64
@export var name: String = "Standard Bomb"
@export var explosion_radius: int = 2
@export var explosion_scene: PackedScene
@export var pattern: ExplosionPattern = ExplosionPattern.CROSS


func get_explosion_directions() -> Array:
	match pattern:
		ExplosionPattern.CROSS:
			return [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		ExplosionPattern.DIAG:
			return [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	return []


func spawn_explosions(origin_position: Vector2, parent_scene: Node):
	var directions = get_explosion_directions()

	print("Spawning explosions from origin: ", origin_position)

	# spawn one at center
	_spawn_explosion_at(origin_position, parent_scene)

	# For each direction (up, down, left, right in cross pattern)
	for dir in directions:
		# Start from 1 (one tile away from origin)
		var i = 1
		var blocked = false
		var max_safety_limit = 30  # Safety limit to prevent infinite explosions

		# Continue until we hit something or reach safety limit
		while not blocked and i <= max_safety_limit:
			var pos = origin_position + dir * i * grid_size

			# Check if there's a wall or border at this position
			if is_position_blocked(pos, parent_scene):
				blocked = true
				print("Explosion blocked at: ", pos)
			else:
				# Spawn explosion and continue outward
				_spawn_explosion_at(pos, parent_scene)
				i += 1


func is_position_blocked(pos: Vector2, parent_scene: Node) -> bool:
	# Use parent_scene to access the scene tree instead of get_tree()
	var blocks = (
		parent_scene.get_tree().get_nodes_in_group("walls")
		+ parent_scene.get_tree().get_nodes_in_group("borders")
	)

	# Check if any block is at the target position (with some tolerance)
	for block in blocks:
		if block.global_position.distance_to(pos) < grid_size * 0.5:
			print("Wall/border detected at position: ", pos)
			return true

	return false


func _spawn_explosion_at(pos: Vector2, parent_scene: Node):
	# Create the explosion instance
	var explosion = explosion_scene.instantiate()
	parent_scene.add_child(explosion)

	# Use global_position directly since pos is already in global coordinates
	explosion.global_position = pos

	print("Explosion spawned at corrected position: ", explosion.global_position)
