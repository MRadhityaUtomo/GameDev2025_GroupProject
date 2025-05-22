extends Node2D

@export var player_body: CharacterBody2D
@export var bomb_scene: PackedScene
@export var grid_size: int = 64
@onready var BombMarker = $"../BombSpawnLocation"

var bombs: Array = []


func place_bomb(spawn_position: Vector2):
	if player_body.BombCount <= 0:
		return

	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = spawn_position
	bomb.owner_player_id = player_body.id
	bomb.bomb_type = player_body.current_bomb_type

	bombs.append(bomb)
	player_body.GlobalBombs.Bombs.append(bomb)

	player_body.BombCount -= 1
	# Signal hookup
	bomb.bomb_exploded.connect(func(pos, bomb_ref): on_bomb_exploded(pos, bomb_ref))
	
	player_body.animations.play("place_bomb")
	await player_body.animations.animation_finished
	player_body.animations.play("idle")


func _physics_process(delta):
	if player_body.action_cooldown_timer > 0:
		player_body.action_cooldown_timer -= delta
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()


func handle_input():
	if Input.is_action_just_pressed(str(player_body.bomb_action)):
		# Update the CanPlace status before attempting to place bomb
		update_can_place_status()

		if player_body.CanPlace:
			place_bomb(BombMarker.global_position)


func update_can_place_status():
	# Use the same raycast from MovementManager
	var raycast = $"../RayCast2D"

	# Set raycast direction to check where we want to place the bomb
	if player_body.last_move_direction:
		raycast.target_position = player_body.last_move_direction * (grid_size * 2.0 / 3.0)

		# Force the raycast to update
		raycast.force_raycast_update()

	player_body.CanPlace = !raycast.is_colliding()

	# Debug output
	if raycast.is_colliding():
		print("Can't place bomb - wall/border detected")
	else:
		print("Bomb placement valid")


func on_bomb_exploded(position: Vector2, bomb_ref):
	$"../sfx".play()
	print("BombManager: Bomb exploded at ", position)
	player_body.BombCount += 1
	# call the explosion
	bomb_ref.bomb_type.spawn_explosions(position, get_tree().current_scene)

	## CLEANUP
	# Remove the exploded bomb from the local bombs array
	if bombs.has(bomb_ref):
		bombs.erase(bomb_ref)
		print("Removed bomb from local array, remaining: ", bombs.size())
	# Remove from global bombs array
	if player_body.GlobalBombs != null:
		if player_body.GlobalBombs.Bombs.has(bomb_ref):
			player_body.GlobalBombs.Bombs.erase(bomb_ref)
			print(
				"Removed bomb from global array, remaining: ", player_body.GlobalBombs.Bombs.size()
			)


func is_bomb_at_position(pos: Vector2, threshold: float = 20.0) -> bool:
	# Check all bombs managed by this BombManager
	for bomb in bombs:
		if is_instance_valid(bomb):
			var distance = bomb.global_position.distance_to(pos)
			if distance < threshold:
				return true
	
	return false
