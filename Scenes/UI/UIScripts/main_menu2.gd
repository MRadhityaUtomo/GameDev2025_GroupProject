extends Control

@onready var main_menu = $main_menu

# Main menu elements
@onready var bg_menu = $main_menu/BGMenu
@onready var t_game = $main_menu/TGame
@onready var b_play = $main_menu/Control
@onready var buttons_list = $main_menu/VBoxContainer
@onready var menu_music = $main_menu/AudioStreamPlayer

var original_scale_bg_menu: Vector2
var original_scale_t_game: Vector2
var original_scale_b_play: Vector2
var original_scale_buttons_list: Vector2

@onready var tween = create_tween()

func _ready():
	main_menu.visible = true
	main_menu.modulate.a = 0.0

	await get_tree().process_frame  # Ensure sizes are valid
	bg_menu.pivot_offset = bg_menu.size / 2
	t_game.pivot_offset = t_game.size / 2
	b_play.pivot_offset = b_play.size / 2
	buttons_list.pivot_offset = buttons_list.size / 2

	original_scale_bg_menu = bg_menu.scale
	original_scale_t_game = t_game.scale
	original_scale_b_play = b_play.scale
	original_scale_buttons_list = buttons_list.scale

	bg_menu.scale = Vector2.ZERO
	t_game.scale = Vector2.ZERO
	b_play.scale = Vector2.ZERO
	buttons_list.scale = Vector2.ZERO

	# Play menu music
	menu_music.volume_db = -40
	menu_music.play()
	create_tween().tween_property(menu_music, "volume_db", 0, 2.0)

	# Fade in main menu
	_tween_fade(main_menu, 1.0)
	await tween.finished

	# Animate scale-in
	var menu_tween = create_tween()
	menu_tween.tween_property(bg_menu, "scale", original_scale_bg_menu, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(t_game, "scale", original_scale_t_game, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(b_play, "scale", original_scale_b_play, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(buttons_list, "scale", original_scale_buttons_list, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await menu_tween.finished

	_start_idle_animations()

func _start_idle_animations():
	var bg_wiggle = create_tween().set_loops()
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", 0.5, 2.0).set_trans(Tween.TRANS_SINE)
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", -0.5, 4.0).set_trans(Tween.TRANS_SINE)
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", 0, 2.0).set_trans(Tween.TRANS_SINE)

	var tgame_wiggle = create_tween().set_loops()
	tgame_wiggle.tween_property(t_game, "rotation_degrees", 0.5, 2.0).set_trans(Tween.TRANS_SINE)
	tgame_wiggle.tween_property(t_game, "rotation_degrees", -0.5, 4.0).set_trans(Tween.TRANS_SINE)
	tgame_wiggle.tween_property(t_game, "rotation_degrees", 0, 2.0).set_trans(Tween.TRANS_SINE)

func _tween_fade(node: Control, target_alpha: float, duration := 1.0):
	tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, duration)
