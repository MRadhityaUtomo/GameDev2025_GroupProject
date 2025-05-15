class_name QueenMovementStrategy
extends BaseMovementStrategy

var _target_position: Vector2
var _is_moving_to_target: bool = false
var _current_input_vector: Vector2 = Vector2.ZERO

func _init(movement_manager: Node):
	super._init(movement_manager)
	if manager and manager.player_body:
		_target_position = manager.player_body.global_position

func handle_input() -> bool:
	if not manager or not manager.player_body: return false
	if manager.player_body.action_cooldown_timer > 0 or _is_moving_to_target: return false

	var temp_input_vector = Vector2.ZERO
	if Input.is_action_pressed(str(manager.player_body.up_action)): temp_input_vector.y -= 1
	if Input.is_action_pressed(str(manager.player_body.down_action)): temp_input_vector.y += 1
	if Input.is_action_pressed(str(manager.player_body.left_action)): temp_input_vector.x -= 1
	if Input.is_action_pressed(str(manager.player_body.right_action)): temp_input_vector.x += 1

	temp_input_vector.x = sign(temp_input_vector.x)
	temp_input_vector.y = sign(temp_input_vector.y)
	
	if temp_input_vector != Vector2.ZERO:
		_current_input_vector = temp_input_vector
		return true
	
	_current_input_vector = Vector2.ZERO
	return false

func can_execute() -> bool:
	if not manager or not manager.Raycast: 
		printerr("CombinedGridMovementStrategy: Manager atau Raycast tidak ditemukan!")
		return false
	if _current_input_vector == Vector2.ZERO: return false
	
	manager.Raycast.target_position = _current_input_vector * (manager.grid_size * 2/3)
	manager.Raycast.force_raycast_update()
	return !manager.Raycast.is_colliding()

func enter():
	if not manager or not manager.player_body: return
	manager.player_body.last_move_direction = _current_input_vector
	_target_position = manager.player_body.global_position + _current_input_vector * manager.grid_size
	_is_moving_to_target = true
	manager.start_action_cooldown()
	manager.update_bomb_marker()

func process_movement(delta: float):
	if not _is_moving_to_target or not manager or not manager.player_body: return
	var body = manager.player_body
	var travel_speed = manager.travel_speed
	var direction = (_target_position - body.global_position).normalized()
	var distance_to_travel = travel_speed * delta
	if body.global_position.distance_to(_target_position) <= distance_to_travel:
		body.global_position = _target_position
		body.velocity = Vector2.ZERO
		exit()
	else:
		body.velocity = direction * travel_speed
		body.move_and_slide()
	
func exit():
	_is_moving_to_target = false
	if manager: 
		manager.notify_movement_finished("combined_grid_move")

func is_moving() -> bool:
	return _is_moving_to_target
