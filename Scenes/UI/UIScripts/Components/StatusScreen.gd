extends Control
@onready var audio_status = $AudioStreamPlayer

func _ready():
	audio_status.play()
