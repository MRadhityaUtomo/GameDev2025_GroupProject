extends TileMapLayer
class_name DynamicTiles

@export var tile1 = preload("res://Scenes/tilescenes/walkable_tile.tscn")
@export var tile2 = preload("res://Scenes/tilescenes/border_tile.tscn")

@export var TILE_SCENES := {
	1: tile1,
	2: tile2	
}

@onready var half_cell_size := tile_set.tile_size / 2

func _ready():
	await get_tree().process_frame
	replace_tiles_with_scenes()

func replace_tiles_with_scenes(scene_dictionary: Dictionary = TILE_SCENES):
	for tile_pos in get_used_cells():
		var tile_data := get_cell_tile_data(tile_pos)
		var source_id := get_cell_source_id(tile_pos)
		
		if scene_dictionary.has(source_id):
			var object_scene = scene_dictionary[source_id]
			replace_tile_with_object(tile_pos, object_scene)

func replace_tile_with_object(tile_pos: Vector2i, object_scene: PackedScene, parent: Node = null):
	print(tile_pos)
	if get_cell_source_id(tile_pos) != -1:
		set_cell(tile_pos, -1)
	
	if object_scene:
		var obj = object_scene.instantiate()
		var ob_pos = map_to_local(tile_pos)
		
		if parent == null:
			parent = get_tree().current_scene
			
		parent.add_child(obj)
		obj.global_position = to_global(ob_pos)
