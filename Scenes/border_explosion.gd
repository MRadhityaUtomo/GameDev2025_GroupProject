extends Area2D
signal explosion_hit_tile(tile_node)

@export var push_force: float = 800.0  # Adjust for stronger/weaker push

func _ready():
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		# Calculate push direction (away from explosion toward center of arena)
		var push_direction = (body.global_position - global_position).normalized()
		
		# Apply damage if not invincible
		if !body.isInvincible:
			body.takedamage()
		
		# Apply push force
		body.push_from_border(push_direction, push_force)
		
		print("Player pushed: ", body.name)
		print(body.name, ": ", body.hp)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bombs"):
		area.queue_free()
