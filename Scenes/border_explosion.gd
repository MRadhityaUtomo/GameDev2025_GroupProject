extends Area2D
signal explosion_hit_tile(tile_node)

func _ready():
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		# Find the dynamic tiles node (parent of this explosion)
		var dynamic_tiles = get_parent()
		if dynamic_tiles is DynamicTiles:
			# Get the player's current tile position
			var player_tile_pos = dynamic_tiles.local_to_map(dynamic_tiles.to_local(body.global_position))
			
			# Calculate direction FROM player TO center (not from explosion)
			var to_center = dynamic_tiles.center - player_tile_pos
			
			# Convert to Vector2 for normalization
			var push_direction = Vector2(to_center.x, to_center.y).normalized()
			
			# Apply damage if not invincible
			if !body.isInvincible:
				body.takedamage()
			
			# Use the grid-aligned push with the correct direction
			body.push_from_border_grid_aligned(push_direction, dynamic_tiles)
			
			print("Player pushed toward center")
			print("Player position: ", player_tile_pos)
			print("Center position: ", dynamic_tiles.center)
			print("Direction vector: ", to_center)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bombs"):
		area.queue_free()
