extends Node2D

@export var player_body : CharacterBody2D
@export var bomb_scene : PackedScene
@export var grid_size : int = 64
@onready var BombMarker = $"../BombSpawnLocation"


var bombs : Array = []

func place_bomb(spawn_position : Vector2):
	# Prevent placing multiple bombs in the same spot
	for bomb in bombs:
		if bomb.global_position == spawn_position:
			return
	
	# Instance and add the bomb
	var bomb = bomb_scene.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.global_position = spawn_position
	bombs.append(bomb)

func _physics_process(delta):
	if player_body.action_cooldown_timer > 0:
		player_body.action_cooldown_timer -= delta
	else:
		if player_body.action_cooldown_timer <= 0:
			handle_input()

func handle_input():
	if Input.is_action_just_pressed("ui_accept"):
		place_bomb(BombMarker.global_position)
