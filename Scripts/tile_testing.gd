extends Node2D
@onready var player1 = $PlayerPiece
@onready var player2 = $PlayerPiece2

    
func _process(delta):
    if !player1:
        print("Player 1 not found, player 2: ", player2)

            
