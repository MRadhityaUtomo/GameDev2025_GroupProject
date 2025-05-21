extends Button

@export var target_scene: String
@export_node_path var target_node_path: NodePath
@onready var audio_player = $AudioStreamPlayer 

var tween: Tween

func _ready():
	self.pivot_offset = self.size / 2
	tween = create_tween()
	tween.kill()

func _on_Button_pressed() -> void:
	audio_player.play()
	if target_scene != "":
		get_tree_transition.change_scene_to_file(target_scene)
	else:
		push_warning("Target scene is not set!")

	# Show the target node with animated scale
	if has_node(target_node_path):
		var node = get_node(target_node_path)
		if node and node is Control:
			node.visible = true
			node.scale = Vector2.ZERO
			var click_pos = get_local_mouse_position()
			node.pivot_offset = click_pos  # Animate from click point
			var show_tween = create_tween()
			show_tween.tween_property(node, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			push_warning("Target node is not a Control or doesn't exist!")

func _on_mouse_entered():
	_animate_scale(Vector2(1.05, 1.05))  # Scale up on hover

func _on_mouse_exited():
	_animate_scale(Vector2(1.0, 1.0))  # Scale back to normal

func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
