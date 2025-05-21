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
@onready var crosshair = $BombSpawnLocation/Crosshair

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
    crosshair.process_mode = Node.PROCESS_MODE_ALWAYS
    animations.process_mode = Node.PROCESS_MODE_ALWAYS
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
        if id == 1:
            if is_instance_valid(PlayUI.ui_instance):
                PlayUI.ui_instance.set_expression_p1("dead")
                if PlayUI.ui_instance.expressionP2 == "neutral":
                    PlayUI.ui_instance.set_expression_p2("happy")
                PlayUI.ui_instance.set_heart_p1(0)
        else:
            if is_instance_valid(PlayUI.ui_instance):
                PlayUI.ui_instance.set_expression_p2("dead")
                if PlayUI.ui_instance.expressionP1 == "neutral":
                    PlayUI.ui_instance.set_expression_p1("happy")
                PlayUI.ui_instance.set_heart_p2(0)
        self.invincible()
        animations.play("hurt")
        await animations.animation_finished
        
        await get_tree().create_timer(1.0).timeout
        die()
        return
    
    if id == 1:
        PlayUI.ui_instance.set_expression_p1("hurt")
        if PlayUI.ui_instance.expressionP2 == "neutral":

            PlayUI.ui_instance.set_expression_p2("happy")
        PlayUI.ui_instance.set_heart_p1(hp)
    else:
        if PlayUI.ui_instance.expressionP1 == "neutral":
            PlayUI.ui_instance.set_expression_p1("happy")
        PlayUI.ui_instance.set_expression_p2("hurt")
        PlayUI.ui_instance.set_heart_p2(hp)
    
    self.invincible()
    animations.play("hurt")
    await animations.animation_finished
    animations.play("idle")
    
    await get_tree().create_timer(0.5).timeout
    
    if id == 1:
        if is_instance_valid(PlayUI.ui_instance):
            PlayUI.ui_instance.set_expression_p1("angry")
            PlayUI.ui_instance.set_expression_p2("neutral")
    else:
        if is_instance_valid(PlayUI.ui_instance):
            PlayUI.ui_instance.set_expression_p1("neutral")
            PlayUI.ui_instance.set_expression_p2("angry")
            
    
    await get_tree().create_timer(0.5).timeout
    
    if id == 1:
        if is_instance_valid(PlayUI.ui_instance):
            PlayUI.ui_instance.set_expression_p1("neutral")
            PlayUI.ui_instance.set_expression_p2("neutral")
    else:
        if is_instance_valid(PlayUI.ui_instance):
            PlayUI.ui_instance.set_expression_p1("neutral")
            PlayUI.ui_instance.set_expression_p2("neutral")
            
# Add this new function for grid-aligned push
func push_from_border_grid_aligned(push_direction: Vector2, dynamic_tiles: DynamicTiles):
    # Calculate the target position
    var current_tile_pos = dynamic_tiles.local_to_map(dynamic_tiles.to_local(global_position))
    
    # Try to find next valid cell in direction of center
    var grid_aligned_direction = Vector2i(
        round(push_direction.x),  # Round to -1, 0, or 1
        round(push_direction.y)   # Round to -1, 0, or 1
    )
    
    # If both components are non-zero (diagonal), choose the stronger one
    if grid_aligned_direction.x != 0 and grid_aligned_direction.y != 0:
        if abs(push_direction.x) > abs(push_direction.y):
            grid_aligned_direction.y = 0
        else:
            grid_aligned_direction.x = 0
    
    # If somehow both components became zero, default to a direction toward center
    if grid_aligned_direction == Vector2i.ZERO:
        var to_center = dynamic_tiles.center - current_tile_pos
        grid_aligned_direction = Vector2i(sign(to_center.x), sign(to_center.y))
        
        # Still need to choose one direction
        if grid_aligned_direction.x != 0 and grid_aligned_direction.y != 0:
            if abs(to_center.x) > abs(to_center.y):
                grid_aligned_direction.y = 0
            else:
                grid_aligned_direction.x = 0
    
    # Calculate target tile position (one tile in the grid direction)
    var target_tile_pos = current_tile_pos + grid_aligned_direction
    
    # Convert back to world position
    var target_world_pos = dynamic_tiles.to_global(dynamic_tiles.map_to_local(target_tile_pos))
    
    # Move directly to the grid-aligned position
    global_position = target_world_pos
    
    # Play hurt animation if not already playing
    if animations.animation != "hurt":
        animations.play("hurt")
        await animations.animation_finished
        animations.play("idle")

# Keep the old function for compatibility
func push_from_border(push_direction: Vector2, push_distance: float = 64.0):
    # Apply a fixed distance movement in the push direction
    print("pushed (deprecated function)")
    position += push_direction * push_distance
    
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
