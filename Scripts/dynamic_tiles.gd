@tool
extends TileMapLayer
class_name DynamicTiles

signal border_shrunk(new_radius)

enum BorderType {
	circle,
	rectangle
}

@onready var half_cell_size := tile_set.tile_size / 2
@export var trap_spawn_rate = 2
@export var trap_amount_limit = 8
@export var max_radius = 7
@export var center = Vector2i(6, 6)
@export var shrinking_time = 30
@export var border_type: BorderType = BorderType.circle
@export var update_in_editor: bool = false: set = _update_in_editor
@export var walkable_tile_alt_texture: Texture2D
@export var walkable_tile_scene: PackedScene
@export var border_tile_scene: PackedScene
@export var trap_tile_scene: PackedScene
@export var maximum_shrinking_stages=3
@export var border_explosion_scene: PackedScene

var current_radius
var current_shrinking_time
var tile_instances = {}
var current_shrinking_stage=0

static var instance : DynamicTiles = null


func set_max_radius(value):
	max_radius = value
	if Engine.is_editor_hint():
		_update_tiles()
		
func set_center(value):
	center = value
	if Engine.is_editor_hint():
		_update_tiles()
		
func set_border_type(value):
	border_type = value
	if Engine.is_editor_hint():
		_update_tiles()
		
func _update_in_editor(value):
	update_in_editor = value
	if Engine.is_editor_hint() and value:
		_update_tiles()
		update_in_editor = false

func _update_tiles():
	# Clear existing tiles
	clear()
	
	# Clear existing tile instances
	for pos in tile_instances.keys():
		if is_instance_valid(tile_instances[pos]):
			tile_instances[pos].queue_free()
	tile_instances.clear()
	
	# Set up radius
	current_radius = max_radius
	
	# Draw border based on type
	if border_type == BorderType.circle:
		draw_circle_border(center.x, center.y, current_radius)
	elif border_type == BorderType.rectangle:
		draw_rectange_border(center.x, center.y, current_radius)
	
	# Fill walkable area
	fill_walkable(center.x, center.y)
	
	# Update edge sprites for walkable tiles
	update_edge_sprites()

func _ready():
	if not Engine.is_editor_hint():
		# Only run game-specific initialization in play mode
		await get_tree().process_frame
		current_radius = max_radius
		current_shrinking_time = shrinking_time
			
		# Clear any existing tile instances
		for pos in tile_instances.keys():
			if is_instance_valid(tile_instances[pos]):
				tile_instances[pos].queue_free()
		tile_instances.clear()
		
		if border_type == BorderType.circle:
			draw_circle_border(center.x, center.y, current_radius)
		elif border_type == BorderType.rectangle:
			draw_rectange_border(center.x, center.y, current_radius)
		fill_walkable(center.x, center.y)
		update_edge_sprites()
	else:
		# Initial setup in the editor
		_update_tiles()

	if instance == null:
		instance = self
		print("DynamicTiles instance set to: ", instance)
	else:
		print("DynamicTiles instance already exists, not setting again.")
		queue_free()

func get_trap_amount():
	return len(get_used_cells_by_id(0, Vector2i(0, 0), 3))
	
func spawn_trap():
	#var walkable_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 1)
	#var random_num = randi_range(0, len(walkable_tiles) - 1)
	#var target_tiles = walkable_tiles[random_num]
	#set_cell(target_tiles, 0, Vector2i(0, 0), 3)
	#create_tile_instance(target_tiles, 3)
	pass

func _on_trap_timer_timeout() -> void:
	if get_trap_amount() + trap_spawn_rate <= trap_amount_limit:
		for i in range(trap_spawn_rate):
			spawn_trap()
	elif get_trap_amount() < trap_amount_limit:
		for i in range(trap_amount_limit - get_trap_amount()):
			spawn_trap()

#comment

# Modify draw_circle_border to handle non-explosion case only
func draw_circle_border(center_x, center_y, radius, spawn_explosions=false):
	var center = Vector2(center_x, center_y)
	var r_max = (radius + 0.7) * (radius + 0.7)
	var r_min = (radius - 0.7) * (radius - 0.7)
	var points = {}
	
	for x in range(center_x - radius - 1, center_x + radius + 2):
		for y in range(center_y - radius - 1, center_y + radius + 2):
			var dist_sq = (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y)
			if dist_sq >= r_min and dist_sq <= r_max:
				points[Vector2(x, y)] = true
	
	# If we need explosions, use the dedicated function instead
	if spawn_explosions and border_explosion_scene and not Engine.is_editor_hint():
		show_circle_border_warnings(center_x, center_y, radius)
	else:
		# Otherwise immediately set border tiles
		for point in points.keys():
			set_border_tile(point)
		
func draw_rectange_border(center_x, center_y, radius):
	var center = Vector2i(center_x, center_y)
	var left = center + Vector2i(-radius, 0)
	var right = center + Vector2i(radius, 0)
	var up = center + Vector2i(0, -radius)
	var down = center + Vector2i(0, radius)
	for i in range(radius + 1):
		# Left vertical borders
		set_border_tile(left + Vector2i(0, -i))
		set_border_tile(left + Vector2i(0, i))
		
		# Right vertical borders
		set_border_tile(right + Vector2i(0, -i))
		set_border_tile(right + Vector2i(0, i))
		
		# Top horizontal borders
		set_border_tile(up + Vector2i(-i, 0))
		set_border_tile(up + Vector2i(i, 0))
		
		# Bottom horizontal borders
		set_border_tile(down + Vector2i(-i, 0))
		set_border_tile(down + Vector2i(i, 0))

func set_border_tile(pos):
	set_cell(pos, 0, Vector2i(0, 0), 2)
	create_tile_instance(pos, 2)
		
func fill_walkable(center_x, center_y):
	var tile_to_fill = [Vector2i(center_x, center_y)]
	while len(tile_to_fill) > 0:
		var tile_pos = tile_to_fill.pop_front()
		if get_cell_source_id(tile_pos) == -1:
			# Set the cell in the tilemap
			set_cell(tile_pos, 0, Vector2i(0, 0), 1)
			# Create instance for the walkable tile
			create_tile_instance(tile_pos, 1)
			
			var up = tile_pos + Vector2i(0, -1)
			var down = tile_pos + Vector2i(0, 1)
			var right = tile_pos + Vector2i(1, 0)
			var left = tile_pos + Vector2i(-1, 0)
			if get_cell_source_id(up) == -1:
				tile_to_fill.push_back(up)
			if get_cell_source_id(down) == -1:
				tile_to_fill.push_back(down)
			if get_cell_source_id(right) == -1:
				tile_to_fill.push_back(right)
			if get_cell_source_id(left) == -1:
				tile_to_fill.push_back(left)

func create_tile_instance(tile_pos, tile_type):
	# Remove any existing tile instance at this position
	if tile_instances.has(tile_pos):
		if is_instance_valid(tile_instances[tile_pos]):
			tile_instances[tile_pos].queue_free()
		tile_instances.erase(tile_pos)
	
	var scene_to_use = null
	match tile_type:
		1: # Walkable
			scene_to_use = walkable_tile_scene
		2: # Border
			scene_to_use = border_tile_scene
		3: # Trap
			scene_to_use = trap_tile_scene
	
	if scene_to_use:
		var obj = scene_to_use.instantiate()
		obj.position = map_to_local(tile_pos)
		add_child(obj)
		
		# For walkable tiles, set alternating pattern
		if tile_type == 1:
			var is_alt = (tile_pos.x + tile_pos.y) % 2 == 1
			
			# Set alt_tile property
			if obj.has_method("set_is_alt_tile"):
				obj.set_is_alt_tile(is_alt)
			elif "is_alt_tile" in obj:
				obj.is_alt_tile = is_alt
			
			# Apply texture based on alternating pattern
			if is_alt and walkable_tile_alt_texture != null:
				if obj.has_node("Sprite2D"):
					obj.get_node("Sprite2D").texture = walkable_tile_alt_texture
			
			# Make sure edge sprites start as invisible
			if obj.has_node("Sprite2D2"):
				obj.get_node("Sprite2D2").visible = false
			if obj.has_node("Sprite2D3"):
				obj.get_node("Sprite2D3").visible = false
		
		tile_instances[tile_pos] = obj
		return obj
	
	return null

func update_edge_sprites():
	# Get all border tile positions
	var border_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 2)
	
	# Check each border tile to see if the tile above is walkable
	for border_pos in border_tiles:
		var above_pos = border_pos + Vector2i(0, -1)
		
		# Check if the tile above is a walkable tile
		if is_walkable_tile(above_pos):
			print("Found walkable tile above border at: ", above_pos)
			var walkable_obj = get_scene_at_position(above_pos)
			
			if walkable_obj:
				print("Found walkable object: ", walkable_obj)
				# Make the appropriate edge sprite visible
				var is_alt = "is_alt_tile" in walkable_obj and walkable_obj.is_alt_tile
				print("Is alt tile: ", is_alt)
				
				if is_alt:
					if walkable_obj.has_node("Sprite2D3"):
						print("Setting Sprite2D3 visible")
						walkable_obj.get_node("Sprite2D3").visible	 = true
				else:
					if walkable_obj.has_node("Sprite2D2"):
						print("Setting Sprite2D2 visible")
						walkable_obj.get_node("Sprite2D2").visible = true


# Function to get a scene instance at a specific position
func get_scene_at_position(pos):
	# First check if we have it in our dictionary
	if tile_instances.has(pos) and is_instance_valid(tile_instances[pos]):
		return tile_instances[pos]
		
	# If not in the dictionary, try to find it among child nodes
	var local_pos = map_to_local(pos)
	for child in get_children():
		# Check if the child is a Node2D and close enough to our position
		if child is Node2D and child.position.distance_to(local_pos) < 1.0:
			# If found, add it to our dictionary for future reference
			tile_instances[pos] = child
			return child
			
	# If still not found, create a new instance
	if is_walkable_tile(pos):
		return create_tile_instance(pos, 1)
		
	return null

func is_walkable_tile(pos):
	return get_cell_atlas_coords(pos) == Vector2i(0, 0) and get_cell_alternative_tile(pos) == 1

func is_border_tile(pos):
	return get_cell_atlas_coords(pos) == Vector2i(0, 0) and get_cell_alternative_tile(pos) == 2

func remove_border():
	var borders_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 2)
	for tiles in borders_tiles:
		erase_cell(tiles)
		if tile_instances.has(tiles):
			if is_instance_valid(tile_instances[tiles]):
				tile_instances[tiles].queue_free()
			tile_instances.erase(tiles)
	
	# Reset all edge sprites to invisible first
	reset_edge_sprites()
	
	# Update edge sprites after removing borders
	update_edge_sprites()

func reset_edge_sprites():
	print("Resetting edge sprites")
	var walkable_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 1)
	for tile_pos in walkable_tiles:
		var obj = get_scene_at_position(tile_pos)
		if obj:
			if obj.has_node("Sprite2D2"):
				obj.get_node("Sprite2D2").visible = false
			if obj.has_node("Sprite2D3"):
				obj.get_node("Sprite2D3").visible = false
		else:
			print("No scene found at walkable tile position: ", tile_pos)

func _on_shrinking_timer_timeout() -> void:
	if current_shrinking_stage < maximum_shrinking_stages:
		current_shrinking_time -= 1
		if current_shrinking_time <= 0:
			current_shrinking_time = shrinking_time
			if current_radius > 1:
				# Calculate new radius but don't apply it yet
				var new_radius = current_radius - 1
				
				if border_type == BorderType.circle:
					# First, show warnings at future border positions
					show_circle_border_warnings(center.x, center.y, new_radius)
				elif border_type == BorderType.rectangle:
					# For rectangle type, immediately update (or implement similar warning system)
					remove_border()
					draw_rectange_border(center.x, center.y, new_radius)
					update_edge_sprites()
					current_radius = new_radius
				
				# Signal that the border has shrunk
				#border_shrunk.emit(current_radius)
				
			current_shrinking_stage += 1

# New function to handle the warning phase
func show_circle_border_warnings(center_x, center_y, radius):
	var center = Vector2(center_x, center_y)
	var r_max = (radius + 0.7) * (radius + 0.7)
	var r_min = (radius - 0.7) * (radius - 0.7)
	var points = {}
	
	# Calculate points for the new border
	for x in range(center_x - radius - 1, center_x + radius + 2):
		for y in range(center_y - radius - 1, center_y + radius + 2):
			var dist_sq = (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y)
			if dist_sq >= r_min and dist_sq <= r_max:
				points[Vector2(x, y)] = true
	
	# Show warnings first - keep old border intact
	var warning_animations = []
	for point in points.keys():
		var warning = $warning.duplicate()
		warning.visible = true
		warning.position = map_to_local(point)
		add_child(warning)
		warning.play("default")
		warning_animations.append(warning)
	
	# After warning finishes, remove old border and create new one
	get_tree().create_timer(1.5).timeout.connect(func():
		$sfx.play()
		# Apply camera shake here
		apply_camera_shake(8.0, 0.5)
		# NOW remove the old border
		remove_border()
		
		for i in range(warning_animations.size()):
			var point = points.keys()[i]
			var warning = warning_animations[i]
			
			# Create explosion
			var explosion = border_explosion_scene.instantiate()
			explosion.position = map_to_local(point)
			add_child(explosion)
			
			# Remove warning animation
			warning.queue_free()
			
			# Set the border tile
			set_border_tile(point)
		
		# Update after all the new border tiles are set
		update_edge_sprites()
		current_radius = radius  # Update the radius AFTER creating new border
		border_shrunk.emit(current_radius)
	)
	
# Simple camera shake function
func apply_camera_shake(intensity: float = 8.0, duration: float = 0.5):
	# Find the camera in the scene
	var camera = get_viewport().get_camera_2d()
	if not camera:
		print("No Camera2D found in the viewport")
		return
	
	# Create a tween for the shake effect
	var shake_tween = create_tween()
	
	# Apply several random shakes with decreasing intensity
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	
	# Initial shake
	var original_position = camera.position
	
	# Add 5 random position changes with decreasing intensity
	for i in range(5):
		var step_intensity = intensity * (1.0 - (float(i) / 5))
		var next_offset = Vector2(
			rand.randf_range(-step_intensity, step_intensity),
			rand.randf_range(-step_intensity, step_intensity)
		)
		shake_tween.tween_property(camera, "offset", next_offset, duration / 5)
	
	# Final step - return to center
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, duration / 5)
func get_random_walkable_tile_position() -> Vector2:
	# Get all walkable tile positions
	var walkable_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 1)
	
	# If no walkable tiles found, return Vector2.ZERO
	if walkable_tiles.size() == 0:
		print("No walkable tiles found")
		return Vector2.ZERO
	
	# Select random walkable tile
	var random_index = randi() % walkable_tiles.size()
	var random_tile_pos = walkable_tiles[random_index]
	
	print("Selected walkable tile pos:", random_tile_pos)
	
	# Convert tile position to world position
	var local_pos = map_to_local(random_tile_pos)
	
	# Convert to global position to account for tilemap's own position
	return to_global(local_pos)

func is_position_inside_border(pos: Vector2) -> bool:
	var tile_pos = local_to_map(to_local(pos))
	print(get_cell_alternative_tile(tile_pos))
	if get_cell_source_id(tile_pos) == -1:
		return false
	if get_cell_source_id(tile_pos) == 0 and get_cell_alternative_tile(tile_pos) == 2:
		return false
	
	return true
