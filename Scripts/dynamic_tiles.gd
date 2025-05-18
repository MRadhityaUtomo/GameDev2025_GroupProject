@tool
extends TileMapLayer
class_name DynamicTiles

enum BorderType {
	circle,
	rectangle
}

@onready var half_cell_size := tile_set.tile_size / 2
@onready var shrinking_time_label = $ShrinkingTimeLabel
@export var trap_spawn_rate = 2
@export var trap_amount_limit = 8
@export var max_radius = 7
@export var center = Vector2i(6, 6)
@export var shrinking_time = 30
@export var border_type: BorderType = BorderType.circle
@export var update_in_editor: bool = false: set = _update_in_editor

var current_radius
var current_shrinking_time

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
	
	# Set up radius
	current_radius = max_radius
	
	# Draw border based on type
	if border_type == BorderType.circle:
		draw_circle_border(center.x, center.y, current_radius)
	elif border_type == BorderType.rectangle:
		draw_rectange_border(center.x, center.y, current_radius)
	
	# Fill walkable area
	fill_walkable(center.x, center.y)

func _ready():
	if not Engine.is_editor_hint():
		# Only run game-specific initialization in play mode
		await get_tree().process_frame
		current_radius = max_radius
		current_shrinking_time = shrinking_time
		if shrinking_time_label:
			shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
		if border_type == BorderType.circle:
			draw_circle_border(center.x, center.y, current_radius)
		elif border_type == BorderType.rectangle:
			draw_rectange_border(center.x, center.y, current_radius)
		fill_walkable(center.x, center.y)
	else:
		# Initial setup in the editor
		_update_tiles()

func get_trap_amount():
	return len(get_used_cells_by_id(0, Vector2i(0, 0), 3))
	
func spawn_trap():
	var walkable_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 1)
	var random_num = randi_range(0, len(walkable_tiles) - 1)
	var target_tiles = walkable_tiles[random_num]
	set_cell(target_tiles, 0, Vector2i(0, 0), 3)

func _on_trap_timer_timeout() -> void:
	if get_trap_amount() + trap_spawn_rate <= trap_amount_limit:
		for i in range(trap_spawn_rate):
			spawn_trap()
	elif get_trap_amount() < trap_amount_limit:
		for i in range(trap_amount_limit - get_trap_amount()):
			spawn_trap()

func draw_circle_border(center_x, center_y, radius):
	var points := {}
	var r_min = pow(radius - 0.5, 2)
	var r_max = pow(radius + 0.5, 2)

	var min_x = int(floor(center_x - radius - 1))
	var max_x = int(ceil(center_x + radius + 1))
	var min_y = int(floor(center_y - radius - 1))
	var max_y = int(ceil(center_y + radius + 1))

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var dx = x - center_x
			var dy = y - center_y
			var dist_sq = float(dx * dx + dy * dy)

			if dist_sq >= r_min and dist_sq < r_max:
				points[Vector2(x, y)] = true
		
		for point in points.keys():
			set_cell(point, 0, Vector2i(0, 0), 2)

func draw_rectange_border(center_x, center_y, radius):
	var center = Vector2i(center_x, center_y)
	var left = center + Vector2i(-radius, 0)
	var right = center + Vector2i(radius, 0)
	var up = center + Vector2i(0, -radius)
	var down = center + Vector2i(0, radius)
	for i in range(radius + 1):
		set_cell(left + Vector2i(0, -i), 0, Vector2i(0, 0), 2)
		set_cell(left + Vector2i(0, i), 0, Vector2i(0, 0), 2)
		
		set_cell(right + Vector2i(0, -i), 0, Vector2i(0, 0), 2)
		set_cell(right + Vector2i(0, i), 0, Vector2i(0, 0), 2)
		
		set_cell(up + Vector2i(-i, 0), 0, Vector2i(0, 0), 2)
		set_cell(up + Vector2i(i, 0), 0, Vector2i(0, 0), 2)
		
		set_cell(down + Vector2i(-i, 0), 0, Vector2i(0, 0), 2)
		set_cell(down + Vector2i(i, 0), 0, Vector2i(0, 0), 2)
		
func fill_walkable(center_x, center_y):
	var tile_to_fill = [Vector2i(center_x, center_y)]
	while len(tile_to_fill) > 0:
		var tile_pos = tile_to_fill.pop_front()
		if get_cell_source_id(tile_pos) == -1:
			set_cell(tile_pos, 0, Vector2i(0, 0), 1)
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
							
func remove_border():
	var borders_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 2)
	for tiles in borders_tiles:
		erase_cell(tiles)

func _on_shrinking_timer_timeout() -> void:
	current_shrinking_time -= 1
	shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
	if current_shrinking_time <= 0:
		current_shrinking_time = shrinking_time
		shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
		if current_radius > 1:
			current_radius -= 1
			remove_border()
			if border_type == BorderType.circle:
				draw_circle_border(center.x, center.y, current_radius)
			elif border_type == BorderType.rectangle:
				draw_rectange_border(center.x, center.y, current_radius)
