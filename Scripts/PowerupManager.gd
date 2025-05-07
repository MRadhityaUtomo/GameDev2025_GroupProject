extends Node2D

@export var grid_size: int = 64
@export var powerup_scene: PackedScene
@export var spawn_interval_min: float = 15.0
@export var spawn_interval_max: float = 30.0
@export var max_powerups: int = 3
@export var grid_width: int = 6
@export var grid_height: int = 6
@export var tile_map_layer: TileMapLayer

var powerups = []
var spawn_timer: float = 0.0
var next_spawn_time: float = 0.0

func _ready():
	spawn_powerup()
	# Initialize with random spawn time
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

func _process(delta):
	# Update spawn timer
	spawn_timer += delta
	
	if Input.is_action_just_pressed("h"):
		spawn_powerup()
	
	# Check if it's time to spawn a new powerup
	if spawn_timer >= next_spawn_time and powerups.size() < max_powerups:
		spawn_powerup()
		
		# Reset timer and set next spawn time
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Clean up invalid powerups
	clean_powerups()

func spawn_powerup():
	# Create a new powerup instance
	var powerup = powerup_scene.instantiate()
	
	# Find a random empty grid position
	var pos = find_empty_position()
	if pos != Vector2.ZERO:
		powerup.global_position = pos
		add_child(powerup)
		powerups.append(powerup)
		print("Spawned powerup at position: ", pos)

func find_empty_position() -> Vector2:
	# Find an empty position on the grid
	var max_attempts = 20
	
	for _attempt in range(max_attempts):
		# Generate random grid position
		var grid_x = randi() % grid_width
		var grid_y = randi() % grid_height
		
		# Convert to world position (center of grid cell)
		var world_pos = Vector2(grid_x * grid_size + grid_size/2, grid_y * grid_size + grid_size/2)
		
		# Check if position is empty
		if is_position_empty(world_pos):
			return world_pos
	
	print("Could not find empty position for powerup")
	return Vector2.ZERO

func is_position_empty(pos: Vector2) -> bool:
	# 1. First check if there's a valid tile at this position
	if not is_valid_tile_position(pos):
		return false
	
	# 2. Check if position has any players or other obstacles
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	var result = space_state.intersect_point(query)
	
	if not result.is_empty():
		return false
	
	# 3. Check for other powerups
	for powerup in powerups:
		if is_instance_valid(powerup) and powerup.global_position.distance_to(pos) < grid_size * 0.5:
			return false
	
	return true

func is_valid_tile_position(pos: Vector2) -> bool:
	if not tile_map_layer:
		return true  # If no tilemap layer found, don't restrict positions
		
	# Convert world position to tile coordinates
	var tile_pos = Vector2i(int(pos.x / grid_size), int(pos.y / grid_size))
	
	# Check if there's a valid tile at this position using the TileMapLayer directly
	var tile_data = tile_map_layer.get_cell_tile_data(tile_pos)
	
	#nanti cek tilenya apa di sini
	
	return tile_data != null
		
func clean_powerups():
	var valid_powerups = []
	
	for powerup in powerups:
		if is_instance_valid(powerup):
			valid_powerups.append(powerup)
	
	powerups = valid_powerups
