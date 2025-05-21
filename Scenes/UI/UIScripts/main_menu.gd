extends Control

@onready var title_screen = $title_screen
@onready var warning_screen = $warning_screen
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



@onready var transition_timer = Timer.new()
@onready var tween = create_tween()

func _ready():
	add_child(transition_timer)
	transition_timer.one_shot = true

	# Set initial visibility and modulate alpha
	title_screen.visible = true
	title_screen.modulate.a = 0.0
	warning_screen.visible = true
	warning_screen.modulate.a = 0.0
	main_menu.visible = true
	main_menu.modulate.a = 0.0

	# Ensure scaling from center by setting pivot_offset to half size
# Ensure scaling from center by setting pivot_offset to half size
	await get_tree().process_frame  # Wait one frame so sizes are updated
	bg_menu.pivot_offset = bg_menu.size / 2
	t_game.pivot_offset = t_game.size / 2
	b_play.pivot_offset = b_play.size / 2
	buttons_list.pivot_offset = buttons_list.size / 2

	# 🔹 Store original scales
	original_scale_bg_menu = bg_menu.scale
	original_scale_t_game = t_game.scale
	original_scale_b_play = b_play.scale
	original_scale_buttons_list = buttons_list.scale

	# Set initial scale to 0 for animation
	bg_menu.scale = Vector2.ZERO
	t_game.scale = Vector2.ZERO
	b_play.scale = Vector2.ZERO
	buttons_list.scale = Vector2.ZERO


	# Fade in title screen
	_tween_fade(title_screen, 1.0)
	await tween.finished

	# Hold for 2 seconds
	transition_timer.timeout.connect(_fade_out_title)
	transition_timer.start(2.0)

func _fade_out_title():
	transition_timer.timeout.disconnect(_fade_out_title)

	_tween_fade(title_screen, 0.0)
	await tween.finished

	_tween_fade(warning_screen, 1.0)
	await tween.finished

	transition_timer.timeout.connect(_fade_out_warning)
	transition_timer.start(3.0)

func _fade_out_warning():
	transition_timer.timeout.disconnect(_fade_out_warning)

	_tween_fade(warning_screen, 0.0)
	await tween.finished

	# Start and loop the menu music
	menu_music.volume_db = -40  # Start quiet
	menu_music.play()
	create_tween().tween_property(menu_music, "volume_db", 0, 2.0)  # Fade to normal volume

	

	_tween_fade(main_menu, 1.0)
	await tween.finished

	# Slower scale in for menu elements
	var menu_tween = create_tween()
	menu_tween.tween_property(bg_menu, "scale", original_scale_bg_menu, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(t_game, "scale", original_scale_t_game, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(b_play, "scale", original_scale_b_play, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	menu_tween.parallel().tween_property(buttons_list, "scale", original_scale_buttons_list, 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await menu_tween.finished

	_start_idle_animations()


func _start_idle_animations():
	# Slower BGMenu rotation (wiggle)
	var bg_wiggle = create_tween().set_loops()
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", 0.5, 2.0).set_trans(Tween.TRANS_SINE)
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", -0.5, 4.0).set_trans(Tween.TRANS_SINE)
	bg_wiggle.tween_property(bg_menu, "rotation_degrees", 0, 2.0).set_trans(Tween.TRANS_SINE)

	# Slower TGame rotation (same style)
	var tgame_wiggle = create_tween().set_loops()
	tgame_wiggle.tween_property(t_game, "rotation_degrees", 0.5, 2.0).set_trans(Tween.TRANS_SINE)
	tgame_wiggle.tween_property(t_game, "rotation_degrees", -0.5, 4.0).set_trans(Tween.TRANS_SINE)
	tgame_wiggle.tween_property(t_game, "rotation_degrees", 0, 2.0).set_trans(Tween.TRANS_SINE)

	# Subtle BPlay pulse (now smoother)
	#var pulse = create_tween().set_loops()
	#pulse.tween_property(b_play, "scale", Vector2.ONE * 1.01, 2.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#pulse.tween_property(b_play, "scale", Vector2.ONE, 2.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _tween_fade(node: Control, target_alpha: float, duration := 1.0):
	tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, duration)
