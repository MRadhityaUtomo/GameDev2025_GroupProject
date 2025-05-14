extends Button

@export var target_scene : String

func _on_Button_pressed() -> void:
	if target_scene != "":
		var scene = load(target_scene)
		if scene:
			get_tree().change_scene_to_packed(scene)
		else:
			push_error("Failed to load the scene: " + target_scene)
	else:
		push_warning("Target scene is not set!")
