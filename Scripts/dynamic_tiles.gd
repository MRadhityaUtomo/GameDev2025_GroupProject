extends TileMapLayer
class_name DynamicTiles

@export var TILE_SCENES := {
	1: preload("res://Scenes/walkable_tile.tscn"),
	2: preload("res://Scenes/border_tile.tscn"),
	5: preload("res://Scenes/wall_tile.tscn"),
}

# Add a second texture for walkable tiles
@export var walkable_tile_alt_texture: Texture2D

@onready var half_cell_size := tile_set.tile_size / 2
var tile_map = {}  # Store all tile positions to check neighbors later

func _ready():
	await get_tree().process_frame
	# First collect all tile information
	collect_tile_info()
	# Then create the objects with edge detection
	replace_tiles_with_scenes()

func collect_tile_info():
	# Clear the tile map dictionary first
	tile_map.clear()
	
	# Collect all tile positions and their types
	for tile_pos in get_used_cells():
		var source_id := get_cell_source_id(tile_pos)
		tile_map[tile_pos] = source_id

func replace_tiles_with_scenes(scene_dictionary: Dictionary = TILE_SCENES):
	for tile_pos in get_used_cells():
		var source_id := get_cell_source_id(tile_pos)
		
		if scene_dictionary.has(source_id):
			var object_scene = scene_dictionary[source_id]
			replace_tile_with_object(tile_pos, object_scene)

func replace_tile_with_object(tile_pos: Vector2i, object_scene: PackedScene, parent: Node = null):
	if get_cell_source_id(tile_pos) != -1:
		set_cell(tile_pos, -1)
	
	if object_scene:
		var obj = object_scene.instantiate()
		var ob_pos = map_to_local(tile_pos)
		
		if parent == null:
			parent = get_tree().current_scene
		
		parent.add_child(obj)
		obj.global_position = to_global(ob_pos)
		
		# For walkable tiles, apply checkered pattern and check for edge
		if object_scene == TILE_SCENES[1]:
			# Determine if this is an alt tile
			var is_alt = walkable_tile_alt_texture != null and (tile_pos.x + tile_pos.y) % 2 == 1
			
			# Explicitly set the is_alt_tile property on the object
			if obj.has_method("set_is_alt_tile"):
				obj.set_is_alt_tile(is_alt)
			elif "is_alt_tile" in obj:
				obj.is_alt_tile = is_alt
			
			# Apply texture based on alternating pattern
			if is_alt:
				if obj.has_node("Sprite2D"):
					obj.get_node("Sprite2D").texture = walkable_tile_alt_texture
			
			# Check if there's a border tile below (south)
			var south_pos = Vector2i(tile_pos.x, tile_pos.y + 1)
			
			# Check if the tile below is a border tile (source_id == 2)
			var has_border_below = tile_map.has(south_pos) and tile_map[south_pos] == 2
			
			# Show edge sprite if there's a border below
			if has_border_below and obj.has_node("Sprite2D2"):
				if is_alt:
					obj.get_node("Sprite2D3").visible = true
				else:
					obj.get_node("Sprite2D2").visible = true
			else:
				obj.get_node("Sprite2D2").visible = false
