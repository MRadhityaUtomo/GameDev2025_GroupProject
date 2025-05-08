extends CharacterBody2D

@export var id : int
@export var hp : int = 3
@export var state : String
@export var BombCount : int = 3
@export var action_cooldown_duration : float = 0.4  # seconds

@export var up_action : String
@export var down_action : String
@export var left_action : String
@export var right_action : String
@export var bomb_action : String

@export var GlobalBombs: Node2D

var action_cooldown_timer : float = 0.0
var last_move_direction : Vector2 = Vector2.ZERO

func _ready():
    pass
