extends CanvasLayer

func change_scene_to_file(target: String) -> void:
	print("Transitioning to scene: " + target)
	#$AnimationPlayer.play("dissolve")
	#await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	#$AnimationPlayer.play_backwards("dissolve")
