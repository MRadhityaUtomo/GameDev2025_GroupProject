extends Node2D

@onready var sprite := $AnimatedSprite2D

# Exported expression shown as dropdown in Inspector, but still usable as string
@export_enum("angry", "dead", "happy", "neutral", "hurt") var expression: String = "neutral"

func _ready():
	set_expression(expression)

# Set expression via string (validated)
func set_expression(state: String):
	if sprite.sprite_frames.has_animation(state):
		sprite.play(state)
	else:
		push_warning("No animation named: " + state)
