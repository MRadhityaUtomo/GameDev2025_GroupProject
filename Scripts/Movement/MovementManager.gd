extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 800

@onready var BombMarker = $"../BombSpawnLocation"

@onready var dynamic_tiles_node: TileMapLayer = player_body.get_parent().get_node_or_null("DynamicTiles") if player_body and player_body.get_parent() else null

@export var walkable_source_ids: Array[int] = [1]

enum MovementMode { 
    KING_MOVEMENT,
    BISHOP_MOVEMENT,
    QUEEN_MOVEMENT
}
var current_movement_mode: MovementMode = MovementMode.QUEEN_MOVEMENT

var king_movement_strategy: KingMovementStrategy
var bishop_movement_strategy: BishopMovementStrategy
var queen_movement_strategy: QueenMovementStrategy

var active_movement_logic_strategy: BaseMovementStrategy = null 
var current_movement_strategy: BaseMovementStrategy = null 

signal movement_has_finished(player_id, movement_type_label: String)
signal action_cooldown_updated(remaining_time: float)
signal movement_mode_changed(new_mode_name: String)


func _ready():
    if not player_body:
        printerr("MovementManager: player_body belum di-assign di Inspector!")
        set_physics_process(false)
        return

    if not dynamic_tiles_node:
        printerr("MovementManager: DynamicTiles node not found. Path should be player_body.get_parent().get_node('DynamicTiles'). Check scene structure.")

    if not "action_cooldown_timer" in player_body:
        player_body.action_cooldown_timer = 0.0
    if not "action_cooldown_duration" in player_body:
        player_body.action_cooldown_duration = 0.25 
        push_warning("MovementManager: 'action_cooldown_duration' tidak ditemukan di player_body, menggunakan default: " + str(player_body.action_cooldown_duration))
    if not "id" in player_body:
        player_body.id = 0 
        push_warning("MovementManager: 'id' tidak ditemukan di player_body, menggunakan default: 0")
    if not "last_move_direction" in player_body:
        player_body.last_move_direction = Vector2.ZERO
    
    king_movement_strategy = KingMovementStrategy.new(self)
    bishop_movement_strategy = BishopMovementStrategy.new(self)
    queen_movement_strategy = QueenMovementStrategy.new(self)

    _update_active_logic_strategy()
    
    
    print("MovementManager siap. Mode awal: ", MovementMode.keys()[current_movement_mode])
    movement_mode_changed.emit(MovementMode.keys()[current_movement_mode])


func _unhandled_input(event: InputEvent):
    if current_movement_strategy and current_movement_strategy.is_moving():
        return

    var mode_changed = false
    if event.is_action_pressed("switch_to_king"): 
        if current_movement_mode != MovementMode.KING_MOVEMENT:
            current_movement_mode = MovementMode.KING_MOVEMENT
            mode_changed = true
            
    elif event.is_action_pressed("switch_to_bishop"): 
        if current_movement_mode != MovementMode.BISHOP_MOVEMENT:
            current_movement_mode = MovementMode.BISHOP_MOVEMENT
            mode_changed = true
            
    elif event.is_action_pressed("switch_to_queen"): 
        if current_movement_mode != MovementMode.QUEEN_MOVEMENT:
            current_movement_mode = MovementMode.QUEEN_MOVEMENT
            mode_changed = true
    
    if mode_changed:
        _update_active_logic_strategy() 
        var mode_name = MovementMode.keys()[current_movement_mode]
        movement_mode_changed.emit(mode_name) 
        print("MovementManager: Mode diubah ke -> ", mode_name)
        get_viewport().set_input_as_handled() 


func _update_active_logic_strategy():
    match current_movement_mode:
        MovementMode.KING_MOVEMENT:
            active_movement_logic_strategy = king_movement_strategy
        MovementMode.BISHOP_MOVEMENT:
            active_movement_logic_strategy = bishop_movement_strategy
        MovementMode.QUEEN_MOVEMENT:
            active_movement_logic_strategy = queen_movement_strategy
    
    if current_movement_strategy and current_movement_strategy.is_moving() and current_movement_strategy != active_movement_logic_strategy:
        current_movement_strategy.exit() 
        current_movement_strategy = null 


func _physics_process(delta: float):
    if not player_body: return 

    if player_body.action_cooldown_timer > 0:
        player_body.action_cooldown_timer -= delta
        player_body.action_cooldown_timer = max(0, player_body.action_cooldown_timer) 
        action_cooldown_updated.emit(player_body.action_cooldown_timer)

    if current_movement_strategy and current_movement_strategy.is_moving():
        current_movement_strategy.process_movement(delta)
    else:
        if current_movement_strategy: 
            current_movement_strategy = null 
        
        if player_body.action_cooldown_timer <= 0:
            _handle_input_delegation()


func _handle_input_delegation():
    if not active_movement_logic_strategy:
        printerr("MovementManager: Tidak ada active_movement_logic_strategy yang diatur!")
        return

    if active_movement_logic_strategy.handle_input():
        if active_movement_logic_strategy.can_execute():
            set_active_strategy(active_movement_logic_strategy)
            return


func set_active_strategy(new_strategy: BaseMovementStrategy):
    if current_movement_strategy and current_movement_strategy.is_moving() and current_movement_strategy != new_strategy:
        current_movement_strategy.exit() 

    current_movement_strategy = new_strategy 
    if current_movement_strategy:
        current_movement_strategy.enter() 


func notify_movement_finished(type_label: String):
    var p_id = player_body.id 
    movement_has_finished.emit(p_id, type_label) 


func start_action_cooldown():
    player_body.action_cooldown_timer = player_body.action_cooldown_duration
    action_cooldown_updated.emit(player_body.action_cooldown_timer)


func update_bomb_marker():
    if BombMarker and player_body.last_move_direction != Vector2.ZERO:
        var new_marker_pos = player_body.global_position + player_body.last_move_direction * grid_size
        BombMarker.global_position = new_marker_pos
    elif BombMarker: 
        BombMarker.global_position = player_body.global_position


func is_grid_cell_walkable(target_tile_map_coords: Vector2i) -> bool:
    if not dynamic_tiles_node:
        printerr("MovementManager.is_grid_cell_walkable: dynamic_tiles_node is null.")
        return false

    var source_id = dynamic_tiles_node.get_cell_source_id(target_tile_map_coords)
    
    if dynamic_tiles_node.get("TILE_SCENES") != null:
        var tile_scenes_dict = dynamic_tiles_node.get("TILE_SCENES")
        if tile_scenes_dict.has(source_id):
            var scene_packed = tile_scenes_dict[source_id]
            if scene_packed is PackedScene:
                print("Checking walkability for tile (Source ID: %d, Type: %s)" % [source_id, scene_packed.resource_path])
            else:
                print("Checking walkability for tile (Source ID: %d, Type: Non-PackedScene value)" % source_id)
        elif source_id == -1:
            print("Checking walkability for an empty tile (Source ID: -1)")
        else:
            print("Checking walkability for tile with unknown Source ID: %d" % source_id)
    else:
        print("Checking walkability for tile (Source ID: %d, TILE_SCENES not accessible)" % source_id)

    if source_id in walkable_source_ids:
        return true
    else:
        return false
