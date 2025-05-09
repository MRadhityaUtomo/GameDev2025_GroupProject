extends Button

# Exported variable for the scene path, so it can be set in the editor
@export var target_scene : String

# Called when the button is clicked
func _on_Button_pressed() -> void:
	if target_scene != "":
		var scene = load(target_scene)  # Load the target scene
		if scene:
			get_tree().change_scene_to(scene)  # Change to the target scene
		else:
			print("Failed to load the scene:", target_scene)
	else:
		print("Target scene is not set!")
