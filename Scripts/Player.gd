class_name Player
extends CharacterBody2D

@export var id: int
@export var hp: int = 3
@export var state: String
@export var BombCount: int = 3
@export var action_cooldown_duration: float = 0.6 # seconds

@export var up_action: String
@export var down_action: String
@export var left_action: String
@export var right_action: String
@export var bomb_action: String

@onready var hurtBox = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var animations = $AnimatedSprite2D
@export var animationSet:SpriteFrames

var isInvincible = false
var CanPlace = true
var original_modulate := Color(1, 1, 1)
@export var current_bomb_type: BombType

@export var GlobalBombs: Node2D

var action_cooldown_timer: float = 0.0
var last_move_direction: Vector2 = Vector2.ZERO
var has_diagonal_movement: bool = false  # Added for diagonal movement powerup
var diagonal_mode_active: bool = false  # New variable for diagonal-only mode


func _ready():
    animations.sprite_frames = animationSet
    animations.play("idle")
    add_to_group("player")
    print("player ready at", global_position)
    pass


func invincible():
    print("test")
    hurtBox.disabled = true
    isInvincible = true
    var flicker_count = 20 
    var flicker_interval = 0.1  
    var original_visibility = animations.modulate.a
    for i in range(flicker_count):
        animations.modulate.a = 0.2 if i % 2 == 0 else original_visibility
        await get_tree().create_timer(flicker_interval).timeout
    animations.modulate.a = original_visibility
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

    
# Add this function to your Player class
func push_from_border(push_direction: Vector2, push_force: float = 500.0):
    # Apply a strong impulse in the push direction
    print("pushed")
    velocity = push_direction * push_force
    move_and_slide()
    
    # Play hurt animation if not already playing
    if animations.animation != "hurt":
        animations.play("hurt")
        await animations.animation_finished
        animations.play("idle")
    
func die():
    queue_free()

func get_movement_manager():
    return $MovementManager

func change_bomb_type_to(new_type: BombType):
    current_bomb_type = new_type
