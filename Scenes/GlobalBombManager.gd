extends Node2D

@export var player_body : CharacterBody2D

var Bombs : Array = []

func on_player_move(mover_player_id: int):
	# Create a new array to store bombs that are still valid
	var valid_bombs = []
	
	# Print current bombs for debugging
	print("Before processing - Global bombs count: ", Bombs.size())
	
	# First pass - clean up the array and build valid bombs list
	for i in range(Bombs.size() - 1, -1, -1):  # Iterate backwards
		var bomb = Bombs[i]
		if is_instance_valid(bomb):
			valid_bombs.append(bomb)
		else:
			print("Removing invalid bomb reference at index ", i)
	
	# Replace with valid bombs only
	Bombs = valid_bombs
	
	# Second pass - trigger countdowns on opponent bombs
	for bomb in Bombs:
		if is_instance_valid(bomb) and bomb.owner_player_id != mover_player_id:
			bomb.trigger_countdown()
			print("Bomb owned by player ", bomb.owner_player_id, " countdown now: ", bomb.countdown)
	
	# Debug print remaining bombs
	print("After processing - Global bombs count: ", Bombs.size())
