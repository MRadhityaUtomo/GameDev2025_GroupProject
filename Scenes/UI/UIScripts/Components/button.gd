extends Button

@export var target_scene: String

@onready var rect_normal = $Rect/RectNormal
@onready var rect_hover = $Rect/RectHover
@onready var mask_normal = $MaskStar/RectNormal
@onready var mask_hover = $MaskStar/RectHover
@onready var label1 = $default_label
@onready var label2 = $default_label2

@onready var tween = create_tween()

func _ready():
	# Start with only normal visible
	rect_hover.modulate.a = 0.0
	mask_hover.modulate.a = 0.0
	rect_normal.modulate.a = 1.0
	mask_normal.modulate.a = 1.0

	# Connect signals if not already connected in the editor
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_Button_pressed)


func _on_Button_pressed() -> void:
	if target_scene != "":
		var scene = load(target_scene)
		if scene:
			get_tree().change_scene_to_packed(scene)
		else:
			push_error("Failed to load the scene: " + target_scene)
	else:
		push_warning("Target scene is not set!")


func _on_mouse_entered():
	print("its entered")
	# Fade to hover rects
	_create_fade_tween(rect_normal, 0.0)
	_create_fade_tween(rect_hover, 1.0)
	_create_fade_tween(mask_normal, 0.0)
	_create_fade_tween(mask_hover, 1.0)

	# Change label colors to white
	label1.add_theme_color_override("font_color", Color("#FFFFFFFF"))
	label2.add_theme_color_override("font_color", Color("#FFFFFFFF"))


func _on_mouse_exited():
	print("its existed")
	# Fade back to normal rects
	_create_fade_tween(rect_normal, 1.0)
	_create_fade_tween(rect_hover, 0.0)
	_create_fade_tween(mask_normal, 1.0)
	_create_fade_tween(mask_hover, 0.0)

	# Change label colors back to gray
	label1.add_theme_color_override("font_color", Color("#55555555"))
	label2.add_theme_color_override("font_color", Color("#55555555"))


func _create_fade_tween(node: CanvasItem, target_alpha: float, duration := 0.2):
	# Cancel existing tween for smoother reentry
	tween.kill()
	tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
