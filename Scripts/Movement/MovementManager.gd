extends Node

@export var player_body : CharacterBody2D
@export var grid_size : int = 64
@export var travel_speed : int = 800

@onready var BombMarker = $"../BombSpawnLocation"
@onready var Raycast = $"../RayCast2D"
@onready var powerup_duration: Timer = $"../PowerupDuration"

var current_movement_mode: MovementMode.Type = MovementMode.Type.KING_MOVEMENT

var king_movement_strategy: KingMovementStrategy
var bishop_movement_strategy: BishopMovementStrategy
var queen_movement_strategy: QueenMovementStrategy
var double_step_movement_strategy: DoubleStepMovementStrategy
var reversed_movement_strategy: ReversedMovementStrategy

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
	double_step_movement_strategy = DoubleStepMovementStrategy.new(self)
	reversed_movement_strategy = ReversedMovementStrategy.new(self)
	
	# Connect the movement_has_finished signal to the GlobalBombManager's on_player_move function
	# This uses a lambda function to ignore the movement_type_label parameter
	if "GlobalBombs" in player_body and player_body.GlobalBombs != null:
		movement_has_finished.connect(
			func(player_id, _movement_type_label): player_body.GlobalBombs.on_player_move(player_id)
		)
	else:
		print("MovementManager: 'GlobalBombs' tidak ditemukan di player_body. Movement completion won't trigger bomb updates.")
		push_warning("MovementManager: 'GlobalBombs' not found in player_body. Movement completion won't trigger bomb updates.")

	_update_active_logic_strategy()
	
	
	print("MovementManager siap. Mode awal: ", MovementMode.Type.keys()[current_movement_mode])
	movement_mode_changed.emit(MovementMode.Type.keys()[current_movement_mode])


func _unhandled_input(event: InputEvent):
	if current_movement_strategy and current_movement_strategy.is_moving():
		return

	var mode_changed = false
	if event.is_action_pressed("switch_to_king"): 
		if current_movement_mode != MovementMode.Type.KING_MOVEMENT:
			current_movement_mode = MovementMode.Type.KING_MOVEMENT
			mode_changed = true
			
	elif event.is_action_pressed("switch_to_bishop"): 
		if current_movement_mode != MovementMode.Type.BISHOP_MOVEMENT:
			current_movement_mode = MovementMode.Type.BISHOP_MOVEMENT
			mode_changed = true
			
	elif event.is_action_pressed("switch_to_queen"): 
		if current_movement_mode != MovementMode.Type.QUEEN_MOVEMENT:
			current_movement_mode = MovementMode.Type.QUEEN_MOVEMENT
			mode_changed = true
			
	elif event.is_action_pressed("switch_to_double_step"):
		if current_movement_mode != MovementMode.Type.DOUBLE_STEP_MOVEMENT:
			current_movement_mode = MovementMode.Type.DOUBLE_STEP_MOVEMENT
			mode_changed = true
			
	elif event.is_action_pressed("switch_to_reversed"):
		if current_movement_mode != MovementMode.Type.REVERSED_MOVEMENT:
			current_movement_mode = MovementMode.Type.REVERSED_MOVEMENT
			mode_changed = true
	
	if mode_changed:
		_update_active_logic_strategy() 
		var mode_name = MovementMode.Type.keys()[current_movement_mode]
		movement_mode_changed.emit(mode_name) 
		print("MovementManager: Mode diubah ke -> ", mode_name)
		get_viewport().set_input_as_handled() 


func _update_active_logic_strategy():
	match current_movement_mode:
		MovementMode.Type.KING_MOVEMENT:
			active_movement_logic_strategy = king_movement_strategy
		MovementMode.Type.BISHOP_MOVEMENT:
			active_movement_logic_strategy = bishop_movement_strategy
		MovementMode.Type.QUEEN_MOVEMENT:
			active_movement_logic_strategy = queen_movement_strategy
		MovementMode.Type.DOUBLE_STEP_MOVEMENT:
			active_movement_logic_strategy = double_step_movement_strategy
		MovementMode.Type.REVERSED_MOVEMENT:
			active_movement_logic_strategy = reversed_movement_strategy
	
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


func change_movement_mode(new_mode: MovementMode.Type, duration: float = 10.0):
	# First, disconnect any existing timeout connections to avoid multiple callbacks
	if powerup_duration.timeout.is_connected(reset_movement_mode):
		powerup_duration.timeout.disconnect(reset_movement_mode)
	
	# Don't change immediately if currently moving
	if current_movement_strategy and current_movement_strategy.is_moving():
		# Schedule the change after movement completes
		var mode_name = MovementMode.Type.keys()[new_mode]
		print("Movement change queued: Will change to " + mode_name + " after current movement completes")
		
		# Use a one-shot timer to change the mode after movement completes
		var timer = Timer.new()
		timer.wait_time = 0.1  # Check frequently
		timer.one_shot = false
		add_child(timer)
		
		# Connect timer to a function that checks if movement has completed
		timer.timeout.connect(func():
			if not current_movement_strategy or not current_movement_strategy.is_moving():
				# Now it's safe to change
				current_movement_mode = new_mode
				_update_active_logic_strategy()
				var new_mode_name = MovementMode.Type.keys()[current_movement_mode]
				movement_mode_changed.emit(new_mode_name)
				print("MovementManager: Mode changed to -> ", new_mode_name)
				
				# Start the powerup duration timer
				powerup_duration.wait_time = duration
				powerup_duration.start()
				powerup_duration.timeout.connect(reset_movement_mode)
				
				# Clean up timer
				timer.stop()
				timer.queue_free()
		)
		
		timer.start()
	else:
		# Change immediately if not moving
		current_movement_mode = new_mode
		_update_active_logic_strategy()
		var mode_name = MovementMode.Type.keys()[current_movement_mode]
		movement_mode_changed.emit(mode_name)
		print("MovementManager: Mode changed to -> ", mode_name)
		
		# Start the powerup duration timer
		powerup_duration.wait_time = duration
		powerup_duration.start()
		powerup_duration.timeout.connect(reset_movement_mode)


func reset_movement_mode():
	print("Powerup duration ended, reverting to KING_MOVEMENT")
	current_movement_mode = MovementMode.Type.KING_MOVEMENT
	_update_active_logic_strategy()
	var mode_name = MovementMode.Type.keys()[current_movement_mode]
	movement_mode_changed.emit(mode_name)
