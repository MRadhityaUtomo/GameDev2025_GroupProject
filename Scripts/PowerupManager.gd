extends Node2D

@export var grid_size: int = 64
@export var powerup_scene: PackedScene
@export var spawn_interval_min: float = 15.0
@export var spawn_interval_max: float = 30.0
@export var max_powerups: int = 3
@export var tile_map_layer: TileMapLayer
@export var available_powerups: Array[PowerupResource]
@export var available_bomb_powerups: Array[BombType]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var global_bomb_manager: Node2D = $"../GlobalBombManager"

var powerups = []
var next_spawn_time: float = 0.0
var combined_powerups = []

func _ready():
	spawn_timer.start(5)
	combined_powerups = available_bomb_powerups + available_powerups
	
	# Connect to the border_shrunk signal
	if tile_map_layer and tile_map_layer.has_signal("border_shrunk"):
		tile_map_layer.border_shrunk.connect(check_powerups_outside_border)


func spawn_powerup():
	# Check if we already have max powerups
	clean_powerups()
	if powerups.size() >= max_powerups:
		print("Maximum powerups reached, not spawning more")
		return
	
	# Get random position
	var pos = tile_map_layer.get_random_walkable_tile_position()
	print("Potential powerup position:", pos)
	
	if pos != Vector2.ZERO:
		# Check for existing powerups at this position
		for existing_powerup in powerups:
			if is_instance_valid(existing_powerup):
				# Use distance check with small threshold to account for floating point imprecision
				if existing_powerup.global_position.distance_to(pos) < 20:
					print("Position already has a powerup, trying again")
					# Try another position
					spawn_powerup()
					return
		
		if global_bomb_manager and global_bomb_manager.has_method("is_bomb_at_position"):
			if global_bomb_manager.is_bomb_at_position(pos):
				print("Position already has a bomb, trying again")
				# Try another position
				spawn_powerup()
				return
		
		# Position is clear, spawn the powerup
		var powerup = powerup_scene.instantiate()
		
		# Select a random powerup type from available resources
		var random_powerup = combined_powerups[randi() % combined_powerups.size()]
		print("WHAT THE FUCK IS GOING ON")
		# Check the type of resource and assign to appropriate property
		if random_powerup is PowerupResource:
			powerup.powerup_resource = random_powerup
			print("Spawned movement powerup: ", random_powerup.display_name)
		elif random_powerup is BombType:
			powerup.bomb_resource = random_powerup
			print("Spawned bomb powerup: ", random_powerup.name)
		else:
			print("Unknown powerup resource type")

		powerup.global_position = pos - get_parent().position
		add_child(powerup)
		powerup.z_index = 5  # Below player but above tiles
		powerups.append(powerup)
		print("Spawned powerup at position:", pos)


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


func check_powerups_outside_border(new_radius):
	print("Border shrunk to radius: ", new_radius, ", checking powerups...")
	var powerups_to_remove = []
	
	for powerup in powerups:
		if is_instance_valid(powerup):
			if not tile_map_layer.is_position_inside_border(powerup.global_position):
				print("Powerup outside border, removing: ", powerup.global_position)
				powerups_to_remove.append(powerup)
	
	# Remove the powerups outside the border
	for powerup in powerups_to_remove:
		powerups.erase(powerup)
		powerup.queue_free()
