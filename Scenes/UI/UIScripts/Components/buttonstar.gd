extends Button

signal custom_pressed_signal

# Exported paths to allow configuration from the editor
@export_node_path("Control") var target_node_path: NodePath
@export_node_path("Node") var signal_receiver_path: NodePath
@export var target_scene: String

@onready var mask_normal = $MaskStar/RectNormal
@onready var mask_hover = $MaskStar/RectHover
@onready var label1 = $default_label

var tween: Tween

func _ready():
	# Set pivot to center so scaling looks natural
	pivot_offset = size / 2

	mask_hover.modulate.a = 0.0
	mask_normal.modulate.a = 1.0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_Button_pressed)

	tween = create_tween()
	tween.kill()

	# Dynamically connect the custom signal to an exported receiver node
	if signal_receiver_path != NodePath(""):
		var receiver = get_node_or_null(signal_receiver_path)
		if receiver:
			custom_pressed_signal.connect(receiver._on_tutorial_button_pressed)
		else:
			push_warning("Signal receiver path is set but node not found!")


func _on_Button_pressed() -> void:
	emit_signal("custom_pressed_signal")
	if target_node_path != NodePath(""):
		var node_to_hide = get_node_or_null(target_node_path)
		if node_to_hide:
			_animate_hide_node(node_to_hide)
		else:
			push_warning("Target node path is set but node not found!")
	elif target_scene != "":
		get_tree_transition.change_scene_to_file(target_scene)
	else:
		push_warning("Target scene is not set!")


func _animate_hide_node(node: Node):
	if not node is Control:
		push_warning("Target node is not a Control and cannot be animated with scale or modulate.")
		return

	var control_node := node as Control

	# Set pivot offset to center for smooth scaling
	control_node.pivot_offset = control_node.size / 2.0

	# Create a tween for hiding with scale down and fade out
	var node_tween = create_tween()
	node_tween.tween_property(control_node, "scale", Vector2(0.0, 0.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	node_tween.tween_property(control_node, "modulate:a", 0.0, 0.3)

	# Optionally disable the node after animation
	node_tween.tween_callback(Callable(control_node, "hide"))



func _on_mouse_entered():
	mask_normal.modulate.a = 0.0
	mask_hover.modulate.a = 1.0
	label1.add_theme_color_override("default_color", Color("#FFFFFF"))
	_animate_scale(Vector2(1.05, 1.05))


func _on_mouse_exited():
	mask_normal.modulate.a = 1.0
	mask_hover.modulate.a = 0.0
	label1.add_theme_color_override("default_color", Color("#555555"))
	_animate_scale(Vector2(1.0, 1.0))


func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
