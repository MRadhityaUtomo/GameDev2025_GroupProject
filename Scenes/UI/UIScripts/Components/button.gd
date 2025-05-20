extends Button

@export var target_scene : String

var tween: Tween

func _ready():
	# Set pivot to center so scaling happens from the middle
	pivot_offset = size / 2

	tween = create_tween()
	tween.kill()  # We will reuse this tween later

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
	_animate_scale(Vector2(1.05, 1.05))  # Scale up

func _on_mouse_exited():
	_animate_scale(Vector2(1.0, 1.0))  # Scale back to normal

func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill()  # Cancel any ongoing tween
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
