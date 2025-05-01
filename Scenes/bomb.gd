extends Area2D

@export var grid_size : int = 64
@export var countdown : int = 3
@export var explosion_radius : int = 2
@export var owner_player_id : int

signal bomb_exploded(position, bomb_ref)

func _ready():
	global_position = global_position.snapped(Vector2(grid_size, grid_size))
	print("Bomb placed by player ", owner_player_id, " with countdown: ", countdown)

func trigger_countdown():
	countdown -= 1
	print("Bomb owned by player ", owner_player_id, " countdown reduced to: ", countdown)
	
	if countdown <= 0:
		print("Bomb owned by player ", owner_player_id, " is exploding!")
		call_deferred("explode")

func explode():
	# Important: emit signal before freeing to pass our reference
	bomb_exploded.emit(global_position, self)
	queue_free()
