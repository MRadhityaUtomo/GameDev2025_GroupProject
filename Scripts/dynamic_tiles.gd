extends TileMapLayer
class_name DynamicTiles

@export var TILE_SCENES := {
	1: preload("res://Scenes/walkable_tile.tscn"),
	2: preload("res://Scenes/border_tile.tscn"),
	5: preload("res://Scenes/wall_tile.tscn"),
}

@onready var half_cell_size := tile_set.tile_size / 2

var walkable_positions = []


func _ready():
	await get_tree().process_frame

	# Store walkable positions before replacing
	for tile_pos in get_used_cells():
		if get_cell_source_id(tile_pos) == 1:
			walkable_positions.append(tile_pos)

	replace_tiles_with_scenes()


func replace_tiles_with_scenes(scene_dictionary: Dictionary = TILE_SCENES):
	for tile_pos in get_used_cells():
		var tile_data := get_cell_tile_data(tile_pos)
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


func get_random_walkable_tile_position() -> Vector2:
	if walkable_positions.size() == 0:
		return Vector2.ZERO

	var random_index = randi() % walkable_positions.size()
	var random_tile_pos = walkable_positions[random_index]
	var local_pos = map_to_local(random_tile_pos)
	return to_global(local_pos)
