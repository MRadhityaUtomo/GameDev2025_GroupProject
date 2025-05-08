# res://Scripts/Movement/Strategies/GridMovementStrategy.gd
class_name GridMovementStrategy
extends BaseMovementStrategy

var _target_position: Vector2
var _is_moving_to_target: bool = false
var _current_input_vector: Vector2 = Vector2.ZERO

func _init(movement_manager: Node):
	super._init(movement_manager)
	if manager.player_body: # Pastikan player_body ada
		_target_position = manager.player_body.global_position

func handle_input() -> bool:
	if not manager or not manager.player_body: 
		return false
	if manager.player_body.action_cooldown_timer > 0 or _is_moving_to_target: 
		return false

	var temp_input_vector = Vector2.ZERO
	# Gunakan if/elif untuk memastikan hanya satu arah cardinal
	if Input.is_action_pressed(str(manager.player_body.up_action)):
		temp_input_vector.y = -1
	elif Input.is_action_pressed(str(manager.player_body.down_action)):
		temp_input_vector.y = 1
	elif Input.is_action_pressed(str(manager.player_body.left_action)):
		temp_input_vector.x = -1
	elif Input.is_action_pressed(str(manager.player_body.right_action)):
		temp_input_vector.x = 1

	if temp_input_vector != Vector2.ZERO:
		_current_input_vector = temp_input_vector
		return true # Input cardinal terdeteksi

	_current_input_vector = Vector2.ZERO
	return false # Tidak ada input cardinal

func can_execute() -> bool:
	if _current_input_vector == Vector2.ZERO:
		return false

	# Gunakan Raycast dari MovementManager
	manager.Raycast.target_position = _current_input_vector * (manager.grid_size * 2.0 / 3.0) # Pastikan float division
	manager.Raycast.force_raycast_update()
	return !manager.Raycast.is_colliding()

func enter():
	manager.player_body.last_move_direction = _current_input_vector
	_target_position = manager.player_body.global_position + _current_input_vector * manager.grid_size
	_is_moving_to_target = true
	manager.start_action_cooldown() # Panggil fungsi di manager
	manager.update_bomb_marker()    # Panggil fungsi di manager
	# manager.movement_started.emit(self.get_class()) # Contoh emisi sinyal

func process_movement(delta: float):
	if not _is_moving_to_target:
		return

	var body = manager.player_body
	var travel_speed = manager.travel_speed # Ambil dari manager
	var direction = (_target_position - body.global_position).normalized()
	var distance_to_travel = travel_speed * delta

	if body.global_position.distance_to(_target_position) <= distance_to_travel:
		body.global_position = _target_position
		exit() # Selesaikan pergerakan
	else:
		body.velocity = direction * travel_speed
		body.move_and_slide()

func exit():
	_is_moving_to_target = false
	_current_input_vector = Vector2.ZERO
	# Notifikasi penyelesaian movement melalui MovementManager
	manager.notify_movement_finished("grid_move") 
	# manager.movement_ended.emit(self.get_class()) # Contoh emisi sinyal

func is_moving() -> bool:
	return _is_moving_to_target