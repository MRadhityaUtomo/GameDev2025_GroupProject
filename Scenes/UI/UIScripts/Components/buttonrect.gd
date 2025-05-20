extends Button

@export var target_scene: String

@onready var rect_normal = $Rect/RectNormal
@onready var rect_hover = $Rect/RectHover
@onready var mask_normal = $MaskStar/RectNormal
@onready var mask_hover = $MaskStar/RectHover
@onready var label1 = $default_label
@onready var label2 = $default_label2

var tween: Tween

func _ready():
	# Set pivot to center so scaling looks natural
	pivot_offset = size / 2

	# Ensure only the "normal" visuals are visible at start
	rect_hover.modulate.a = 0.0
	mask_hover.modulate.a = 0.0
	rect_normal.modulate.a = 1.0
	mask_normal.modulate.a = 1.0

	# Connect signals (optional if already connected in editor)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_Button_pressed)

	# Create the tween node for scaling
	tween = create_tween()
	tween.kill() # Kill it immediately, we'll reuse later



func _on_Button_pressed() -> void:
	if target_scene != "":
		#var scene = load(target_scene)
		#if scene:
		get_tree_transition.change_scene_to_file(target_scene)
		#else:
			#push_error("Failed to load the scene: " + target_scene)
	else:
		push_warning("Target scene is not set!")


func _on_mouse_entered():
	# Show hover visuals instantly
	rect_normal.modulate.a = 0.0
	rect_hover.modulate.a = 1.0
	mask_normal.modulate.a = 0.0
	mask_hover.modulate.a = 1.0

	# Change label colors to white
	label1.add_theme_color_override("default_color", Color("#FFFFFF"))
	label2.add_theme_color_override("default_color", Color("#FFFFFF"))

	# Animate scale up smoothly
	_animate_scale(Vector2(1.05, 1.05)) # Slight zoom in


func _on_mouse_exited():
	# Show normal visuals instantly
	rect_normal.modulate.a = 1.0
	rect_hover.modulate.a = 0.0
	mask_normal.modulate.a = 1.0
	mask_hover.modulate.a = 0.0

	# Change label colors back to gray
	label1.add_theme_color_override("default_color", Color("#555555"))
	label2.add_theme_color_override("default_color", Color("#555555"))

	# Animate scale back to normal
	_animate_scale(Vector2(1.0, 1.0))


func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill() # Cancel any ongoing tween
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
