extends TileMapLayer
class_name DynamicTiles

@onready var half_cell_size := tile_set.tile_size / 2
@onready var shrinking_time_label = $ShrinkingTimeLabel
@export var trap_spawn_rate = 2
@export var trap_amount_limit = 8
@export var max_radius = 7
@export var center = Vector2i(6, 6)
@export var shrinking_time = 30

var current_radius
var current_shrinking_time


func _ready():
	await get_tree().process_frame
	current_radius = max_radius
	current_shrinking_time = shrinking_time
	shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
	draw_border(center.x, center.y, current_radius)
	
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

func draw_border(center_x, center_y, radius):
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

		var prev_borders_tiles = get_used_cells_by_id(0, Vector2i(0, 0), 2)
		for tiles in prev_borders_tiles:
			erase_cell(tiles)
		
		for point in points.keys():
			set_cell(point, 0, Vector2i(0, 0), 2)


func _on_shrinking_timer_timeout() -> void:
	current_shrinking_time -= 1
	shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
	if current_shrinking_time <= 0:
		current_shrinking_time = shrinking_time
		shrinking_time_label.text = "Time Until Shrinking %d" % [current_shrinking_time]
		if current_radius > 1:
			current_radius -= 1
			draw_border(center.x, center.y, current_radius)
