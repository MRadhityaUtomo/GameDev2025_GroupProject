extends Button

@export var target_scene: String
@export_node_path var target_node_path: NodePath
@onready var audio_player = $AudioStreamPlayer 

@export_enum("Credits", "LogOut", "Pause", "Play", "Player", "Settings", "Version", "Wrench")
var icon_name: String = "Play"  # Dropdown enum for selecting icon

var tween: Tween
var icon_tween: Tween

func _ready():
	self.pivot_offset = self.size / 2
	tween = create_tween()
	tween.kill()

	_update_icon()

func _update_icon():
	var icon_path = "res://Scenes/UI/UIAssets/Icon/%s.png" % icon_name
	if $Icon and $Icon is TextureRect:
		if ResourceLoader.exists(icon_path):
			$Icon.texture = load(icon_path)
			
			# Center the pivot and anchors
			await get_tree().process_frame  # Wait for size to update after texture load
			$Icon.set_pivot_offset($Icon.size / 2)
			#$Icon.set_anchors_preset(Control.PRESET_CENTER)
			#$Icon.set_position(Vector2.ZERO)
		else:
			push_warning("Icon not found: " + icon_path)


func _on_Button_pressed() -> void:
	audio_player.play()
	if icon_name == "LogOut":
		get_tree().quit()
		return  # Don't continue with other logic
		
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
	_animate_scale(Vector2(1.05, 1.05))  # Scale up
	_wiggle_icon()

func _on_mouse_exited():
	_animate_scale(Vector2(1.0, 1.0))  # Reset scale
	_reset_icon_rotation()

func _animate_scale(target_scale: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _wiggle_icon():
	if icon_tween:
		icon_tween.kill()
	icon_tween = create_tween()

	# Wiggle: rotate slightly right, then left, then center
	icon_tween.tween_property($Icon, "rotation_degrees", 5.0, 0.1).set_trans(Tween.TRANS_SINE)
	icon_tween.tween_property($Icon, "rotation_degrees", -5.0, 0.2).set_trans(Tween.TRANS_SINE)
	icon_tween.tween_property($Icon, "rotation_degrees", 0.0, 0.1).set_trans(Tween.TRANS_SINE)

func _reset_icon_rotation():
	if icon_tween:
		icon_tween.kill()
	icon_tween = create_tween()
	icon_tween.tween_property($Icon, "rotation_degrees", 0.0, 0.1).set_trans(Tween.TRANS_SINE)
