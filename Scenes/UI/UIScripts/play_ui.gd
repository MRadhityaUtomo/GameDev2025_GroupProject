extends Control
class_name PlayUI

@onready var tutorial = $Tutorial
@onready var cready = $Ready
@onready var ready_1 = $Ready/Ready1
@onready var ready_2 = $Ready/Ready2
@onready var countdown_label = $Ready/countdown
@onready var main = $Main

@onready var minute_label = $Main/Time/CountdownTime/minute
@onready var second_label = $Main/Time/CountdownTime/seconds

@onready var p1_win_label = $EndGame/P1Win
@onready var p2_win_label = $EndGame/P2Win
@onready var sudden_death_label = $EndGame/SuddenDeath
@onready var draw_label = $EndGame/Draw

@onready var tex_move_p1 = $Main/PTall/P1/TexMove/TexItem
@onready var tex_powup_p1 = $Main/PTall/P1/TexPowUp/TexItem
@onready var tex_move_p2 = $Main/PTall/P2/TexMove/TexItem
@onready var tex_powup_p2 = $Main/PTall/P2/TexPowUp/TexItem

@onready var p1tall = $Main/PTall/P1/P1Tall
@onready var p2tall = $Main/PTall/P2/P2Tall

#keep this for now
@export_enum("angry", "dead", "happy", "neutral", "hurt") var expressionP1: String = "neutral"
@export_enum("angry", "dead", "happy", "neutral", "hurt") var expressionP2: String = "neutral"

@onready var audio_ready = $AudioReady
@onready var audio_close = $AudioClose
@onready var audio_start = $AudioStart
@onready var audio_count = $AudioCount

static var ui_instance: PlayUI = null


func set_expression_p1(value: String) -> void:
	expressionP1 = value
	if is_instance_valid(p1tall):
		p1tall.set_expression(value)

func set_expression_p2(value: String) -> void:
	expressionP2 = value
	if is_instance_valid(p2tall):
		p2tall.set_expression(value)


@export var heartP1: int = 3
@export var heartP2: int = 3

@onready var heartP1RichTextLabel =  $Main/PTall/P1/TexHeart/RTLCount
@onready var heartP2RichTextLabel = $Main/PTall/P2/Heart/Count

@export_enum("BISHOP_MOVEMENT", "MoveDiagonal", "DOUBLE_STEP_MOVEMENT", "KING_MOVEMENT", "QUEEN_MOVEMENT", "REVERSED_MOVEMENT")
var move_icon_p1: String = "KING_MOVEMENT"
@export_enum("PowUpDiagonalBomb", "PowUpNormalBomb", "PowUpWideBomb")
var powup_icon_p1: String = "PowUpNormalBomb"

@export_enum("BISHOP_MOVEMENT", "MoveDiagonal", "DOUBLE_STEP_MOVEMENT", "KING_MOVEMENT", "QUEEN_MOVEMENT", "REVERSED_MOVEMENT")
var move_icon_p2: String = "KING_MOVEMENT"
@export_enum("PowUpDiagonalBomb", "PowUpNormalBomb", "PowUpWideBomb")
var powup_icon_p2: String = "PowUpNormalBomb"

var pending_check: bool = false
var dead_player: int = 0 # 0 = none, 1 = P1 died, 2 = P2 died


const MOVE_TEXTURES := {
	"BISHOP_MOVEMENT": preload("res://Scenes/UI/UIAssets/Power/MoveBishop.png"),
	"MoveDiagonal": preload("res://Scenes/UI/UIAssets/Power/MoveDiagonal.png"),
	"DOUBLE_STEP_MOVEMENT": preload("res://Scenes/UI/UIAssets/Power/MoveDouble.png"),
	"KING_MOVEMENT": preload("res://Scenes/UI/UIAssets/Power/MoveKing.png"),
	"QUEEN_MOVEMENT": preload("res://Scenes/UI/UIAssets/Power/MoveQueen.png"),
	"REVERSED_MOVEMENT": preload("res://Scenes/UI/UIAssets/Power/MoveReversed.png"),
}

const POWUP_TEXTURES := {
	"PowUpDiagonalBomb": preload("res://Scenes/UI/UIAssets/Power/PowUpDiagonalBomb.png"),
	"PowUpNormalBomb": preload("res://Scenes/UI/UIAssets/Power/PowUpNormalBomb.png"),
	"PowUpWideBomb": preload("res://Scenes/UI/UIAssets/Power/PowUpWideBomb.png"),
}


var tween: Tween
var ready_1_active := false
var ready_2_active := false
var countdown = 3
var countdown_timer := Timer.new()
var game_timer := Timer.new()
var total_game_seconds = 5 * 45  # 5 minutes

func _ready():
	if ui_instance == null:
		ui_instance = self
		set_process_mode(Node.PROCESS_MODE_ALWAYS)
	else:
		queue_free()
	get_tree().paused = true
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	tutorial.visible = true
	cready.visible = false
	main.visible = false
	
	await get_tree().process_frame
	tutorial.pivot_offset = tutorial.size * 0.5
	p1_win_label.pivot_offset = p1_win_label.size * 0.5
	p2_win_label.pivot_offset = p2_win_label.size * 0.5
	sudden_death_label.pivot_offset = sudden_death_label.size * 0.5
	draw_label.pivot_offset = draw_label.size * 0.5
	
	countdown_timer.one_shot = false
	countdown_timer.wait_time = 1.0
	countdown_timer.connect("timeout", Callable(self, "_on_countdown_tick"))
	add_child(countdown_timer)

	game_timer.one_shot = false
	game_timer.wait_time = 1.0
	game_timer.connect("timeout", Callable(self, "_on_game_timer_tick"))
	add_child(game_timer)

	_set_darken(main, true)
	_set_darken(ready_1, true)
	_set_darken(ready_2, true)


	# Hide all endgame labels by default
	for node in [$EndGame/P1Win, $EndGame/P2Win, $EndGame/SuddenDeath, $EndGame/Draw]:
		node.visible = false
		node.scale = Vector2.ZERO

	set_process_input(true)
	update_player_icons()
	set_expression_p1(expressionP1)
	set_expression_p2(expressionP2)
	set_heart_p1(heartP1)
	set_heart_p2(heartP2)

func _input(event):
	if event is InputEvent and event.is_pressed():
		if tutorial.visible:
			if Input.is_action_pressed("p1Interact") or Input.is_action_pressed("p2Interact"):
				audio_close.play()
				_animate_scale(tutorial, Vector2.ZERO)
		elif cready.visible:
			if Input.is_action_pressed("p1Interact") and not ready_1_active:
				audio_ready.play()
				ready_1_active = true
				_set_darken(ready_1, false)
				_check_start_countdown()
			elif Input.is_action_pressed("p2Interact") and not ready_2_active:
				audio_ready.play()
				ready_2_active = true
				_set_darken(ready_2, false)
				_check_start_countdown()

func _check_start_countdown():
	if ready_1_active and ready_2_active:
		countdown = 3
		countdown_label.text = str(countdown)
		countdown_timer.start()

func _on_countdown_tick():
	if countdown == 3:
		# Play first announcement
		$announce1.play()
		
		# Wait for announce1 to finish
		await $announce1.finished
		
		# Play duel announcement
		$duel.play()
		
		# Wait for duel to finish
		await $duel.finished
		
		# Small delay after announcements
		await get_tree().create_timer(0.5).timeout
		
		# Stop the countdown timer and set game ready
		countdown_timer.stop()
		countdown_label.text = "GO!"
		
		# Start game timing and play BGM
		minute_label.text = "3"
		second_label.text = "45"
		game_timer.start()
		$BGM.play()
		
		# Show game and hide ready
		_set_darken(main, false)
		cready.visible = false
		get_tree().paused = false
		
		# Don't continue with the countdown
		return
	
	# For countdown 2 and 1
	countdown -= 1
	audio_count.play()
	countdown_label.text = str(countdown)

func _on_game_timer_tick():
	total_game_seconds -= 1
	var mins = total_game_seconds / 60
	var secs = total_game_seconds % 60
	minute_label.text = str(mins)
	second_label.text = str(secs).pad_zeros(2)

	if total_game_seconds <= 0:
		game_timer.stop()
		show_endgame_status("SuddenDeath")

# SHOW WHOS WIN, SUDDENT DEATH, AND DRAW
func show_endgame_status(status: String) -> void:
	var status_node: Node = null
	var target_scene_path: String = ""

	match status:
		"P1 Win":
			status_node = $EndGame/P1Win
			target_scene_path = "res://Scenes/UI/UIScenes/win_screenP1.tscn"
		"P2 Win":
			status_node = $EndGame/P2Win
			target_scene_path = "res://Scenes/UI/UIScenes/win_screenP2.tscn"
		"Draw":
			status_node = $EndGame/Draw
			target_scene_path = "res://Scenes/UI/UIScenes/draw_screen.tscn"
		"SuddenDeath":
			status_node = $EndGame/SuddenDeath
		_:
			push_warning("Unknown endgame status: " + status)
			return

	if status_node:
		status_node.visible = true
		status_node.scale = Vector2.ZERO

		var tween_in = create_tween()
		tween_in.tween_property(status_node, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		await tween_in.finished
		await get_tree().create_timer(1.5).timeout  # Pause for readability

		var tween_out = create_tween()
		tween_out.tween_property(status_node, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

		await tween_out.finished

		# Only change scene if not SuddenDeath
		if target_scene_path != "":
			get_tree_transition.change_scene_to_file(target_scene_path)



func _animate_scale(target_node: Node, target_scale: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(target_node, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if target_scale == Vector2.ZERO:
		tween.connect("finished", Callable(self, "_on_tutorial_closed"))

func _on_tutorial_button_pressed():
	# Close tutorial with animation (same as pressing F/Enter)
	_animate_scale(tutorial, Vector2.ZERO)
	
func _on_tutorial_closed():
	tutorial.visible = false
	tutorial.scale = Vector2.ONE
	cready.visible = true
	main.visible = true
	_set_darken(main, true)
	_set_darken(ready_1, true)
	_set_darken(ready_2, true)

func _set_darken(node: Node, darken: bool):
	if node.has_method("set_modulate"):
		node.modulate = Color(0.5, 0.5, 0.5, 1) if darken else Color(1, 1, 1, 1)
	elif node is CanvasItem:
		node.modulate = Color(0.5, 0.5, 0.5, 1) if darken else Color(1, 1, 1, 1)

func update_player_icons():
	tex_move_p1.texture = MOVE_TEXTURES.get(move_icon_p1, null)
	tex_powup_p1.texture = POWUP_TEXTURES.get(powup_icon_p1, null)
	tex_move_p2.texture = MOVE_TEXTURES.get(move_icon_p2, null)
	tex_powup_p2.texture = POWUP_TEXTURES.get(powup_icon_p2, null)

func set_player_icon(player: int, move: String, powup: String):
	audio_ready.play()
	if player == 1:
		set_p1_move_icon(move)
		set_p1_powup_icon(powup)
	elif player == 2:
		set_p2_move_icon(move)
		set_p2_powup_icon(powup)
	update_player_icons()

func set_p1_move_icon(move: String) -> void:
	if move == "KING_MOVEMENT":
		audio_close.play()
	else:
		audio_ready.play()
	move_icon_p1 = move
	tex_move_p1.texture = MOVE_TEXTURES.get(move_icon_p1, null)

func set_p1_powup_icon(powup: String) -> void:
	audio_ready.play()
	powup_icon_p1 = powup

func set_p2_move_icon(move: String) -> void:
	if move == "KING_MOVEMENT":
		audio_close.play()
	else:
		audio_ready.play()
	move_icon_p2 = move
	tex_move_p2.texture = MOVE_TEXTURES.get(move_icon_p2, null)

func set_p2_powup_icon(powup: String) -> void:
	audio_ready.play()
	powup_icon_p2 = powup


#func _check_endgame_status():
	#if pending_check:
		#return
#
	#if heartP1 <= 0 and heartP2 <= 0:
		#show_endgame_status("Draw")
	#elif heartP1 <= 0:
		#pending_check = true
		#dead_player = 1
		#$DrawCheckTimer.start()
	#elif heartP2 <= 0:
		#pending_check = true
		#dead_player = 2
		#$DrawCheckTimer.start()
#
#func _on_draw_check_timer_timeout():
	#pending_check = false
#
	#if heartP1 <= 0 and heartP2 <= 0:
		#show_endgame_status("Draw")
	#elif dead_player == 1:
		#show_endgame_status("P2 Win")
	#elif dead_player == 2:
		#show_endgame_status("P1 Win")
	#
	#dead_player = 0

func set_heart_p1(value: int):
	audio_close.play()
	heartP1 = max(0, value)
	heartP1RichTextLabel.text = str(heartP1)
	#_check_endgame_status()

func set_heart_p2(value: int):
	audio_close.play()
	heartP2 = max(0, value)
	heartP2RichTextLabel.text = str(heartP2)
	#_check_endgame_status()
