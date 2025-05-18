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

@onready var hurtBox = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var animations = $AnimatedSprite2D
@export var animationSet:SpriteFrames

var isInvincible = false
var CanPlace = true
var original_modulate := Color(1, 1, 1)  
@export var current_bomb_type : BombType

@export var GlobalBombs: Node2D

var action_cooldown_timer : float = 0.0
var last_move_direction : Vector2 = Vector2.ZERO

func _ready():
	animations.sprite_frames = animationSet
	animations.play("idle")
	add_to_group("player")
	pass
	
func invincible():
	print("test")
	hurtBox.disabled = true
	isInvincible = true
	await get_tree().create_timer(2).timeout
	hurtBox.disabled = false
	isInvincible = false

func takedamage():	
	hp -= 1
	if hp <= 0:
		die()
	self.invincible()
	animations.play("hurt")
	await animations.animation_finished
	animations.play("idle")

	
	
func die():
	queue_free()
	
