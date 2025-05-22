extends Node2D
@onready var player1 = $PlayerPiece
@onready var player2 = $PlayerPiece2

var finished = false
	
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
			

			
