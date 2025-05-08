class_name BombType
extends Resource

enum ExplosionPattern { CROSS, DIAG }

@export var grid_size : int = 64
@export var name: String = "Standard Bomb"
@export var explosion_radius: int = 2
@export var explosion_scene: PackedScene
@export var pattern: ExplosionPattern = ExplosionPattern.CROSS

# INI RESOURCE BUAT BOMB, pattern bombnya meledak di handle disini

func get_explosion_directions() -> Array:
	match pattern:
		ExplosionPattern.CROSS:
			return [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		ExplosionPattern.DIAG:
			return [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	return []

func spawn_explosions(origin_position: Vector2, parent_scene: Node):
	var directions = get_explosion_directions()
	var viewport_size = parent_scene.get_viewport_rect().size
	var max_cells_x = int(viewport_size.x / grid_size) + 2  
	var max_cells_y = int(viewport_size.y / grid_size) + 2  
	var max_cells = max(max_cells_x, max_cells_y)
	
	_spawn_explosion_at(origin_position, parent_scene)
	# Sampe ujung screen buat sknrg
	for dir in directions:
		for i in range(1, max_cells):
			var pos = origin_position + dir * i * grid_size
			if pos.x >= -grid_size and pos.x <= viewport_size.x + grid_size and \
			   pos.y >= -grid_size and pos.y <= viewport_size.y + grid_size:
				_spawn_explosion_at(pos, parent_scene)
			else:
				break

func _spawn_explosion_at(pos: Vector2, parent_scene: Node):
	var explosion = explosion_scene.instantiate()
	explosion.global_position = pos - Vector2(grid_size*2, grid_size*2)
	parent_scene.add_child(explosion)
