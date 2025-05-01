extends Node2D

@export var player_body : CharacterBody2D

var Bombs : Array = []

func on_player_move(mover_player_id: int):
	for bomb in Bombs:
		if bomb.owner_player_id != mover_player_id:
			print("here")
			bomb.trigger_countdown()


func cleanup_freed_bombs():
	# Filter out any invalid references
	Bombs = Bombs.filter(func(b): return is_instance_valid(b))
