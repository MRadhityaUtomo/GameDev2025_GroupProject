extends Area2D

@export var grid_size : int = 64
@export var countdown : int = 3
@export var explosion_radius : int = 2
@export var owner_player_id : int
@export var bomb_type: BombType

signal bomb_exploded(position, bomb_ref)

func _ready():
	add_to_group("bombs")
	global_position = global_position.snapped(Vector2(grid_size, grid_size))

func trigger_countdown():
	countdown -= 1
	
	if countdown <= 0:
		call_deferred("explode")

func explode():
	bomb_exploded.emit(global_position, self)
	queue_free()
