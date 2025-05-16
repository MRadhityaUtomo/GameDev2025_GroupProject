extends Area2D


func _ready():
	await get_tree().create_timer(0.5).timeout
	queue_free()


func _on_body_entered(body: Node):
	print(1)
	if body.is_in_group("player"):
		if !body.isInvincible:
			body.takedamage()
		print("Player hit: ", body.name)
		print(body.name, ": ", body.hp)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bombs"):
		area.trigger_countdown()
