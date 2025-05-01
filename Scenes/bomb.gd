extends Area2D

@export var grid_size : int = 64
@export var countdown : int = 3
@export var explosion_radius : int = 2
@export var owner_player_id : int

signal bomb_exploded(position)

func _ready():
	global_position = global_position.snapped(Vector2(grid_size, grid_size))

func trigger_countdown():
	print(countdown)
	countdown -= 1
	if countdown <= 0:
		explode()

func explode():
	bomb_exploded.emit(global_position)
	queue_free()
