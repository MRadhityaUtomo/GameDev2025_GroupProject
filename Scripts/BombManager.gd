extends Node2D

@export var player_body : CharacterBody2D
@export var bomb_scene : PackedScene
@export var grid_size : int = 64
@onready var BombMarker = $"../BombSpawnLocation"
@onready var GlobalBombs = player_body.GlobalBombs.Bombs

var bombs : Array = []

func place_bomb(spawn_position : Vector2):
	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = spawn_position
	bomb.owner_player_id = player_body.id  # set owner
	bombs.append(bomb)
	GlobalBombs.append(bomb)
	player_body.BombCount -= 1
	print(GlobalBombs)
	
	bomb.bomb_exploded.connect(func(pos): on_bomb_exploded(pos))


func _physics_process(delta):
	if player_body.action_cooldown_timer > 0:
		player_body.action_cooldown_timer -= delta
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()

func handle_input():
	if Input.is_action_just_pressed(str(player_body.bomb_action)):
		place_bomb(BombMarker.global_position)

## Call this when the player moves
#func on_player_move(mover_player_id: int):
	#for bomb in bombs:
		#if bomb.owner_player_id != mover_player_id:
			#bomb.trigger_countdown()
#
func on_bomb_exploded(position: Vector2):
	# Remove exploded bombs from list
	cleanup_freed_bombs()
	bombs = bombs.filter(func(b): return b.global_position != position)
	GlobalBombs = GlobalBombs.filter(func(b): return b.global_position != position)

func cleanup_freed_bombs():
	print("test")
	bombs = bombs.filter(func(b): return is_instance_valid(b))
	# Also clean up the global bombs array
	if player_body.GlobalBombs and player_body.GlobalBombs.has_method("cleanup_freed_bombs"):
		player_body.GlobalBombs.cleanup_freed_bombs()
