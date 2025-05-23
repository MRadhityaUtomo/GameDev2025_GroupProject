extends Node2D
@onready var player1 = $PlayerPiece
@onready var player2 = $PlayerPiece2

var finished = false
var sudden_death_triggered = false
	
func _process(delta):
	if finished:
		return
	if !player1:
		finished = true
		Engine.time_scale = 1
		if player2:
			PlayUI.ui_instance.show_endgame_status("P2 Win")
		else:
			PlayUI.ui_instance.show_endgame_status("Draw")
	if finished:
		return
	if !player2:
		finished = true
		Engine.time_scale = 1
		if player1:
			PlayUI.ui_instance.show_endgame_status("P1 Win")
		else:
			PlayUI.ui_instance.show_endgame_status("Draw")
			

			
	if PlayUI.ui_instance.total_game_seconds <= 0 and !sudden_death_triggered:
		sudden_death_triggered = true
		
		player1.invincible(10, 0.1)
		player2.invincible(10, 0.1)
		
		await get_tree().create_timer(1.0).timeout
		
		var hp1 = player1.hp
		var hp2 = player2.hp
		player1.takedamage(hp1-1)
		player2.takedamage(hp2-1)
