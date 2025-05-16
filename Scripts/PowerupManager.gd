extends Node2D

@export var grid_size: int = 64
@export var powerup_scene: PackedScene
@export var spawn_interval_min: float = 15.0
@export var spawn_interval_max: float = 30.0
@export var max_powerups: int = 3
@export var tile_map_layer: TileMapLayer

@onready var spawn_timer: Timer = $SpawnTimer

var powerups = []
var next_spawn_time: float = 0.0


func _ready():
	spawn_timer.start(5)


func spawn_powerup():
	var powerup = powerup_scene.instantiate()
	var pos = tile_map_layer.get_random_walkable_tile_position()
	print(pos)

	if pos != Vector2.ZERO:
		powerup.global_position = pos - get_parent().position
		add_child(powerup)
		powerup.z_index = 10
		powerups.append(powerup)
		print("Spawned powerup at position: ", pos)


func clean_powerups():
	var valid_powerups = []

	for powerup in powerups:
		if is_instance_valid(powerup):
			valid_powerups.append(powerup)

	powerups = valid_powerups


func _on_spawn_timer_timeout() -> void:
	spawn_powerup()

	var random_interval = randf_range(spawn_interval_min, spawn_interval_max)
	print("Next powerup in ", random_interval, " seconds")
	spawn_timer.start(random_interval)
