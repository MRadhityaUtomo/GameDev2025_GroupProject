extends Area2D

@export var grid_size : int = 64
@export var countdown : int = 3
@export var explosion_radius : int = 2  # how many tiles out it reaches (adjustable)

signal bomb_exploded(position)

func _ready():
	# Snap to grid immediately
	global_position = global_position.snapped(Vector2(grid_size, grid_size))

func trigger_countdown():
	countdown -= 1
	if countdown <= 0:
		explode()

func explode():
	# Emit a signal so the manager can spawn explosions
	bomb_exploded.emit(global_position)
	queue_free()
