extends Node2D

@export var player_body : CharacterBody2D
@export var bomb_scene : PackedScene
@export var grid_size : int = 64
@onready var BombMarker = $"../BombSpawnLocation"

var bombs : Array = []

func place_bomb(spawn_position : Vector2):
	# Check if player has bombs left to place
	if player_body.BombCount <= 0:
		return
		
	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = spawn_position
	bomb.owner_player_id = player_body.id  # set owner
	
	# Add to local bombs array
	bombs.append(bomb)
	
	# Add to global bombs array
	player_body.GlobalBombs.Bombs.append(bomb)
	
	# Decrease player's bomb count
	player_body.BombCount -= 1
	
	# Connect explosion signal
	bomb.bomb_exploded.connect(func(pos, bomb_ref): on_bomb_exploded(pos, bomb_ref))
	
	print("Player ", player_body.id, " placed a bomb at ", spawn_position)


func _physics_process(delta):
	if player_body.action_cooldown_timer > 0:
		player_body.action_cooldown_timer -= delta
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()


func handle_input():
	if Input.is_action_just_pressed(str(player_body.bomb_action)):
		place_bomb(BombMarker.global_position)


func on_bomb_exploded(position: Vector2, bomb_ref):
	print("BombManager: Bomb exploded at ", position)
	player_body.BombCount += 1
	# Remove the exploded bomb from the local bombs array
	if bombs.has(bomb_ref):
		bombs.erase(bomb_ref)
		print("Removed bomb from local array, remaining: ", bombs.size())
	
	# Remove from global bombs array
	if player_body.GlobalBombs != null:
		if player_body.GlobalBombs.Bombs.has(bomb_ref):
			player_body.GlobalBombs.Bombs.erase(bomb_ref)
			print("Removed bomb from global array, remaining: ", player_body.GlobalBombs.Bombs.size())
