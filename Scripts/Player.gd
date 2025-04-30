extends CharacterBody2D

@export var hp : int = 3
@export var state : String
@export var BombCount : int = 3
@export var action_cooldown_duration : float = 0.25  # seconds

var action_cooldown_timer : float = 0.0

func _ready():
	pass
