extends Control

@onready var title_screen = $title_screen
@onready var warning_screen = $warning_screen
@onready var main_menu = $main_menu

@onready var transition_timer = Timer.new()

func _ready():
	# Add a timer for transitions
	add_child(transition_timer)
	transition_timer.one_shot = true

	# Initial state
	title_screen.visible = true
	warning_screen.visible = false
	main_menu.visible = false

	# Show title for 2 seconds, then move to warning
	transition_timer.start(2.0)
	transition_timer.timeout.connect(_show_warning)

func _show_warning():
	title_screen.visible = false
	warning_screen.visible = true

	# Show warning for 6 seconds, then move to main menu
	transition_timer.timeout.disconnect(_show_warning)
	transition_timer.timeout.connect(_show_main_menu)
	transition_timer.start(5.0)

func _show_main_menu():
	warning_screen.visible = false
	main_menu.visible = true
